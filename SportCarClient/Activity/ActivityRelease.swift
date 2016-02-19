//
//  ActivityRelease.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox


class ActivityReleaseController: InputableViewController, UITableViewDataSource, UITableViewDelegate, FFSelectDelegate, MGLMapViewDelegate, CLLocationManagerDelegate {
    
    var board: ActivityReleaseInfoBoard!
    var boardHeight: CGFloat = 0
    var tableView: UITableView!
    
    var datePicker: CustomDatePicker!
    var datePickerMode: String = "startAt"  // startAt or endAt
    
    var attendNum: Int = 10
    var startAt: String = LS("请选择活动开始时间")
    var endAt: String = LS("请选择活动截止时间")
    var clubLimit: String = LS("全部")
    var clubLimitID: String? = nil
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocation?
    
    override func viewDidLoad() {
        navSettings()
        super.viewDidLoad()
        //
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布活动")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: LS("发布"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func createSubviews() {
        super.createSubviews()
        // 创建列表
        tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        //
        board = ActivityReleaseInfoBoard()
        board.releaser = self
        tableView.addSubview(board)
        board.frame = tableView.bounds
        let boardHeight = board.getRequiredHeight()
        self.boardHeight = boardHeight
        board.frame = CGRectMake(0, -boardHeight, UIScreen.mainScreen().bounds.width, boardHeight)
        tableView.contentInset = UIEdgeInsetsMake(boardHeight, 0, -44, 0)
        board.actNameInput.delegate = self
        board.actDesInput.delegate = self
        self.inputFields.append(board.actNameInput)
        self.inputFields.append(board.actDesInput)
        //
        tableView.separatorStyle = .None
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.registerClass(ActivityReleaseCell.self, forCellReuseIdentifier: ActivityReleaseCell.reuseIdentifier)
        tableView.registerClass(MapCell.self, forCellReuseIdentifier: MapCell.reuseIdentifier)
        tableView.registerClass(ActivityReleaseMapCell.self, forCellReuseIdentifier: ActivityReleaseMapCell.reuseIdentifier)
        //
        
    }
    
    func test() {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! PrivateChatSettingsHeader
        header.titleLbl.text = LS("具体设置")
        return header
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < 4 {
            return 50
        }else{
            return 250
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < 4 {
            let cell = (tableView.dequeueReusableCellWithIdentifier(ActivityReleaseCell.reuseIdentifier) as! ActivityReleaseCell) ?? ActivityReleaseCell(style: .Default, reuseIdentifier: ActivityReleaseCell.reuseIdentifier)
            cell.staticLbl.text = [LS("人数要求"), LS("开始时间"), LS("截止时间"), LS("参加成员")][indexPath.row]
            cell.editable = false
            cell.infoInput.keyboardType = .Default
            switch indexPath.row {
            case 0:
                // 活动参加人数
                cell.infoInput.text = "\(attendNum)"
                cell.infoInput.delegate = self
                cell.infoInput.keyboardType = .NumberPad
                var add = true
                for view in inputFields {
                    if view == cell.infoInput {
                        add = false
                        break
                    }
                }
                if add {
                    inputFields.append(cell.infoInput)
                }
                cell.arrowDirection = "left"
                break
            case 1:
                // 开始时间
                cell.infoInput.text = startAt
                cell.arrowDirection = "down"
                cell.infoInput.keyboardType = .Default
                break
            case 2:
                // 结束时间
                cell.infoInput.text = endAt
                cell.arrowDirection = "down"
                break
            case 3:
                cell.infoInput.text = clubLimit
                cell.arrowDirection = "down"
            default:
                break
            }
            return cell
        }else{
            let cell = (tableView.dequeueReusableCellWithIdentifier(ActivityReleaseMapCell.reuseIdentifier) as? ActivityReleaseMapCell) ?? ActivityReleaseMapCell(style: .Default, reuseIdentifier: MapCell.reuseIdentifier)
            // 添加进inputField
            var add = true
            for view in inputFields {
                if view == cell.locInput {
                    add = false
                    break
                }
            }
            if add {
                inputFields.append(cell.locInput)
                cell.locInput.delegate = self
            }
            if userLocation != nil {
                let center = CLLocationCoordinate2D(latitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude)
                cell.setMapCenter(center)
            }
            return cell
        }
    }
}

extension ActivityReleaseController {
    
    //
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == board.actNameInput {
            // 
            tableView.setContentOffset(CGPointMake(0, -boardHeight), animated: true)
        }else {
            // 此时必然是cell中的textField
            // 沿着view树向上找到cell
            var view: UIView? = textField
            var index: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            while true {
                if let cell = view as? UITableViewCell {
                    index = self.tableView.indexPathForCell(cell)!
                    break
                }
                view = view?.superview
                if view == nil{
                    return
                }
            }
            if index.section == 0 && index.row == 0 {
                tableView.setContentOffset(CGPointMake(0, 0), animated: true)
            }else if index.section == 0 && index.row == 4 {
                tableView.setContentOffset(CGPointMake(0, 100), animated: true)
            }
        }
    }
    
    // 初次开始编辑时清除placeholder
    func textViewDidBeginEditing(textView: UITextView) {
        if board.actDesEditStart {
            return
        }
        textView.text = ""
    }
    
    // 字数统计
    func textViewDidChange(textView: UITextView) {
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = textView.text
        if text.length > 90 {
            textView.text = text[0..<90]
        }
        board.actDesInputWordCount.text = "\(min(text.length, 90))/90"
    }
    
    // 防止编辑的文字过长
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRnage = textView.markedTextRange
            if selectedRnage == nil {
                return true
            }
        }
        let curText = textView.text as NSString
        let newText = curText.stringByReplacingCharactersInRange(range, withString: text) as String
        if newText.length > 90 {
            return false
        }
        return true
    }
}

extension ActivityReleaseController {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last()
        tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
}

extension ActivityReleaseController {
    func userSelectCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        board.informOfUsers = users
        board.informOfList.users = users
        board.informOfList.collectionView?.reloadData()
        board.informOfListCountLbl.text = "\(users.count)/9"
    }
}
