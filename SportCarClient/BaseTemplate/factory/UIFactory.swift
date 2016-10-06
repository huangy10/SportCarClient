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
    _ font: UIFont,
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
    _ font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment
    ) -> ((String)->UILabel) {
        func wrapped(_ text: String) -> UILabel {
            return ss_createLabel(font, textColor: textColor, textAlignment: textAlignment, text: text)
        }
        return wrapped
}

extension UIColor {
    class func RGB(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIView {
    
    @discardableResult
    @nonobjc func addSubview<T: UIView>(_ type: T.Type) -> T {
        let subview = type.self.init()
        addSubview(subview)
        if let imageView = subview as? UIImageView {
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
        }
        return subview
    }
    
    @discardableResult
    @nonobjc func config(
        _ backgroundColor: UIColor = UIColor.white
        ) -> Self {
        self.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    @nonobjc func layout( _ closurer: (ConstraintMaker) -> Void) -> Self {
        self.snp.makeConstraints(closurer)
        return self
    }
    
    @discardableResult
    @nonobjc func addShadow(
        _ blur: CGFloat = 2,
        color: UIColor = UIColor.black,
        opacity: Float = 0.12,
        offset: CGSize = CGSize(width: 0, height: 1)
        ) -> Self {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = blur
        return self
    }
    
    @discardableResult
    @nonobjc func setFrame(_ frame: CGRect) -> Self {
        self.frame = frame
        return self
    }
    
    @discardableResult
    @nonobjc func toRound(_ corner: CGFloat, clipsToBound: Bool = true) -> Self {
        self.layer.cornerRadius = corner
        self.clipsToBounds = clipsToBounds
        return self
    }
    
    @discardableResult
    @nonobjc func toRound(_ clipsToBounds: Bool = true) -> Self {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = clipsToBounds
        return self
    }
    
    @discardableResult
    @nonobjc func customize(_ config: (UIView)->Void) -> Self {
        config(self)
        return self
    }
}


extension UILabel {
    
    @discardableResult
    @nonobjc func config(
        _ fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.black,
        textAlignment: NSTextAlignment  = .left,
        text: String?                   = nil,
        multiLine: Bool                 = false
        ) -> UILabel {
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
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
    
    @discardableResult
    @nonobjc func styleCopy(_ lbl: UILabel, text: String? = nil) -> Self {
        font = lbl.font
        textColor = lbl.textColor
        textAlignment = lbl.textAlignment
        numberOfLines = lbl.numberOfLines
        self.text = text
        return self
    }
    
    class func facotry(
        _ fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.black,
        textAlignment: NSTextAlignment  = .left
        ) -> (String) -> UILabel {
        func _factory(_ text: String) -> UILabel {
            return UILabel().config(fontSize, fontWeight: fontWeight, textColor: textColor, textAlignment: textAlignment, text: text)
        }
        return _factory
    }
}

extension UITextField {
    
    @discardableResult
    @nonobjc func config(
        _ fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.black,
        textAlignment: NSTextAlignment  = .left,
        placeholder: String?            = nil,
        text: String?                   = nil
        ) -> UITextField {
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.placeholder = placeholder
        self.text = text
        return self
    }
    
    @discardableResult
    @nonobjc func addToInputable(_ inputable: InputableViewController) -> Self {
        self.delegate = inputable
        inputable.inputFields.append(self)
        return self
    }
}

extension UITextView {
    
    @discardableResult
    @nonobjc func config(
        _ fontSize: CGFloat               = 14,
        fontWeight: CGFloat             = UIFontWeightUltraLight,
        textColor: UIColor              = UIColor.black,
        textAlignment: NSTextAlignment  = .left,
        text: String?                   = nil
        ) -> UITextView {
        self.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.text = text
        return self
    }
    
    @discardableResult
    @nonobjc func addToInputable(_ inputable: InputableViewController) -> UITextView {
        self.delegate = inputable
        inputable.inputFields.append(self)
        return self
    }
}

extension UIImageView {
    
    @discardableResult
    @nonobjc func config(
        _ image: UIImage? = nil,
        contentMode: UIViewContentMode = .scaleAspectFill
        ) -> Self {
        self.image = image
        self.contentMode = contentMode
        self.clipsToBounds = true
        return self
    }
    
    @discardableResult
    @nonobjc func layout(
        _ cornerRadius: CGFloat,
        closurer: (ConstraintMaker) -> Void
        ) -> Self {
        self.layer.cornerRadius = cornerRadius
        self.snp.makeConstraints(closurer)
        return self
    }
}

extension UIRefreshControl {
    @nonobjc func config(
        _ target: AnyObject,
        selector: Selector
        ) -> Self {
        self.addTarget(target, action: selector, for: .valueChanged)
        return self
    }
}

extension UIButton {
    
    @discardableResult
    @nonobjc func config(
        _ target: AnyObject,
        selector: Selector,
        title: String? = nil,
        titleColor: UIColor? = kHighlightedRedTextColor,
        titleSize: CGFloat = 14,
        titleWeight: CGFloat = UIFontWeightUltraLight,
        image: UIImage? = nil,
        contentMode: UIViewContentMode = .scaleAspectFill
        ) -> UIButton {
        self.setTitle(title, for: .normal)
        self.setImage(image, for: .normal)
        self.imageView?.contentMode = contentMode
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: titleSize, weight: titleWeight)
        self.addTarget(target, action: selector, for: .touchUpInside)
        return self
    }
    
    @discardableResult
    @nonobjc func toRoundButton(_ corner: CGFloat) -> UIButton {
        imageView?.layer.cornerRadius = corner
        return self
    }
}

extension UISwitch {
    
    @discardableResult
    @nonobjc func config(
        _ target: AnyObject,
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
        self.addTarget(target, action: selector, for: .valueChanged)
        return self
    }
}

extension UIScrollView {
    
    @discardableResult
    @nonobjc func config(
        _ contentSize: CGSize
        ) -> Self {
        return self
    }
}


extension UIViewController {
    func toNavWrapper() -> BlackBarNavigationController {
        let wrapper = BlackBarNavigationController(rootViewController: self)
        return wrapper
    }
}

