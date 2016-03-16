//
//  ActivityRelease.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityReleaseController: InputableViewController, UITableViewDataSource, UITableViewDelegate, FFSelectDelegate, CustomDatePickerDelegate, ImageInputSelectorDelegate, BMKLocationServiceDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate {
    
    weak var actHomeController: ActivityHomeController?
    
    var board: ActivityReleaseInfoBoard!
    var boardHeight: CGFloat = 0
    var tableView: UITableView!
    
    var datePicker: CustomDatePicker!
    var datePickerMode: String = "startAt"  // startAt or endAt
    
    var attendNum: Int = 10
    var startAt: String = LS("请选择活动开始时间")
    var startAtDate: NSDate?
    var endAt: String = LS("请选择活动截止时间")
    var endAtDate: NSDate?
    var clubLimit: String = LS("全部")
    var clubLimitID: String? = nil
    var poster: UIImage?
    
    var locationService: BMKLocationService?
    var userLocation: CLLocationCoordinate2D?
    var geoSearch: BMKGeoCodeSearch?
    var mapCell: ActivityReleaseMapCell!
    var skipFirstLocFlag = true
    var locDescriptin: String?
    var setCenterFlag: Bool = false
    var locInput: UITextField? {
        return mapCell.locInput
    }
    
    var mapView: BMKMapView? {
        return mapCell.map
    }
    
    override func viewDidLoad() {
        navSettings()
        super.viewDidLoad()
        
        locationService = BMKLocationService()
        geoSearch = BMKGeoCodeSearch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationService?.delegate = self
        locationService?.startUserLocationService()
        geoSearch?.delegate = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        locationService?.delegate = nil
        geoSearch?.delegate = nil
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布活动")
        //
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: "navLeftBtnPressed")
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem
        //
        let rightItem = UIBarButtonItem(title: LS("发布"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.inputFields.each { (view) -> () in
            view?.resignFirstResponder()
        }
        // 检查数据完整性
        guard let actName = board.actNameInput.text where actName != "" else{
            self.displayAlertController(LS("请填写活动名称"), message: nil)
            return
        }
        
        guard let actDes = board.actDesInput.text where board.actDesEditStart else {
            self.displayAlertController(LS("请填写活动描述"), message: nil)
            return
        }
        
        guard let posterImage = self.poster else{
            self.displayAlertController(LS("请选择活动海报"), message: nil)
            return
        }
        
        if userLocation == nil{
            self.displayAlertController(LS("无法获取当前位置"), message: nil)
            return
        }
        
        if startAtDate == nil {
            self.displayAlertController(LS("请选择活动开始时间"), message: nil)
            return
        }
        
        if endAtDate == nil {
            self.displayAlertController(LS("请选择活动结束时间"), message: nil)
            return
        }
        
        var informUser: [String]? = nil
        if board.informOfUsers.count > 0 {
            informUser = board.informOfUsers.map({ (user) -> String in
                return user.userID!
            })
        }
        
        // 上传数据
        let toast = showStaticToast(LS("发布中..."))
        let requester = ActivityRequester.requester
        requester.createNewActivity(actName, des: actDes, informUser: informUser, maxAttend: attendNum, startAt: startAtDate!, endAt: endAtDate!, clubLimit: clubLimitID, poster: posterImage, lat: userLocation!.latitude, lon: userLocation!.longitude, loc_des: locDescriptin ?? "", onSuccess: { (json) -> () in
            self.navigationController?.popViewControllerAnimated(true)
            let mine = self.actHomeController?.mine
            mine?.refreshControl?.beginRefreshing()
            mine?.getLatestActData()
            self.hideToast(toast)
            self.showToast(LS("发布成功！"))
            }) { (code) -> () in
                self.hideToast(toast)
                self.showToast(LS("发布失败，请检查网络设置"))
                print(code)
        }
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
        board.posterBtn.addTarget(self, action: "posterSelectBtnPressed", forControlEvents: .TouchUpInside)
        //
        tableView.separatorStyle = .None
        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.registerClass(ActivityReleaseCell.self, forCellReuseIdentifier: ActivityReleaseCell.reuseIdentifier)
        tableView.registerClass(ActivityReleaseMapCell.self, forCellReuseIdentifier: ActivityReleaseMapCell.reuseIdentifier)
        //
        datePicker = CustomDatePicker()
        datePicker.delegate = self
        self.view.addSubview(datePicker)
        datePicker.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.height.equalTo(CustomDatePicker.requiredHegiht)
            make.bottom.equalTo(self.view).offset(CustomDatePicker.requiredHegiht)
        }
        //
        mapCell = ActivityReleaseMapCell(style: .Default, reuseIdentifier: ActivityReleaseMapCell.reuseIdentifier)
        inputFields.append(mapCell.locInput)
        mapCell.locInput.delegate = self
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
            return 500
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
                cell.editable = true
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
                cell.staticInfoLabel.text = startAt
                cell.arrowDirection = "down"
                break
            case 2:
                // 结束时间
                cell.staticInfoLabel.text = endAt
                cell.arrowDirection = "down"
                break
            case 3:
                cell.staticInfoLabel.text = clubLimit
                cell.arrowDirection = "down"
            default:
                break
            }
            return cell
        }else{
            if !setCenterFlag && self.userLocation != nil {
                let region = BMKCoordinateRegionMakeWithDistance(self.userLocation!, 3000, 5000)
                setCenterFlag = true
                mapView?.setRegion(region, animated: true)
            }
            
            return mapCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 1:
            datePickerMode = "startAt"
            showDatePicker()
            break
        case 2:
            datePickerMode = "endAt"
            showDatePicker()
            break
        default:
            datePickerMode = ""
            break
        }
    }
}

extension ActivityReleaseController {
    
    //
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == board.actNameInput {
            // 
            board.actNameInput.textColor = UIColor.blackColor()
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
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == board.actNameInput {
            return
        }
        var view: UIView? = textField
        var index: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        while true {
            if let cell = view as? UITableViewCell {
                index = self.tableView.indexPathForRowAtPoint(cell.center)!
//                index = self.tableView.indexPathForCell(cell)!
                break
            }
            view = view?.superview
            if view == nil{
                return
            }
        }
        if index.section == 0 && index.row == 0 {
            attendNum = Int(textField.text ?? "0")!
        } else if index.section == 0 && index.row == 4 {
            locDescriptin = textField.text
        }
    }

    // 初次开始编辑时清除placeholder
    func textViewDidBeginEditing(textView: UITextView) {
        if board.actDesEditStart {
            return
        }
        board.actDesInput.textColor = UIColor.blackColor()
        board.actDesEditStart = true
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
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService?.stopUserLocationService()
        self.userLocation = userLocation.location.coordinate
        let region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 3000, 5000)
        mapView?.setRegion(region, animated: true)
        mapView?.delegate = self
    }
    
    func mapView(mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
        let visibleRegion = mapView.region
        if !skipFirstLocFlag || userLocation == nil{
            userLocation = visibleRegion.center
        } else {
            skipFirstLocFlag = false
        }
        tableView.scrollEnabled = true
        getLocationDescription(userLocation!)
    }
    
    func mapView(mapView: BMKMapView!, regionWillChangeAnimated animated: Bool) {
        tableView.scrollEnabled = false
    }
    
    func getLocationDescription(location: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = location
        let res = geoSearch!.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取制定位置信息"))
        }
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locDescriptin = result.address
            locInput?.text = result.address
        } else {
            self.showToast(LS("无法获取制定位置信息"))
        }
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

extension ActivityReleaseController {
    
    func posterSelectBtnPressed() {
        let detail = ImageInputSelectorController()
        detail.delegate = self
        detail.bgImage = self.getScreenShotBlurred(false)
        self.presentViewController(detail, animated: false, completion: nil)
    }
    
    func imageInputSelectorDidCancel() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func imageInputSelectorDidSelectImage(image: UIImage) {
        self.dismissViewControllerAnimated(false, completion: nil)
        poster = image
        let btn = board.posterBtn
        btn.setTitle("", forState: .Normal)
        btn.setImage(image, forState: .Normal)
        board.posterLbl.hidden = true
    }
}

extension ActivityReleaseController {
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        if datePickerMode == "startAt" || datePickerMode == "endAt" {
            hideDatePicker()
        }
    }
    
    func showDatePicker() {
        self.tapper?.enabled = true
        datePicker.reset()
        datePicker.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideDatePicker() {
        datePicker.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(CustomDatePicker.requiredHegiht)
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func dateDidPicked(date: NSDate) {
        
        if datePickerMode == "startAt" {
            if endAtDate != nil && endAtDate!.compare(date) == NSComparisonResult.OrderedAscending {
                self.displayAlertController(LS("结束时间不能早于开始时间"), message: nil)
                return
            }
            startAt = date.stringDisplay()!
            startAtDate = date
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
        }else if datePickerMode == "endAt" {
            if startAtDate != nil && startAtDate!.compare(date) == NSComparisonResult.OrderedDescending {
                self.displayAlertController(LS("开始时间不能晚于结束时间"), message: nil)
                return
            }
            endAt = date.stringDisplay()!
            endAtDate = date
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
        }
        hideDatePicker()
    }
    
    func datePickCancel() {
        hideDatePicker()
    }
}
