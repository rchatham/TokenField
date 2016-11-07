//
//  TokenField.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public protocol TokenFieldDelegate: class {
    func tokenField(_ tokenField: TokenField, didEnterText text: String)
    func tokenField(_ tokenField: TokenField, didDeleteTokenAtIndex index: Int)
    func tokenField(_ tokenField: TokenField, didChangeText text: String)
    func tokenFieldDidBeginEditing(_ tokenField: TokenField)
    func tokenField(_ tokenField: TokenField, didChangeContentHeight height: CGFloat)
}

public protocol TokenFieldDataSource: class {
    func tokenField(_ tokenField: TokenField, titleForTokenAtIndex index: Int) -> String
    func tokenField(_ tokenField: TokenField, colorSchemedForTokenAtIndex index: Int) -> UIColor
    func numberOfTokensInTokenField(_ tokenField: TokenField) -> Int
    func tokenFieldCollapsedText(_ tokenField: TokenField) -> String
}

public class TokenField: UIView {

    public weak var delegate: TokenFieldDelegate?
    public weak var dataSource: TokenFieldDataSource?
    
    public struct Constants {
        public static let defaultVerticalInset: CGFloat      = 7.0
        public static let defaultHorizontalInset: CGFloat    = 15.0
        public static let defaultToLabelPadding: CGFloat     = 5.0
        public static let defaultTokenPadding: CGFloat       = 2.0
        public static let defaultMinInputWidth: CGFloat      = 80.0
        public static let defaultMaxHeight: CGFloat          = 150.0
        public static let defaultTokenHeight: CGFloat        = 30.0
    }
    
    public var maxHeight: CGFloat = Constants.defaultMaxHeight
    public var verticalInset: CGFloat = Constants.defaultVerticalInset
    public var horizontalInset: CGFloat = Constants.defaultHorizontalInset
    public var tokenPadding: CGFloat = Constants.defaultTokenPadding
    public var minInputWidth: CGFloat = Constants.defaultMinInputWidth
    
    public var inputTextViewKeyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    
    public var autocorrectionType: UITextAutocorrectionType = .no
    public var autocapitalizationType: UITextAutocapitalizationType = .sentences
    public var inputTextViewAccessoryView: UIView? {
        didSet {
            inputTextView.inputAccessoryView = inputTextViewAccessoryView
        }
    }
    public var toLabelTextColor: UIColor = UIColor(red: 112/255.0, green: 124/255.0, blue: 124/255.0, alpha: 1.0) {
        didSet {
            toLabel.textColor = toLabelTextColor
        }
    }
    public var toLabelText: String = NSLocalizedString("To:", comment: "") {
        didSet {
            toLabel.text = toLabelText
            reloadData()
        }
    }
    public var inputTextViewTextColor: UIColor = UIColor(red: 38/255.0, green: 39/255.0, blue: 41/255.0, alpha: 1.0) {
        didSet {
            inputTextView.textColor = inputTextViewTextColor
        }
    }
    public var colorScheme: UIColor = .blue {
        didSet {
            collapsedLabel?.textColor = colorScheme
            inputTextView.textColor = colorScheme
            for token in tokens {
                token.colorScheme = colorScheme
            }
        }
    }
    
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
    public lazy var inputTextView: BackspaceTextView = {
        let inputTextView = BackspaceTextView()
        inputTextView.keyboardType = self.inputTextViewKeyboardType
        inputTextView.textColor = self.inputTextViewTextColor
        inputTextView.font = UIFont(name: "HelveticaNeue", size: 15.5)
        inputTextView.autocorrectionType = self.autocorrectionType
        inputTextView.autocapitalizationType = self.autocapitalizationType
        inputTextView.tintColor = self.colorScheme
        inputTextView.delegate = self
        inputTextView.backspaceDelegate = self
        // TODO: - Add placeholder to BackspaceTextView and set it here
        inputTextView.accessibilityLabel = self.accessibilityLabel ?? NSLocalizedString("To", comment: "")
        inputTextView.inputAccessoryView = self.inputTextViewAccessoryView
        return inputTextView
    }()
    
    public var delimiters: [String] = [] // Are these strings??????
    public var placeholderText: String! {
        didSet {
            print("Placeholder not implemented")
        }
    }
    public var inputTextFieldAccessibilityLabel: String! {
        didSet {
            inputTextView.accessibilityLabel = inputTextFieldAccessibilityLabel
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override public var isFirstResponder: Bool {
        return super.isFirstResponder
    }
    
    override public func becomeFirstResponder() -> Bool {
        layoutTokensAndInputWithFrameAdjustment(true)
        inputTextViewBecomeFirstResponder()
        return true
    }
    
    override public func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return inputTextView.resignFirstResponder()
    }
    
    public func collapse() {
        layoutCollapsedLabel()
    }
    
    public func reloadData() {
        layoutTokensAndInputWithFrameAdjustment(true)
    }
    
    public func inputText() -> String {
        return inputTextView.text ?? ""
    }
    
    // MARK: - View layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        scrollView?.contentSize = CGSize(
            width: frame.width - Constants.defaultHorizontalInset * 2,
            height: frame.height - Constants.defaultVerticalInset * 2
        )
        if collapsedLabel?.superview != nil {
            layoutCollapsedLabel()
        } else {
            layoutTokensAndInputWithFrameAdjustment(false)
        }
    }
    
    internal func handleSingleTap(_ sender: UITapGestureRecognizer) {
        _ = becomeFirstResponder()
    }
    
    // MARK: - Fileprivate
    
    fileprivate var tokens: [Token] = []
    
    fileprivate func setCursorVisibility() {
        let highlightedTokens = tokens.filter { $0.highlighted }
        let visible = highlightedTokens.count == 0
        if visible {
            inputTextViewBecomeFirstResponder()
        } else {
            inputTextView.becomeFirstResponder()
        }
    }
    
    fileprivate func updateInputTextField() {
        print("TokenField: Should set placeholder text")
    }
    
    private func focusInputTextView() {
        let contentOffest = scrollView?.contentOffset ?? CGPoint.zero
        let targetY = inputTextView.frame.origin.y + Constants.defaultTokenHeight - maxHeight
        if targetY > contentOffest.y {
            scrollView?.setContentOffset(CGPoint(x: contentOffest.x, y: targetY), animated: false)
        }
    }
    
    fileprivate func unhighlightAllTokens() {
        for token in tokens {
            token.highlighted = false
        }
        setCursorVisibility()
    }
    
    // MARK: - Private
    
    private var scrollView: UIScrollView?
    private var originalHeight: CGFloat = 0.0
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var invisibleTextField: BackspaceTextView?
    private var collapsedLabel: UILabel?
    
    
    private func setup() {
        originalHeight = frame.height
        
        layoutInvisibleTextView()
        layoutScrollView()
        reloadData()
    }
    
    private func layoutCollapsedLabel() {
        collapsedLabel?.removeFromSuperview()
        scrollView?.isHidden = true
        var frame = self.frame
        frame.size.height = originalHeight
        self.frame = frame
        
        var currentX: CGFloat = 0.0
        layoutToLabelInView(self, origin: CGPoint(x: Constants.defaultHorizontalInset, y: Constants.defaultVerticalInset), currentX: &currentX)
        layoutCollapsedLabelWith(currentX: &currentX)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TokenField.handleSingleTap(_:)))
        addGestureRecognizer(tapGestureRecognizer!)
    }
    
    private func layoutScrollView() {
        scrollView = UIScrollView(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: frame.width,
                height: frame.height
            )
        )
        scrollView?.scrollsToTop = false
        scrollView?.contentSize = CGSize(
            width: frame.width - horizontalInset * 2,
            height: frame.height - verticalInset * 2
        )
        scrollView?.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
        scrollView?.autoresizingMask = [
            UIViewAutoresizing.flexibleHeight,
            UIViewAutoresizing.flexibleWidth
        ]
        addSubview(scrollView!)
    }
    
    private func layoutTokensAndInputWithFrameAdjustment(_ shouldAdjustFrame: Bool) {
        collapsedLabel?.removeFromSuperview()
        let inputViewShouldBecomeFirstResponder = inputTextView.isFirstResponder
        scrollView?.subviews.forEach { $0.removeFromSuperview() }
        scrollView?.isHidden = false
        if tapGestureRecognizer != nil {
            removeGestureRecognizer(tapGestureRecognizer!)
        }
        
        tokens = []
        
        var currentX: CGFloat = 0.0
        var currentY: CGFloat = 0.0
        
        layoutToLabelInView(scrollView!, origin: CGPoint.zero, currentX: &currentX)
        layoutTokensWith(currentX: &currentX, currentY: &currentY)
        layoutInputTextViewWith(clearInput: shouldAdjustFrame)
        
        if shouldAdjustFrame {
            adjustHeightFor(currentY: currentY)
        }
        
        scrollView?.contentSize = CGSize(
            width: scrollView!.contentSize.width,
            height: currentY + Constants.defaultTokenHeight
        )
        
        updateInputTextField()
        
        if inputViewShouldBecomeFirstResponder {
            inputTextViewBecomeFirstResponder()
        } else {
            focusInputTextView()
        }
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
            token.didTapTokenBlock = { [weak self] token in
                self?.didTap(token: token)
            }
            token.colorScheme = dataSource?.tokenField(self, colorSchemedForTokenAtIndex: i) ?? colorScheme
            
            tokens.append(token)
            if (currentX + token.frame.width <= scrollView?.contentSize.width ?? 0) { // token fits in current line
                token.frame = CGRect(
                    x: currentX,
                    y: currentY,
                    width: token.frame.width,
                    height: token.frame.height
                )
            } else {
                currentY += token.frame.height
                currentX = 0
                var tokenWidth = token.frame.width
                if (tokenWidth > scrollView?.contentSize.width ?? 0.0) { // token is wider than max width
                    tokenWidth = scrollView?.contentSize.width ?? 0.0
                }
                token.frame = CGRect(
                    x: currentX,
                    y: currentY,
                    width: tokenWidth,
                    height: token.frame.height
                )
            }
            currentX += token.frame.width + tokenPadding
            scrollView?.addSubview(token)
        }
    }
    
    
    private func layoutInputTextViewWith(clearInput: Bool) {
        
        inputTextView.frame = CGRect(
            x: 0.0,
            y: 0.0,
            width: scrollView?.contentSize.width ?? 0.0,
            height: scrollView?.contentSize.width ?? 0.0
        )
    
        var exclusiontPaths: [UIBezierPath] = []
        
        exclusiontPaths.append(UIBezierPath(rect: toLabel.frame))
        
        for token in tokens {
            exclusiontPaths.append(UIBezierPath(rect: token.frame))
        }
        inputTextView.textContainer.exclusionPaths = exclusiontPaths
        
        if clearInput {
            inputTextView.text = ""
        }
        scrollView?.addSubview(inputTextView)
        scrollView?.sendSubview(toBack: inputTextView)
    }
    
    private func inputTextViewBecomeFirstResponder() {
        guard !inputTextView.isFirstResponder else { return }
        inputTextView.becomeFirstResponder()
        delegate?.tokenFieldDidBeginEditing(self)
    }
    
    private func layoutInvisibleTextView() {
        invisibleTextField = BackspaceTextView(frame: CGRect.zero)
        invisibleTextField?.autocorrectionType = autocorrectionType
        invisibleTextField?.autocapitalizationType = autocapitalizationType
        invisibleTextField?.backspaceDelegate = self
        addSubview(invisibleTextField!)
    }
    
    private func didTap(token aToken: Token) {
        for token in tokens {
            if aToken == token {
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

extension TokenField: BackspaceTextViewDelegate {
    
    public func textViewDidEnterBackspace(_ textView: BackspaceTextView) {
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

extension TokenField: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        delegate?.tokenField(self, didChangeText: textView.text ?? "")
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        unhighlightAllTokens()
        
        guard text != "\n" else {
            if !textView.text.isEmpty {
                delegate?.tokenField(self, didEnterText: textView.text)
            }
            return false
        }
        
        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as String
        
        for delimiter in delimiters {
            let offset = newString.characters.count - delimiter.characters.count
            let index = newString.index(newString.startIndex, offsetBy: offset)
            //index(newString.endIndex, offsetBy: delimiter.characters.count)
            if (newString.characters.count > delimiter.characters.count) && (newString.substring(from: index) == delimiter) {
                let enteredText = newString.substring(to: index)
                if !enteredText.isEmpty {
                    delegate?.tokenField(self, didEnterText: enteredText)
                    return false
                }
            }
        }
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === inputTextView {
            unhighlightAllTokens()
        }
    }
}
