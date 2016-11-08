//
//  Token.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public class Token: UIView {

    public let title: String
    public var colorScheme: UIColor = UIColor.blue { didSet { updateUI() } }
    internal var highlighted: Bool = false { didSet { updateUI() } }
    internal var didTapTokenBlock: (Token)->Void = { _ in }
    
    public init(title: String) {
        self.title = title
        super.init(frame: CGRect.zero)
        loadView()
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = titleLabel.intrinsicContentSize
        return CGSize(width: size.width + 6, height: TokenField.Constants.defaultTokenHeight)
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        return intrinsicContentSize
    }
    
    internal func didTapToken(_ sender: UITapGestureRecognizer) {
        didTapTokenBlock(self)
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = colorScheme
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 15.5)
        }
    }
    
    // MARK: - Private
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first! as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func setup() {
        backgroundView.layer.cornerRadius = 5
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Token.didTapToken(_:)))
        colorScheme = UIColor.blue
        titleLabel.textColor = colorScheme
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func updateUI() {
        let textColor = highlighted ? UIColor.white : colorScheme
        let backgroundColor = highlighted ? colorScheme : UIColor.clear
        titleLabel.textColor = textColor
        backgroundView.backgroundColor = backgroundColor
    }
    
}
