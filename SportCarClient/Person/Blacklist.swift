//
//  Blacklist.swift
//  SportCarClient
//
//  Created by 黄延 on 16/7/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar
import Alamofire


class BlacklistController: UserSelectController {
    
    var blockedUsers: [User] = []
    weak var ongoingRequest: Request?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var users: [User] {
        get {
            return blockedUsers
        }
    }
    
    override func navTitle() -> String {
        return LS("黑名单")
    }
    
    override func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func createSubviews() {
        super.createSubviews()
        //
        let superview = self.view!
        searchBar?.snp.updateConstraints({ (make) -> Void in
            make.right.equalTo(superview).offset(0)
        })
        //
        selectedUserList?.isHidden = true
        userTableView?.register(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSelectCellUnselectable
        let user = users[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf.setImage(with: user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onBlacklistChanged(_:)), name: NSNotification.Name(rawValue: kAccountBlacklistChange), object: nil)
        getMoreBlockedUser()
    }
    
    override func searchUserUsingSearchText() {
        if let request = ongoingRequest {
            request.cancel()
        }
        blockedUsers.removeAll()
        userTableView?.reloadData()
        getMoreBlockedUser()
    }
    
    func getMoreBlockedUser() {
        guard ongoingRequest == nil else {
            return
        }
        let skip = users.count
        let limit = 10
        let requester = AccountRequester2.sharedInstance
        ongoingRequest = requester.getBlacklist(
            skip,
            limit: limit,
            searchText: self.searchText ?? "",
            onSuccess: { (json) in
                let data = json!.arrayValue
                for userJson in data {
                    let user: User = try! MainManager.sharedManager.getOrCreate(userJson)
                    self.blockedUsers.append(user)
                }
                if data.count > 0 {
                    self.blockedUsers = $.uniq(self.blockedUsers, by: { $0.ssid })
                    self.userTableView?.reloadData()
                }
            }) { (code) in
                self.showToast(LS("获取数据失败"))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreBlockedUser()
        }
    }
    
    func onBlacklistChanged(_ notification: Foundation.Notification) {
        let user = (notification as NSNotification).userInfo![kUserKey] as! User
        let blockStatus = (notification as NSNotification).userInfo![kAccountBlackStatusKey] as! String
        
        if blockStatus == kAccountBlackStatusBlocked {
            if $.find(blockedUsers, callback: { $0.ssid == user.ssid }) == nil {
                blockedUsers.insert(user, at: 0)
            }
        } else {
            if let _ = $.find(blockedUsers, callback: { $0.ssid == user.ssid }) {
                blockedUsers = $.remove(blockedUsers, callback: { $0.ssid == user.ssid})
            }
        }
        DispatchQueue.main.async { 
            self.userTableView?.reloadData()
        }
        
    }
    
}
