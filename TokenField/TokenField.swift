//
//  TokenField.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

/// Delegate protocol for the TokenField. Conform to this if you want to respond to actions from the TokenField.
public protocol TokenFieldDelegate: class {
    /// Called when the user returns for a given input.
    func tokenField(_ tokenField: TokenField, didEnterText text: String)
    /// Called when the user tries to delete a token at the given index.
    func tokenField(_ tokenField: TokenField, didDeleteTokenAtIndex index: Int)
    /// Called when the user changes the text in the textField.
    func tokenField(_ tokenField: TokenField, didChangeText text: String)
    /// Called when the TokenField did begin editing.
    func tokenFieldDidBeginEditing(_ tokenField: TokenField)
    /// Called when the TokenField's content height changes.
    func tokenField(_ tokenField: TokenField, didChangeContentHeight height: CGFloat)
}

/// DataSource protocol for the TokenField. Conform to this to provide the token data for the TokenField.
public protocol TokenFieldDataSource: class {
    /// The title for the Token object at a given index.
    func tokenField(_ tokenField: TokenField, titleForTokenAtIndex index: Int) -> String
    /// The color scheme for the Token object at a given index.
    func tokenField(_ tokenField: TokenField, colorSchemedForTokenAtIndex index: Int) -> UIColor
    /// The number of Token objects in the TokenField.
    func numberOfTokensInTokenField(_ tokenField: TokenField) -> Int
    /// The text to display in the TokenField when the field is inactive.
    func tokenFieldCollapsedText(_ tokenField: TokenField) -> String
}

/// TokenField subclass of UIView to display tokens and text as in the messages and mail app.
public class TokenField: UIView {

    /// The TokenField's delegate.
    public weak var delegate: TokenFieldDelegate?
    /// The TokenField's data source.
    public weak var dataSource: TokenFieldDataSource?
    
    /// Struct of static default values for the TokenField.
    public struct Constants {
        /// Default maximum height = 150.0
        public static let defaultMaxHeight: CGFloat          = 150.0
        /// Default vertical inset = 7.0
        public static let defaultVerticalInset: CGFloat      = 7.0
        /// Default horizontal inset = 15.0
        public static let defaultHorizontalInset: CGFloat    = 15.0
        /// Default token padding = 2.0
        public static let defaultTokenPadding: CGFloat       = 2.0
        /// Default minimum input width = 80.0
        public static let defaultMinInputWidth: CGFloat      = 80.0
        /// Default to label paddig = 5.0
        public static let defaultToLabelPadding: CGFloat     = 5.0
        /// Default token height = 30.0
        public static let defaultTokenHeight: CGFloat        = 30.0
        /// Default vertical padding = 2.0
        public static let defaultVeritcalPadding: CGFloat    = 2.0
    }
    
    /// TokenField's maximum height value.
    public var maxHeight: CGFloat = Constants.defaultMaxHeight
    /// TokenField's vertical inset.
    public var verticalInset: CGFloat = Constants.defaultVerticalInset
    /// TokenField's horizontal inset.
    public var horizontalInset: CGFloat = Constants.defaultHorizontalInset
    /// TokenField's token padding.
    public var tokenPadding: CGFloat = Constants.defaultTokenPadding
    /// TokenField's minimum input text width.
    public var minInputWidth: CGFloat = Constants.defaultMinInputWidth
    
    /// Keyboard type inital value .default.
    public var inputTextViewKeyboardType: UIKeyboardType = .default
    /// Keyboard appearance initial value .default.
    public var keyboardAppearance: UIKeyboardAppearance = .default
    
    /// Autocorrection type for textView initial value .no
    public var autocorrectionType: UITextAutocorrectionType = .no {
        didSet {
            inputTextView.autocorrectionType = autocorrectionType
        }
    }
    /// Autocapitalization type for textView inital value .sentences
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences {
        didSet {
            inputTextView.autocapitalizationType = autocapitalizationType
        }
    }
    /// Input accessory view for textView.
    public var inputTextViewAccessoryView: UIView? {
        didSet {
            inputTextView.inputAccessoryView = inputTextViewAccessoryView
        }
    }
    /// To label text color.
    public var toLabelTextColor: UIColor = UIColor(red: 112/255.0, green: 124/255.0, blue: 124/255.0, alpha: 1.0) {
        didSet {
            toLabel.textColor = toLabelTextColor
        }
    }
    /// To label text.
    public var toLabelText: String = NSLocalizedString("To:", comment: "") {
        didSet {
            toLabel.text = toLabelText
            reloadData()
        }
    }
    /// Input textView text color.
    public var inputTextViewTextColor: UIColor = UIColor(red: 38/255.0, green: 39/255.0, blue: 41/255.0, alpha: 1.0) {
        didSet {
            inputTextView.textColor = inputTextViewTextColor
        }
    }
    /// TokenField color scheme, initial value = .blue
    public var colorScheme: UIColor = .blue {
        didSet {
            collapsedLabel?.textColor = colorScheme
            inputTextView.textColor = colorScheme
            for token in tokens {
                token.colorScheme = colorScheme
            }
        }
    }
    /// Input textView accessibility label.
    public var inputTextViewAccessibilityLabel: String! {
        didSet {
            inputTextView.accessibilityLabel = inputTextViewAccessibilityLabel
        }
    }
    
    /// To label. Lazily instantiated.
    public lazy var toLabel: UILabel = {
        let toLabel = UILabel(frame: CGRect.zero)
        toLabel.textColor = self.toLabelTextColor
        toLabel.font = UIFont(name: "HelveticaNeue", size: 15.0)
        toLabel.frame.origin.x = 0.0
        toLabel.text = self.toLabelText
        toLabel.sizeToFit()
        toLabel.frame.size.height = Constants.defaultTokenHeight
        return toLabel
    }()
    
    /// Input textView. Lazily instantited.
    public lazy var inputTextView: UITextView = {
        let inputTextView = BackspaceTextView()
        inputTextView.keyboardType = self.inputTextViewKeyboardType
        inputTextView.textColor = self.inputTextViewTextColor
        inputTextView.font = UIFont(name: "HelveticaNeue", size: 15.5)
        inputTextView.autocorrectionType = self.autocorrectionType
        inputTextView.autocapitalizationType = self.autocapitalizationType
        inputTextView.tintColor = self.colorScheme
        inputTextView.isScrollEnabled = false
        inputTextView.textContainer.lineBreakMode = .byWordWrapping
        inputTextView.delegate = self
        inputTextView.backspaceDelegate = self
        // TODO: - Add placeholder to BackspaceTextView and set it here
        inputTextView.accessibilityLabel = self.accessibilityLabel ?? NSLocalizedString("To", comment: "")
        inputTextView.inputAccessoryView = self.inputTextViewAccessoryView
        inputTextView.accessibilityLabel = self.inputTextViewAccessibilityLabel
        return inputTextView
    }()
    
    /// - Returns: `Bool` value which is true if the TokenField view is the first responder.
    override public var isFirstResponder: Bool {
        return super.isFirstResponder
    }
    
    // MARK: - initializers
    
    /// Initializes a TokenField with a `CGRect` frame within it's superview.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// Initializer used by the storyboard to initialize a TokenField.
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    /// TokenField override of UIView's awakeFromNib() function. Calls super.awakeFromNib() and then self.setup().
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    /// TokenField calls self.layoutTokensAndInputWithFrameAdjustment(true) and self.inputTextViewBecomeFirstResponder()
    /// - Returns: Always returns `true`
    override public func becomeFirstResponder() -> Bool {
        layoutTokensAndInputWithFrameAdjustment(true)
        inputTextViewBecomeFirstResponder()
        return true
    }
    
    /// Resigns first responder.
    override public func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return inputTextView.resignFirstResponder()
    }
    
    /// Collapses the TokenField.
    public func collapse() {
        layoutCollapsedLabel()
    }
    
    /// Reload's the TokenField's data and lays out it's views.
    public func reloadData() {
        layoutTokensAndInputWithFrameAdjustment(true)
    }
    
    /// - Returns: the input text from the textView.
    public var inputText: String {
        return inputTextView.text ?? ""
    }
    
    // MARK: - View layout
    
    /// Lays out the TokenField's subviews.
    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView.contentSize = CGSize(
            width: frame.width - Constants.defaultHorizontalInset * 2,
            height: frame.height - Constants.defaultVerticalInset * 2
        )
        if collapsedLabel?.superview != nil {
            layoutCollapsedLabel()
        } else {
            layoutTokensAndInputWithFrameAdjustment(false)
        }
    }
    
    // MARK: - Internal
    
    @objc internal func handleSingleTap(_ sender: UITapGestureRecognizer) {
        _ = becomeFirstResponder()
    }
    
    // MARK: - Fileprivate
    
    fileprivate var tokens: [Token] = []
    
    fileprivate func layoutTokensAndInputWithFrameAdjustment(_ shouldAdjustFrame: Bool) {
        collapsedLabel?.removeFromSuperview()
        let inputViewShouldBecomeFirstResponder = inputTextView.isFirstResponder
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        scrollView.isHidden = false
        
        if tapGestureRecognizer != nil {
            removeGestureRecognizer(tapGestureRecognizer!)
            tapGestureRecognizer = nil
        }
        
        tokens = []
        
        var currentX: CGFloat = 0.0
        var currentY: CGFloat = 0.0
        
        layoutToLabelInView(scrollView, origin: CGPoint.zero, currentX: &currentX)
        layoutTokensWith(currentX: &currentX, currentY: &currentY)
        layoutInputTextViewWith(currentX: &currentX, currentY: &currentY, clearInput: shouldAdjustFrame)
        
        if shouldAdjustFrame {
            adjustHeightFor(currentY: currentY)
        }
        
        scrollView.contentSize = CGSize(
            width: scrollView.contentSize.width,
            height: currentY + inputTextView.frame.height
        )
        
        scrollView.isScrollEnabled = scrollView.contentSize.height > maxHeight
        
        if inputViewShouldBecomeFirstResponder {
            inputTextViewBecomeFirstResponder()
        } else {
            focusInputTextView()
        }
    }
    
    fileprivate func setCursorVisibility() {
        let highlightedTokens = tokens.filter { $0.highlighted }
        let visible = highlightedTokens.count == 0
        if visible {
            inputTextViewBecomeFirstResponder()
        } else {
            invisibleTextField.becomeFirstResponder()
        }
    }
    
    private func focusInputTextView() {
        let contentOffset = scrollView.contentOffset
        let targetY = inputTextView.frame.origin.y + Constants.defaultTokenHeight - maxHeight
        if targetY > contentOffset.y {
            scrollView.setContentOffset(
                CGPoint(x: contentOffset.x, y: targetY),
                animated: false
            )
        }
    }
    
    fileprivate func unhighlightAllTokens() {
        for token in tokens {
            token.highlighted = false
        }
        setCursorVisibility()
    }
    
    // MARK: - Private
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: self.frame.width,
                height: self.frame.height
            )
        )
        scrollView.scrollsToTop = false
        scrollView.contentSize = CGSize(
            width: self.frame.width - self.horizontalInset * 2,
            height: self.frame.height - self.verticalInset * 2
        )
        scrollView.contentInset = UIEdgeInsets(
            top: self.verticalInset,
            left: self.horizontalInset,
            bottom: self.verticalInset,
            right: self.horizontalInset
        )
        scrollView.autoresizingMask = [
            UIView.AutoresizingMask.flexibleHeight,
            UIView.AutoresizingMask.flexibleWidth
        ]
        return scrollView
    }()
    private var originalHeight: CGFloat = 0.0
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private lazy var invisibleTextField: BackspaceTextView = {
        let invisibleTextField = BackspaceTextView(frame: CGRect.zero)
        invisibleTextField.autocorrectionType = self.autocorrectionType
        invisibleTextField.autocapitalizationType = self.autocapitalizationType
        invisibleTextField.backspaceDelegate = self
        return invisibleTextField
    }()
    private var collapsedLabel: UILabel?
    
    
    private func setup() {
        originalHeight = frame.height
        
        addSubview(invisibleTextField)
        addSubview(scrollView)
        reloadData()
    }
    
    private func layoutCollapsedLabel() {
        collapsedLabel?.removeFromSuperview()
        scrollView.isHidden = true
        var frame = self.frame
        frame.size.height = originalHeight
        self.frame = frame
        
        var currentX: CGFloat = 0.0
        layoutToLabelInView(self, origin: CGPoint(x: Constants.defaultHorizontalInset, y: Constants.defaultVerticalInset), currentX: &currentX)
        layoutCollapsedLabelWith(currentX: &currentX)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TokenField.handleSingleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    private func layoutCollapsedLabelWith(currentX: inout CGFloat) {
        let label = UILabel(
            frame: CGRect(
                x: currentX,
                y: toLabel.frame.minY,
                width: frame.size.width - currentX - Constants.defaultHorizontalInset,
                height: toLabel.frame.height
            )
        )
        label.font = UIFont(name: "HelveticaNeue", size: 15.5)
        label.text = dataSource?.tokenFieldCollapsedText(self) ?? ""
        label.textColor = colorScheme
        label.minimumScaleFactor = 5.0/label.font.pointSize
        label.adjustsFontSizeToFitWidth = true
        addSubview(label)
        collapsedLabel = label
    }
    
    private func layoutToLabelInView(_ view: UIView, origin: CGPoint, currentX: inout CGFloat) {
        toLabel.removeFromSuperview()
        
        currentX = origin.x
        
        var newFrame = toLabel.frame
        newFrame.origin = origin
        
        toLabel.sizeToFit()
        newFrame.size.width = toLabel.frame.width
        
        toLabel.frame = newFrame
        
        view.addSubview(toLabel)
        let xIncrement = toLabel.isHidden ? 0.0 : toLabel.frame.width + Constants.defaultTokenPadding
        currentX += xIncrement
    }
    
    private func layoutTokensWith(currentX: inout CGFloat, currentY: inout CGFloat) {
        for i in 0..<(dataSource?.numberOfTokensInTokenField(self) ?? 0) {
            let title = dataSource?.tokenField(self, titleForTokenAtIndex: i) ?? ""
            let token = Token(title: title)
            token.sizeToFit()
            token.delegate = self
            //token.didTapTokenBlock = { [weak self] token in
            //    self?.didTap(token: token)
            //}
            token.colorScheme = dataSource?.tokenField(self, colorSchemedForTokenAtIndex: i) ?? colorScheme
            
            tokens.append(token)
            if currentX + token.frame.width <= scrollView.contentSize.width { // token fits in current line
                token.frame = CGRect(
                    x: currentX,
                    y: currentY,
                    width: token.frame.width,
                    height: token.frame.height
                )
            } else {
                currentY += token.frame.height + Constants.defaultVeritcalPadding
                currentX = 0
                var tokenWidth = token.frame.width
                if (tokenWidth > scrollView.contentSize.width) { // token is wider than max width
                    tokenWidth = scrollView.contentSize.width
                }
                token.frame = CGRect(
                    x: currentX,
                    y: currentY,
                    width: tokenWidth,
                    height: token.frame.height
                )
            }
            currentX += token.frame.width + tokenPadding
            scrollView.addSubview(token)
        }
    }
    
    private func layoutInputTextViewWith(currentX: inout CGFloat, currentY: inout CGFloat, clearInput: Bool) {
        
        let inputHeight = inputTextView.intrinsicContentSize.height > Constants.defaultTokenHeight
          ? inputTextView.intrinsicContentSize.height
          : Constants.defaultTokenHeight
        
        if currentX + Constants.defaultMinInputWidth >= scrollView.contentSize.width {
            currentY += Constants.defaultTokenHeight + Constants.defaultVeritcalPadding
            
        }
        
        inputTextView.frame = CGRect(
            x: 0.0,
            y: currentY,
            width: scrollView.contentSize.width,
            height: inputHeight
        )
    
        var exclusionPaths: [UIBezierPath] = []
        
        if inputTextView.frame.origin.y == toLabel.frame.origin.y {
            exclusionPaths.append(UIBezierPath(rect: toLabel.frame))
        }
        
        for token in tokens {
            if inputTextView.frame.origin.y == token.frame.origin.y {
                
                var frame = token.frame
                frame.origin.y = 0.0
                
                exclusionPaths.append(UIBezierPath(rect: frame))
            }
        }
        inputTextView.textContainer.exclusionPaths = exclusionPaths
        
        if clearInput {
            inputTextView.text = ""
        }
        scrollView.addSubview(inputTextView)
        scrollView.sendSubviewToBack(inputTextView)
    }
    
    private func inputTextViewBecomeFirstResponder() {
        guard !inputTextView.isFirstResponder else { return }
        inputTextView.becomeFirstResponder()
        delegate?.tokenFieldDidBeginEditing(self)
    }
    
    private func didTap(token aToken: Token) {
        for token in tokens {
            if aToken === token {
                aToken.highlighted = !aToken.highlighted
            } else {
                aToken.highlighted = false
            }
        }
        setCursorVisibility()
    }
    
    private func adjustHeightFor(currentY: CGFloat) {
        let oldHeight = frame.size.height
        var newFrame = frame
        
        if currentY + Constants.defaultTokenHeight > frame.height {
            if currentY + Constants.defaultTokenHeight <= maxHeight {
                newFrame.size.height = currentY
                    + Constants.defaultTokenHeight
                    + Constants.defaultVerticalInset * 2
            } else {
                newFrame.size.height = maxHeight
            }
        } else {
            if currentY + Constants.defaultTokenHeight > originalHeight {
                newFrame.size.height = currentY
                    + Constants.defaultTokenHeight
                    + Constants.defaultVerticalInset * 2
            } else {
                newFrame.size.height = maxHeight
            }
        }
        if oldHeight != newFrame.height {
            frame = newFrame
            delegate?.tokenField(self, didChangeContentHeight: newFrame.height)
        }
    }
}

/// :nodoc:
extension TokenField: BackspaceTextViewDelegate {
    
    /// :nodoc:
    internal func textViewDidEnterBackspace(_ textView: BackspaceTextView) {
        if let tokenCount = dataSource?.numberOfTokensInTokenField(self), tokenCount > 0 {
            var tokenDeleted = false
            for token in tokens {
                if token.highlighted {
                    let index = tokens.index(of: token)!
                    delegate?.tokenField(self, didDeleteTokenAtIndex: index)
                    tokenDeleted = true
                    break
                }
            }
            if !tokenDeleted {
                let last = tokens.last!
                last.highlighted = true
            }
            setCursorVisibility()
        }
    }
}

/// :nodoc:
extension TokenField: TokenDelegate {
    /// :nodoc:
    public func didTapToken(_ token: Token) {
        
        for aToken in tokens {
            if aToken === token {
                aToken.highlighted = !aToken.highlighted
            } else {
                aToken.highlighted = false
            }
        }
        setCursorVisibility()
    }
}

/// :nodoc:
extension TokenField: UITextViewDelegate {
    
    /// :nodoc:
    public func textViewDidChange(_ textView: UITextView) {
        //unhighlightAllTokens()
        delegate?.tokenField(self, didChangeText: textView.text ?? "")
        
        if textView.contentSize.height > textView.frame.height {
            layoutTokensAndInputWithFrameAdjustment(true)
        }
    }
    
    /// :nodoc:
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        //unhighlightAllTokens()
        
        guard text != "\n" else {
            if !textView.text.isEmpty {
                delegate?.tokenField(self, didEnterText: textView.text)
            }
            return false
        }
        return true
    }
    
    /// :nodoc:
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === inputTextView {
            unhighlightAllTokens()
        }
    }
}
