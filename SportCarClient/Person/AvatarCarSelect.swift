//
//  AvatarCarSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol AvatarCarSelectDelegate: class {
    func avatarCarSelectDidFinish(_ selectedCar: SportCar)
    
    func avatarCarSelectDidCancel()
}


class AvatarCarSelectController: AvatarItemSelectController {
    
    weak var delegate: AvatarCarSelectDelegate?
    
    var cars: [SportCar] = []
    var user: User = MainManager.sharedManager.hostUser!
    
    var selectedRow: Int = -1
    
    fileprivate var addAuthCarBtn: UIButton!
    fileprivate var addAuthCarLbl: UILabel!
    fileprivate weak var toast: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        let requester = AccountRequester2.sharedInstance
        toast = showStaticToast(LS("载入中...请稍后"))
        _ = requester.getAuthedCarsList(user.ssidString, onSuccess: { (json) in
            let data = json!.arrayValue
            var i = 0
            if data.count > 0 {
                for carJSON in data {
                    let car = try! MainManager.sharedManager.getOrCreate(SportCar.reorgnaizeJSON(carJSON)) as SportCar
                    self.cars.append(car)
                    if car.ssid == self.user.avatarCarModel?.ssid {
                        self.selectedRow = i
                    }
                    i += 1
                }
                self.tableView.reloadData()
            } else {
                self.showNoCars()
            }
            if self.toast != nil {
                self.hideToast(self.toast!)
            }
            }) { (code) in
                assert(Thread.isMainThread)
                self.showNoCars()
                if self.toast != nil {
                    self.hideToast(self.toast!)
                }
        }
    }
    
    func showNoCars() {
        let superview = self.view!
        //
        addAuthCarBtn = UIButton()
        addAuthCarBtn.setImage(UIImage(named: "auth_add_item_btn"), for: UIControlState())
        superview.addSubview(addAuthCarBtn)
        addAuthCarBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(35)
            make.size.equalTo(90)
        }
        addAuthCarBtn.addTarget(self, action: #selector(AvatarCarSelectController.addAuthBtnPressed), for: .touchUpInside)
        //
        addAuthCarLbl = UILabel()
        addAuthCarLbl.text = LS("暂无认证跑车，点击添加")
        addAuthCarLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        addAuthCarLbl.textColor = UIColor(white: 0.72, alpha: 1)
        addAuthCarLbl.textAlignment = .center
        superview.addSubview(addAuthCarLbl)
        addAuthCarLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(addAuthCarBtn)
            make.top.equalTo(addAuthCarBtn.snp.bottom).offset(25)
        }
        
        addAuthCarBtn.isHidden = true
        addAuthCarLbl.isHidden = true
    }
    
    func addAuthBtnPressed() {
        
    }
    
    override func navTitle() -> String {
        return "签名车"
    }
    
    override func navLeftBtnPressed() {
        super.navLeftBtnPressed()
        delegate?.avatarCarSelectDidCancel()
    }
    
    override func navRightBtnPressed() {
        super.navRightBtnPressed()
        if selectedRow >= 0 {
            delegate?.avatarCarSelectDidFinish(cars[selectedRow])
        }else{
            delegate?.avatarCarSelectDidCancel()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AvatarItemSelectCell.reuseIdentifier, for: indexPath) as! AvatarItemSelectCell
        let car = cars[(indexPath as NSIndexPath).row]
        cell.avatarImg.kf.setImage(with: car.logoURL!)
        cell.nickNameLbl?.text = car.name
        cell.selectBtn?.tag = (indexPath as NSIndexPath).row
        if car.identified {
            cell.authed = true
            cell.authIcon.image = UIImage(named: "auth_status_authed")
        }else{
            cell.authed = false
            cell.authIcon.image = UIImage(named: "auth_status_unauthed")
        }
        //
        if selectedRow == (indexPath as NSIndexPath).row {
            cell.selectBtn?.isSelected = true
        }else {
            cell.selectBtn?.isSelected = false
        }
        cell.onSelect = { [weak self] (sender: UIButton) in
            guard let sSelf = self else {
                return false
            }
            let row = sender.tag
            let targetOwn = sSelf.cars[row]
            if targetOwn.identified == false {
                sSelf.showToast(LS("请返回认证跑车"))
                return true
            }
            if sender.isSelected {
                sSelf.selectedRow = -1
            }else{
                sSelf.selectedRow = row
            }
            sSelf.tableView.reloadData()
            return true
        }
        return cell
    }
}
