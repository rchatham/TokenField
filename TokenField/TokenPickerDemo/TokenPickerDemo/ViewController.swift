//
//  ViewController.swift
//  TokenPickerDemo
//
//  Created by Reid Chatham on 11/5/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit
import TokenField


class ViewController: UIViewController {
    
    var tokens: [String] = []
    
    var tokenField: TokenField! {
        didSet {
            tokenField.delegate = self
            tokenField.dataSource = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        tokenField = TokenField(
            frame: CGRect(
                x: 0.0,
                y: UIApplication.shared.statusBarFrame.height,
                width: view.frame.size.width,
                height: 50
            )
        )
        view.addSubview(tokenField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: TokenFieldDelegate {
    
    func tokenField(_ tokenField: TokenField, didChangeText text: String) {
        
    }
    
    func tokenField(_ tokenField: TokenField, didEnterText text: String) {
        tokens.append(text)
        tokenField.reloadData()
    }

    func tokenFieldDidBeginEditing(_ tokenField: TokenField) {
        
    }
    
    func tokenField(_ tokenField: TokenField, didDeleteTokenAtIndex index: Int) {
        tokens.remove(at: index)
        tokenField.reloadData()
    }
    
    func tokenField(_ tokenField: TokenField, didChangeContentHeight height: CGFloat) {
        if height < TokenField.Constants.defaultMaxHeight {
            var frame = tokenField.frame
            frame.size.height = height
            tokenField.frame = frame
        }
    }
}

extension ViewController: TokenFieldDataSource {
    
    func numberOfTokensInTokenField(_ tokenField: TokenField) -> Int {
        return tokens.count
    }
    
    func tokenField(_ tokenField: TokenField, titleForTokenAtIndex index: Int) -> String {
        return tokens[index]
    }
    
    func tokenField(_ tokenField: TokenField, colorSchemedForTokenAtIndex index: Int) -> UIColor {
        return UIColor.blue
    }
    
    func tokenFieldCollapsedText(_ tokenField: TokenField) -> String {
        return ""
    }
    
}

