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


class PersonMineInfoController: UITableViewController, AvatarCarSelectDelegate, AvatarClubSelectDelegate, CityElementSelectDelegate, SinglePropertyModifierDelegate, ProgressProtocol, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var user: User = MainManager.sharedManager.hostUser!
    
    let signatureMaxLen = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        SSPropertyCell.registerTableView(tableView)
        SSAvatarCell.registerTableView(tableView)
        tableView.register(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 80, 0)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = user.nickName
        
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    func navLeftBtnPressed() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else {
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else{
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! PrivateChatSettingsHeader
            header.titleLbl.text = [LS("信息"), LS("详细")][section - 1]
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            return 114
        }else{
            return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return tableView.ss_reuseablePropertyCell(SSAvatarCell.self, forIndexPath: indexPath)
                .setData(user.avatarURL!)
        case 1:
            let rawCell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            switch (indexPath as NSIndexPath).row {
            case 0:
                return rawCell.setData(LS("昵称"), propertyValue: user.nickName)
            case 1:
                return rawCell.setData(
                    LS("签名车"),
                    propertyValue: user.avatarCarModel?.name,
                    propertyImageURL: user.avatarCarModel?.logoURL,
                    propertyEmptyPlaceHolder: LS("无签名车")
                )
            case 2:
                return rawCell.setData(
                    LS("签名俱乐部"),
                    propertyValue: user.avatarClubModel?.name,
                    propertyImageURL: user.avatarClubModel?.logoURL,
                    propertyEmptyPlaceHolder: LS("无签名俱乐部")
                )
            case 3:
                return rawCell.setData(LS("性别"), propertyValue: user.gender, editable: false)
            default:
                return rawCell.setData(LS("年龄"), propertyValue: "\(user.age)", editable: false)
            }
        default:
            let rawCell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            switch (indexPath as NSIndexPath).row {
            case 0:
                return rawCell.setData(LS("星座"), propertyValue: user.starSign, editable: false)
            case 1:
                return rawCell.setData(LS("职业"), propertyValue: user.job)
            case 2:
                return rawCell.setData(LS("活跃地区"), propertyValue: user.district)
            default:
                let sigLen = user.signature!.length
                let sig: String
                if sigLen > signatureMaxLen {
                    sig = user.signature![0..<signatureMaxLen]
                } else {
                    sig = user.signature!
                }
                return rawCell.setData(LS("个性签名"), propertyValue: sig)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 0:
            setAvatarPressed()
            break
        case 1:
            switch (indexPath as NSIndexPath).row{
            case 0:
                SinglePropertyModifierController(
                    propertyName: LS("修改昵称"),
                    delegate: self,
                    forcusedIndexPath: indexPath,
                    placeholder: LS("请输入昵称"),
                    text: user.nickName).pushFromViewController(self)
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
            switch (indexPath as NSIndexPath).row {
            case 1:
                SinglePropertyModifierController(
                    propertyName: LS("职业"),
                    delegate: self,
                    forcusedIndexPath: indexPath,
                    placeholder: LS("请输入职业"),
                    text: user.job).pushFromViewController(self)
            case 2:
                let detail = CityElementSelectController()
                detail.delegate = self
                detail.maxLevel = 2
                self.navigationController?.pushViewController(detail, animated: true)
            case 3:
                SinglePropertyModifierController(
                    propertyName: LS("个性签名"),
                    delegate: self,
                    forcusedIndexPath: indexPath,
                    placeholder: LS("请输入个性签名"),
                    text: user.signature).pushFromViewController(self)
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
    
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource) {
        _ = self.navigationController?.popToViewController(self, animated: true)
        let district = dataSource.selectedCity! + dataSource.selectedDistrict!
        self.singlePropertyModifierDidModify(district, forIndexPath: IndexPath(row: 2, section: 2))
    }
    
    func cityElementSelectDidCancel() {
        _ = self.navigationController?.popToViewController(self, animated: true)
    }
    
    func singlePropertyModifierDidModify(_ newValue: String?, forIndexPath indexPath: IndexPath) {
        let requester = AccountRequester2.sharedInstance
        switch (indexPath as NSIndexPath).section {
        case 0:
            break
        case 1:
            switch (indexPath as NSIndexPath).row {
            case 0:
                _ = requester.profileModifiy(["nick_name": newValue!], onSuccess: { (json) -> () in
                    self.user.nickName = newValue
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                    }, onError: { (code) -> () in
                        self.showToast(LS("修改昵称失败"))
                })
                break
            default:
                break
            }
            break
        case 2:
            switch (indexPath as NSIndexPath).row {
            case 1:
                self.user.job = newValue
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                _ = requester.profileModifiy(["job": newValue!], onSuccess: { (json) -> () in
//                    self.user.job = newValue
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                })
                break
            case 2:
                self.user.district = newValue
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                _ = requester.profileModifiy(["district": newValue!], onSuccess: { (json) -> () in
//                    self.user.district = newValue
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                })
            case 3:
                self.user.signature = newValue
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
                _ = requester.profileModifiy(["signature": newValue!], onSuccess: { (json) -> () in
//                    self.user.signature = newValue
//                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                    }, onError: { (code) -> () in
                })
            default:
                break
            }
            break
        default:
            break
        }
        do {
         try MainManager.sharedManager.save()
        } catch {}
    }
    
    func singlePropertyModifierDidCancelled() {
        // DO NOTHING
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: false, completion: nil)
        // 开始上传头像
        self.pp_showProgressView()
        let requester = AccountRequester2.sharedInstance
        requester.profileModifyUploadAvatar(image, onSuccess: { (json) -> () in
            let avatarURL = SFURL(json!.stringValue)!
            KingfisherManager.shared.cache.store(image, forKey: avatarURL.absoluteString)
            self.user.avatar = json!.stringValue
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.showToast(LS("头像上传成功"))
            self.pp_hideProgressView()
        }, onProgress: { (progress) in
            self.pp_updateProgress(progress)
        }) { (code) -> () in
            self.showToast(LS("头像上传失败"))
            self.pp_hideProgressView()
        }
    }
    
    func avatarCarSelectDidCancel() {
        //
    }
    
    func avatarCarSelectDidFinish(_ selectedCar: SportCar) {
        // 将修改的内容提交到服务器
        let requester = AccountRequester2.sharedInstance
        _ = requester.profileModifiy(["avatar_car": selectedCar.ssidString], onSuccess: { (data) -> () in
            // 
            let targetUser = self.user
            targetUser.avatarCarModel = selectedCar
            self.tableView.reloadRows(at: [IndexPath(row: 1, section: 1)], with: .automatic)
            }) { (code) -> () in
                self.showToast(LS("网络错误"), onSelf: true)
        }
    }
    
    func avatarClubSelectDidCancel() {
        
    }
    
    func avatarClubSelectDidFinish(_ selectedClub: Club) {
        let requester = AccountRequester2.sharedInstance
        _ = requester.profileModifiy(["avatar_club": selectedClub.ssidString], onSuccess: { (data) -> () in
            //
            let targetUser = self.user
            targetUser.avatarClubModel = selectedClub
            self.tableView.reloadRows(at: [IndexPath(row: 2, section: 1)], with: .automatic)
            }) { (code) -> () in
                self.showToast(LS("网络错误"), onSelf: true)
        }
    }
    
    func setAvatarPressed() {
        let alert = UIAlertController(title: NSLocalizedString("选择图片", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
        iconImage.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(infoLbl.snp.left).offset(-8)
            make.centerY.equalTo(infoLbl)
            make.size.equalTo(20)
        }
        
        boolSelect.isHidden = true
        markIcon.isHidden = true
        self.selectionStyle = .none
    }
}




