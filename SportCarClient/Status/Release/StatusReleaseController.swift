//
//  StatusReleaseController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation
import Cent
import Dollar
import Kingfisher


class StatusReleaseController: InputableViewController, FFSelectDelegate, BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, ProgressProtocol, PresentableProtocol, LocationSelectDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*
    ================================================================================================ 子控件
    */
    ///
    weak var home: StatusHomeController?
    weak var presenter: UIViewController?
    //
    var pp_progressView: UIProgressView?
    /// 面板
    var board: UIScrollView?
    /// 添加图片的操作面板
    var addImageBtn: UIButton!
    var selectedImage: UIImage?
    /// 状态文字内容输入框
    var statusContentInput: UITextView?
    var firstEditting = true
    /// 状态文字内容输入字数统计标签
    var statusContentWordCountLbl: UILabel?
    /// @别人的这一栏的容器
    var informOfList: InformOtherUserController?
    var informOfListCountLbl: UILabel?
    var informOfUsers: [User] = []
    /// 跑车选择列表
    var sportCarList: SportCarSelectListController?
    /// 地图控件
    var mapView: BMKMapView!
    var locInput: UITextField!
    var locationService: BMKLocationService?
    var userLocation: CLLocationCoordinate2D?
    var locSearch: BMKGeoCodeSearch?
    var annotation: BMKPointAnnotation!
    
    var requesting = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService = BMKLocationService()
//        locationService?.allowsBackgroundLocationUpdates = true
        locSearch = BMKGeoCodeSearch()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusReleaseController.changeLayoutWhenKeyboardAppears(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusReleaseController.changeLayoutWhenKeyboardDisappears(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        locationService?.delegate = self
        mapView.viewWillAppear()
        mapView.delegate = self
        locSearch?.delegate = self
        if self.userLocation == nil {
            locationService?.startUserLocationService()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.viewWillDisappear()
        mapView.delegate = nil
        locationService?.delegate = nil
        locSearch?.delegate = nil
    }
    
    override func createSubviews() {
        super.createSubviews()
        navSettings()
        self.view.backgroundColor = UIColor.whiteColor()
        let superview = self.view
        //
        board = UIScrollView()
        board?.backgroundColor = UIColor.whiteColor()
        board?.contentSize = self.view.bounds.size
        superview.addSubview(board!)
        board?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview).offset(0)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(superview)
        })
        addImageBtn = UIButton()
        addImageBtn.setImage(UIImage(named: "status_add_image"), forState: .Normal)
        addImageBtn.addTarget(self, action: #selector(StatusReleaseController.addImageBtnPressed), forControlEvents: .TouchUpInside)
        board?.addSubview(addImageBtn)
        addImageBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(board!).offset(20)
            make.size.equalTo(100)
        }
        // 状态内容
        statusContentInput = UITextView()
        statusContentInput?.text = LS("有什么想说的呢...")
        statusContentInput?.delegate = self
        inputFields.append(statusContentInput)
        statusContentInput?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        statusContentInput?.textColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(statusContentInput!)
        statusContentInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(addImageBtn.snp_bottom).offset(15)
            make.height.equalTo(120)
        })
        // 状态内容的字数统计
        statusContentWordCountLbl = UILabel()
        statusContentWordCountLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        statusContentWordCountLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        statusContentWordCountLbl?.textAlignment = .Right
        statusContentWordCountLbl?.text = "0/140"
        board?.addSubview(statusContentWordCountLbl!)
        statusContentWordCountLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(statusContentInput!.snp_bottom).offset(10)
            make.height.equalTo(17)
        })
        //
        informOfList = InformOtherUserController()
        informOfList?.onInvokeUserSelectController = { [weak self] (sender: InformOtherUserController) in
            // 在这里弹出用户选择页面
            guard let sSelf = self else {
                return
            }
            let userSelect = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: sSelf.informOfUsers, forced: false)
            userSelect.delegate = self
            let nav = BlackBarNavigationController(rootViewController: userSelect)
            sSelf.presentViewController(nav, animated: true, completion: nil)
        }
        let informOfListView = informOfList?.view
        board?.addSubview(informOfListView!)
        informOfListView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(statusContentWordCountLbl!.snp_bottom).offset(3)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(35)
        })
        //
        informOfListCountLbl = UILabel()
        informOfListCountLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        informOfListCountLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        informOfListCountLbl?.textAlignment = .Right
        informOfListCountLbl?.text = "0/9"
        board?.addSubview(informOfListCountLbl!)
        informOfListCountLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(informOfListView!)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(17)
        })
        //
        sportCarList = SportCarSelectListController()
        let sportCarListView = sportCarList!.view
        board?.addSubview(sportCarListView)
        sportCarListView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(informOfListView!.snp_bottom).offset(7)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(60)
        }
        //
        mapView = BMKMapView()
        board?.addSubview(mapView!)
        mapView?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(sportCarListView.snp_bottom)
            make.left.equalTo(superview)
            make.height.equalTo(650)
        })
        //
        let locDesContainer = board!.addSubview(UIView).config(UIColor.whiteColor())
            .addShadow()
            .layout { (make) in
                make.centerX.equalTo(superview)
                make.height.equalTo(50)
                make.width.equalTo(superview).multipliedBy(0.776)
                make.top.equalTo(mapView!).offset(22)
        }
        let locDesIcon = locDesContainer.addSubview(UIImageView)
            .config(UIImage(named: "news_comment_icon"))
            .layout { (make) in
                make.size.equalTo(15)
                make.left.equalTo(locDesContainer).offset(20)
                make.centerY.equalTo(locDesContainer)
        }
        //
        locInput = locDesContainer.addSubview(UITextField).config(14)
            .layout({ (make) in
                make.left.equalTo(locDesIcon.snp_right).offset(25)
                make.height.equalTo(locDesIcon)
                make.centerY.equalTo(locDesContainer)
                make.right.equalTo(locDesContainer).offset(-20)
            })
        locInput.delegate = self
        self.inputFields.append(locInput)
        autoSetBoardContentSize()
    }
    
    func autoSetBoardContentSize() {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in board!.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        board?.contentSize = CGSizeMake(self.view.frame.width, contentRect.height - 250)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布动态")
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .Plain, target: self, action: #selector(StatusReleaseController.navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem
        
        let rightBtn = UIButton(frame: CGRectMake(0, 0, 28, 16))
        rightBtn.setTitle(LS("发布"), forState: .Normal)
        rightBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        rightBtn.addTarget(self, action: #selector(StatusReleaseController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        if requesting {
            return
        }
        requesting = true
        // Check the validate of the data
        // 发布这条状态
        if selectedImage == nil {
            showToast(LS("您的动态还差一张图片"), onSelf: true)
            return
        }
        let content = firstEditting ? "" : statusContentInput?.text ?? ""
        let car_id = sportCarList?.selectedCar?.ssidString
        guard let lat: Double = userLocation?.latitude else {
            showToast(LS("无法获取当前位置"), onSelf: true)
            return
        }
        guard let lon: Double = userLocation?.longitude else {
            return
        }
        let loc_description = locInput!.text == "" ? "未知地点" : locInput!.text
        let requester = StatusRequester.sharedInstance
        let toast = self.showStaticToast(LS("发布中..."))
        let informUserIds = informOfUsers.map { (user) -> String in
            return user.ssidString
        }
        pp_showProgressView()
        requester.postNewStatus(content, image: selectedImage!, car_id: car_id, lat: lat, lon: lon, loc_description: loc_description!, informOf: informUserIds, onSuccess: { (json) -> () in
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
//            self.home?.followStatusCtrl.loadLatestData()
            self.hideToast(toast)
            self.pp_hideProgressView()
            self.navLeftBtnPressed()
            self.requesting = false
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC))
            dispatch_after(delay, dispatch_get_main_queue(), {
                AppManager.sharedAppManager.showToast(LS("动态发布成功"))
                self.home?.followStatusCtrl.loadLatestData()
            })
            
            // send notificaiton to inform the presence of new status
            let status = try! MainManager.sharedManager.getOrCreate(json!) as Status
            // 将图片存入缓存：注意Key应当是包含了域名等部分的完整URL
            KingfisherManager.sharedManager.cache.storeImage(self.selectedImage!, forKey: SF(status.image!)!)
            /*
             注意这里发布Notification，主要是为了让『我的』页面中的动态列表及时进行更新，而『动态』中的列表不会接收这个Notification。
             */
            NSNotificationCenter.defaultCenter().postNotificationName(kStatusNewNotification, object: nil, userInfo: [kStatusKey: status])
            }, onError: { (code) -> () in
                self.requesting = false
                self.hideToast(toast)
                self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
                self.pp_hideProgressView()
            }) { (progress) -> () in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.pp_updateProgress(progress)
                })
        }
    }
    
    func navLeftBtnPressed() {
        pp_dismissSelf()
    }
}


// MARK: - About photo Select
extension StatusReleaseController {
    
    func addImageBtnPressed() {
        let alert = UIAlertController(title: NSLocalizedString("选择图片", comment: ""), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.Camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        selectedImage = image
        addImageBtn?.setImage(image, forState: .Normal)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - About User Inform
extension StatusReleaseController {
    
    func userSelectCancelled() {
        // Do nothing
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSelected(users: [User]) {
        informOfUsers.appendContentsOf(users)
        informOfUsers = $.uniq(informOfUsers, by: { return $0.ssid })
        informOfList?.users = informOfUsers
        informOfList?.collectionView?.reloadData()
        informOfListCountLbl?.text = "\(informOfUsers.count)/9"
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - About map
extension StatusReleaseController {
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService?.stopUserLocationService()
        locationService?.delegate = nil
        // 只需要获取当前的数据
        self.userLocation = userLocation.location.coordinate
        annotation = BMKPointAnnotation()
        annotation.coordinate = userLocation.location.coordinate
        mapView.addAnnotation(annotation)
        let region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 3000, 5000)
        mapView.setRegion(region, animated: true)
        // reverse geo code search after getting the position
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = userLocation.location.coordinate
        let res = locSearch!.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取当前位置信息"), onSelf: true)
        }
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "user_location")
        view.annotation = annotation
        return view
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locInput!.text = result.address
        } else {
            self.showToast(LS("无法获取当前位置信息"), onSelf: true)
        }
    }
    
    func locationSelectBtnPressed() {
        let locationSelect = LocationSelectController(currentLocation: self.userLocation, des: self.locInput.text)
        locationSelect.delegate = self
        self.presentViewController(locationSelect.toNavWrapper(), animated: true, completion: nil)
    }
    
    func locationSelectDidCancel() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func locationSelectDidSelect(location: Location) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.userLocation = location.location
        locInput.text = location.description
        mapView.setCenterCoordinate(location.location, animated: true)
    }
    
}


// MARK: - About content input
extension StatusReleaseController {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = statusContentInput!.text! as NSString
        let newText = curText.stringByReplacingCharactersInRange(range, withString: text) as String
        if newText.length > 140 {
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = statusContentInput?.text ?? ""
        if text.length > 140 {
            statusContentInput?.text = text[0..<140]
        }
        
        statusContentWordCountLbl?.text = "\(min(text.length, 140))/140"
    }
    
    func textViewDidBeginEditing(textView: UITextView) {

        if firstEditting {
            statusContentInput?.text = ""
            statusContentInput?.textColor = UIColor.blackColor()
            firstEditting = false
            statusContentInput?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        }
    }
    
    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
        let userInfo = notif.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        if !locInput!.editing {
            if statusContentInput!.frame.origin.y < keyboardFrame.height {
                return
            }
        }

            board?.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(-(keyboardFrame.height))
            })
//        }
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
}