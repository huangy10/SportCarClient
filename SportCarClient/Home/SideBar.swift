//
//  SideBar.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Dollar
import Spring

class SideBarController: UIViewController {
    var bgImg: UIImageView?
    var avatarBtn: LoadingButton?
    var nameLbl: UILabel?
    var carIcon: UIImageView?
    var carNameLbl: UILabel?
    /// 当前被选中的子模块代表的按钮，nil时代表个人中心被选中
    var selectedBtn: UIButton?
    /// 所有边栏按钮的集合
    var btnArray = [UIButton]()
    /// 红色的确定被选中按钮的marker
    var btnMarker: UIImageView?
    
    var unreadMessagesLbl: UILabel!
    var unreadMessagesIcon: UIImageView!
    
    weak var delegate: HomeDelegate?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadUserData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SideBarController.unreadMessageNumDidChange), name: kUnreadNumberDidChangeNotification, object: nil)
    }
    
    func createSubviews() {
        createSubviewsHigherResolution()
    } 
    
    func createSubviewsHigherResolution() {
        let superview = self.view
        guard let host = MainManager.sharedManager.hostUser else{
            assertionFailure()
            return
        }
        //
        bgImg = UIImageView(image: UIImage(named: "home_bg"))
        superview.addSubview(bgImg!)
        bgImg?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.height.equalTo(superview)
            make.width.equalTo(bgImg!.snp_height).multipliedBy(0.75)
        })
        // 头像
        avatarBtn = LoadingButton(size: CGSize(width: 125, height: 125))
        avatarBtn?.layer.cornerRadius = 62.5
        avatarBtn?.clipsToBounds = true
        avatarBtn?.loadImageFromURL(host.avatarURL!, placeholderImage: UIImage(named: "account_profile_avatar_btn"))
        avatarBtn?.tag = 0
        superview.addSubview(avatarBtn!)
        let screenWidth = superview.frame.width
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(CGSize(width: 125, height: 125))
            make.centerX.equalTo(superview.snp_left).offset(screenWidth * 0.45)
            make.top.equalTo(superview).offset(40)
        })
        avatarBtn?.addTarget(self, action: #selector(SideBarController.sideBtnPressed(_:)), forControlEvents: .TouchUpInside)
        // 姓名
        nameLbl = UILabel()
        nameLbl?.font = UIFont.systemFontOfSize(24)
        nameLbl?.textColor = UIColor.whiteColor()
        nameLbl?.textAlignment = .Center
        nameLbl?.text = host.nickName ?? LS("正在获取数据")
        superview.addSubview(nameLbl!)
        nameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(avatarBtn!)
            make.top.equalTo(avatarBtn!.snp_bottom).offset(11)
            make.width.equalTo(superview).multipliedBy(0.8)
            make.height.equalTo(33)
        })
        if let car = host.avatarCarModel {
            carNameLbl = UILabel()
            carNameLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
            carNameLbl?.textColor = UIColor(white: 0.72, alpha: 1)
            carNameLbl?.text = car.name
            superview.addSubview(carNameLbl!)
            let size = carNameLbl?.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max))
            carNameLbl?.translatesAutoresizingMaskIntoConstraints = true
            carNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(avatarBtn!.snp_centerX).offset((25 - size!.width) / 2)
                make.top.equalTo(nameLbl!.snp_bottom).offset(10)
            })
            
            carIcon = UIImageView()
            carIcon?.layer.cornerRadius = 10.5
            carIcon?.clipsToBounds = true
            carIcon?.kf_setImageWithURL(car.logoURL!)
            superview.addSubview(carIcon!)
            carIcon?.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(carNameLbl!.snp_left).offset(-5)
                make.centerY.equalTo(carNameLbl!)
                make.size.equalTo(CGSize(width: 21, height: 21))
            })
        }
        // 创建左侧的一列按钮
        let titles = $.each(["雷达", "活动", "资讯", "动态", "消息"]) { (value) -> () in
            return LS(value)
        }
        var preView: UIView = nameLbl!
        for i in 0..<5 {
            let btn = UIButton()
            btn.setTitle(titles[i], forState: .Normal)
            btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            btn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
            btn.contentHorizontalAlignment = .Left
            btn.addTarget(self, action: #selector(SideBarController.sideBtnPressed(_:)), forControlEvents: .TouchUpInside)
            btn.tag = i + 1
            btnArray.append(btn)
            superview.addSubview(btn)
            btn.snp_makeConstraints(closure: { (make) -> Void in
                make.centerY.equalTo(preView).offset({ ()-> Int in
                    if i == 0 {
                        // 第一个页面
                        return 80
                    }
                    return 64
                    }())
                make.width.equalTo(superview)
                make.left.equalTo(superview)
                make.height.equalTo(44)
            })
            btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 83, bottom: 0, right: 0)
            
            preView = btn
        }
        
        // 创建未读消息数量
        unreadMessagesLbl = UILabel()
        unreadMessagesLbl.textColor = UIColor.whiteColor()
        unreadMessagesLbl.backgroundColor = kHighlightedRedTextColor
        unreadMessagesLbl.font = UIFont.systemFontOfSize(9, weight: UIFontWeightUltraLight)
        unreadMessagesLbl.layer.cornerRadius = 9
        unreadMessagesLbl.clipsToBounds = true
        unreadMessagesLbl.textAlignment = .Center
        superview.addSubview(unreadMessagesLbl)
        unreadMessagesLbl.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(btnArray[4])
            make.left.equalTo(superview).offset(125)
            make.size.equalTo(18)
        }
        
        let radarBtn = btnArray[0]
        let marker = UIImage(named: "home_slct_marker")
        btnMarker = UIImageView(image: marker)
        superview.addSubview(btnMarker!)
        btnMarker?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(CGSize(width: 243, height: 36))
            make.centerY.equalTo(radarBtn)
            make.left.equalTo(superview).offset(34)
        })
        superview.sendSubviewToBack(btnMarker!)
        superview.sendSubviewToBack(bgImg!)
        
        self.selectedBtn = radarBtn
    }
    
    func animateBG() {
        bgImg?.layer.removeAllAnimations()
        let superview = self.view
        bgImg?.snp_remakeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.height.equalTo(superview)
            make.width.equalTo(bgImg!.snp_height).multipliedBy(0.75)
        })
        superview.updateConstraints()
        superview.layoutIfNeeded()
        bgImg?.snp_remakeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.height.equalTo(superview)
            make.width.equalTo(bgImg!.snp_height).multipliedBy(0.75)
        })
        UIView.animateWithDuration(10) { () -> Void in
            superview.layoutIfNeeded()
        }
    }
}

// MARK: - 数据设置
extension SideBarController {
    /**
     从输入的user数据中载入数据，设置到对应的控件之中
     */
    func reloadUserData() {
        // 获取当前用户
        guard let user = MainManager.sharedManager.hostUser else{
            // 如果没有当前登录用户，直接退出
            return
        }
        avatarBtn?.loadImageFromURL(user.avatarURL!, placeholderImage: avatarBtn?.imageView?.image)
        nameLbl?.text = user.nickName ?? LS("离线用户")
        if let car = user.avatarCarModel {
            carNameLbl?.text = car.name
            let size = carNameLbl?.sizeThatFits(CGSizeMake(CGFloat.max, CGFloat.max))
            carNameLbl?.translatesAutoresizingMaskIntoConstraints = true
            carNameLbl?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(avatarBtn!.snp_centerX).offset((25 - size!.width) / 2)
                make.top.equalTo(nameLbl!.snp_bottom).offset(10)
            })

            carIcon?.kf_setImageWithURL(car.logoURL!)
            carIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.right.equalTo(carNameLbl!.snp_left).offset(-5)
                make.centerY.equalTo(carNameLbl!)
                make.size.equalTo(CGSize(width: 21, height: 21))
            })

            
        }
        let unreadNum = MessageManager.defaultManager.unreadNum
        if unreadNum > 0 {
            unreadMessagesLbl.hidden = false
            unreadMessagesLbl.text = "\(unreadNum)"
        }else {
            unreadMessagesLbl.hidden = true
        }
    }
    
    func unreadMessageNumDidChange() {
        let unreadNum = MessageManager.defaultManager.unreadNum
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if unreadNum > 0 {
                self.unreadMessagesLbl.hidden = false
                self.unreadMessagesLbl.text = "\(unreadNum)"
            }else {
                self.unreadMessagesLbl.hidden = true
            }   
        }
    }
}

// MARK: - 这个extension解决边栏按钮的响应处理
extension SideBarController {
    func sideBtnPressed(sender: UIButton) {
        delegate?.switchController(selectedBtn!.tag, to: sender.tag)
        if selectedBtn!.tag != sender.tag && sender.tag != 0 {
            switchBtnMarker(sender)
        }
        selectedBtn = sender
    }
    
    func switchBtnMarker(nextBtn: UIButton, animated: Bool=true) {
        btnMarker?.snp_remakeConstraints(closure: { (make) -> Void in
            make.size.equalTo(CGSize(width: 243, height: 36))
            make.centerY.equalTo(selectedBtn!)
            make.left.equalTo(self.view.snp_right)
        })
        SpringAnimation.springWithCompletion(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                self.view.updateConstraints()
                self.btnMarker?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.size.equalTo(CGSize(width: 243, height: 36))
                    make.centerY.equalTo(nextBtn)
                    make.left.equalTo(self.view.snp_right)
                })
                self.view.layoutIfNeeded()
                self.btnMarker?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.size.equalTo(CGSize(width: 243, height: 36))
                    make.centerY.equalTo(nextBtn)
                    make.left.equalTo(self.view).offset(34)
                })
                SpringAnimation.spring(0.5, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
        }
    }
}

// MARK: - 这个extension处理动画的问题
extension SideBarController {
    
}