//
//  PersonMineInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class PersonMineInfoController: UITableViewController, PersonMineSinglePropertyModifierDelegate, ImageInputSelectorDelegate, AvatarCarSelectDelegate, AvatarClubSelectDelegate, CityElementSelectDelegate {
    
    var user: User = MainManager.sharedManager.hostUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        tableView.registerClass(PersonMineInfoCell.self, forCellReuseIdentifier: PersonMineInfoCell.reuseIdentifier)
        tableView.registerClass(PrivateChatSettingsAvatarCell.self, forCellReuseIdentifier: PrivateChatSettingsAvatarCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = user.nickName
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 4
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else{
            let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! PrivateChatSettingsHeader
            header.titleLbl.text = [LS("信息"), LS("详细")][section - 1]
            return header
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 114
        }else{
            return 50
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            cell.avatarImage.kf_setImageWithURL(user.avatarURL!)
            return cell
        }else {
            let cell = tableView.dequeueReusableCellWithIdentifier(PersonMineInfoCell.reuseIdentifier, forIndexPath: indexPath) as! PersonMineInfoCell
            if indexPath.section == 1 {
                cell.staticLbl.text = [LS("昵称"), LS("签名车"), LS("签名俱乐部"), LS("性别"), LS("年龄")][indexPath.row]
                switch indexPath.row {
                case 0:
                    cell.infoLbl.text = user.nickName
                    cell.iconImage.image = nil
                    cell.editable = true
                    break
                case 1:
                    if let car = user.avatarCarModel {
                        cell.infoLbl.text = car.name
                        cell.iconImage.kf_setImageWithURL(car.logoURL!)
                    }else {
                        cell.infoLbl.text = ""
                        cell.iconImage.image = nil
                    }
                    cell.editable = true
                case 2:
                    if let club = user.avatarClubModel {
                        cell.infoLbl.text = club.name
                        cell.iconImage.kf_setImageWithURL(club.logoURL!)
                    }else{
                        cell.infoLbl.text = ""
                        cell.iconImage.image = nil
                    }
                    cell.editable = true
                    break
                case 3:
                    cell.infoLbl.text = user.gender
                    cell.iconImage.image = nil
                    cell.editable = false
                case 4:
                    cell.infoLbl.text = "\(user.age)"
                    cell.iconImage.image = nil
                    cell.editable = false
                default:
                    break
                }
            }else {
                cell.staticLbl.text = [LS("星座"), LS("职业"), LS("活跃地区"), LS("个性签名")][indexPath.row]
                switch indexPath.row {
                case 0:
                    cell.editable = false
                    cell.infoLbl.text = user.starSign
                    cell.iconImage.image = nil
                    break
                case 1:
                    cell.editable = true
                    cell.infoLbl.text = user.job
                    cell.iconImage.image = nil
                case 2:
                    cell.editable = true
                    cell.infoLbl.text = user.district
                    cell.iconImage.image = nil
                case 3:
                    cell.editable = true
                    cell.iconImage.image = nil
                    cell.infoLbl.text = user.signature
                default:
                    break
                }
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let detail = ImageInputSelectorController()
            detail.bgImage = self.getScreenShotBlurred(false)
            detail.delegate = self
            self.presentViewController(detail, animated: false, completion: nil)
            break
        case 1:
            switch indexPath.row{
            case 0:
                let detail = PersonMineSinglePropertyModifierController()
                detail.focusedIndexPath = indexPath
                detail.delegate = self
                detail.initValue = user.nickName
                self.navigationController?.pushViewController(detail, animated: true)
                break
            case 1:
                let detail = AvatarCarSelectController()
                detail.delegate = self
                self.navigationController?.pushViewController(detail, animated: true)
            case 2:
                let detail = AvatarClubSelectController()
                detail.delegate = self
                self.navigationController?.pushViewController(detail, animated: true)
                break
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 1:
                let detail = PersonMineSinglePropertyModifierController()
                detail.focusedIndexPath = indexPath
                detail.delegate = self
                detail.initValue = user.job
                detail.propertyName = LS("职业")
                self.navigationController?.pushViewController(detail, animated: true)
                break
            case 2:
                let detail = CityElementSelectController()
                detail.delegate = self
                detail.maxLevel = 2
                self.navigationController?.pushViewController(detail, animated: true)
            case 3:
                let detail = PersonMineSinglePropertyModifierController()
                detail.focusedIndexPath = indexPath
                detail.delegate = self
                detail.initValue = user.signature
                detail.propertyName = LS("个性签名")
                self.navigationController?.pushViewController(detail, animated: true)
            default:
                break
            }
            break
        default:
            break
        }
    }
}

extension PersonMineInfoController {
    
    func cityElementSelectDidSelect(dataSource: CityElementSelectDataSource) {
        let district = dataSource.selectedCity! + dataSource.selectedDistrict!
        self.didModify(district, indexPath: NSIndexPath(forItem: 2, inSection: 2))
    }
    
    func didModify(newValue: String?, indexPath: NSIndexPath) {
        let requester = PersonRequester.requester
        switch indexPath.section {
        case 0:
            break
        case 1:
            switch indexPath.row {
            case 0:
                requester.profileModifiy(["nick_name": newValue!], onSuccess: { (json) -> () in
                    self.user.nickName = newValue
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                        print(code)
                })
                break
            default:
                break
            }
            break
        case 2:
            switch indexPath.row {
            case 1:
                requester.profileModifiy(["job": newValue!], onSuccess: { (json) -> () in
                    self.user.job = newValue
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                        print(code)
                })
                break
            case 2:
                requester.profileModifiy(["district": newValue!], onSuccess: { (json) -> () in
                    self.user.district = newValue
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                        print(code)
                })
            case 3:
                requester.profileModifiy(["signature": newValue!], onSuccess: { (json) -> () in
                    self.user.signature = newValue
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                        print(code)
                })
            default:
                break
            }
            break
        default:
            break
        }
    }
    
    func modificationCancelled() {
        
    }
    
    func imageInputSelectorDidCancel() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imageInputSelectorDidSelectImage(image: UIImage) {
        self.dismissViewControllerAnimated(false, completion: nil)
        // 开始上传头像
        let requester = PersonRequester.requester
        requester.profileModifyUploadAvatar(image, onSuccess: { (json) -> () in
            let avatarURL = SFURL(json!.stringValue)!
            KingfisherManager.sharedManager.cache.storeImage(image, forKey: avatarURL.absoluteString)
            self.user.avatar = json!.stringValue
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
            }) { (code) -> () in
                print(code)
        }
    }
    
    func avatarCarSelectDidCancel() {
        //
    }
    
    func avatarCarSelectDidFinish(selectedCar: SportCar) {
        // 将修改的内容提交到服务器
        let requester = PersonRequester.requester
        requester.profileModifiy(["avatar_car": selectedCar.ssidString], onSuccess: { (data) -> () in
            // 
            let targetUser = self.user
            targetUser.avatarCarModel = selectedCar
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 1)], withRowAnimation: .Automatic)
            }) { (code) -> () in
                
        }
    }
    
    func avatarClubSelectDidCancel() {
        
    }
    
    func avatarClubSelectDidFinish(selectedClub: Club) {
        let requester = PersonRequester.requester
        requester.profileModifiy(["avatar_club": selectedClub.ssidString], onSuccess: { (data) -> () in
            //
            let targetUser = self.user
            targetUser.avatarClubModel = selectedClub
            self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 1)], withRowAnimation: .Automatic)
            }) { (code) -> () in
                
        }
    }
}

class PersonMineInfoCell: PrivateChatSettingsCommonCell {
    var iconImage: UIImageView!
    
    override func createSubviews() {
        super.createSubviews()
        iconImage = UIImageView()
        self.contentView.addSubview(iconImage)
        iconImage.layer.cornerRadius = 10
        iconImage.clipsToBounds = true
        iconImage.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(infoLbl.snp_left).offset(-8)
            make.centerY.equalTo(infoLbl)
            make.size.equalTo(20)
        }
        
        boolSelect.hidden = true
        markIcon.hidden = true
        self.selectionStyle = .None
    }
}




