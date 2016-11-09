//
//  Token.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public protocol TokenDelegate: class {
    func didTapToken(_ token: Token)
}

public class Token: UIView {
    
    public weak var delegate: TokenDelegate?

    public let title: String
    public var colorScheme: UIColor = UIColor.blue { didSet { updateUI() } }
    internal var highlighted: Bool = false { didSet { updateUI() } }
    // internal var didTapTokenBlock: (Token)->Void = { _ in }
    
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
        // didTapTokenBlock(self)
        delegate?.didTapToken(self)
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "HelveticaNeue", size: 15.5)
        }
    }
    
    // MARK: - Private
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private func loadView() {
        let type = type(of: self)
        let bundle = Bundle(for: type)
        let nib = UINib(nibName: String(describing: type), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first! as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func setup() {
        backgroundView.layer.cornerRadius = 5
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Token.didTapToken(_:)))
        colorScheme = UIColor.blue
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func updateUI() {
        let backgroundColor = highlighted ? colorScheme : colorScheme.withAlphaComponent(0.6)
        backgroundView.backgroundColor = backgroundColor
    }
    
}
