//
//  ClubMembersList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/7/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class ClubMembersController: UserSelectController {
    var targetClub: Club!
    
    var members: [User] = []
    
    override var users: [User] {
        get {
            return members
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
    }
    
    override func createSubviews() {
        super.createSubviews()
        
        let superview = self.view
        searchBar?.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(superview).offset(0)
        })
        selectedUserList?.hidden = true
        userTableView?.registerClass(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
    }
    
    override func navTitle() -> String {
        return LS("全部成员")
    }
    
    override func navLeftBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserSelectCellUnselectable
        let user = users[indexPath.row]
        cell.avatarImg?.kf_setImageWithURL(user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        return cell
    }
    
    override func searchUserUsingSearchText() {
        members.removeAll()
        userTableView?.reloadData()
        getMoreUserData()
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
    
    func getMoreUserData() {
        let skip = users.count
        let limit = 10
        ClubRequester.sharedInstance.getClubMembers(targetClub.ssidString, skip: skip, limit: limit, searchText: searchBar?.text ?? "", onSuccess: { (json) in
            if let data = json?.arrayValue {
                for element in data {
                    let user: User = try! MainManager.sharedManager.getOrCreate(element["user"])
                    self.members.append(user)
                }
                if data.count > 0 {
                    self.members = $.uniq(self.members, by: { $0.ssid })
                    self.userTableView?.reloadData()
                }
            }
            }) { (code) in
                self.showToast(LS("网络错误"))
        }
    }
}
