//
//  ActivityRelease.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class ActivityReleaseController: InputableViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, ProgressProtocol, CustomDatePickerDelegate, AvatarClubSelectDelegate, ImageInputSelectorDelegate, FFSelectDelegate, LocationSelectDelegate {
    weak var actHomeController: ActivityHomeController?
    
//    var pp_progressView: UIProgressView?
    
    var imagePickerBtn: UIButton!
    var nameInput: UITextField!
    var desInput: UITextView!
    var desWordCountLbl: UILabel!
    var datePicker: CustomDatePicker!
    
    var tableView: UITableView!
    var inlineMiniUserSelectView: UICollectionView!
    var userSelectedCount: UILabel!
    var mapCell: ActivityReleaseMapCell!
    var mapView: BMKMapView {
        return mapCell.map
    }
    var maxAttendCell: SSPropertyInputableCell!
    
    var poster: UIImage?
    var startAt: NSDate?
    var endAt: NSDate?
    var clubLimit: Club?
    var maxAttend: Int = 10
    var selectedUser: [User] = []
    
    var locationService: BMKLocationService!
    var geoSearch: BMKGeoCodeSearch!
    var userLocation: CLLocationCoordinate2D?
    var locDescription: String?
    
    var didBeginEditActDes: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        locationService = BMKLocationService()
        geoSearch = BMKGeoCodeSearch()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
        locationService.delegate = self
        mapView.delegate = self
        geoSearch.delegate = self
        if self.userLocation == nil {
            locationService.startUserLocationService()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
        locationService.delegate = nil
        mapView.delegate = nil
        geoSearch.delegate = nil
        locationService.delegate = nil
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        
        tableView = UITableView(frame: CGRectZero, style: .Grouped)
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        superview.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        tableView.contentInset = UIEdgeInsetsMake(275, 0, 0, 0)
        tableView.setContentOffset(CGPointMake(0, -275), animated: false)
        SSPropertyCell.registerTableView(tableView)
        SSPropertyInputableCell.registerTableView(tableView)
        SSCommonHeader.registerTableView(tableView)
        
        let container = tableView.addSubview(UIView)
            .setFrame(CGRectMake(0, -275, superview.frame.width, 275))
            .config(UIColor.whiteColor())
        imagePickerBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(needPickPoster), image: UIImage(named: "status_add_image"))
            .layout({ (make) in
                make.left.equalTo(container).offset(15)
                make.top.equalTo(container).offset(15)
                make.size.equalTo(100)
            })
        let static1 = container.addSubview(UILabel)
            .config(fontWeight: UIFontWeightSemibold, text: LS("取一个名字"))
            .layout { (make) in
                make.left.equalTo(imagePickerBtn.snp_right).offset(18)
                make.top.equalTo(imagePickerBtn)
        }
        let wrapper = container.addSubview(UIScrollView).config(UIColor.whiteColor())
            .layout { (make) in
                make.left.equalTo(static1)
                make.top.equalTo(static1.snp_bottom).offset(14)
                make.bottom.equalTo(imagePickerBtn)
                make.right.equalTo(container).offset(-15)
        }
        nameInput = wrapper.addSubview(UITextField)
            .config(14, placeholder: LS("为活动取一个名字...")).layout({ (make) in
                make.left.equalTo(static1)
                make.top.equalTo(static1.snp_bottom).offset(14)
            }).addToInputable(self)
        desInput = container.addSubview(UITextView)
            .config(14, textColor: UIColor(white: 0.72, alpha: 1), text: LS("活动描述..."))
            .layout({ (make) in
                make.left.equalTo(imagePickerBtn)
                make.right.equalTo(container).offset(-15)
                make.top.equalTo(imagePickerBtn.snp_bottom).offset(16)
                make.height.equalTo(100)
            }).addToInputable(self)
        desWordCountLbl = container.addSubview(UILabel)
            .config(12, textAlignment: .Right, text: "0/40", textColor: UIColor(white: 0.72, alpha: 1)).layout({ (make) in
                make.right.equalTo(container).offset(-15)
                make.bottom.equalTo(desInput)
            })
        let atBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(needAtSomeone), title: LS("@提醒谁看"), titleColor: UIColor.blackColor())
            .layout { (make) in
                make.left.equalTo(container).offset(15)
                make.top.equalTo(desInput.snp_bottom)
                make.bottom.equalTo(container)
                make.width.equalTo(80)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSizeMake(35, 35)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        inlineMiniUserSelectView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout).config(UIColor.whiteColor())
        inlineMiniUserSelectView.delegate = self
        inlineMiniUserSelectView.dataSource = self
        container.addSubview(inlineMiniUserSelectView)
        inlineMiniUserSelectView.snp_makeConstraints { (make) in
            make.left.equalTo(atBtn.snp_right)
            make.right.equalTo(container)
            make.top.equalTo(desInput.snp_bottom)
            make.bottom.equalTo(container)
        }
        inlineMiniUserSelectView.registerClass(InlineUserSelectMiniCell.self, forCellWithReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier)
        
        userSelectedCount = container.addSubview(UILabel)
            .config(12, textAlignment: .Right, text: "0/\(kMaxSelectUserNum)", textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.right.equalTo(container).offset(-15)
                make.bottom.equalTo(container).offset(-5)
            })
        
        //
        mapCell = ActivityReleaseMapCell(trailingHeight: 100)
        mapCell.map.delegate = self
        mapCell.onInvokeLocationSelect = { [weak self] in
            guard let sSelf = self else {
                return
            }
            let locationSelect = LocationSelectController(currentLocation: self?.userLocation, des: self?.mapCell.locDisplay.text)
            locationSelect.delegate = sSelf
            sSelf.presentViewController(locationSelect.toNavWrapper(), animated: true, completion: nil)
        }
        
        maxAttendCell = SSPropertyInputableCell(style: .Default, reuseIdentifier: "inputable")
        maxAttendCell.contentInput.addToInputable(self)
        //
        datePicker = CustomDatePicker()
        datePicker.delegate = self
        superview.addSubview(datePicker)
        datePicker.snp_makeConstraints { (make) in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview).offset(CustomDatePicker.requiredHegiht)
            make.height.equalTo(CustomDatePicker.requiredHegiht)
        }
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        if datePicker.tag >= 0 {
            datePicker.hide()
        }
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布活动")
        //
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: #selector(ActivityReleaseController.navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem
        //
        let rightItem = UIBarButtonItem(title: LS("发布"), style: .Done, target: self, action: #selector(ActivityReleaseController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        self.inputFields.each { (view) in
            view?.resignFirstResponder()
        }
        // check integrity of the data
        guard let actName = nameInput.text where actName.length > 0 else {
            showToast(LS("请填写活动名称"), onSelf: true)
            return
        }
        guard let actDes = desInput.text where actDes.length > 0 else {
            showToast(LS("请填写活动描述"), onSelf: true)
            return
        }
        guard let posterImage = poster else {
            showToast(LS("请选择活动海报"), onSelf: true)
            return
        }
        guard let loc = userLocation else {
            showToast(LS("无法获取当前位置"), onSelf: true)
            return
        }
        guard let startAtDate = startAt, let endAtDate = endAt else {
            showToast(LS("请设置活动时间"), onSelf: true)
            return
        }
        let clubLimitID = clubLimit?.ssidString
        var selectedUserIDs: [String]? = nil
        if selectedUser.count > 0 {
            selectedUserIDs = selectedUser.map { $0.ssidString }
        }
        let toast = showStaticToast(LS("发布中..."))
        pp_showProgressView()
        ActivityRequester.sharedInstance.createNewActivity(actName, des: actDes, informUser: selectedUserIDs, maxAttend: maxAttend, startAt: startAtDate, endAt: endAtDate, clubLimit: clubLimitID, poster: posterImage, lat: loc.latitude, lon: loc.longitude, loc_des: locDescription ?? "", onSuccess: { (json) in
            self.navigationController?.popViewControllerAnimated(true)
            if let mine = self.actHomeController?.mine {
                mine.refreshControl.beginRefreshing()
                mine.getLatestActData()
            }
            self.hideToast(toast)
            self.pp_hideProgressView()
            if let presenter = self.presentingViewController {
                presenter.showToast(LS("发布成功"))
            } else {
                self.showToast(LS("发布成功!"))
            }
            
            }, onProgress: { (progress) in
                dispatch_async(dispatch_get_main_queue(), { 
                    self.pp_updateProgress(progress)
                })
            }) { (code) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideToast(toast)
                    self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
                    self.pp_hideProgressView()
                })
        }
    }
    
    func needPickPoster() {
        let picker = ImageInputSelectorController()
        picker.bgImage = getScreenShotBlurred(false)
        picker.delegate = self
        self.presentViewController(picker, animated: false, completion: nil)
    }
    
    func needAtSomeone() {
        let select = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: selectedUser, preSelect: true, forced: false)
        select.delegate = self
        self.presentViewController(select.toNavWrapper(), animated: true, completion: nil)
    }
    
    // MARK: tableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.ss_reusableHeader(SSCommonHeader)
        header.titleLbl.text = LS("基本设置")
        return header
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row < 4 {
            return 50
        } else {
            return 450
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < 4 {
            switch indexPath.row {
            case 0:
                maxAttendCell.staticLbl.text = LS("人数要求")
                maxAttendCell.extraSettings(nil, text: "\(maxAttend)", placeholder: LS("活动最大人数"))
                return maxAttendCell
            case 1:
                let cell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
                return cell.setData(LS("开始时间"), propertyValue: startAt?.stringDisplay() ?? LS("请选择开始时间"))
            case 2:
                let cell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
                return cell.setData(LS("截止时间"), propertyValue: endAt?.stringDisplay() ?? LS("请选择结束时间"))
            default:
                let cell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
                return cell.setData(LS("参加成员"), propertyValue: clubLimit?.name ?? LS("全部"))
            }
        } else {
            return mapCell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 1:
            datePicker.tag = 0
            self.tapper?.enabled = true
            datePicker.show()
        case 2:
            datePicker.tag = 1
            self.tapper?.enabled = true
            datePicker.show()
        case 3:
            let detail = AvatarClubSelectController()
            detail.delegate = self
            detail.preSelectID = clubLimit?.ssid
            detail.noIntialSelect = true
            self.navigationController?.pushViewController(detail, animated: true)
        default:
            break
        }
    }
    
    // MARK: Collection
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUser.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectMiniCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectMiniCell
        cell.user = selectedUser[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = selectedUser[indexPath.row]
        self.navigationController?.pushViewController(user.showDetailController(), animated: true)
    }
    
    // MARK: user select
    
    func userSelectCancelled() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        selectedUser = users
        userSelectedCount.text = "\(users.count)/\(kMaxSelectUserNum)"
        inlineMiniUserSelectView.reloadData()
    }
    
    // MARK: image select
    
    func imageInputSelectorDidSelectImage(image: UIImage) {
        dismissViewControllerAnimated(false, completion: nil)
        poster = image
        imagePickerBtn.setImage(image, forState: .Normal)
    }
    
    func imageInputSelectorDidCancel() {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: Avatar club select
    
    func avatarClubSelectDidFinish(selectedClub: Club) {
        clubLimit = selectedClub
        tableView.beginUpdates()
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    func avatarClubSelectDidCancel() {
        // do nothing
    }
    
    // MARK: date picker
    
    func datePickCancel() {
        datePicker.hide()
        datePicker.tag = -1
    }
    
    func dateDidPicked(date: NSDate) {
        datePicker.hide()
        if datePicker.tag == 0 {
            startAt = date
            endAt = nil
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0)], withRowAnimation: .Automatic)
        } else if datePicker.tag == 1 {
            endAt = date
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
        } else {
            assertionFailure()
        }
        datePicker.tag = -1
    }
    
    // MARK: map
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        locationService.delegate = nil
        self.userLocation = userLocation.location.coordinate
        mapView.setCenterCoordinate(self.userLocation!, animated: true)
        mapView.zoomLevel = 16
        mapView.delegate = self
        getLocationDescription(self.userLocation!)
    }
//    
//    func mapView(mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
//        if !animated {
//            let visibleRegion = mapView.region
//            userLocation = visibleRegion.center
//            tableView.scrollEnabled = true
//        }
//        getLocationDescription(userLocation!)
//    }
//    
//    func mapView(mapView: BMKMapView!, regionWillChangeAnimated animated: Bool) {
//        if !animated {
//            tableView.scrollEnabled = false
//        }
//    }
    
    func getLocationDescription(location: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = location
        let res = geoSearch!.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取位置信息"), onSelf: true)
        }
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locDescription = result.address
            mapCell.locDisplay.text = result.address
        } else {
            self.showToast(LS("无法获取位置信息"), onSelf: true)
        }
    }
    
    // MARK: textfield and textview
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == nameInput {
            tableView.setContentOffset(CGPointMake(0, -275), animated: true)
        } else {
            if textField.tag == 0 {
                tableView.setContentOffset(CGPointMake(0, 0), animated: true)
            } else {
                tableView.setContentOffset(CGPointMake(0, 100), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == nameInput {
            return
        }
        if textField.tag == 1 {
            locDescription = textField.text
        } else {
            maxAttend = Int(textField.text ?? "0") ?? 0
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // clear the placeholder content before first edit
        if didBeginEditActDes {
            return
        }
        desInput.textColor = UIColor.blackColor()
        didBeginEditActDes = true
        desInput.text = ""
    }
    
    func textViewDidChange(textView: UITextView) {
        // word count
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = textView.text
        if text.length > 40 {
            textView.text = text[0..<40]
        }
        desWordCountLbl.text = "\(min(text.length, 40))/40"
    }
    
    // MARK: - Location Select Delegate
    
    func locationSelectDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationSelectDidSelect(location: Location) {
        dismissViewControllerAnimated(true, completion: nil)
        self.userLocation = location.location
        self.locDescription = location.description
        mapCell.locDisplay.text = location.description
        mapView.setCenterCoordinate(location.location, animated: true)
        
//        self.tableView.reloadData()
    }
}

//
//class ActivityReleaseController2: InputableViewController, UITableViewDataSource, UITableViewDelegate, FFSelectDelegate, CustomDatePickerDelegate, ImageInputSelectorDelegate, BMKLocationServiceDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, ProgressProtocol, AvatarClubSelectDelegate {
//    
//    weak var actHomeController: ActivityHomeController?
//    
//    var pp_progressView: UIProgressView?
//    
//    var board: ActivityReleaseInfoBoard!
//    var boardHeight: CGFloat = 0
//    var tableView: UITableView!
//    
//    var datePicker: CustomDatePicker!
//    var datePickerMode: String = "startAt"  // startAt or endAt
//    
//    var attendNum: Int = 10
//    var startAt: String = LS("请选择活动开始时间")
//    var startAtDate: NSDate?
//    var endAt: String = LS("请选择活动截止时间")
//    var endAtDate: NSDate?
//    var clubLimit: String = LS("全部")
//    var clubLimitID: Int32? = nil
//    var poster: UIImage?
//    
//    var locationService: BMKLocationService?
//    var userLocation: CLLocationCoordinate2D?
//    var geoSearch: BMKGeoCodeSearch?
//    var mapCell: ActivityReleaseMapCell!
//    var skipFirstLocFlag = true
//    var locDescriptin: String?
//    var setCenterFlag: Bool = false
//    var locInput: UITextField? {
//        return mapCell.locInput
//    }
//    
//    var mapView: BMKMapView? {
//        return mapCell.map!
//    }
//    
//    deinit {
//        print("deinit activity releaser")
//    }
//    
//    override func viewDidLoad() {
//        navSettings()
//        super.viewDidLoad()
//        
//        locationService = BMKLocationService()
//        geoSearch = BMKGeoCodeSearch()
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        locationService?.delegate = self
//        locationService?.startUserLocationService()
//        geoSearch?.delegate = self
//        mapView?.viewWillAppear()
//    }
//    
//    override func viewWillDisappear(animated: Bool) {
//        super.viewWillDisappear(animated)
//        locationService?.delegate = nil
//        geoSearch?.delegate = nil
//        mapView?.delegate = nil
//        mapView?.viewWillDisappear()
//    }
//    
//    func navSettings() {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationItem.title = LS("发布活动")
//        //
//        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: #selector(ActivityReleaseController.navLeftBtnPressed))
//        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
//        self.navigationItem.leftBarButtonItem = leftBtnItem
//        //
//        let rightItem = UIBarButtonItem(title: LS("发布"), style: .Done, target: self, action: #selector(ActivityReleaseController.navRightBtnPressed))
//        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
//        self.navigationItem.rightBarButtonItem = rightItem
//    }
//    
//    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func navRightBtnPressed() {
//        self.inputFields.each { (view) -> () in
//            view?.resignFirstResponder()
//        }
//        // 检查数据完整性
//        guard let actName = board.actNameInput.text where actName != "" else{
//            showToast(LS("请填写活动名称"), onSelf: true)
//            return
//        }
//        
//        guard let actDes = board.actDesInput.text where board.actDesEditStart else {
//            showToast(LS("请填写活动描述"), onSelf: true)
//            return
//        }
//        
//        guard let posterImage = self.poster else{
//            showToast(LS("请选择活动海报"), onSelf: true)
//            return
//        }
//        
//        if userLocation == nil{
//            showToast(LS("无法获取当前位置"), onSelf: true)
//            return
//        }
//        
//        if startAtDate == nil {
//            showToast(LS("请选择活动开始时间"), onSelf: true)
//            return
//        }
//        
//        if endAtDate == nil {
//            showToast(LS("请选择活动结束时间"), onSelf: true)
//            return
//        }
//        
//        var informUser: [String]? = nil
//        if board.informOfUsers.count > 0 {
//            informUser = board.informOfUsers.map({$0.ssidString})
//        }
//        
//        // 上传数据
//        let toast = showStaticToast(LS("发布中..."))
//        pp_showProgressView()
//        let requester = ActivityRequester.requester
//        let clubLimitIDString: String? = clubLimitID == nil ? nil : "\(clubLimitID!)"
//        requester.createNewActivity(actName, des: actDes, informUser: informUser, maxAttend: attendNum, startAt: startAtDate!, endAt: endAtDate!, clubLimit: clubLimitIDString, poster: posterImage, lat: userLocation!.latitude, lon: userLocation!.longitude, loc_des: locDescriptin ?? "", onSuccess: { (json) -> () in
//            self.navigationController?.popViewControllerAnimated(true)
//            let mine = self.actHomeController?.mine
//            mine?.refreshControl?.beginRefreshing()
//            mine?.getLatestActData()
//            self.hideToast(toast)
//            self.showToast(LS("发布成功！"), onSelf: true)
//            self.pp_hideProgressView()
//            }, onProgress: { (progress) -> () in
//                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.pp_updateProgress(progress)
//                })
//            }) { (code) -> () in
//                self.hideToast(toast)
//                self.showToast(LS("发布失败，请检查网络设置"))
//                self.pp_hideProgressView()
//                print(code)
//        }
//    }
//    
//    override func createSubviews() {
//        super.createSubviews()
//        // 创建列表
//        tableView = UITableView(frame: self.view.bounds, style: .Grouped)
//        tableView.delegate = self
//        tableView.dataSource = self
//        self.view.addSubview(tableView)
//        tableView.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(self.view)
//        }
//        //
//        board = ActivityReleaseInfoBoard()
//        board.releaser = self
//        tableView.addSubview(board)
//        board.frame = tableView.bounds
//        let boardHeight = board.getRequiredHeight()
//        self.boardHeight = boardHeight
//        board.frame = CGRectMake(0, -boardHeight, UIScreen.mainScreen().bounds.width, boardHeight)
//        tableView.contentInset = UIEdgeInsetsMake(boardHeight, 0, -44, 0)
//        board.actNameInput.delegate = self
//        board.actDesInput.delegate = self
//        self.inputFields.append(board.actNameInput)
//        self.inputFields.append(board.actDesInput)
//        board.posterBtn.addTarget(self, action: #selector(ActivityReleaseController.posterSelectBtnPressed), forControlEvents: .TouchUpInside)
//        //
//        tableView.separatorStyle = .None
//        tableView.registerClass(PrivateChatSettingsHeader.self, forHeaderFooterViewReuseIdentifier: "header")
//        tableView.registerClass(ActivityReleaseCell.self, forCellReuseIdentifier: ActivityReleaseCell.reuseIdentifier)
//        tableView.registerClass(ActivityReleaseMapCell.self, forCellReuseIdentifier: ActivityReleaseMapCell.reuseIdentifier)
//        //
//        datePicker = CustomDatePicker()
//        datePicker.delegate = self
//        self.view.addSubview(datePicker)
//        datePicker.snp_makeConstraints { (make) -> Void in
//            make.right.equalTo(self.view)
//            make.left.equalTo(self.view)
//            make.height.equalTo(CustomDatePicker.requiredHegiht)
//            make.bottom.equalTo(self.view).offset(CustomDatePicker.requiredHegiht)
//        }
//        //
//        mapCell = ActivityReleaseMapCell(style: .Default, reuseIdentifier: ActivityReleaseMapCell.reuseIdentifier)
//        inputFields.append(mapCell.locInput)
//        mapCell.locInput.delegate = self
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 50
//    }
//    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! PrivateChatSettingsHeader
//        header.titleLbl.text = LS("具体设置")
//        return header
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row < 4 {
//            return 50
//        }else{
//            return 500
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.row < 4 {
//            let cell = (tableView.dequeueReusableCellWithIdentifier(ActivityReleaseCell.reuseIdentifier) as! ActivityReleaseCell) ?? ActivityReleaseCell(style: .Default, reuseIdentifier: ActivityReleaseCell.reuseIdentifier)
//            cell.staticLbl.text = [LS("人数要求"), LS("开始时间"), LS("截止时间"), LS("参加成员")][indexPath.row]
//            cell.editable = false
//            cell.infoInput.keyboardType = .Default
//            switch indexPath.row {
//            case 0:
//                // 活动参加人数
//                cell.infoInput.text = "\(attendNum)"
//                cell.infoInput.delegate = self
//                cell.infoInput.keyboardType = .NumberPad
//                cell.editable = true
//                var add = true
//                for view in inputFields {
//                    if view == cell.infoInput {
//                        add = false
//                        break
//                    }
//                }
//                if add {
//                    inputFields.append(cell.infoInput)
//                }
//                cell.arrowDirection = "left"
//                break
//            case 1:
//                // 开始时间
//                cell.staticInfoLabel.text = startAt
//                cell.arrowDirection = "down"
//                break
//            case 2:
//                // 结束时间
//                cell.staticInfoLabel.text = endAt
//                cell.arrowDirection = "down"
//                break
//            case 3:
//                cell.staticInfoLabel.text = clubLimit
//                cell.arrowDirection = "down"
//            default:
//                break
//            }
//            return cell
//        }else{
//            if !setCenterFlag && self.userLocation != nil {
////                let region = BMKCoordinateRegionMakeWithDistance(self.userLocation!, 3000, 5000)
////                setCenterFlag = true
////                
////                mapView?.setRegion(region, animated: true)
//                mapView?.setCenterCoordinate(self.userLocation!, animated: true)
//                mapView?.zoomLevel = 12
//            }
//            return mapCell
//        }
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch indexPath.row {
//        case 1:
//            datePickerMode = "startAt"
//            showDatePicker()
//            break
//        case 2:
//            datePickerMode = "endAt"
//            showDatePicker()
//            break
//        case 3:
//            let detail = AvatarClubSelectController()
//            detail.delegate = self
//            detail.preSelectID = clubLimitID
//            detail.noIntialSelect = true
//            self.navigationController?.pushViewController(detail, animated: true)
//        default:
//            datePickerMode = ""
//            break
//        }
//    }
//}
//
//extension ActivityReleaseController {
//    
//    //
//    func textFieldDidBeginEditing(textField: UITextField) {
//        if textField == board.actNameInput {
//            // 
//            board.actNameInput.textColor = UIColor.blackColor()
//            tableView.setContentOffset(CGPointMake(0, -boardHeight), animated: true)
//        }else {
//            // 此时必然是cell中的textField
//            // 沿着view树向上找到cell
//            var view: UIView? = textField
//            var index: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
//            while true {
//                if let cell = view as? UITableViewCell {
//                    index = self.tableView.indexPathForCell(cell)!
//                    break
//                }
//                view = view?.superview
//                if view == nil{
//                    return
//                }
//            }
//            if index.section == 0 && index.row == 0 {
//                tableView.setContentOffset(CGPointMake(0, 0), animated: true)
//            }else if index.section == 0 && index.row == 4 {
//                tableView.setContentOffset(CGPointMake(0, 100), animated: true)
//            }
//        }
//    }
//    
//    func textFieldDidEndEditing(textField: UITextField) {
//        if textField == board.actNameInput {
//            return
//        }
//        var view: UIView? = textField
//        var index: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
//        while true {
//            if let cell = view as? UITableViewCell {
//                index = self.tableView.indexPathForRowAtPoint(cell.center)!
//                break
//            }
//            view = view?.superview
//            if view == nil{
//                return
//            }
//        }
//        if index.section == 0 && index.row == 0 {
//            attendNum = Int(textField.text ?? "0")!
//        } else if index.section == 0 && index.row == 4 {
//            locDescriptin = textField.text
//        }
//    }
//
//    // 初次开始编辑时清除placeholder
//    func textViewDidBeginEditing(textView: UITextView) {
//        if board.actDesEditStart {
//            return
//        }
//        board.actDesInput.textColor = UIColor.blackColor()
//        board.actDesEditStart = true
//        textView.text = ""
//    }
//    
//    // 字数统计
//    func textViewDidChange(textView: UITextView) {
//        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
//            let selectedRange = textView.markedTextRange
//            if selectedRange != nil {
//                return
//            }
//        }
//        let text = textView.text
//        if text.length > 90 {
//            textView.text = text[0..<90]
//        }
//        board.actDesInputWordCount.text = "\(min(text.length, 90))/90"
//    }
//    
//    // 防止编辑的文字过长
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        
//        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
//            let selectedRnage = textView.markedTextRange
//            if selectedRnage == nil {
//                return true
//            }
//        }
//        let curText = textView.text as NSString
//        let newText = curText.stringByReplacingCharactersInRange(range, withString: text) as String
//        if newText.length > 90 {
//            return false
//        }
//        return true
//    }
//}
//
//extension ActivityReleaseController {
//    
//    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
//        locationService?.stopUserLocationService()
//        self.userLocation = userLocation.location.coordinate
////        print(userLocation.location.coordinate)
////        let region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 3000, 5000)
////        mapView?.setRegion(region, animated: true)
////        setCenterFlag = true
//        mapView?.setCenterCoordinate(userLocation.location.coordinate, animated: true)
//        mapView?.delegate = self
//    }
//    
//    func mapView(mapView: BMKMapView!, regionDidChangeAnimated animated: Bool) {
//        let visibleRegion = mapView.region
//        if !skipFirstLocFlag || userLocation == nil{
//            userLocation = visibleRegion.center
//        } else {
//            skipFirstLocFlag = false
//        }
//        tableView.scrollEnabled = true
//        getLocationDescription(userLocation!)
//    }
//    
//    func mapView(mapView: BMKMapView!, regionWillChangeAnimated animated: Bool) {
//        tableView.scrollEnabled = false
//    }
//    
//    func getLocationDescription(location: CLLocationCoordinate2D) {
//        let option = BMKReverseGeoCodeOption()
//        option.reverseGeoPoint = location
//        let res = geoSearch!.reverseGeoCode(option)
//        if !res {
//            self.showToast(LS("无法获取制定位置信息"))
//        }
//    }
//    
//    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
//        if error == BMK_SEARCH_NO_ERROR {
//            locDescriptin = result.address
//            locInput?.text = result.address
//        } else {
//            self.showToast(LS("无法获取制定位置信息"))
//        }
//    }
//    
//}
//
//extension ActivityReleaseController {
//    func userSelectCancelled() {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func userSelected(users: [User]) {
//        self.dismissViewControllerAnimated(true, completion: nil)
//        board.informOfUsers = users
//        board.informOfList.users = users
//        board.informOfList.collectionView?.reloadData()
//        board.informOfListCountLbl.text = "\(users.count)/9"
//    }
//}
//
//extension ActivityReleaseController {
//    
//    func posterSelectBtnPressed() {
//        let detail = ImageInputSelectorController()
//        detail.delegate = self
//        detail.bgImage = self.getScreenShotBlurred(false)
//        self.presentViewController(detail, animated: false, completion: nil)
//    }
//    
//    func imageInputSelectorDidCancel() {
//        // Do nothing
//    }
//    
//    func imageInputSelectorDidSelectImage(image: UIImage) {
//        self.dismissViewControllerAnimated(false, completion: nil)
//        poster = image
//        let btn = board.posterBtn
//        btn.setTitle("", forState: .Normal)
//        btn.setImage(image, forState: .Normal)
//        board.posterLbl.hidden = true
//    }
//}
//
//extension ActivityReleaseController {
//    
//    override func dismissKeyboard() {
//        super.dismissKeyboard()
//        if datePickerMode == "startAt" || datePickerMode == "endAt" {
//            hideDatePicker()
//        }
//    }
//    
//    func showDatePicker() {
//        self.tapper?.enabled = true
//        datePicker.reset()
//        datePicker.snp_updateConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        }
//        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }
//    
//    func hideDatePicker() {
//        datePicker.snp_updateConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(CustomDatePicker.requiredHegiht)
//        }
//        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }
//    
//    func dateDidPicked(date: NSDate) {
//        
//        if datePickerMode == "startAt" {
//            startAt = date.stringDisplay()!
//            startAtDate = date
//            endAt = LS("请选择活动截止时间")
//            endAtDate = nil
//            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 1, inSection: 0), NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
//        }else if datePickerMode == "endAt" {
//            if startAtDate != nil && startAtDate!.compare(date) == NSComparisonResult.OrderedDescending {
//                self.showToast(LS("开始时间不能晚于结束时间"))
//                return
//            }
//            endAt = date.stringDisplay()!
//            endAtDate = date
//            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 2, inSection: 0)], withRowAnimation: .Automatic)
//        }
//        hideDatePicker()
//    }
//    
//    func datePickCancel() {
//        hideDatePicker()
//    }
//    
//    func avatarClubSelectDidFinish(selectedClub: Club) {
//        clubLimitID = selectedClub.ssid
//        clubLimit = selectedClub.name!
//    }
//    
//    func avatarClubSelectDidCancel() {
//        
//    }
//
//}
