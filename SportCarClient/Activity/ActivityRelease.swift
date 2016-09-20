//
//  ActivityRelease.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class ActivityReleaseController: InputableViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, ProgressProtocol, CustomDatePickerDelegate, FFSelectDelegate, LocationSelectDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    weak var actHomeController: ActivityHomeController?
    
//    var pp_progressView: UIProgressView?

    var imagePickerBtn: UIButton!
    var nameInput: UITextField!
    var desInput: UITextView!
    var desWordCountLbl: UILabel!
    var datePicker: CustomDatePicker!
    
    var tableView: UITableView!
    var inlineMiniUserSelectView: UICollectionView!
    var mapCell: ActivityReleaseMapCell!
    var mapView: BMKMapView {
        return mapCell.map
    }
    var maxAttendCell: SSPropertyInputableCell!
    
    var poster: UIImage?
    var startAt: Date?
    var endAt: Date?
    var authedUserOnly: Bool = false
    var maxAttend: Int = 10
    var selectedUser: [User] = []
    
    var locationService: BMKLocationService!
    var geoSearch: BMKGeoCodeSearch!
    var userLocation: CLLocationCoordinate2D?
    var locDescription: String?
    var city: String?
    
    var didBeginEditActDes: Bool = false
    weak var presenter: UIViewController? = nil
    
    //
    let actDescriptionWordLimit: Int = 140
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        locationService = BMKLocationService()
        geoSearch = BMKGeoCodeSearch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
        locationService.delegate = self
        mapView.delegate = self
        geoSearch.delegate = self
        
        assert(presenter != nil)
        
        if self.userLocation == nil {
            locationService.startUserLocationService()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        superview?.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        tableView.contentInset = UIEdgeInsetsMake(275, 0, 0, 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -275), animated: false)
        SSPropertyCell.registerTableView(tableView)
        SSPropertyInputableCell.registerTableView(tableView)
        SSCommonHeader.registerTableView(tableView)
        SSPropertySwitcherCell.registerTableView(tableView)
        
        let container = tableView.addSubview(UIView)
            .setFrame(CGRect(x: 0, y: -275, width: superview.frame.width, height: 275))
            .config(UIColor.white)
        imagePickerBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(needPickPoster), image: UIImage(named: "status_add_image"))
            .layout({ (make) in
                make.left.equalTo(container).offset(15)
                make.top.equalTo(container).offset(15)
                make.size.equalTo(100)
            })
        let static1 = container.addSubview(UILabel)
            .config(fontWeight: UIFontWeightUltraLight, text: LS("取一个名字"))
            .layout { (make) in
                make.left.equalTo(imagePickerBtn.snp_right).offset(18)
                make.top.equalTo(imagePickerBtn)
        }
        let wrapper = container.addSubview(UIScrollView).config(UIColor.white)
            .layout { (make) in
                make.left.equalTo(static1)
                make.top.equalTo(static1.snp_bottom).offset(14)
                make.bottom.equalTo(imagePickerBtn)
                make.right.equalTo(container).offset(-15)
        }
        nameInput = wrapper.addSubview(UITextField)
            .config(17, placeholder: LS("为活动取一个名字..."), fontWeight: UIFontWeightSemibold).layout({ (make) in
                make.left.equalTo(static1)
                make.top.equalTo(static1.snp_bottom).offset(14)
            }).addToInputable(self)
        desInput = container.addSubview(UITextView)
            .config(16, textColor: UIColor(white: 0.72, alpha: 1), text: LS("活动描述..."))
            .layout({ (make) in
                make.left.equalTo(imagePickerBtn)
                make.right.equalTo(container).offset(-15)
                make.top.equalTo(imagePickerBtn.snp_bottom).offset(16)
                make.height.equalTo(100)
            }).addToInputable(self)
        desWordCountLbl = container.addSubview(UILabel)
            .config(12, textAlignment: .right, text: "0/\(actDescriptionWordLimit)", textColor: UIColor(white: 0.72, alpha: 1)).layout({ (make) in
                make.right.equalTo(container).offset(-15)
                make.bottom.equalTo(desInput)
            })
        let atBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(needAtSomeone), title: LS("@提醒谁看"), titleColor: UIColor.black)
            .layout { (make) in
                make.left.equalTo(container).offset(15)
                make.top.equalTo(desInput.snp_bottom)
                make.bottom.equalTo(container)
                make.width.equalTo(80)
        }
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 35, height: 35)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        inlineMiniUserSelectView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout).config(UIColor.white)
        inlineMiniUserSelectView.delegate = self
        inlineMiniUserSelectView.dataSource = self
        container.addSubview(inlineMiniUserSelectView)
        inlineMiniUserSelectView.snp_makeConstraints { (make) in
            make.left.equalTo(atBtn.snp_right)
            make.right.equalTo(container).offset(-15)
            make.top.equalTo(desInput.snp_bottom)
            make.bottom.equalTo(container)
        }
        inlineMiniUserSelectView.register(InlineUserSelectMiniCell.self, forCellWithReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier)
        
        //
        mapCell = ActivityReleaseMapCell(trailingHeight: 100)
        mapCell.map.delegate = self
        mapCell.onInvokeLocationSelect = { [weak self] in
            guard let sSelf = self else {
                return
            }
            let locationSelect = LocationSelectController(currentLocation: self?.userLocation, des: self?.mapCell.locDisplay.text)
            locationSelect.delegate = sSelf
            sSelf.present(locationSelect.toNavWrapper(), animated: true, completion: nil)
        }
        
        maxAttendCell = SSPropertyInputableCell(style: .default, reuseIdentifier: "inputable")
        maxAttendCell.contentInput.addToInputable(self)
        //
        datePicker = CustomDatePicker()
        datePicker.delegate = self
        superview?.addSubview(datePicker)
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
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .plain, target: self, action: #selector(ActivityReleaseController.navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
        self.navigationItem.leftBarButtonItem = leftBtnItem
        //
        let rightItem = UIBarButtonItem(title: LS("发布"), style: .done, target: self, action: #selector(ActivityReleaseController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
        presenter?.dismiss(animated: true, completion: nil)
    }
    
    func navRightBtnPressed() {
        
        self.inputFields.each { (view) in
            view?.resignFirstResponder()
        }
        // check integrity of the data
        guard let actName = nameInput.text , actName.length > 0 else {
            showToast(LS("请填写活动名称"), onSelf: true)
            return
        }
        guard let actDes = desInput.text , actDes.length > 0 else {
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
        if startAtDate.compare(endAtDate) == .orderedDescending {
            showToast(LS("开始时间不能晚于结束时间"))
            return
        }
        var selectedUserIDs: [String]? = nil
        if selectedUser.count > 0 {
            selectedUserIDs = selectedUser.map { $0.ssidString }
        }
        let toast = showStaticToast(LS("发布中..."))
        pp_showProgressView()
        ActivityRequester.sharedInstance.createNewActivity(actName, des: actDes, informUser: selectedUserIDs, maxAttend: maxAttend, startAt: startAtDate, endAt: endAtDate, authedUserOnly: authedUserOnly, poster: posterImage, lat: loc.latitude, lon: loc.longitude, loc_des: locDescription ?? "", city: city ?? "", onSuccess: { (json) in
            self.presenter?.dismiss(animated: true, completion: {
                self.presenter?.showToast(LS("发布成功"))
            })
            if let mine = self.actHomeController?.mine {
                mine.refreshControl.beginRefreshing()
                mine.getLatestActData()
            }
            self.hideToast(toast)
            self.pp_hideProgressView()
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
        }) { (code) in
            DispatchQueue.main.async(execute: {
                self.hideToast(toast)
                self.pp_hideProgressView()
                if code == "no permission" {
                    self.showToast(LS("请先认证一辆车再发布活动"), onSelf: true)
                } else {
                    self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
                }
            })
        }
//        self.inputFields.each { (view) in
//            view?.resignFirstResponder()
//        }
//        // check integrity of the data
//        guard let actName = nameInput.text where actName.length > 0 else {
//            showToast(LS("请填写活动名称"), onSelf: true)
//            return
//        }
//        guard let actDes = desInput.text where actDes.length > 0 else {
//            showToast(LS("请填写活动描述"), onSelf: true)
//            return
//        }
//        guard let posterImage = poster else {
//            showToast(LS("请选择活动海报"), onSelf: true)
//            return
//        }
//        guard let loc = userLocation else {
//            showToast(LS("无法获取当前位置"), onSelf: true)
//            return
//        }
//        guard let startAtDate = startAt, let endAtDate = endAt else {
//            showToast(LS("请设置活动时间"), onSelf: true)
//            return
//        }
//        let clubLimitID = clubLimit?.ssidString
//        var selectedUserIDs: [String]? = nil
//        if selectedUser.count > 0 {
//            selectedUserIDs = selectedUser.map { $0.ssidString }
//        }
//        let toast = showStaticToast(LS("发布中..."))
//        pp_showProgressView()
//        ActivityRequester.sharedInstance.createNewActivity(actName, des: actDes, informUser: selectedUserIDs, maxAttend: maxAttend, startAt: startAtDate, endAt: endAtDate, clubLimit: clubLimitID, poster: posterImage, lat: loc.latitude, lon: loc.longitude, loc_des: locDescription ?? "", onSuccess: { (json) in
//            self.navigationController?.popViewControllerAnimated(true)
//            if let mine = self.actHomeController?.mine {
//                mine.refreshControl.beginRefreshing()
//                mine.getLatestActData()
//            }
//            self.hideToast(toast)
//            self.pp_hideProgressView()
//            if let presenter = self.presentingViewController {
//                presenter.showToast(LS("发布成功"))
//            } else {
//                self.showToast(LS("发布成功!"))
//            }
//            
//            }, onProgress: { (progress) in
//                dispatch_async(dispatch_get_main_queue(), { 
//                    self.pp_updateProgress(progress)
//                })
//            }) { (code) in
//                dispatch_async(dispatch_get_main_queue(), {
//                    self.hideToast(toast)
//                    self.pp_hideProgressView()
//                    if code == "no permission" {
//                        self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
//                    } else {
//                        self.showToast(LS("请先认证一辆车再发布活动"), onSelf: true)
//                    }
//                })
//        }
    }
    
    func needPickPoster() {
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
    
    func needAtSomeone() {
        let select = FFSelectController(maxSelectNum: 0, preSelectedUsers: selectedUser, preSelect: true, forced: false)
        select.delegate = self
        self.present(select.toNavWrapper(), animated: true, completion: nil)
    }
    
    // MARK: tableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.ss_reusableHeader(SSCommonHeader)
        header.titleLbl.text = LS("基本设置")
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row < 4 {
            return 50
        } else {
            return 450
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).row < 4 {
            switch (indexPath as NSIndexPath).row {
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
                let cell = tableView.ss_reuseablePropertyCell(SSPropertySwitcherCell.self, forIndexPath: indexPath)
                return cell.setData(LS("只限认证用户参加"), propertyValue: false, bindObj: self, bindPropertyName: "authedUserOnly")
            }
        } else {
            return mapCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).row {
        case 1:
            datePicker.tag = 0
            self.tapper?.isEnabled = true
            datePicker.show()
        case 2:
            datePicker.tag = 1
            self.tapper?.isEnabled = true
            datePicker.show()
//        case 3:
//            let detail = AvatarClubSelectController()
//            detail.delegate = self
//            detail.preSelectID = clubLimit?.ssid
//            detail.noIntialSelect = true
//            self.navigationController?.pushViewController(detail, animated: true)
        default:
            break
        }
    }
    
    // MARK: Collection
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier, for: indexPath) as! InlineUserSelectMiniCell
        cell.user = selectedUser[(indexPath as NSIndexPath).row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = selectedUser[(indexPath as NSIndexPath).row]
        self.navigationController?.pushViewController(user.showDetailController(), animated: true)
    }
    
    // MARK: user select
    
    func userSelectCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func userSelected(_ users: [User]) {
        self.dismiss(animated: true, completion: nil)
        selectedUser = users
        inlineMiniUserSelectView.reloadData()
    }
    
    // MARK: image select
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        dismiss(animated: false, completion: nil)
        poster = image
        imagePickerBtn.setImage(image, for: UIControlState())
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    
//    func avatarClubSelectDidFinish(selectedClub: Club) {
//        clubLimit = selectedClub
//        tableView.beginUpdates()
//        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 3, inSection: 0)], withRowAnimation: .Automatic)
//        tableView.endUpdates()
//    }
//    
//    func avatarClubSelectDidCancel() {
//        // do nothing
//    }
    
    // MARK: date picker
    
    func datePickCancel() {
        datePicker.hide()
        datePicker.tag = -1
    }
    
    func dateDidPicked(_ date: Date) {
        datePicker.hide()
        if datePicker.tag == 0 {
            startAt = date
            endAt = nil
            tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
        } else if datePicker.tag == 1 {
            endAt = date
            tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
        } else {
            assertionFailure()
        }
        datePicker.tag = -1
    }
    
    // MARK: map
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        locationService.delegate = nil
        self.userLocation = userLocation.location.coordinate
        mapView.setCenter(self.userLocation!, animated: true)
        mapView.zoomLevel = 16
        mapView.delegate = self
        getLocationDescription(self.userLocation!)
    }
    
    func getLocationDescription(_ location: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = location
        let res = geoSearch!.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取位置信息"), onSelf: true)
        }
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locDescription = result.address
            city = result.addressDetail.city
            mapCell.locDisplay.text = result.address
        } else {
            self.showToast(LS("无法获取位置信息"), onSelf: true)
        }
    }
    
    // MARK: textfield and textview
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameInput {
            tableView.setContentOffset(CGPoint(x: 0, y: -275), animated: true)
        } else {
            if textField.tag == 0 {
                tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            } else {
                tableView.setContentOffset(CGPoint(x: 0, y: 100), animated: true)
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameInput {
            return
        }
        if textField.tag == 1 {
            locDescription = textField.text
        } else {
            maxAttend = Int(textField.text ?? "0") ?? 0
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // clear the placeholder content before first edit
        if didBeginEditActDes {
            return
        }
        desInput.textColor = UIColor.black
        didBeginEditActDes = true
        desInput.text = ""
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // word count
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = textView.text
        if text.length > actDescriptionWordLimit {
            textView.text = text?[0..<actDescriptionWordLimit]
        }
        desWordCountLbl.text = "\(min(text.length, actDescriptionWordLimit))/\(actDescriptionWordLimit)"
    }
    
    // MARK: - Location Select Delegate
    
    func locationSelectDidCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func locationSelectDidSelect(_ location: Location) {
        dismiss(animated: true, completion: nil)
        self.userLocation = location.location
        self.locDescription = location.description
        self.city = location.city
        
        mapCell.locDisplay.text = location.description
        mapView.setCenter(location.location, animated: true)
        
//        self.tableView.reloadData()
    }
    
    func presentFrom(_ controller: UIViewController) {
        presenter = controller
        controller.present(self.toNavWrapper(), animated: true, completion: nil)
    }
}

