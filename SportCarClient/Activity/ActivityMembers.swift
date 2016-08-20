//
//  ActivityMembers.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


protocol ActivityMemberCellDelegate: class {
    
    func activityMemberKickoutPressed(at cell: ActivityMemberCell)
    
}

protocol  ActivityMemberDelegate: class {
    func activityMemberControllerDidRemove(user: User)
}


class ActivityMembersController: UITableViewController, ActivityMemberCellDelegate {
    var act: Activity!
    var members: [User] = []
    
    weak var toast: UIView?
    
    weak var delegate: ActivityMemberDelegate!
    var indexToDelete: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }
    
    func configureTableView() {
        tableView.separatorColor = UIColor(white: 0, alpha: 0.12)
        tableView.separatorStyle = .SingleLine
        tableView.rowHeight = 90
        
        tableView.registerClass(ActivityMemberCell.self, forCellReuseIdentifier: "cell")
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("已报名")
        let leftBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed))
        leftBtn.frame = CGRectMake(0, 0, 15, 15)
        leftBtn.contentMode = .ScaleAspectFit
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    func navLeftBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ActivityMemberCell
        let member = members[indexPath.row]
        cell.delegate = self
        cell.setData(
            member.nickName!,
            avatarURL: member.avatarURL!,
            avatarCarName: member.avatarCarModel?.name,
            authed: member.identified)
        return cell
    }
    
    func activityMemberKickoutPressed(at cell: ActivityMemberCell) {
        if let indexPath = tableView.indexPathForCell(cell) {
            indexToDelete = indexPath.row
            
        }
    }
    
    func confirmKickoutUser() {
        hideToast()
        guard let user = indexToDelete else {
            return
        }
//        delegate.activityMemberControllerDidRemove(user)
        
    }
    
    func hideToast() {
        if let toast = toast {
            hideToast(toast)
        }
    }
}

class ActivityMemberCell: UITableViewCell {
    
    weak var delegate: ActivityMemberCellDelegate!
    
    var avatar: UIImageView!
    var nameLbl: UILabel!
    var avatarCarLbl: UILabel!
    var authIcon: UIImageView!
    var kickoutBtn: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        configureAvatar()
        configureNameLbl()
        configureAvatarCarLbl()
        configureAuthIcon()
        configureKickoutBtn()
    }
    
    func configureAvatar() {
        avatar = contentView.addSubview(UIImageView)
            .toRound(17.5)
            .layout({ (make) in
                make.left.equalTo(contentView).offset(20)
                make.centerY.equalTo(contentView)
                make.size.equalTo(35)
            })
    }
    
    func configureNameLbl() {
        nameLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightSemibold, textColor: UIColor.blackColor())
            .layout({ (make) in
                make.left.equalTo(13)
                make.top.equalTo(avatar)
            })
    }
    
    func configureAvatarCarLbl() {
        avatarCarLbl = contentView.addSubview(UILabel)
            .config(12, fontWeight: UIFontWeightUltraLight, textColor: UIColor(white: 0, alpha: 0.58))
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.bottom.equalTo(avatar)
            })
    }
    
    func configureAuthIcon() {
        authIcon = contentView.addSubview(UIImageView)
            .layout({ (make) in
                make.centerY.equalTo(avatarCarLbl)
                make.left.equalTo(avatarCarLbl.snp_right).offset(5)
                make.size.equalTo(CGSizeMake(40, 15))
            })
    }
    
    func configureKickoutBtn() {
        kickoutBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(kickoutBtnPressed))
            .layout({ (make) in
                make.centerY.equalTo(contentView)
                make.right.equalTo(contentView).offset(-15)
                make.size.equalTo(CGSizeMake(75, 30))
            })
        kickoutBtn.setTitle(LS("请出"), forState: .Normal)
        kickoutBtn.setTitleColor(kHighlightRed, forState: .Normal)
        kickoutBtn.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        kickoutBtn.layer.cornerRadius = 2
        kickoutBtn.layer.borderColor = kHighlightRed.CGColor
        kickoutBtn.layer.borderWidth = 0.5
    }
    
    func kickoutBtnPressed() {
        delegate.activityMemberKickoutPressed(at: self)
    }
    
    func setData(username: String, avatarURL: NSURL, avatarCarName: String?, authed: Bool) {
        nameLbl.text = username
        avatarCarLbl.text = avatarCarName
        avatar.kf_setImageWithURL(avatarURL)
        authIcon.image = authed ? UIImage(named: "auth_status_authed") : UIImage(named: "auth_status_unauthed")
    }
}
