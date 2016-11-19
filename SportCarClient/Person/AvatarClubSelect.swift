//
//  AvatarClubSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  This is where current user selecting his/her avatar car
//

import UIKit
import SwiftyJSON
import Alamofire


protocol AvatarClubSelectDelegate: class {
    func avatarClubSelectDidFinish(_ selectedClub: Club)
    func avatarClubSelectDidCancel()
}


class AvatarClubSelectController: AvatarItemSelectController, RequestManageMixin {
    internal var onGoingRequest: [String : Request] = [:]

    
    weak var delegate: AvatarClubSelectDelegate?
    
    var clubs: [Club] = []
    fileprivate var user: User = MainManager.sharedManager.hostUser!
    var preSelectID: Int32? = nil
    
    var selectedRow: Int = -1
    var noIntialSelect: Bool = false
    
    var noClubLbl: UILabel!
    var authed_only = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        let requester = ClubRequester.sharedInstance
        if authed_only {
            requester.getClubListAuthed({ (json) -> () in
                self.requestResponseHandler(json!.arrayValue)
            }) { (code) -> () in
                self.showReqError(withCode: code)
            }.registerForRequestManage(self)
        } else {
            requester.getClubList({ (json) in
                self.requestResponseHandler(json!.arrayValue)
            }, onError: { (code) in
                self.showReqError(withCode: code)
            }).registerForRequestManage(self)
        }
    }
    
    func requestResponseHandler(_ json: [JSON]) {
        var i = 0
        for data in json {
            let club: Club = try! MainManager.sharedManager.getOrCreate(Club.reorganizeJSON(data))
            self.clubs.append(club)
            if club.ssid == self.preSelectID ?? self.user.avatarClubModel?.ssid && !self.noIntialSelect{
                self.selectedRow = i
            }
            i += 1
        }
        self.tableView.reloadData()
    }
    
    func createSubviews() {
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        
        noClubLbl = UILabel()
        noClubLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        noClubLbl.textColor = kTextGray28
        noClubLbl.text = LS("暂未加入认证俱乐部，在群聊中申请认证")
        superview.addSubview(noClubLbl)
        noClubLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(100)
        }
        if clubs.count == 0 {
            noClubLbl.isHidden = true
        }
    }
    
    override func navTitle() -> String {
        return LS("签名俱乐部")
    }
    
    override func navLeftBtnPressed() {
        super.navLeftBtnPressed()
        delegate?.avatarClubSelectDidCancel()
    }
    
    override func navRightBtnPressed() {
        super.navRightBtnPressed()
        //
        if selectedRow >= 0 {
            delegate?.avatarClubSelectDidFinish(clubs[selectedRow])
        }else {
            delegate?.avatarClubSelectDidCancel()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noClubLbl.isHidden = clubs.count != 0
        return clubs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AvatarItemSelectCell.reuseIdentifier, for: indexPath) as! AvatarItemSelectCell
        let club = clubs[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf.setImage(with: club.logoURL!)
        cell.selectBtn?.tag = (indexPath as NSIndexPath).row
        cell.nickNameLbl?.text = club.name
        cell.authIcon.isHidden = true
        cell.selectBtn?.isSelected = selectedRow == (indexPath as NSIndexPath).row
        cell.onSelect = { [weak self] (sender: UIButton) in
            let row = sender.tag
            if sender.isSelected {
                self?.selectedRow = -1
            }else{
                self?.selectedRow = row
            }
            self?.tableView.reloadData()
            return true
        }
        return cell
    }
}
