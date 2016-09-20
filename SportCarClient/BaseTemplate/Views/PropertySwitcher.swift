//
//  PropertySwitcher.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

class SSPropertySwitcherCell: SSPropertyBaseCell {
    
    fileprivate weak var bindObj: AnyObject?
    fileprivate var bindPropertyName: String?
    
    class override var reuseIdentifier: String {
        return "switcher_cell"
    }
    
    internal var switcher: UISwitch!
    
    internal override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        switcher = superview.addSubview(UISwitch.self)
            .config(self, selector: #selector(switcherPressed(_:)))
            .layout({ (make) in
                make.right.equalTo(superview).offset(-15)
                make.centerY.equalTo(staticLbl)
                make.size.equalTo(CGSize(width: 51, height: 31))
            })
    }
    
    @objc fileprivate func switcherPressed(_ sender: UISwitch) {
        if bindPropertyName == nil || bindObj == nil {
            // Not binded
            assertionFailure()
        }
        if let obj = bindObj as? NSObject, let keypath = bindPropertyName {
            obj.setValue(sender.isOn, forKeyPath: keypath)
        }
//        bindObj?.setBool(sender.on, forKey: bindPropertyName!)
    }
    
    func setData(
        _ propertyName: String,
        propertyValue: Bool,
        bindObj: AnyObject?,
        bindPropertyName: String,
        showArrow: Bool = false
        ) -> Self {
        staticLbl.text = propertyName
        switcher.isOn = propertyValue
        arrowIcon.isHidden = !showArrow
        self.bindObj = bindObj
        self.bindPropertyName = bindPropertyName
        return self
    }
}
