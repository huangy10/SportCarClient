//
//  SportCarAuth.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class SportCarAuthController: PersonMineSettingsAuthController {
    
    var district: UITextField!
    var carNumber: UITextField!
    
    override func navTitle() -> String {
        return "跑车认证"
    }
    
    override func navRightBtnPressed() {
        
    }
    
    override func getStaticLabelContentForIndex(index: Int) -> String {
        return [LS("上传驾驶证"), LS("上传身份证"), LS("上传带牌照的人车合影")][index]
    }
    
    override func createDescriptionLabel() -> UIView {
        let container = UIView()
        //
        let staticLabel1 = UILabel()
        staticLabel1.text = LS("车牌地区")
        staticLabel1.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticLabel1.textColor = UIColor(white: 0.72, alpha: 1)
        container.addSubview(staticLabel1)
        staticLabel1.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(container)
            make.top.equalTo(container)
        }
        //
        district = UITextField()
        
        return container
    }
    
    override func getHeightForDescriptionLable() -> CGFloat {
            return 85
    }
}
