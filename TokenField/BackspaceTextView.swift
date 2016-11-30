//
//  BackspaceTextView.swift
//  TokenField
//
//  Created by Reid Chatham on 11/4/16.
//  Copyright © 2016 Reid Chatham. All rights reserved.
//

import UIKit

/// Delegate object for the BackspaceTextView type that inherits from class and gives access to a call when the textView hits backspace.
internal protocol BackspaceTextViewDelegate: class {
    func textViewDidEnterBackspace(_ textView: BackspaceTextView)
}

/// UITextView subclass that gives access to when the text view calls backspace on empty text.
internal class BackspaceTextView: UITextView {

    /// The backspace delegate for the BackspaceTextView
    internal weak var backspaceDelegate: BackspaceTextViewDelegate?
    
    internal func keyboardInputShouldDelete(_ textView: UITextView) -> Bool {
        if text.characters.count == 0 {
            backspaceDelegate?.textViewDidEnterBackspace(self)
        }
        return true
    }
}
