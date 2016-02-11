//
//  BlackListViewer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/11.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol BlackListViewDelegate {
    func didSelectUser(users: [User])
}


class BlackListViewController: UserSelectController {
    
    var delegate: BlackListViewDelegate?
    
    var blUsers: [User] = []
    override var users: [User] {
        get {
            return blUsers
        }
    }
    var dateThreshold = NSDate()
    
    var loading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
    }
    //
    override func navSettings() {
        self.navigationItem.title = LS("黑名单")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("移除"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    override func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRigthBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.didSelectUser(self.blUsers)
    }
    
    func getMoreUserData() {
        if loading {
            return
        }
        loading = true
        let requester = PersonRequester.requester
        requester.getBlackList(dateThreshold, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let user = User.objects.create(data["target"]).value
                user?.recentStatusDes = data["recent_status_des"].string
                self.blUsers.append(user!)
                self.dateThreshold = DateSTR(data["blacklist_at"].stringValue)!
            }
            self.loading = false
            self.userTableView?.reloadData()
            }) { (code) -> () in
                print(code)
                self.loading = false
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
    
    override func userSelectionDidChange() {
        
    }
    
}