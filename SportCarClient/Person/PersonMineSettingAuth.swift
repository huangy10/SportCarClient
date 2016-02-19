//
//  PersonMineSettingAuth.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class PersonMineSettingsAuthController: AuthThreeImagesController {
    
    override func titleForRightNavBtn() -> String {
        return LS("提交")
    }
    
    override func navTitle() -> String {
        return LS("企业认证")
    }
    
    override func navRightBtnPressed() {
        
        //
        var uploadImages: [UIImage] = []
        for x in selectedImages {
            // 如果三张图片没有选全，则放弃之
            if x == nil {
                self.displayAlertController(LS("错误"), message: LS("请完整提供要求的信息"))
                return
            }
            uploadImages.append(x!)
        }
        let requester = PersonRequester.requester
        requester.postCorporationUserApplication(uploadImages, onSuccess: { (data) -> () in
            print("down")
            }) { (code) -> () in
                print(code)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func getStaticLabelContentForIndex(index: Int) -> String {
        return [LS("上传营业执照"), LS("上传身份证"), LS("上传补充材料")][index]
    }
    
    override func createPrivilegeBoard() -> UIView {
        let container = UIView()
        let image1 = UIImageView(image: UIImage(named: "privilege_show_avatar_logo"))
        container.addSubview(image1)
        image1.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(container)
            make.top.equalTo(container).offset(22)
            make.size.equalTo(37)
        }
        let static1 = UILabel()
        static1.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        static1.textColor = UIColor.blackColor()
        static1.textAlignment = .Center
        static1.text = LS("头像旁企业标志")
        container.addSubview(static1)
        static1.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(image1)
            make.top.equalTo(image1.snp_bottom).offset(11)
        }
        //
        let image2 = UIImageView(image: UIImage(named: "privilege_show_on_map"))
        container.addSubview(image2)
        image2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(image1.snp_left).offset(-78.5)
            make.top.equalTo(container).offset(22)
            make.size.equalTo(37)
        }
        let static2 = UILabel()
        static2.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        static2.textColor = UIColor.blackColor()
        static2.textAlignment = .Center
        static2.text = LS("在雷达上显示")
        container.addSubview(static2)
        static2.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(image2)
            make.top.equalTo(image2.snp_bottom).offset(11)
        }
        //
        let image3 = UIImageView(image: UIImage(named: "privilege_allow_start_activity"))
        container.addSubview(image3)
        image3.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(image1.snp_right).offset(78.5)
            make.top.equalTo(container).offset(22)
            make.size.equalTo(37)
        }
        let static3 = UILabel()
        static3.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        static3.textColor = UIColor.blackColor()
        static3.textAlignment = .Center
        static3.text = LS("允许发布活动")
        container.addSubview(static3)
        static3.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(image3)
            make.top.equalTo(image3.snp_bottom).offset(11)
        }
        return container
    }
    
    override func getHeightForPrivilegeBoard() -> CGFloat {
        return 103
    }
    
    let descriptionText = "1. 头像应为企业商标/标识或品牌Logo\n2.昵称应为企业/品牌的全称或无歧义简称；若昵称为代理品牌，需体现代理区域n.昵称不能仅包含一个通用性描述词语，且不可使用过度修饰性词语\n4.企业提供完成有效年检的《企业法人营业执照》/《个体工商户营业执照》等资料\n5.微博昵称与营业执照登记名称不一致需提供相关补充材料，如《商标注册证》、《代理授权书》等"
    
    override func createDescriptionLabel() -> UIView {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textColor = UIColor(white: 0.72, alpha: 1)
        lbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        lbl.text = descriptionText
        return lbl
    }
    
    override func getHeightForDescriptionLable() -> CGFloat {
        let width = UIScreen.mainScreen().bounds.width - 30
        return descriptionText.boundingRectWithSize(CGSizeMake(width, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)], context: nil).size.height
    }
}
