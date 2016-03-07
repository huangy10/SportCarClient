//
//  AvatarCarSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol AvatarCarSelectDelegate {
    func avatarCarSelectDidFinish(selectedCar: SportCarOwnerShip)
    
    func avatarCarSelectDidCancel()
}


class AvatarCarSelectController: AvatarItemSelectController {
    
    var delegate: AvatarCarSelectDelegate?
    
    var cars: [SportCarOwnerShip] = []
    var user: User = User.objects.hostUser()!
    
    var selectedRow: Int = -1
    
    var addAuthCarBtn: UIButton!
    var addAuthCarLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
        //
        let requester = PersonRequester.requester
        requester.getAuthedCars(user.userID!, onSuccess: { (json) -> () in
            let data = json!.arrayValue
            var i = 0
            for carJSON in data {
                let own = SportCarOwnerShip.objects.createOrLoadOwnedCars(carJSON, owner: self.user)
                self.cars.append(own!)
                if own!.car?.carID == self.user.profile?.avatarCarID {
                    self.selectedRow = i
                }
                i += 1
            }
            self.tableView.reloadData()
            }) { (code) -> () in
        }
    }
    
    func createSubviews() {
        let superview = self.view
        //
        addAuthCarBtn = UIButton()
        addAuthCarBtn.setImage(UIImage(named: "auth_add_item_btn"), forState: .Normal)
        superview.addSubview(addAuthCarBtn)
        addAuthCarBtn.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(35)
            make.size.equalTo(90)
        }
        addAuthCarBtn.addTarget(self, action: "addAuthBtnPressed", forControlEvents: .TouchUpInside)
        //
        addAuthCarLbl = UILabel()
        addAuthCarLbl.text = LS("暂无认证跑车，点击添加")
        addAuthCarLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        addAuthCarLbl.textColor = UIColor(white: 0.72, alpha: 1)
        addAuthCarLbl.textAlignment = .Center
        superview.addSubview(addAuthCarLbl)
        addAuthCarLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(addAuthCarBtn)
            make.top.equalTo(addAuthCarBtn.snp_bottom).offset(25)
        }
        
        addAuthCarBtn.hidden = true
        addAuthCarLbl.hidden = true
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addAuthCarLbl.hidden = cars.count != 0
        addAuthCarBtn.hidden = addAuthCarLbl.hidden
        return cars.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(AvatarItemSelectCell.reuseIdentifier, forIndexPath: indexPath) as! AvatarItemSelectCell
        let own = cars[indexPath.row]
        let car = own.car
        cell.avatarImg?.kf_setImageWithURL(SFURL(car!.logo!)!)
        cell.nickNameLbl?.text = car?.name
        cell.selectBtn?.tag = indexPath.row
        if own.identified {
            cell.authed = true
            cell.authIcon.image = UIImage(named: "auth_status_authed")
        }else{
            cell.authed = false
            cell.authIcon.image = UIImage(named: "auth_status_unauthed")
        }
        //
        if selectedRow == indexPath.row {
            cell.selectBtn?.selected = true
        }else {
            cell.selectBtn?.selected = false
        }
        cell.onSelect = { (sender: UIButton) in
            let row = sender.tag
            if sender.selected {
                self.selectedRow = -1
            }else{
                self.selectedRow = row
            }
            self.tableView.reloadData()
        }
        return cell
    }
}
