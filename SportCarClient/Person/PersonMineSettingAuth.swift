//
//  PersonMineSettingAuth.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class PersonMineSettingsAuthController: AuthThreeImagesController, ProgressProtocol {
    
    var pp_progressView: UIProgressView?
    
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
            guard x != nil else {
                showToast(LS("请完整提供要求的信息"))
                return
            }
            uploadImages.append(x!)
        }
        pp_showProgressView()
        AccountRequester2.sharedInstance.postCorporationUserApplication(uploadImages, onSuccess: { (data) -> () in
            self.pp_hideProgressView()
            self.showToast(LS("认证请求已发送"))
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
            }) { (code) -> () in
                self.pp_hideProgressView()
                self.showToast(LS("认证请求发送失败"))
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func getStaticLabelContentForIndex(_ index: Int) -> String {
        return [LS("上传营业执照"), LS("上传身份证"), LS("上传补充材料")][index]
    }
    
    override func createPrivilegeBoard() -> UIView {
        let container = UIView()
        let image1 = container.addSubview(UIImageView.self).config(UIImage(named: "privilege_show_avatar_logo"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.centerX.equalTo(container)
                make.top.equalTo(container).offset(22)
                make.size.equalTo(37)
        }
        container.addSubview(UILabel.self)
            .config(12, textAlignment: .center, text: LS("头像旁企业标志"))
            .layout { (make) in
                make.centerX.equalTo(image1)
                make.top.equalTo(image1.snp.bottom).offset(11)
        }
        let image2 = container.addSubview(UIImageView.self)
            .config(UIImage(named: "privilege_show_on_map"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.right.equalTo(image1.snp.left).offset(-78.5)
                make.top.equalTo(container).offset(22)
                make.size.equalTo(37)
        }
        container.addSubview(UILabel.self)
            .config(12, textAlignment: .center, text: LS("在雷达上显示"))
            .layout { (make) in
                make.centerX.equalTo(image2)
                make.top.equalTo(image2.snp.bottom).offset(11)
        }
        //
        let image3 = container.addSubview(UIImageView.self)
            .config(UIImage(named: "privilege_allow_start_activity"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.left.equalTo(image1.snp.right).offset(78.5)
                make.top.equalTo(container).offset(22)
                make.size.equalTo(37)
        }
        container.addSubview(UILabel.self)
            .config(12, textAlignment: .center, text: LS("允许发布活动"))
            .layout { (make) in
                make.centerX.equalTo(image3)
                make.top.equalTo(image3.snp.bottom).offset(11)
        }
        return container
    }
    
    override func getHeightForPrivilegeBoard() -> CGFloat {
        return 103
    }
    
    let descriptionText = "1. 头像应为企业商标/标识或品牌Logo\n2.昵称应为企业/品牌的全称或无歧义简称；若昵称为代理品牌，需体现代理区域n.昵称不能仅包含一个通用性描述词语，且不可使用过度修饰性词语\n4.企业提供完成有效年检的《企业法人营业执照》/《个体工商户营业执照》等资料\n5.微博昵称与营业执照登记名称不一致需提供相关补充材料，如《商标注册证》、《代理授权书》等"
    
    override func createDescriptionLabel() -> UIView {
        let label = UILabel()
        label.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        let attrText = NSAttributedString(string: descriptionText, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: kTextGray54])
        label.attributedText = attrText
        return label
//        return UILabel().config(14, textColor: kTextGray28, text: descriptionText, multiLine: true)
    }
    
    override func getHeightForDescriptionLable() -> CGFloat {
        let width = UIScreen.main.bounds.width - 30
        return descriptionText.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)], context: nil).size.height
    }
}
