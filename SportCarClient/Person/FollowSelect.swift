//
//  FollowSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/1.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class FollowSelectController: UserSelectController {
    var targetUser: User?
    
    var follows: [User] = []
    override var users: [User] {
        get {
            return follows
        }
    }
    
    var followsDateThreshold: NSDate?
    
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
        return LS("关注")
    }
    
    override func navLeftBtnPressed() {
        // dismiss self
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
        let threshold: NSDate = followsDateThreshold ?? NSDate()
        let requester = AccountRequester.sharedRequester
        requester.getFollowList(targetUser!.userID!, dateThreshold: threshold, op_type: "more", limit: 20, filterStr: searchText, onSuccess: { (let data) -> () in
            print(data)
            if let fansJSONData = data?.arrayValue {
                for json in fansJSONData {
                    let user = User.objects.create(json).value
                    user?.recentStatusDes = json["recent_status_des"].string
                    print(user?.avatarUrl)
                    self.follows.append(user!)
                    self.followsDateThreshold = DateSTR(json["created_at"].stringValue)
                }
                if fansJSONData.count > 0 {
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
