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


class SportCarSelectParamCell: UITableViewCell {
    
    static let reuseIdentifier = "SportCarSelectParamCell"
    
    var content: UILabel?
    var header: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.createSubviews()
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
        
        let icon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
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

class SportCarSelectDetailController: UIViewController, SportCarBrandSelecterControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var carDisplay: UIImageView?
    var carSelectBtn: UIButton?
    
    var tableView: UITableView?
    var headers: [String]?
    var contents: [String?]?
    
    var carType: String?
    var carDisplayURL: NSURL?
    
    var carId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBarSettings()
        createSubviews()
    }
    
    // MARK: Navigation设置
    func navigationBarSettings() {
        self.navigationItem.title = NSLocalizedString("补充信息", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
        self.navigationItem.rightBarButtonItem = navBarRigthBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), forState: .Normal)
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: "nextBtnPressed", forControlEvents: .TouchUpInside)
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
        let requester = SportCarRequester.sharedSCRequester
        requester.postToFollow(contents![1], carId: carId!, onSuccess: { () -> () in
            print("Done！")
            }) { (code) -> () in
                self.displayAlertController(LS("错误"), message: LS("服务器发生了内部错误"))
        }
    }
    
    func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        carDisplay = UIImageView()
        let downloadIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        superview.addSubview(carDisplay!)
        carDisplay?.kf_setImageWithURL(carDisplayURL!, placeholderImage: UIImage(named: "account_car_select_placeholder"), optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            downloadIndicator.stopAnimating()
        })
        carDisplay?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(0.5)
            make.height.equalTo(carDisplay!.snp_width).multipliedBy(0.58)
        })
        
        carDisplay?.addSubview(downloadIndicator)
        downloadIndicator.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(carDisplay!)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        downloadIndicator.startAnimating()
        downloadIndicator.hidesWhenStopped = true
        //
        carSelectBtn = UIButton()
        carSelectBtn?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        carSelectBtn?.setTitle(carType, forState: .Normal)
        carSelectBtn?.titleLabel?.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        carSelectBtn?.titleLabel?.textAlignment = .Center
        superview.addSubview(carSelectBtn!)
        carSelectBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(carDisplay!.snp_right)
            make.right.equalTo(superview)
            make.centerY.equalTo(carDisplay!)
            make.height.equalTo(44)
        })
        carSelectBtn?.addTarget(self, action: "selectSportCarBrandPressed", forControlEvents: .TouchUpInside)
        //
        let btnIcon = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        carSelectBtn?.addSubview(btnIcon)
        btnIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(carSelectBtn!).offset(-15)
            make.centerY.equalTo(carSelectBtn!)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        //
        tableView = UITableView(frame: CGRect.zero, style: .Plain)
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.registerClass(SportCarSelectParamCell.self, forCellReuseIdentifier: SportCarSelectParamCell.reuseIdentifier)
        tableView?.separatorColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(tableView!)
        tableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(carDisplay!.snp_bottom)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview)
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if headers == nil {
            return 0
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if headers == nil {
            return 0
        }
        if section == 0 {
            return 2
        }
        return headers!.count - 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return nil
        }else{
            return LS("性能参数")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 0.01
        }
        return 50
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
        carSelectBtn?.setTitle(LS("获取跑车资料中..."), forState: .Normal)
        carSelectBtn?.enabled = false
        let requester = SportCarRequester.sharedSCRequester
        requester.querySportCarWith(manufacturer!, carName: carType!, onSuccess: { (data) -> () in
            let carImgURL = SF(data["image_url"].stringValue)
            self.carDisplayURL = NSURL(string: carImgURL ?? "")
            let downloadIndicator = self.carDisplay?.subviews.first! as! UIActivityIndicatorView
            downloadIndicator.startAnimating()
            self.carDisplay?.kf_setImageWithURL(self.carDisplayURL!, placeholderImage: UIImage(named: "account_car_select_placeholder"), optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                downloadIndicator.stopAnimating()
            })
            
            self.carId = data["car_id"].string
            self.contents = [carType, self.contents![1], data["price"].string, data["engine"].string, data["transmission"].string, data["body"].string, data["max_speed"].string, data["zeroTo60"].string]
            self.carSelectBtn?.enabled = true
            self.carSelectBtn?.setTitle(carType, forState: .Normal)
            self.tableView?.reloadData()
            
            }) { (code) -> () in
                // 弹窗说明错误
                let alert = UIAlertController(title: LS("载入跑车数据失败"), message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: { (action) -> Void in
                    self.carSelectBtn?.setTitle(LS("重选跑车"), forState: .Normal)
                }))
                self.carSelectBtn?.enabled = true
        }
    }
}




