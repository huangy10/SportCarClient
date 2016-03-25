//
//  FansSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar

class FansSelectController: UserSelectController {
    var targetUser: User?
    
    var fans: [User] = []
    override var users: [User] {
        get {
            return fans
        }
    }
    
    var fansDateThreshold: NSDate?
    
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
        findOnMapBtn?.hidden = true
        selectedUserList?.hidden = true
        userTableView?.registerClass(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
    }
    
    override func navTitle() -> String {
        return LS("粉丝")
    }
    
    override func navLeftBtnPressed() {
        // dismiss self
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserSelectCellUnselectable
        let user = users[indexPath.row]
        cell.avatarImg?.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        return cell
    }
    
    override func searchUserUsingSearchText() {
        
    }
    
    func getMoreUserData() {
        let threshold: NSDate = fansDateThreshold ?? NSDate()
        let requester = AccountRequester.sharedRequester
        requester.getFansList(targetUser!.userID!, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (let data) -> () in
            if let fansJSONData = data?.arrayValue {
                for json in fansJSONData {
                    let user = User.objects.getOrCreate(json)
                    user.recentStatusDes = json["recent_status_des"].string
                    self.fans.append(user)
                    self.fansDateThreshold = DateSTR(json["created_at"].stringValue)
                }
                if fansJSONData.count > 0 {
                    self.fans = $.uniq(self.fans, by: {$0.userID!})
                    self.userTableView?.reloadData()
                }
            }
            }) { (code) -> () in
                
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
}


class UserSelectCellUnselectable: UserSelectCell {
    
    override func createSubviews() {
        super.createSubviews()
        selectBtn?.hidden = true
        avatarImg?.snp_remakeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(35)
            make.left.equalTo(self.contentView).offset(15)
        })
    }
    
}