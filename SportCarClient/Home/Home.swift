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
import Kingfisher
/**
 *  HomeController来实现
 */
protocol HomeDelegate: class {
    
    /**
     返回到边栏
     
     - parameter onComplete: 完成后将会执行这一个closure
     */
    func backToHome(onComplete: (()->())?, screenShot: UIImage)
    
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
    let board: UIButton!
    //
    var person: PersonBasicController?
    var news: NewsController?
    var status: StatusHomeController?
    var message: MessageController?
    var act: ActivityHomeController?
    var radar: RadarHomeController?
    //
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        sideBarCtl = SideBarController()
        board = UIButton()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("deinit home controller")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createSubviews()
        
//        radar = RadarHomeController()
//        radar?.homeDelegate = self
//        self.navigationController?.pushViewController(radar!, animated: false)
        
        ChatRecordDataSource.sharedDataSource.start()
        
        let requester = AccountRequester.sharedRequester
        requester.getProfileDataFor(self.hostUser!.userID!, onSuccess: { (data) -> () in
            // 获取到了数据之后更新
            guard data != nil else{
                return
            }
            // 将获取到的数据设置给hostUser
            self.hostUser?.loadFromJSON(data!, ctx: nil, basic: false)
            User.objects.saveAll()
            // 令侧边栏更新数据
            self.reloadData()
            }) { (code) -> ()? in
                print("\(code)")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // 更新页面数据
        self.sideBarCtl.reloadUserData()
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
        board.addTarget(self, action: "boardPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(board)
        board.tag = 1
        self.board.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
        board.frame = superview.bounds
        self.showSideBar(false)
    }
    
    func boardPressed() {
        switchController(0, to: board.tag)
    }
}

// MARK: - 空间显示数据管理
extension HomeController {
    
    /**
     重新载入hostuser的数据
     */
    func reloadData() {
        sideBarCtl.reloadUserData()
    }
}

// MARK: - 这个extension主要是控制功能模块的载入动画及其逆动画
extension HomeController {
    
    /**
     显示边栏
     */
    func showSideBar(animated:Bool) {
        
        sideBarCtl.reloadUserData()
        let screenWidth = view.frame.width
        var move = CATransform3DTranslate(CATransform3DIdentity, 0.876 * screenWidth, 0, 0)
        move.m34 = 1.0 / -500
        var scale = CATransform3DScale(move, 0.8, 0.8, 1)
        scale.m34 = 1.0 / -500
        var trans = CATransform3DRotate(scale, -3.14/9.0, 0, 1, 0)
        trans.m34 = 1.0 / -500.0
        if !animated {
            board.layer.transform = trans
            return
        }
        SpringAnimation.spring(0.5) { () -> Void in
            // 绕Y轴旋转-20度
            self.board.layer.transform = trans
        }
        sideBarCtl.animateBG()
    }
    
    /**
    */
    func hideSideBar(animated: Bool = false) {
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
    
    func backToHome(onComplete: (()->())?, screenShot: UIImage) {
        board.layer.transform = CATransform3DIdentity
        board.setImage(screenShot, forState: .Normal)
        self.navigationController?.popViewControllerAnimated(false)
        radar = nil
        showSideBar(true)
    }
    
    func switchController(from: Int, to: Int) {
        board.tag = to
        switch to {
        case 0:
            if person == nil {
                person = PersonBasicController(user: User.objects.hostUser()!)
                person?.homeDelegate = self
            }
            self.navigationController?.pushViewController(person!, animated: true)
        case 1:
            if radar == nil {
                radar = RadarHomeController()
                radar?.homeDelegate = self
            }
            self.navigationController?.pushViewController(radar!, animated: true)
            break
        case 2:
            if act == nil {
                act = ActivityHomeController()
                act?.homeDelegate = self
            }
            
            self.navigationController?.pushViewController(act!, animated: true)
            break
        case 3:
            if news == nil {
                news = NewsController(style: .Plain)
                news?.homeDelegate = self
            }
            self.navigationController?.pushViewController(news!, animated: true)
            break
        case 4:
            if status == nil {
                status = StatusHomeController()
                status?.homeDelegate = self
            }
            self.navigationController?.pushViewController(status!, animated: true)
            break
        case 5:
            ChatRecordDataSource.sharedDataSource.start()
            if message == nil {
                message = MessageController()
                message?.homeDelegate = self
            }
            self.navigationController?.pushViewController(message!, animated: true)
            break
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        if board.tag != 3 {
            radar = nil
        }
        let cache = KingfisherManager.sharedManager.cache
        cache.clearMemoryCache()
        print("clear cache")
    }
}