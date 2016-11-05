//
//  BackspaceTextView.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

protocol BackspaceTextViewDelegate: class {
    func textViewDidEnterBackspace(_ textView: BackspaceTextView)
}

class BackspaceTextView: UITextView {

    weak var backspaceDelegate: BackspaceTextViewDelegate?
    
    func keyboardInputShouldDelete(_ textView: UITextView) -> Bool {
        if text.characters.count == 0 {
            backspaceDelegate?.textViewDidEnterBackspace(self)
        }
        return true
    }
}
