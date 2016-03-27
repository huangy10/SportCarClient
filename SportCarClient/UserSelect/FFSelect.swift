//
//  FFSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar

let kMaxSelectUserNum = 9

enum FFSelectState {
    case Fans
    case Follow
}

protocol FFSelectDelegate: class {
    
    func userSelected(users: [User])
    
    func userSelectCancelled()
    
}


/// Selector for fans and follows
class FFSelectController: UserSelectController {
    
    weak var delegate: FFSelectDelegate?
    
    let targetUser: User = MainManager.sharedManager.hostUser!
    
    var fans: [User] = []
    var follows: [User] = []
    
    override var users: [User] {
        get {
            switch navTitlestate{
            case .Fans:
                return fans
            case .Follow:
                return follows
            }
        }
    }
    
    var fansDateThreshold: NSDate?
    var followDateThreshold: NSDate?
    var navTitlestate: FFSelectState = .Fans
    
    var maxSelectUserNum: Int
    
    var titleFansBtn: UIButton?
    var titleFollowBtn: UIButton?
    var titleBtnIcon: UIImageView?
    var navRightBtn: UIButton?
    
    convenience init(maxSelectNum: Int, preSelectedUsers: [User] = []) {
        self.init(nibName: nil, bundle: nil)
        maxSelectUserNum = maxSelectNum
        selectedUsers.appendContentsOf(preSelectedUsers)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        maxSelectUserNum = kMaxSelectUserNum
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
    }
    
    /**
     重新布置一下title的显示
     这里面的titleView的构建方式和LoginRegisterController里面是类似的
     */
    override func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let barHeight = self.navigationController!.navigationBar.frame.size.height
        let screenWidth = UIScreen.mainScreen().bounds.width
        let containerWidth = screenWidth * 0.5
        let container = UIView(frame: CGRectMake(0, 0, containerWidth, barHeight))
        // 创建粉丝按钮
        titleFansBtn = UIButton()
        titleFansBtn?.tag = 0
        titleFansBtn?.setTitleColor(kBarBgColor, forState: .Normal)
        titleFansBtn?.setTitle(LS("粉丝"), forState: .Normal)
        titleFansBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleFansBtn!)
        titleFansBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp_centerX).offset(-9)
        })
        titleFansBtn?.addTarget(self, action: "titleBtnPressed:", forControlEvents: .TouchUpInside)
        // 创建关注按钮
        titleFollowBtn = UIButton()
        titleFollowBtn?.tag = 1
        titleFollowBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleFollowBtn?.setTitle(LS("关注"), forState: .Normal)
        titleFollowBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleFollowBtn!)
        titleFollowBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp_centerX).offset(9)
        })
        titleFollowBtn?.addTarget(self, action: "titleBtnPressed:", forControlEvents: .TouchUpInside)
        // 创建可以平移的白色按钮形状
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon!)
        container.sendSubviewToBack(titleBtnIcon!)
        titleBtnIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(titleFansBtn!)
        })
        self.navigationItem.titleView = container
        
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: "navLeftBtnPressed")
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem

        
        navRightBtn = UIButton()
        navRightBtn?.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        navRightBtn?.setTitle(LS("确定") + "(\(selectedUsers.count)/\(maxSelectUserNum))", forState: .Normal)
        navRightBtn?.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        navRightBtn?.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        navRightBtn?.frame = CGRectMake(0, 0, 67, 20)
        let rightBtnItem = UIBarButtonItem(customView: navRightBtn!)
        self.navigationItem.rightBarButtonItem = rightBtnItem

    }
    
    func titleBtnPressed(sender: UIButton) {
        if sender.tag == 0 {
            // 按下了粉丝键
            if navTitlestate == .Fans {
                // 此时不需要任何操作
                return
            }
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(sender)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                sender.superview?.layoutIfNeeded()
                self.titleFansBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                self.titleFollowBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }, completion: nil)
            navTitlestate = .Fans
            self.userTableView?.reloadData()
        }else{
            if navTitlestate == .Follow {
                return
            }
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(sender)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                sender.superview?.layoutIfNeeded()
                self.titleFansBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.titleFollowBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                }, completion: nil)
            navTitlestate = .Follow
            if follows.count == 0 {
                getMoreUserData()
            }
            self.userTableView?.reloadData()
        }
    }
    
    func navRightBtnPressed() {
        delegate?.userSelected(selectedUsers)
    }
    
    override func navLeftBtnPressed() {
        delegate?.userSelectCancelled()
    }
    
    /**
     根据当前选定的模式从服务器获取更多的数据
     */
    func getMoreUserData() {
        let threshold: NSDate
        let requester = AccountRequester.sharedRequester
        switch navTitlestate {
        case .Fans:
            threshold = fansDateThreshold ?? NSDate()
            requester.getFansList(targetUser.ssidString, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (let data) -> () in
                if let fansJSONData = data?.arrayValue {
                    for json in fansJSONData {
                        let user: User = try! MainManager.sharedManager.getOrCreate(json)
                        user.recentStatusDes = json["recent_status_des"].string
                        self.fans.append(user)
                        self.fansDateThreshold = DateSTR(json["created_at"].stringValue)
                    }
                    if fansJSONData.count > 0 {
                        self.fans = $.uniq(self.fans, by: { return $0.ssid })
                        self.userTableView?.reloadData()
                    }
                }
                }, onError: { (code) -> () in
                    print(code)
            })
            break
        case .Follow:
            threshold = followDateThreshold ?? NSDate()
            requester.getFollowList(targetUser.ssidString, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (let data) -> () in
                if let followJSONData = data?.arrayValue {
                    for json in followJSONData {
                        let user: User = try! MainManager.sharedManager.getOrCreate(json)
                        user.recentStatusDes = json["recent_status_des"].string
                        self.follows.append(user)
                        self.followDateThreshold = DateSTR(json["created_at"].stringValue)
                    }
                    if followJSONData.count > 0 {
                        self.follows = $.uniq(self.follows, by: {return $0.ssid})
                        self.userTableView?.reloadData()
                    }
                }
                }, onError: { (code) -> () in
                    print(code)
            })
        }
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
    
    override func userSelectionDidChange() {
        let currentSelectedNum = selectedUsers.count
        navRightBtn?.setTitle(LS("确定") + "(\(currentSelectedNum)/\(maxSelectUserNum))", forState: .Normal)
    }
    
    override func userSelectionShouldChange(user: User, addOrDelete: Bool) -> Bool {
        if selectedUsers.count >= maxSelectUserNum && addOrDelete {
            self.displayAlertController(nil, message: LS("你最多只能同时@\(maxSelectUserNum)名用户"))
            return false
        }
        return true
    }
}
