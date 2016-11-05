//
//  Token.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

public class Token: UIView {

    public internal(set) var title: String? {
        didSet {
            titleView.text = title
            titleView.textColor = colorScheme
            titleView.sizeToFit()
            frame = CGRect(
                x: frame.minX,
                y: frame.minY,
                width: titleView.frame.maxX + 3,
                height: frame.height
            )
            titleView.sizeToFit()
        }
    }
    internal var highlighted: Bool = false { didSet { updateUI() } }
    internal var colorScheme: UIColor! { didSet { updateUI() } }
    internal var didTapTokenBlock: (Token)->Void = {_ in}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first! as! UIView
        addSubview(view)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func didTapToken(_ sender: UITapGestureRecognizer) {
        didTapTokenBlock(self)
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var titleView: UILabel!
    
    // MARK: - Private
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private func updateUI() {
        let textColor = highlighted ? UIColor.white : colorScheme
        let backgroundColor = highlighted ? colorScheme : UIColor.clear
        titleView.textColor = textColor
        backgroundView.backgroundColor = backgroundColor
    }
    
    private func setup() {
        backgroundView.layer.cornerRadius = 5
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Token.didTapToken(_:)))
        colorScheme = UIColor.blue
        titleView.textColor = colorScheme
        addGestureRecognizer(tapGestureRecognizer)
    }
    
}
