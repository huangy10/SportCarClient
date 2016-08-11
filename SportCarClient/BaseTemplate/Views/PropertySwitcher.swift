//
//  PropertySwitcher.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

class SSPropertySwitcherCell: SSPropertyBaseCell {
    
    private weak var bindObj: AnyObject?
    private var bindPropertyName: String?
    
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
                make.size.equalTo(CGSizeMake(51, 31))
            })
    }
    
    @objc private func switcherPressed(sender: UISwitch) {
        if bindPropertyName == nil || bindObj == nil {
            // Not binded
            assertionFailure()
        }
        if let obj = bindObj as? NSObject, keypath = bindPropertyName {
            obj.setValue(sender.on, forKeyPath: keypath)
        }
//        bindObj?.setBool(sender.on, forKey: bindPropertyName!)
    }
    
    func setData(
        propertyName: String,
        propertyValue: Bool,
        bindObj: AnyObject?,
        bindPropertyName: String,
        showArrow: Bool = false
        ) -> Self {
        staticLbl.text = propertyName
        switcher.on = propertyValue
        arrowIcon.hidden = !showArrow
        self.bindObj = bindObj
        self.bindPropertyName = bindPropertyName
        return self
    }
}
