//
//  FollowSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class FollowSelectController: UserSelectController {
    var targetUser: User?
    
    var follows: [User] = []
    override var users: [User] {
        get {
            return follows
        }
    }
    
    var followsDateThreshold: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
    }
    
    override func createSubviews() {
        super.createSubviews()
        //
        let superview = self.view
        searchBar?.snp_updateConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(0)
        })
        //
        selectedUserList?.isHidden = true
        userTableView?.register(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
    }
    
    override func navTitle() -> String {
        return LS("关注")
    }
    
    override func navLeftBtnPressed() {
        // dismiss self
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSelectCellUnselectable
        let user = users[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf_setImageWithURL(user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        return cell
    }
    
    override func searchUserUsingSearchText() {
        follows.removeAll()
        userTableView?.reloadData()
        followsDateThreshold = Date()
        getMoreUserData()
    }
    
    func getMoreUserData() {
        let threshold: Date = followsDateThreshold ?? Date()
        let requester = AccountRequester2.sharedInstance
        requester.getFollowList(targetUser!.ssidString, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (data) -> () in
            
            if let fansJSONData = data?.arrayValue {
                for json in fansJSONData {
                    let user: User = try! MainManager.sharedManager.getOrCreate(json["user"])
                    self.follows.append(user)
                    self.followsDateThreshold = DateSTR(json["created_at"].stringValue)
                }
                if fansJSONData.count > 0 {
                    self.follows = $.uniq(self.follows, by: { return $0.ssid })
                    self.userTableView?.reloadData()
                }
            }
            }) { (code) -> () in
                
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
}
