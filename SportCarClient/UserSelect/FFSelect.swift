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
    case fans
    case follow
}

protocol FFSelectDelegate: class {
    
    func userSelected(_ users: [User])
    
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
            switch navTitlestate {
            case .fans:
                return fans
            case .follow:
                return follows
            }
        }
    }
    
    var fansDateThreshold: Date?
    var followDateThreshold: Date?
    var navTitlestate: FFSelectState = .fans
    
    var maxSelectUserNum: Int
    
    var titleFansLbl: UILabel!
    var titleFollowLbl: UILabel!
    var titleBtnIcon: UIImageView!
    var navRightBtn: UIButton?
    
    var authedUserOnly: Bool = false
    
    convenience init(maxSelectNum: Int, preSelectedUsers: [User] = [], preSelect: Bool = true, forced: Bool = true, authedUserOnly: Bool = false) {
        // 2016-08-11 authedUserOnly这个参数表明是否只允许选择认证用户
        self.init()
        maxSelectUserNum = maxSelectNum
        self.authedUserOnly = authedUserOnly
        if forced {
            forceSelectedUsers.append(contentsOf: preSelectedUsers)
        }
        if preSelect {
            selectedUsers.append(contentsOf: preSelectedUsers)
        }
    }
    
    override init () {
        maxSelectUserNum = kMaxSelectUserNum
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
        
        if authedUserOnly {
            userTableView?.register(UserSelectCellGray.self, forCellReuseIdentifier: "user_select_cell_gray")
        }
    }
    
    /**
     重新布置一下title的显示
     这里面的titleView的构建方式和LoginRegisterController里面是类似的
     */
    override func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let barHeight = self.navigationController!.navigationBar.frame.size.height
        let screenWidth = UIScreen.main.bounds.width
        let containerWidth = screenWidth * 0.5
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: barHeight))
        // 创建粉丝按钮
        let titleFansBtn = UIButton()
        titleFansBtn.tag = 0
        container.addSubview(titleFansBtn)
        titleFansBtn.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp.centerX)
        })
        titleFansBtn.addTarget(self, action: #selector(FFSelectController.titleBtnPressed(_:)), for: .touchUpInside)
        titleFansLbl = titleFansBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightBold, textColor: kTextBlack, textAlignment: .center, text: LS("粉丝"))
            .layout({ (make) in
                make.center.equalTo(titleFansBtn)
                make.size.equalTo(LS(" 粉丝 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        // 创建关注按钮
        let titleFollowBtn = UIButton()
        titleFollowBtn.tag = 1
        container.addSubview(titleFollowBtn)
        titleFollowBtn.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(70)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp.centerX)
        })
        titleFollowBtn.addTarget(self, action: #selector(FFSelectController.titleBtnPressed(_:)), for: .touchUpInside)
        titleFollowLbl = titleFollowBtn.addSubview(UILabel.self)
            .config(15, fontWeight: UIFontWeightBold, textColor: kTextGray, textAlignment: .center, text: LS("关注"))
            .layout({ (make) in
                make.center.equalTo(titleFollowBtn)
                make.size.equalTo(LS(" 关注 ").sizeWithFont(kBarTextFont, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)))
            })
        // 创建可以平移的白色按钮形状
        titleBtnIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleBtnIcon!)
        container.sendSubview(toBack: titleBtnIcon!)
        titleBtnIcon?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(container)
            make.left.equalTo(titleFansLbl)
            make.right.equalTo(titleFansLbl)
            make.height.equalTo(2.5)
        })
        self.navigationItem.titleView = container
        
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .plain, target: self, action: #selector(UserSelectController.navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem

        
        navRightBtn = UIButton()
        navRightBtn?.setTitleColor(kHighlightedRedTextColor, for: .normal)
        if maxSelectUserNum == 0 {
            navRightBtn?.setTitle(LS("确定(0)"), for: .normal)
        } else {
            navRightBtn?.setTitle(LS("确定") + "(\(selectedUsers.count)/\(maxSelectUserNum))", for: .normal)
        }
        navRightBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        navRightBtn?.titleLabel?.textAlignment = .right
        navRightBtn?.addTarget(self, action: #selector(FFSelectController.navRightBtnPressed), for: .touchUpInside)
        navRightBtn?.frame = CGRect(x: 0, y: 0, width: 67, height: 20)
        let rightBtnItem = UIBarButtonItem(customView: navRightBtn!)
        self.navigationItem.rightBarButtonItem = rightBtnItem

    }
    
    func titleBtnPressed(_ sender: UIButton) {
        if sender.tag == 0 {
            // 按下了粉丝键
            if navTitlestate == .fans {
                // 此时不需要任何操作
                return
            }
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(titleBtnIcon!.superview!)
                make.left.equalTo(titleFansLbl)
                make.right.equalTo(titleFansLbl)
                make.height.equalTo(2.5)
            })
            titleFansLbl.textColor = kTextBlack
            titleFollowLbl.textColor = kTextGray
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                sender.superview?.layoutIfNeeded()
                }, completion: nil)
            navTitlestate = .fans
            self.userTableView?.reloadData()
        }else{
            if navTitlestate == .follow {
                return
            }
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(titleBtnIcon!.superview!)
                make.left.equalTo(titleFollowLbl)
                make.right.equalTo(titleFollowLbl)
                make.height.equalTo(2.5)
            })
            titleFansLbl.textColor = kTextGray
            titleFollowLbl.textColor = kTextBlack
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                sender.superview?.layoutIfNeeded()
                }, completion: nil)
            navTitlestate = .follow
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
        let threshold: Date
        let requester = AccountRequester2.sharedInstance
        switch navTitlestate {
        case .fans:
            threshold = fansDateThreshold ?? Date()
            _ = requester.getFansList(targetUser.ssidString, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (data) -> () in
                if let fansJSONData = data?.arrayValue {
                    for json in fansJSONData {
                        let user: User = try! MainManager.sharedManager.getOrCreate(json["user"])
                        self.fans.append(user)
                        self.fansDateThreshold = DateSTR(json["created_at"].stringValue)
                    }
                    if fansJSONData.count > 0 {
                        self.fans = $.uniq(self.fans, by: { return $0.ssid })
                        self.userTableView?.reloadData()
                    }
                }
                }, onError: { (code) -> () in
                    self.showToast(LS("获取数据失败"))
            })
            break
        case .follow:
            threshold = followDateThreshold ?? Date()
            _ = requester.getFollowList(targetUser.ssidString, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (data) -> () in
                if let followJSONData = data?.arrayValue {
                    for json in followJSONData {
                        let user: User = try! MainManager.sharedManager.getOrCreate(json["user"])
                        self.follows.append(user)
                        self.followDateThreshold = DateSTR(json["created_at"].stringValue)
                    }
                    if followJSONData.count > 0 {
                        self.follows = $.uniq(self.follows, by: {return $0.ssid})
                        self.userTableView?.reloadData()
                    }
                }
                }, onError: { (code) -> () in
                    self.showToast(LS("获取数据失败"))
            })
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
    
    override func userSelectionDidChange() {
        if maxSelectUserNum > 0 {
            let currentSelectedNum = selectedUsers.count
            navRightBtn?.setTitle(LS("确定") + "(\(currentSelectedNum)/\(maxSelectUserNum))", for: .normal)
        } else {
            let currentSelectedNum = selectedUsers.count
            navRightBtn?.setTitle(LS("确定") + "(\(currentSelectedNum))", for: .normal)
        }
    }
    
    override func userSelectionShouldChange(_ user: User, addOrDelete: Bool) -> Bool {
        if selectedUsers.count >= maxSelectUserNum && addOrDelete && maxSelectUserNum > 0 {
            showToast(LS("你最多只能同时@\(maxSelectUserNum)名用户"))
            return false
        }
        return true
    }
    
    override func searchUserUsingSearchText() {
        // clear old search result
        fans.removeAll()
        follows.removeAll()
        userTableView?.reloadData()
        fansDateThreshold = Date()
        followDateThreshold = Date()
        // get new data
        getMoreUserData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[(indexPath as NSIndexPath).row]
        if user.identified || !authedUserOnly {
            return super.tableView(tableView, cellForRowAt: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "user_select_cell_gray", for: indexPath) as! UserSelectCellGray
            cell.avatarImg?.kf.setImage(with: user.avatarURL!)
            cell.nickNameLbl?.text = user.nickName
            cell.recentStatusLbL?.text = user.recentStatusDes
            if forceSelectedUsers.findIndex(callback: { $0.ssid == user.ssid}) != nil {
                cell.forceSelected = true
                cell.selectBtn?.isSelected = true
            } else {
                cell.forceSelected = false
                cell.selectBtn?.isSelected = false
            }
            return cell
        }
    }
}

class UserSelectCellGray: UserSelectCell {
    override func createSubviews() {
        super.createSubviews()
        selectBtn?.isEnabled = false
        nickNameLbl?.textColor = UIColor(white: 0.72, alpha: 1)
    }
}
