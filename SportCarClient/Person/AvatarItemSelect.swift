//
//  AvatarItemSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class AvatarItemSelectController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        tableView.registerClass(AvatarItemSelectCell.self, forCellReuseIdentifier: AvatarItemSelectCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 90
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = navTitle()
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: #selector(AvatarItemSelectController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .Done, target: self, action: #selector(AvatarItemSelectController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navTitle() -> String {
        assertionFailure()
        return ""
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    
}

class AvatarItemSelectCell: UserSelectCell {
    var authed: Bool = false
    var authIcon: UIImageView!
    
    override func createSubviews() {
        super.createSubviews()
        
        authIcon = UIImageView()
        self.contentView.addSubview(authIcon)
        authIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(avatarImg!)
            make.right.equalTo(self.contentView).offset(-40)
            make.size.equalTo(CGSizeMake(44, 18.5))
        }
        recentStatusLbL?.hidden = true
        nickNameLbl?.snp_remakeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarImg!.snp_right).offset(12)
            make.centerY.equalTo(avatarImg!)
            make.height.equalTo(avatarImg!).multipliedBy(0.5)
        })
    }
}
