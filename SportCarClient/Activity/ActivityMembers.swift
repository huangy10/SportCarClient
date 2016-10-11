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
    func activityMemberControllerDidRemove(_ user: User)
}


class ActivityMembersController: UITableViewController, ActivityMemberCellDelegate, LoadingProtocol {
    var act: Activity! {
        didSet {
            showKickoutBtn = act.user!.isHost
        }
    }
    var showKickoutBtn: Bool = false
    
    weak var delegate: ActivityMemberDelegate!
    var indexToDelete: Int?
    
    var delayWorkItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureNavigationBar()
    }
    
    func configureTableView() {
        tableView.separatorColor = UIColor(white: 0, alpha: 0.12)
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 90
        
        tableView.register(ActivityMemberCell.self, forCellReuseIdentifier: "cell")
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("已报名")
        let leftBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed))
        leftBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        leftBtn.contentMode = .scaleAspectFit
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return act.applicants.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ActivityMemberCell
        let member = act.applicants[(indexPath as NSIndexPath).row]
        cell.delegate = self
        cell.setData(
            member.nickName!,
            avatarURL: member.avatarURL!,
            avatarCarName: member.avatarCarModel?.name,
            authed: member.identified,
            showKickoutBtn: showKickoutBtn
        )
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = act.applicants[(indexPath as NSIndexPath).row]
        navigationController?.pushViewController(user.showDetailController(), animated: true)
    }
    
    func activityMemberKickoutPressed(at cell: ActivityMemberCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            indexToDelete = (indexPath as NSIndexPath).row
            let user = act.applicants[(indexPath as NSIndexPath).row]
            let message = String(format: LS("确认将 %@ 从活动 %@ 中请出？"), user.nickName!, act.name!)
            showConfirmToast(LS("请出成员"), message: message, target: self, onConfirm: #selector(confirmKickoutUser))
        } else {
            assertionFailure()
        }
    }
    
    func confirmKickoutUser() {
        guard let userIndex = indexToDelete else {
            return
        }
        let user = act.applicants[userIndex]
        lp_start()
        _ = ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: user.ssidString, opType: "kick_out", onSuccess: { (json) in
            self.lp_stop()
            self.delegate.activityMemberControllerDidRemove(user)
            self.act.applicants.remove(at: userIndex)
            self.tableView.deleteRows(at: [IndexPath(row: userIndex, section: 0)], with: .automatic)
            }) { (code) in
                self.lp_stop()
                self.showToast(LS("删除失败"))
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
        selectionStyle = .none
        
        configureAvatar()
        configureNameLbl()
        configureAvatarCarLbl()
        configureAuthIcon()
        configureKickoutBtn()
    }
    
    func configureAvatar() {
        avatar = contentView.addSubview(UIImageView.self)
            .toRound(17.5)
            .layout({ (make) in
                make.left.equalTo(contentView).offset(20)
                make.centerY.equalTo(contentView)
                make.size.equalTo(35)
            })
        avatar.clipsToBounds = true
    }
    
    func configureNameLbl() {
        nameLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightSemibold, textColor: UIColor.black)
            .layout({ (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalTo(avatar)
            })
    }
    
    func configureAvatarCarLbl() {
        avatarCarLbl = contentView.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0, alpha: 0.58))
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.bottom.equalTo(avatar)
            })
    }
    
    func configureAuthIcon() {
        authIcon = contentView.addSubview(UIImageView.self)
            .layout({ (make) in
                make.bottom.equalTo(avatar)
                make.left.equalTo(avatarCarLbl.snp.right).offset(5)
                make.size.equalTo(CGSize(width: 40, height: 15))
            })
    }
    
    func configureKickoutBtn() {
        kickoutBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(kickoutBtnPressed))
            .layout({ (make) in
                make.centerY.equalTo(contentView)
                make.right.equalTo(contentView).offset(-15)
                make.size.equalTo(CGSize(width: 75, height: 30))
            })
        kickoutBtn.setTitle(LS("请出"), for: .normal)
        kickoutBtn.setTitleColor(kHighlightRed, for: .normal)
        kickoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        kickoutBtn.layer.cornerRadius = 2
        kickoutBtn.layer.borderColor = kHighlightRed.cgColor
        kickoutBtn.layer.borderWidth = 0.5
    }
    
    func kickoutBtnPressed() {
        delegate.activityMemberKickoutPressed(at: self)
    }
    
    func setData(_ username: String, avatarURL: URL, avatarCarName: String?, authed: Bool, showKickoutBtn: Bool) {
        nameLbl.text = username
        avatarCarLbl.text = avatarCarName ?? "奥迪"
        avatar.kf.setImage(with: avatarURL)
        authIcon.image = authed ? UIImage(named: "auth_status_authed") : UIImage(named: "auth_status_unauthed")
        kickoutBtn.isHidden = !showKickoutBtn
    }
}
