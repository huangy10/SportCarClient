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

protocol HomeDelegate: class {
    func backToHome(_ onComplete: (()->())?)
    func switchController(_ from: Int, to: Int)
}

class HomeController2: UIViewController, HomeDelegate {
    var hostUser: User {
        return MainManager.sharedManager.hostUser!
    }
    
    // MARK: controllers
    var person: PersonController?
    var news: NewsController2?
    var billboard: BillboardController?
    var status: StatusHomeController?
    var message: MessageController?
    var act: ActivityHomeController?
    var radar: RadarHomeController?
    var wrappedControllers: [Int: BlackBarNavigationController] = [:]
    // MARK: views
    
    var sideBar: UIView!
    var avatarBtn: UIButton!
    var nameLbl: UILabel!
    var sideBtns: [UIButton] = []
    var sepLine: UIView!
    var adviceBtn: UIButton!
    var marker: UIView!
    var unreadLbl: UILabel!
    
    var invokeBtn: UIButton!
    var curControllerIndex: Int = 0
    
    fileprivate var initFrame: CGRect!
    fileprivate var hideFrame: CGRect!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSidebar()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        initFrame = CGRect(x: view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        hideFrame = CGRect(x: -view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUnreadNumberChange(_:)), name: NSNotification.Name(rawValue: kUnreadNumberDidChangeNotification), object: nil)
        
        setUnreadNum(MessageManager.defaultManager.unreadNum)
    }

    func createSidebar() {
        let superview = self.view!
        
        setInitContentController()
        
        invokeBtn = superview.addSubview(UIButton.self).config(self, selector: #selector(hideSidebar)).layout({ (make) in
            make.edges.equalTo(superview)
        }).config(UIColor(white: 0, alpha: 0.2))
        invokeBtn.layer.isHidden = true
        
        sideBar = superview.addSubview(UIView.self)
            .config(UIColor.RGB(23, 19, 19)).layout({ (make) in
                make.top.equalTo(superview)
                make.right.equalTo(superview.snp.left).offset(-10)
                make.bottom.equalTo(superview)
                make.width.equalTo(superview).multipliedBy(0.667)
            }).addShadow(offset: CGSize(width: 2, height: 0))
        
        avatarBtn = sideBar.addSubview(UIButton.self)
            .config(self, selector: #selector(avatarPressed))
            .toRoundButton(25)
            .layout({ (make) in
                make.left.equalTo(sideBar).offset(20)
                make.top.equalTo(superview).offset(50)
                make.size.equalTo(50)
            })
//        avatarBtn.enabled = false
        avatarBtn.kf.setImage(with: hostUser.avatarURL!, for: .normal)
        
        nameLbl = sideBar.addSubview(UILabel.self)
            .config(20, fontWeight: UIFontWeightRegular, textColor: UIColor.white)
            .layout({ (make) in
                make.centerY.equalTo(avatarBtn)
                make.left.equalTo(avatarBtn.snp.right).offset(12)
            })
        nameLbl.text = hostUser.nickName
        
        sideBar.addSubview(UIButton.self)
            .config(self, selector: #selector(avatarPressed))
            .layout({ (make) in
                make.bottom.equalTo(avatarBtn)
                make.left.equalTo(avatarBtn)
                make.top.equalTo(avatarBtn)
                make.right.equalTo(nameLbl)
            })
        
        var formerView: UIView! = avatarBtn
        let titles = [LS("雷达"), LS("活动"), LS("资讯"), LS("动态"), LS("消息"), LS("排行")]
        let icons = ["side_discover", "side_act", "side_news", "side_status", "side_message", "side_billboard"]
        var topOffset: CGFloat = 25
        for index in 0..<titles.count {
            let container = sideBar.addSubview(UIButton.self)
                .config(self, selector: #selector(sideBarBtnPressed(_:)))
                .layout({ (make) in
                make.left.equalTo(superview).offset(-self.view.bounds.width)
                make.width.equalTo(sideBar)
                make.height.equalTo(50)
                make.top.equalTo(formerView.snp.bottom).offset(topOffset)
            })
            sideBtns.append(container)
            container.tag = index
            let icon = container.addSubview(UIImageView.self)
                .config(UIImage(named: icons[index]), contentMode: .scaleAspectFit)
                .layout({ (make) in
                    make.centerY.equalTo(container)
                    make.left.equalTo(container).offset(20)
                    make.size.equalTo(17)
                })
            container.addSubview(UILabel.self)
                .config(17, fontWeight: UIFontWeightRegular, textColor: UIColor.white, text: titles[index])
                .layout({ (make) in
                    make.centerY.equalTo(icon)
                    make.left.equalTo(icon.snp.right).offset(20)
                })
            formerView = container
            topOffset = 10
        }
        
        sepLine = sideBar.addSubview(UIView.self)
            .config(UIColor(white: 0.38, alpha: 1))
            .layout { (make) in
                make.left.equalTo(superview).offset(-self.view.bounds.width)
                make.width.equalTo(sideBar).multipliedBy(0.6)
                make.height.equalTo(0.5)
                make.top.equalTo(formerView.snp.bottom).offset(20)
        }
        
        adviceBtn = sideBar.addSubview(UIButton.self)
            .config(self, selector: #selector(adviceBtnPressed))
            .layout { (make) in
                make.left.equalTo(superview).offset(-self.view.bounds.width)
                make.height.equalTo(50)
                make.width.equalTo(sideBar).dividedBy(2)
                make.top.equalTo(sepLine).offset(20)
        }
        adviceBtn.tag = 7
        
        adviceBtn.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0.38, alpha: 1), text: LS("意见反馈"))
            .layout { (make) in
                make.centerY.equalTo(adviceBtn)
                make.left.equalTo(adviceBtn).offset(20)
        }
        
        marker = sideBar.addSubview(UIView.self).config(UIColor(white: 0.145, alpha: 1))
            .layout({ (make) in
                make.edges.equalTo(sideBtns[0])
            })
        sideBar.sendSubview(toBack: marker)
        marker.addSubview(UIView.self).config(kHighlightRed)
            .addShadow(4, color: kHighlightRed, opacity: 0.4, offset: CGSize(width: 1, height: 0))
            .layout { (make) in
                make.left.equalTo(marker)
                make.top.equalTo(marker)
                make.bottom.equalTo(marker)
                make.width.equalTo(3)
        }
        
        unreadLbl = sideBar.addSubview(UILabel.self)
            .config(9, textColor: UIColor.white, textAlignment: .center)
            .config(kHighlightedRedTextColor)
            .layout({ (make) in
                let messageBtn = self.sideBtns[4]
                make.right.equalTo(messageBtn).offset(-50)
                make.centerY.equalTo(messageBtn)
                make.size.equalTo(18)
            })
        unreadLbl.layer.cornerRadius = 9
        unreadLbl.clipsToBounds = true
        unreadLbl.isHidden = true
    }
    
    func avatarPressed() {
//        sideBarBtnPressed(sideBtns.last!)
        switchController(curControllerIndex, to: 6)
        curControllerIndex = 6
    }
    
    func sideBarBtnPressed(_ sender: UIButton) {
        switchController(curControllerIndex, to: sender.tag)
        curControllerIndex = sender.tag
    }
    
    func setInitContentController() {
        // set radar as the controller
        let target = getControllerForIndex(0)
        self.addChildViewController(target)
        self.view.insertSubview(target.view, at: 0)
        target.view.frame = self.view.bounds
//        target.view.snp_makeConstraints { (make) in
//            make.edges.equalTo(self.view)
//        }
        target.didMove(toParentViewController: self)
    }
    
    // MARK: - Animation
    
    func hideSidebar() {
        let superview = self.view!
        sideBar.snp.remakeConstraints { (make) in
            make.top.equalTo(superview)
            make.right.equalTo(superview.snp.left).offset(-10)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.667)
        }
        for btn in sideBtns {
            btn.snp.updateConstraints({ (make) in
                make.left.equalTo(superview).offset(-self.view.bounds.width)
            })
        }
        sepLine.snp.updateConstraints { (make) in
            make.left.equalTo(superview).offset(-self.view.bounds.width)
        }
        adviceBtn.snp.updateConstraints { (make) in
            make.left.equalTo(superview).offset(-self.view.bounds.width)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            
        }) 
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.layoutIfNeeded()
            self.invokeBtn.layer.opacity = 0
            }, completion: { (_) in
                self.invokeBtn.isHidden = true
        }) 
    }
    
    func showSidebar() {
        
        avatarBtn.kf.setImage(with: hostUser.avatarURL!, for: .normal)
        nameLbl.text = hostUser.nickName
        
        var temp: [UIView] = []
        temp.append(contentsOf: sideBtns as [UIView])
        temp.append(sepLine)
        temp.append(adviceBtn)
        let superview = view!
        sideBar.snp.remakeConstraints { (make) in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.667)
        }
        invokeBtn.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.invokeBtn.layer.opacity = 1
        }) 
        var timeOffset: Int64 = 40
        for v in temp {
            let t = DispatchTime.now() + Double(Int64(NSEC_PER_MSEC) * timeOffset) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: t, execute: { 
        
//                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseOut, animations: {
//                    self.view.layoutIfNeeded()
//                    }, completion: nil)
                UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .calculationModeCubicPaced, animations: {
                        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1, animations: { 
                            v.snp.updateConstraints({ (make) in
                                make.left.equalTo(superview).offset(-self.view.bounds.width * 0.9)
                            })
                            self.view.layoutIfNeeded()
                        })
                        UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4, animations: {
                            v.snp.updateConstraints({ (make) in
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
    
    func backToHome(_ onComplete: (() -> ())?) {
        invokeBtn.isHidden = false
        showSidebar()
    }
    
    func adviceBtnPressed() {
        let detail = SuggestionController(parent: self)
        present(detail, animated: false, completion: nil)
    }
    
    func switchController(_ from: Int, to: Int) {
        // Hide side bar anyway
        hideSidebar()
        if from == to {
            return
        }
        if to < sideBtns.count {
            marker.snp.remakeConstraints { (make) in
                make.edges.equalTo(sideBtns[to])
            }
        }
        let oldVC = getControllerForIndex(from)
        let newVC = getControllerForIndex(to)
        oldVC.willMove(toParentViewController: nil)
        addChildViewController(newVC)
        self.view.insertSubview(newVC.view, at: 0)
        newVC.view.frame = self.view.bounds
        newVC.view.layer.opacity = 0
        
        UIView.animate(withDuration: 0.25, animations: {
            newVC.view.layer.opacity = 1
            oldVC.view.layer.opacity = 0
            self.sideBar.layoutIfNeeded()
            }, completion: { (_) in
                oldVC.view.removeFromSuperview()
                newVC.didMove(toParentViewController: self)
                oldVC.removeFromParentViewController()
                self.view.bringSubview(toFront: self.invokeBtn)
                self.view.bringSubview(toFront: self.sideBar)
        }) 
    }
    
    func getControllerForIndex(_ index: Int) -> BlackBarNavigationController {
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
                news = NewsController2(style: .plain)
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
            if message == nil {
                message = MessageController()
                message?.homeDelegate = self
                wrappedControllers[index] = message!.toNavWrapper()
            }
        case 5:
            if billboard == nil {
                billboard = BillboardController()
                billboard?.homeDelegate = self
                wrappedControllers[index] = billboard?.toNavWrapper()
        }
        case 6:
            if person == nil {
//                person = PersonBasicController(user: MainManager.sharedManager.hostUser!)
//                person?.isRoot = true
//                person?.homeDelegate = self
                person = PersonController(user: MainManager.sharedManager.hostUser!)
                person?.homeDelegate = self
                wrappedControllers[index] = person!.toNavWrapper()
            }
        default:
            break
        }
        return wrappedControllers[index]!
    }

    
    // MARK: - Unread number display
    
    func onUnreadNumberChange(_ notification: Notification) {
        DispatchQueue.main.async { 
            self.setUnreadNum(MessageManager.defaultManager.unreadNum)
        }
    }
    
    func setUnreadNum(_ num: Int) {
        if num == 0 {
            unreadLbl.isHidden = true
        } else {
            unreadLbl.text = "\(num)"
            unreadLbl.isHidden = false
        }
    }
}
