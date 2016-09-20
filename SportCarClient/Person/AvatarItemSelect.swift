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
        tableView.register(AvatarItemSelectCell.self, forCellReuseIdentifier: AvatarItemSelectCell.reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 90
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = navTitle()
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(AvatarItemSelectController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(AvatarItemSelectController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navTitle() -> String {
        assertionFailure()
        return ""
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewController(animated: true)
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
            make.size.equalTo(CGSize(width: 44, height: 18.5))
        }
        recentStatusLbL?.isHidden = true
        nickNameLbl?.snp_remakeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarImg!.snp_right).offset(12)
            make.centerY.equalTo(avatarImg!)
            make.height.equalTo(avatarImg!).multipliedBy(0.5)
        })
    }
}
