//
//  File.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Spring
import AlecrimCoreData
/**
 *  HomeController来实现
 */
protocol HomeDelegate {
    
    /**
     返回到边栏
     
     - parameter onComplete: 完成后将会执行这一个closure
     */
    func backToHome(onComplete: (()->())?)
    
    /**
     切换各个功能模块
     
     - parameter from: 当前的功能模块
     - parameter to:   目标功能模块
     */
    func switchController(from: Int, to: Int)
}

class HomeController: UIViewController, HomeDelegate {
    //
    /// homeController的用户资料
    var hostUser: User?
    
    /// 边栏按钮集群的问题
    var sideBarCtl: SideBarController
    let board: UIView
    //
    var person: PersonBasicController?
    var news: NewsController?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        sideBarCtl = SideBarController()
        board = UIView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSubviews()
        
        let requester = AccountRequester.sharedRequester
        requester.getProfileDataFor(self.hostUser!.userID!, onSuccess: { (data) -> () in
            // 获取到了数据之后更新
            guard data != nil else{
                print("Duang!")
                return
            }
            // 将获取到的数据设置给hostUser
            self.hostUser?.loadValueFromJSON(data!, forceUpdateNil: true)
            // 令侧边栏更新数据
            self.reloadData()
            }) { (code) -> ()? in
                print("\(code)")
        }
    }
    
    func createSubviews() {
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        let superview = self.view
        superview.backgroundColor = UIColor.greenColor()
        // 
        superview.addSubview(self.sideBarCtl.view)
        sideBarCtl.delegate = self
        // 
        board.backgroundColor = UIColor.whiteColor()
        superview.addSubview(board)
        self.board.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        board.frame = superview.bounds
        self.showSideBar(false)
        
        let testBtn = UIButton()
        board.addSubview(testBtn)
        testBtn.frame = board.bounds
        testBtn.addTarget(self, action: "testBtn", forControlEvents: .TouchUpInside)
        //
    }
    
    func testBtn() {
        self.backToHome(nil)
    }
}

// MARK: - 空间显示数据管理
extension HomeController {
    
    /**
     重新载入hostuser的数据
     */
    func reloadData() {
        self.sideBarCtl.reloadUserData()
    }
}

// MARK: - 这个extension主要是控制功能模块的载入动画及其逆动画
extension HomeController {
    
    /**
     显示边栏
     */
    func showSideBar(animated:Bool) {
        let screenWidth = self.view.frame.width
        if !animated {
            var move = CATransform3DTranslate(CATransform3DIdentity, 0.876 * screenWidth, 0, 0)
            move.m34 = 1.0 / -500
            var scale = CATransform3DScale(move, 0.8, 0.8, 1)
            scale.m34 = 1.0 / -500
            var trans = CATransform3DRotate(scale, -3.14/9.0, 0, 1, 0)
            trans.m34 = 1.0 / -500.0
            self.board.layer.transform = trans
            return
        }
        SpringAnimation.spring(0.5) { () -> Void in
            // 绕Y轴旋转-20度
            var move = CATransform3DTranslate(CATransform3DIdentity, 0.876 * screenWidth, 0, 0)
            move.m34 = 1.0 / -500
            var scale = CATransform3DScale(move, 0.8, 0.8, 1)
            scale.m34 = 1.0 / -500
            var trans = CATransform3DRotate(scale, -3.14/9.0, 0, 1, 0)
            trans.m34 = 1.0 / -500.0
            self.board.layer.transform = trans
        }
    }
    
    /**
    */
    func hideSideBar() {
        SpringAnimation.springWithCompletion(0.5, animations: { () -> Void in
            let screenWidth = self.view.frame.width
            var move = CATransform3DTranslate(CATransform3DIdentity, 0 * screenWidth, 0, 0)
            move.m34 = 1.0 / -500
            var scale = CATransform3DScale(move, 1, 1, 1)
            scale.m34 = 1.0 / -500
            var trans = CATransform3DRotate(scale, -0.06, 0, 1, 0)
            trans.m34 = 1.0 / -500.0
            self.board.layer.transform = trans
            }) { (finished) -> Void in
                self.board.layer.transform = CATransform3DIdentity
        }
    }
}

// MARK: - Sidebar的代理
extension HomeController {
    
    func backToHome(onComplete: (()->())?) {
        showSideBar(true)
    }
    
    func switchController(from: Int, to: Int) {
        switch to {
        case 0:
            if person == nil {
                person = PersonBasicController(user: User.objects.hostUser!)
            }
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.pushViewController(person!, animated: true)
//            self.board.addSubview(person!.view!)
        case 1:
            news = NewsController(style: .Plain)
            self.navigationController?.pushViewController(news!, animated: true)
            break
        case 2:
//            if status == nil {
//                status = StatusHomeController()
//            }
//            self.navigationController?.pushViewController(status!, animated: true)
            let test = StatusHomeController()
            self.navigationController?.pushViewController(test, animated: true)
            break
        case 5:
            ChatRecordDataSource.sharedDataSource.start()
//            let messages = MessageController()
            let messages = PrivateChatSettingController(targetUser: User.objects.hostUser!)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            self.navigationController?.pushViewController(messages, animated: true)
            break
        default:
            break
        }
        // hideSideBar()
    }

}