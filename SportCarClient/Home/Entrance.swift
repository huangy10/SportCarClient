//
//  Entrance.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring
import Kingfisher
import SnapKit

class HomeController2: UIViewController, HomeDelegate {
    var hostUser: User {
        return MainManager.sharedManager.hostUser!
    }
    
    // MARK: controllers
    var person: PersonBasicController?
    var news: NewsController?
    var status: StatusHomeController?
    var message: MessageController?
    var act: ActivityHomeController?
    var radar: RadarHomeController?
    var settings: PersonMineSettings?
    var wrappedControllers: [Int: BlackBarNavigationController] = [:]
    // MARK: views
    
    var sideBar: UIView!
    var avatarBtn: UIButton!
    var nameLbl: UILabel!
    var sideBtns: [UIButton] = []
    var sepLine: UIView!
    var settingsBtn: UIButton!
    var marker: UIView!
    
    var invokeBtn: UIButton!
    var curControllerIndex: Int = 0
    
    private var initFrame: CGRect!
    private var hideFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSidebar()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        initFrame = CGRectMake(view.bounds.width, 0, view.bounds.width, view.bounds.height)
        hideFrame = CGRectMake(-view.bounds.width, 0, view.bounds.width, view.bounds.height)
    }

    func createSidebar() {
        let superview = self.view
        
        setInitContentController()
        
        invokeBtn = superview.addSubview(UIButton).config(self, selector: #selector(hideSidebar)).layout({ (make) in
            make.edges.equalTo(superview)
        }).config(UIColor(white: 0, alpha: 0.2))
        
        sideBar = superview.addSubview(UIView)
            .config(UIColor.RGB(23, 19, 19)).layout({ (make) in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.667)
            }).addShadow(offset: CGSizeMake(2, 0))
        
        avatarBtn = sideBar.addSubview(UIButton)
            .config(self, selector: #selector(sideBarBtnPressed(_:)))
            .toRoundButton(25)
            .layout({ (make) in
                make.left.equalTo(sideBar).offset(20)
                make.top.equalTo(superview).offset(50)
                make.size.equalTo(50)
            })
        avatarBtn.enabled = false
        avatarBtn.kf_setImageWithURL(hostUser.avatarURL!, forState: .Normal)
        
        nameLbl = sideBar.addSubview(UILabel)
            .config(20, fontWeight: UIFontWeightRegular, textColor: UIColor.whiteColor())
            .layout({ (make) in
                make.centerY.equalTo(avatarBtn)
                make.left.equalTo(avatarBtn.snp_right).offset(12)
            })
        nameLbl.text = hostUser.nickName
        
        var formerView: UIView! = avatarBtn
        let titles = [LS("发现"), LS("活动"), LS("资讯"), LS("动态"), LS("消息"), LS("我的")]
        let icons = ["side_discover", "side_act", "side_news", "side_status", "side_message", "side_mine"]
        var topOffset: CGFloat = 25
        for index in 0..<titles.count {
            let container = sideBar.addSubview(UIButton)
                .config(self, selector: #selector(sideBarBtnPressed(_:)))
                .layout({ (make) in
                make.left.equalTo(superview).offset(0)
                make.width.equalTo(sideBar)
                make.height.equalTo(50)
                make.top.equalTo(formerView.snp_bottom).offset(topOffset)
            })
            sideBtns.append(container)
            container.tag = index
            let icon = container.addSubview(UIImageView)
                .config(UIImage(named: icons[index]), contentMode: .ScaleAspectFit)
                .layout({ (make) in
                    make.centerY.equalTo(container)
                    make.left.equalTo(container).offset(20)
                    make.size.equalTo(17)
                })
            container.addSubview(UILabel)
                .config(17, fontWeight: UIFontWeightRegular, textColor: UIColor.whiteColor(), text: titles[index])
                .layout({ (make) in
                    make.centerY.equalTo(icon)
                    make.left.equalTo(icon.snp_right).offset(20)
                })
            formerView = container
            topOffset = 10
        }
        
        sepLine = sideBar.addSubview(UIView)
            .config(UIColor(white: 0.6, alpha: 1))
            .layout { (make) in
                make.left.equalTo(superview).offset(20)
                make.width.equalTo(sideBar).multipliedBy(0.6)
                make.height.equalTo(0.5)
                make.top.equalTo(formerView.snp_bottom).offset(20)
        }
        
        settingsBtn = sideBar.addSubview(UIButton)
            .config(self, selector: #selector(sideBarBtnPressed(_:)))
            .layout { (make) in
                make.left.equalTo(superview).offset(20)
                make.height.equalTo(50)
                make.width.equalTo(sideBar).dividedBy(2)
                make.top.equalTo(sepLine).offset(20)
        }
        settingsBtn.tag = 7
        
        settingsBtn.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0.72, alpha: 1), text: LS("设置"))
            .layout { (make) in
                make.centerY.equalTo(settingsBtn)
                make.left.equalTo(settingsBtn).offset(20)
        }
        
        
        marker = sideBar.addSubview(UIView).config(UIColor(white: 0.145, alpha: 1))
            .layout({ (make) in
                make.edges.equalTo(sideBtns[0])
            })
        sideBar.sendSubviewToBack(marker)
    }
    
    func sideBarBtnPressed(sender: UIButton) {
        switchController(curControllerIndex, to: sender.tag)
        curControllerIndex = sender.tag
    }
    
    func setInitContentController() {
        // set radar as the controller
        let target = getControllerForIndex(0)
        self.addChildViewController(target)
        self.view.insertSubview(target.view, atIndex: 0)
        target.view.frame = self.view.bounds
//        target.view.snp_makeConstraints { (make) in
//            make.edges.equalTo(self.view)
//        }
        target.didMoveToParentViewController(self)
    }
    
    // MARK: - Animation
    
    func hideSidebar() {
        let superview = self.view
        sideBar.snp_remakeConstraints { (make) in
            make.top.equalTo(superview)
            make.right.equalTo(superview.snp_left).offset(-10)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.667)
        }
        for btn in sideBtns {
            btn.snp_updateConstraints(closure: { (make) in
                make.left.equalTo(superview).offset(-self.view.bounds.width)
            })
        }
        sepLine.snp_updateConstraints { (make) in
            make.left.equalTo(superview).offset(-self.view.bounds.width)
        }
        settingsBtn.snp_updateConstraints { (make) in
            make.left.equalTo(superview).offset(-self.view.bounds.width)
        }
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
            
        }
        UIView.animateWithDuration(0.3, animations: { 
            self.view.layoutIfNeeded()
            self.invokeBtn.layer.opacity = 0
            }) { (_) in
                self.invokeBtn.hidden = true
        }
    }
    
    func showSidebar() {
        var temp: [UIView] = []
        temp.appendContentsOf(sideBtns as [UIView])
        temp.append(sepLine)
        temp.append(settingsBtn)
        let superview = view
        sideBar.snp_remakeConstraints { (make) in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.667)
        }
        invokeBtn.hidden = false
        UIView.animateWithDuration(0.3) {
            self.view.layoutIfNeeded()
            self.invokeBtn.layer.opacity = 1
        }
        var timeOffset: Int64 = 40
        for v in temp {
            let t = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_MSEC) * timeOffset)
            dispatch_after(t, dispatch_get_main_queue(), { 
        
//                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
//                    self.view.layoutIfNeeded()
//                    }, completion: nil)
                UIView.animateKeyframesWithDuration(0.5, delay: 0, options: .CalculationModeCubicPaced, animations: {
                        UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.1, animations: { 
                            v.snp_updateConstraints(closure: { (make) in
                                make.left.equalTo(superview).offset(-self.view.bounds.width * 0.9)
                            })
                            self.view.layoutIfNeeded()
                        })
                        UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.4, animations: {
                            v.snp_updateConstraints(closure: { (make) in
                                make.left.equalTo(superview).offset(v == self.sepLine! ? 20 : 0)
                            })
                            self.view.layoutIfNeeded()
                        })
                    }, completion: nil)
            })
            timeOffset += 40
        }
    }
    
    // MARK: - Home delegate
    
    func backToHome(onComplete: (() -> ())?) {
        invokeBtn.hidden = false
        showSidebar()
    }
    
    func switchController(from: Int, to: Int) {
        // Hide side bar anyway
        hideSidebar()
        if from == to {
            return
        }
        if to < sideBtns.count {
            marker.snp_remakeConstraints { (make) in
                make.edges.equalTo(sideBtns[to])
            }
        }
        let oldVC = getControllerForIndex(from)
        let newVC = getControllerForIndex(to)
        oldVC.willMoveToParentViewController(nil)
        addChildViewController(newVC)
        self.view.insertSubview(newVC.view, atIndex: 0)
        newVC.view.frame = self.view.bounds
        newVC.view.layer.opacity = 0
        
        UIView.animateWithDuration(0.25, animations: {
            newVC.view.layer.opacity = 1
            oldVC.view.layer.opacity = 0
            self.sideBar.layoutIfNeeded()
            }) { (_) in
                oldVC.view.removeFromSuperview()
                newVC.didMoveToParentViewController(self)
                oldVC.removeFromParentViewController()
                self.view.bringSubviewToFront(self.invokeBtn)
                self.view.bringSubviewToFront(self.sideBar)
        }
    }
    
    func getControllerForIndex(index: Int) -> BlackBarNavigationController {
        switch index {
        case 0:
            if radar == nil {
                radar = RadarHomeController()
                radar?.homeDelegate = self
                wrappedControllers[index] = radar!.toNavWrapper()
            }
        case 1:
            if act == nil {
                act = ActivityHomeController()
                act?.homeDelegate = self
                wrappedControllers[index] = act!.toNavWrapper()
            }
        case 2:
            if news == nil {
                news = NewsController(style: .Plain)
                news?.homeDelegate = self
                wrappedControllers[index] = news?.toNavWrapper()
            }
        case 3:
            if status == nil {
                status = StatusHomeController()
                status?.homeDelegate = self
                wrappedControllers[index] = status!.toNavWrapper()
            }
        case 4:
            ChatRecordDataSource.sharedDataSource.start()
            if message == nil {
                message = MessageController()
                message?.homeDelegate = self
                wrappedControllers[index] = message!.toNavWrapper()
            }
        case 5:
            if person == nil {
                person = PersonBasicController(user: MainManager.sharedManager.hostUser!)
                person?.isRoot = true
                person?.homeDelegate = self
                wrappedControllers[index] = person!.toNavWrapper()
            }
        default:
            if settings == nil {
                settings = PersonMineSettings()
                settings?.homeDelegate = self
                wrappedControllers[index] = settings!.toNavWrapper()
            }
        }
        return wrappedControllers[index]!
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
