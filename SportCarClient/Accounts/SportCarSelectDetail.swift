//
//  SportCarSelectDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/15.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


protocol SportCarSelectDetailProtocol: class {
    func sportCarSelectDeatilDidAddCar(car: SportCar)
}


class SportCarSelectParamCell: UITableViewCell {
    
    static let reuseIdentifier = "SportCarSelectParamCell"
    
    var content: UILabel?
    var header: UILabel?
    var icon: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubviews()
        self.selectionStyle = .None
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        content = UILabel()
        content?.font = UIFont.systemFontOfSize(14)
        content?.textColor = UIColor.blackColor()
        content?.textAlignment = .Right
        self.contentView.addSubview(content!)
        
        header = UILabel()
        header?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        header?.textColor = UIColor(white: 0.72, alpha: 1)
        header?.textAlignment = .Left
        self.contentView.addSubview(header!)
        
        icon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        self.contentView.addSubview(icon)
        
        let superview = self.contentView
        // 添加约束
        content?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-38)
            make.top.equalTo(superview).offset(22)
            make.height.equalTo(20)
            make.width.equalTo(self.contentView).multipliedBy(0.5)
        })
        //
        header?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(content!)
            make.height.equalTo(17)
            make.width.equalTo(self.contentView).multipliedBy(0.4)
        })
        //
        icon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(content!)
            make.right.equalTo(self.contentView).offset(-15)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
    }
}

class SportCarSelectParamEditableCell: SportCarSelectParamCell {
    var contentInput: UITextField!

    override func createSubviews() {
        super.createSubviews()
        contentInput = UITextField()
        contentInput.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        contentInput.textColor = UIColor.blackColor()
        contentInput.textAlignment = .Right
        self.contentView.addSubview(contentInput)
        contentInput.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(content!)
        }
        content?.text = ""
        content?.userInteractionEnabled = false
        self.contentView.addSubview(contentInput)
    }
}

class SportCarSelectDetailController: UITableViewController, SportCarBrandSelecterControllerDelegate {
    
    var headers: [String]?
    var contents: [String?]?
    
    var carType: String?
    var carDisplayURL: NSURL?
    
    var carId: String?
    
    weak var contentInput: UITextField?
    weak var delegate: SportCarSelectDetailProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSettings()
        createSubviews()
    }
    
    // MARK: Navigation设置
    func navigationBarSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = NSLocalizedString("补充信息", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
        self.navigationItem.rightBarButtonItem = navBarRigthBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(SportCarSelectDetailController.backBtnPressed), forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), forState: .Normal)
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: #selector(SportCarSelectDetailController.nextBtnPressed), forControlEvents: .TouchUpInside)
        let rightBtnItem = UIBarButtonItem(customView: nextStepBtn)
        return rightBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
     下一步，将本处选择的跑车设置为未认证的关注跑车
     */
    func nextBtnPressed() {
        contentInput?.resignFirstResponder()
        let signature: String = contentInput?.text ?? ""
        SportCarRequester.sharedInstance.postToFollow(signature, carId: carId!, onSuccess: { (json) -> () in
            // add this car to current users
            let car: SportCar = try! MainManager.sharedManager.getOrCreate(SportCar.reorgnaizeJSON(json!))
            if MainManager.sharedManager.hostUser != nil {
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                let app = AppManager.sharedAppManager
                app.guideToContent()
            }
            self.delegate?.sportCarSelectDeatilDidAddCar(car)
            }) { (code) -> () in
                if code == "No permission" {
                    self.showToast(LS("请先认证您的第一辆爱车"))
                } else {
                    self.showToast(LS("服务器发生了内部错误"))
                }
        }
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        tableView.registerClass(SportCarSelectParamCell.self, forCellReuseIdentifier: SportCarSelectParamCell.reuseIdentifier)
        tableView.registerClass(SportCarSelectParamEditableCell.self, forCellReuseIdentifier: "edit")
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.separatorColor = UIColor(white: 0.92, alpha: 1)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if headers == nil {
            return 0
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headers == nil {
            return 0
        }
        if section == 0 {
            return 2
        }
        return headers!.count - 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("edit", forIndexPath: indexPath) as! SportCarSelectParamEditableCell
            cell.header?.text = LS(headers![indexPath.row])
            cell.contentInput.placeholder = LS("为爱车写一段签名吧(选填)")
            self.contentInput = cell.contentInput
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(SportCarSelectParamCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarSelectParamCell
        if indexPath.section == 0 {
            cell.header?.text = LS(headers![indexPath.row])
            cell.content?.text = contents![indexPath.row]
        }else{
            cell.header?.text = LS(headers![indexPath.row + 2])
            cell.content?.text = contents![indexPath.row + 2]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! PrivateChatSettingsHeader
        header.titleLbl.text = [LS("爱车型号"), LS("性能参数")][section]
        return header
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            selectSportCarBrandPressed()
        }
    }
    
    func selectSportCarBrandPressed() {
        let select = SportCarBrandSelecterController()
        select.delegate = self
        let nav = BlackBarNavigationController(rootViewController: select)
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func brandSelected(manufacturer: String?, carType: String?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if manufacturer == nil || carType == nil {
            return
        }
        SportCarRequester.sharedInstance.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
            guard let data = data else {
                return
            }
            let carImgURL = SF(data["image_url"].stringValue)
            self.carDisplayURL = NSURL(string: carImgURL ?? "")
            self.carId = data["carID"].stringValue
            self.contents = [carType, self.contents![1], data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            self.tableView?.reloadData()

            }) { (code) -> () in
                self.showToast(LS("载入爱车数据失败"))
        }
    }
}




