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
    
    var tokenField: TokenField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        tokenField = TokenField(
            frame: CGRect(
                x: 0.0,
                y: 0.0,
                width: view.frame.size.width,
                height: 50
            )
        )
        tokenField.sizeToFit()
        view.addSubview(tokenField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

