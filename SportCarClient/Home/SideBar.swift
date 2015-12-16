//
//  SideBar.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

enum SideBarBtn {
    case News(UIButton)
    case Status(UIButton)
    case Radar(UIButton)
    case Activity(UIButton)
    case Message(UIButton)
    case Search(UIButton)
}

class SideBarController: UIViewController {
    var bgImg: UIImageView?
    var avatarBtn: LoadingButton?
    var nameLbl: UILabel?
    var carIcon: UIImageView?
    var carNameLbl: UILabel?
    /// 当前被选中的子模块代表的按钮，nil时代表个人中心被选中
    var selectedBtn: SideBarBtn?
    /// 所有边栏按钮的集合
    var btnArray: [SideBarBtn]?
    
    var delegate: HomeDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createSubviews() {
        let superview = self.view
        //
        bgImg = UIImageView()
        superview.addSubview(bgImg!)
        bgImg?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(superview)
            make.width.equalTo(superview)
            make.height.equalTo(superview).multipliedBy(1.4)
        })
        //
        avatarBtn = LoadingButton(size: CGSize(width: 125, height: 125))
        superview.addSubview(avatarBtn!)
    }

}