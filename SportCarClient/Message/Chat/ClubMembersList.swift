//
//  ClubMembersList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/7/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class ClubMembersController: UserSelectController, ClubMemberCellDelegate, LoadingProtocol {
    var targetClub: Club!
    
    var members: [User] = []
    
    override var users: [User] {
        get {
            return members
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getMoreUserData()
        
        registerAsObserver()
    }
    
    func registerAsObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(onMemberDeletedElsewhere(notification:)), name: NSNotification.Name(rawValue: kMessageClubMemberChangeNotification), object: nil)
    }
    
    override func createSubviews() {
        super.createSubviews()
        
        let superview = self.view!
        searchBar?.snp.makeConstraints({ (make) in
            make.right.equalTo(superview).offset(0)
        })
        selectedUserList?.isHidden = true
        userTableView?.register(ClubMemberCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func navTitle() -> String {
        return LS("全部成员")
    }
    
    override func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClubMemberCell
        let user = users[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf.setImage(with: user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        cell.delegate = self
        if user == targetClub.founderUser! || MainManager.sharedManager.hostUser != targetClub.founderUser {
            cell.kickOutBtn.isHidden = true
            cell.rightArrowImg.isHidden = false
        } else {
            cell.kickOutBtn.isHidden = false
            cell.rightArrowImg.isHidden = true
        }
        return cell
    }
    
    override func searchUserUsingSearchText() {
        members.removeAll()
        userTableView?.reloadData()
        getMoreUserData()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreUserData()
        }
    }
    
    func getMoreUserData() {
        let skip = users.count
        let limit = 10
        lp_start()
        _ = ClubRequester.sharedInstance.getClubMembers(targetClub.ssidString, skip: skip, limit: limit, searchText: searchBar?.text ?? "", onSuccess: { (json) in
            if let data = json?.arrayValue {
                for element in data {
                    let user: User = try! MainManager.sharedManager.getOrCreate(element)
                    self.members.append(user)
                }
                if data.count > 0 {
                    self.members = $.uniq(self.members, by: { $0.ssid })
                    self.userTableView?.reloadData()
                }
            }
            self.lp_stop()
            }) { (code) in
                self.showToast(LS("网络错误"))
                self.lp_stop()
        }
    }
    
    func kickOutBtnPressed(at cell: ClubMemberCell) {
        lp_start()
        let indexPath = userTableView!.indexPath(for: cell)!
        let userToBeDeleted = members[indexPath.row]
        _ = ClubRequester.sharedInstance.updateClubMembers(targetClub.ssidString, members: [userToBeDeleted.ssidString], opType: "delete", onSuccess: { (_) in
            self.remove(member: userToBeDeleted)
            self.removeCell(at: indexPath)
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kMessageClubMemberChangeNotification), object: self, userInfo: [kMessageClubKey: self.targetClub, kUserKey: userToBeDeleted, kOpertaionCodeKey: "delete"])
            self.lp_stop()
            }, onError: { (code) in
                self.showToast(LS("删除失败"))
                self.lp_stop()
        })
    }
    
    func removeCell(at indexPath: IndexPath) {
        userTableView?.beginUpdates()
        userTableView?.deleteRows(at: [indexPath], with: .automatic)
        userTableView?.endUpdates()
    }
    
    func onMemberDeletedElsewhere(notification: NSNotification) {
        guard notification.name.rawValue == kMessageClubMemberChangeNotification else {
            return
        }
        guard let relatedClub = notification.userInfo![kMessageClubKey] as? Club , relatedClub == targetClub else {
            return
        }
        guard let deletedUser = notification.userInfo![kUserKey] as? User else {
            return
        }
        guard let operationType = notification.userInfo?[kOpertaionCodeKey] as? String, operationType == "delete" else {
            return
        }
        if let userIndex = members.findIndex(callback: { $0 == deletedUser }) {
            remove(member: deletedUser)
            removeCell(at: IndexPath(row: userIndex, section: 0))
        }
    }
    
    func remove(member: User) {
        targetClub.remove(member: member)
        members = $.remove(members, value: member)
    }
}


protocol ClubMemberCellDelegate: class {
    
    func kickOutBtnPressed(at cell: ClubMemberCell)
    
}


class ClubMemberCell: UserSelectCellUnselectable {
    
    var kickOutBtn: UIButton!
    
    weak var delegate: ClubMemberCellDelegate!
    
    override func createSubviews() {
        super.createSubviews()
        rightArrowImg.isHidden = true
        
        configureKickOutBtn()
    }
    
    func configureKickOutBtn() {
        kickOutBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(kickOutBtnPressed))
            .layout({ (make) in
                make.bottom.equalTo(avatarImg!)
                make.right.equalTo(contentView).offset(-15)
                make.size.equalTo(CGSize(width: 75, height: 30))
            })
        kickOutBtn.setTitle(LS("请出"), for: .normal)
        kickOutBtn.setTitleColor(kHighlightRed, for: .normal)
        kickOutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        kickOutBtn.layer.cornerRadius = 2
        kickOutBtn.layer.borderColor = kHighlightRed.cgColor
        kickOutBtn.layer.borderWidth = 0.5
    }
    
    func kickOutBtnPressed() {
        delegate.kickOutBtnPressed(at: self)
    }
}
