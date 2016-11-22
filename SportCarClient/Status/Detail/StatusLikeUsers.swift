//
//  StatusLikeUsers.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/22.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON


class StatusLikeUsersList: UserSelectController, LoadingProtocol {
    
    var status: Status!
    var likers: [User] = []
    var dateThreshold: Date?
    
    override var users: [User] {
        return likers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMoreLikers()
    }
    
    override func createSubviews() {
        super.createSubviews()
        searchBar?.isHidden = true
        selectedUserList?.isHidden = true
        
        userTableView?.snp.remakeConstraints { (mk) in
            mk.edges.equalTo(self.view)
        }
        
        userTableView?.register(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
        userTableView?.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty")
    }
    
    override func navTitle() -> String {
        return LS("点赞")
    }
    
    override func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if users.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有人点赞")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSelectCellUnselectable
            let user = users[indexPath.row]
            cell.avatarImg?.kf.setImage(with: user.avatarURL!)
            cell.nickNameLbl?.text = user.nickName
            cell.recentStatusLbL?.text = user.recentStatusDes
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if users.isNotEmpty {
            super.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(users.count, 1)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if users.isEmpty {
            return 100
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func getMoreLikers() {
        let threshold: Date = dateThreshold ?? Date()
        StatusRequester.sharedInstance.getStatusLikeList(status.ssidString, dateThreshold: threshold, limit: 10, opType: "more", onSuccess: { (json) -> () in
            var newUsers: [User] = []
            for data in json!.arrayValue {
                let user = try! MainManager.sharedManager.getOrCreate(data) as User
                newUsers.append(user)
                self.dateThreshold = DateSTR(data["like_at"].stringValue)
            }
            
            if newUsers.count > 0 {
                let empty = self.likers.isEmpty
                self.likers.append(contentsOf: newUsers)
                if empty {
                    UIView.transition(with: self.userTableView!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.userTableView?.reloadData()
                    }, completion: nil)
                } else {
                    self.userTableView?.reloadData()
                }
            }
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            getMoreLikers()
        }
    }
}
