//
//  LabelFactory.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/24.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

func ss_createLabel(
    font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment,
    text: String? = nil
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.text = text
        return label
}

/**
 Factory function which is able to return a function who will create UILabel with given attributes
 
 - parameter font:          font
 - parameter textColor:     color
 - parameter textAlignment: alignment
 
 - returns: the factory function
 */
func ss_labelFactory(
    font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment
    ) -> ((String)->UILabel) {
        func wrapped(text: String) -> UILabel {
            return ss_createLabel(font, textColor: textColor, textAlignment: textAlignment, text: text)
        }
        return wrapped
}

extension UIView {
    
    @nonobjc func addSubview<T: UIView>(type: T.Type) -> T {
        let subview = type.self.init()
        addSubview(subview)
        return subview
    }
    
    @nonobjc func config(
        backgroundColor: UIColor = UIColor.whiteColor()
        ) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @nonobjc func layout(@noescape closurer: ConstraintMaker -> Void) -> Self {
        self.snp_makeConstraints(closure: closurer)
        return self
    }
    
    @nonobjc func addShadow(
        blur: CGFloat = 2,
        color: UIColor = UIColor.blackColor(),
        opacity: Float = 0.4,
        offset: CGSize = CGSizeMake(0, 3)
        ) -> Self {
        self.layer.shadowColor = color.CGColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = blur
        return self
    }
    
    @nonobjc func setFrame(frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    @nonobjc func customize(config: UIView->Void) -> Self {
        config(self)
        return self
    }
}


extension UILabel {
    @nonobjc func config(
        fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.blackColor(),
        textAlignment: NSTextAlignment  = .Left,
        text: String?                   = nil,
        multiLine: Bool                 = false
        ) -> UILabel {
        self.font = UIFont.systemFontOfSize(fontSize, weight: fontWeight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.text = text
        if multiLine {
            numberOfLines = 0
        } else{
            numberOfLines = 1
        }
        return self
    }
    
    class func facotry(
        fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.blackColor(),
        textAlignment: NSTextAlignment  = .Left
        ) -> String -> UILabel {
        func _factory(text: String) -> UILabel {
            return UILabel().config(fontSize, fontWeight: fontWeight, textColor: textColor, textAlignment: textAlignment, text: text)
        }
        return _factory
    }
}

extension UITextField {
    @nonobjc func config(
        fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.blackColor(),
        textAlignment: NSTextAlignment  = .Left,
        placeholder: String?            = nil,
        text: String?                   = nil
        ) -> UITextField {
        self.font = UIFont.systemFontOfSize(fontSize, weight: fontWeight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.placeholder = placeholder
        self.text = text
        return self
    }
    
    @nonobjc func addToInputable(inputable: InputableViewController) -> Self {
        self.delegate = inputable
        inputable.inputFields.append(self)
        return self
    }
}

extension UIImageView {
    @nonobjc func config(
        image: UIImage? = nil,
        contentMode: UIViewContentMode = .ScaleToFill
        ) -> Self {
        self.image = image
        self.contentMode = contentMode
        self.clipsToBounds = true
        return self
    }
    
    @nonobjc func layout(
        cornerRadius: CGFloat,
        @noescape closurer: ConstraintMaker -> Void
        ) -> Self {
        self.layer.cornerRadius = cornerRadius
        self.snp_makeConstraints(closure: closurer)
        return self
    }
}

extension UIButton {
    @nonobjc func config(
        target: AnyObject,
        selector: Selector,
        title: String? = nil,
        image: UIImage? = nil
        ) -> Self {
        self.setTitle(title, forState: .Normal)
        self.setImage(image, forState: .Normal)
        self.addTarget(target, action: selector, forControlEvents: .TouchUpInside)
        return self
    }
}

extension UISwitch {
    @nonobjc func config(
        target: AnyObject,
        selector: Selector,
        tintColor: UIColor = UIColor(white: 0.72, alpha: 1),
        onTintColor: UIColor = kHighlightedRedTextColor,
        backgroundColor: UIColor = UIColor(white: 0.72, alpha: 1),
        cornerRadius: CGFloat = 15.5
        ) -> UISwitch {
        self.tintColor = tintColor
        self.onTintColor = onTintColor
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadius
        self.addTarget(target, action: selector, forControlEvents: .ValueChanged)
        return self
    }
}

extension UIScrollView {
    @nonobjc func config(
        contentSize: CGSize
        ) -> Self {
        return self
    }
}

