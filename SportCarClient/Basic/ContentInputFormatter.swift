//
//  ContentInputFormatter.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol ContentInputFormatterDelegate: class {
    func contentInputConfirmed(contentInputFormatter: ContentInputFormatter)
    func contentInputShouldChangeHeight(into height: CGFloat)
}


class ContentInputFormatter: NSObject, UITextViewDelegate {
    
    var textCountLimit = 140
    var textInput: UITextView! {
        didSet {
            configureTextInput()
        }
    }
    var disableConfirmKey: Bool = false
    var confirmKey: String = "\n"
    var callDidChangeAfterTruncate: Bool = true
    
    weak var forwardToDelegate: UITextViewDelegate?
    weak var delegate: ContentInputFormatterDelegate?
    
    func configureTextInput() {
        textInput.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
        textInput.isScrollEnabled = false
        textInput.bounces = false
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !callDidChangeAfterTruncate {
            forwardToDelegate?.textViewDidChange?(textView)
        }
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        
        let text = textView.text ?? ""
        if text.length > textCountLimit {
            textView.text = text[0..<textCountLimit]
        }
        
        // calculate new height
        if text == "" {
            delegate?.contentInputShouldChangeHeight(into: 0)
        } else {
            let fixedWidth = textInput.bounds.width
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            delegate?.contentInputShouldChangeHeight(into: newSize.height + 10)
        }
        
        if callDidChangeAfterTruncate {
            forwardToDelegate?.textViewDidChange?(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidEndEditing?(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        forwardToDelegate?.textViewDidBeginEditing?(textView)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let res = forwardToDelegate?.textViewShouldEndEditing?(textView) {
            return res
        }
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let res = forwardToDelegate?.textViewShouldBeginEditing?(textView) {
            return res
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == confirmKey {
            delegate?.contentInputConfirmed(contentInputFormatter: self)
            return false
        }
        if let res = forwardToDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) {
            return res
        }
        return true
    }

}
