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


class StatusReleaseController: InputableViewController, FFSelectDelegate, BMKGeoCodeSearchDelegate, ProgressProtocol, PresentableProtocol, LocationSelectDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationService = BMKLocationService()
//        locationService?.allowsBackgroundLocationUpdates = true
        locSearch = BMKGeoCodeSearch()

        NotificationCenter.default.addObserver(self, selector: #selector(StatusReleaseController.changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StatusReleaseController.changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationService?.delegate = self
        mapView.viewWillAppear()
        mapView.delegate = self
        locSearch?.delegate = self
        if self.userLocation == nil {
            locationService?.startUserLocationService()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mapView.viewWillDisappear()
        mapView.delegate = nil
        locationService?.delegate = nil
        locSearch?.delegate = nil
    }
    
    override func createSubviews() {
        super.createSubviews()
        navSettings()
        self.view.backgroundColor = UIColor.white
        let superview = self.view!
        //
        board = UIScrollView()
        board?.backgroundColor = UIColor.white
        board?.contentSize = self.view.bounds.size
        superview.addSubview(board!)
        board?.snp.makeConstraints({ (make) -> Void in
            make.bottom.equalTo(superview).offset(0)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(superview)
        })
        addImageBtn = UIButton()
        addImageBtn.setImage(UIImage(named: "status_add_image"), for: .normal)
        addImageBtn.addTarget(self, action: #selector(StatusReleaseController.addImageBtnPressed), for: .touchUpInside)
        board?.addSubview(addImageBtn)
        addImageBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(board!).offset(20)
            make.size.equalTo(100)
        }
        // 状态内容
        statusContentInput = UITextView()
        statusContentInput?.text = LS("有什么想说的呢...")
        statusContentInput?.delegate = self
        inputFields.append(statusContentInput)
        statusContentInput?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        statusContentInput?.textColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(statusContentInput!)
        statusContentInput?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(addImageBtn.snp.bottom).offset(15)
            make.height.equalTo(120)
        })
        // 状态内容的字数统计
        statusContentWordCountLbl = UILabel()
        statusContentWordCountLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        statusContentWordCountLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        statusContentWordCountLbl?.textAlignment = .right
        statusContentWordCountLbl?.text = "0/140"
        board?.addSubview(statusContentWordCountLbl!)
        statusContentWordCountLbl?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(statusContentInput!.snp.bottom).offset(10)
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
            sSelf.present(nav, animated: true, completion: nil)
        }
        let informOfListView = informOfList?.view
        board?.addSubview(informOfListView!)
        informOfListView?.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(statusContentWordCountLbl!.snp.bottom).offset(3)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(35)
        })
        //
        informOfListCountLbl = UILabel()
        informOfListCountLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        informOfListCountLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        informOfListCountLbl?.textAlignment = .right
        informOfListCountLbl?.text = "0/9"
        board?.addSubview(informOfListCountLbl!)
        informOfListCountLbl?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(informOfListView!)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(17)
        })
        //
        sportCarList = SportCarSelectListController()
        let sportCarListView = sportCarList!.view
        board?.addSubview(sportCarListView!)
        sportCarListView?.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(informOfListView!.snp.bottom).offset(7)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(60)
        }
        //
        mapView = BMKMapView()
        board?.addSubview(mapView!)
        mapView?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(sportCarListView!.snp.bottom)
            make.left.equalTo(superview)
            make.height.equalTo(650)
        })
        //
        let locDesContainer = board!.addSubview(UIView.self).config(UIColor.white)
            .addShadow()
            .layout { (make) in
                make.centerX.equalTo(superview)
                make.height.equalTo(50)
                make.width.equalTo(superview).multipliedBy(0.776)
                make.top.equalTo(mapView!).offset(22)
        }
        let locDesIcon = locDesContainer.addSubview(UIImageView.self)
            .config(UIImage(named: "news_comment_icon"))
            .layout { (make) in
                make.size.equalTo(15)
                make.left.equalTo(locDesContainer).offset(20)
                make.centerY.equalTo(locDesContainer)
        }
        //
        locInput = locDesContainer.addSubview(UITextField.self).config(14)
            .layout({ (make) in
                make.left.equalTo(locDesIcon.snp.right).offset(25)
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
        var contentRect = CGRect.zero
        for view in board!.subviews {
            contentRect = contentRect.union(view.frame)
        }
        board?.contentSize = CGSize(width: self.view.frame.width, height: contentRect.height - 250)
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布动态")
        let leftBtnItem = UIBarButtonItem(title: LS("取消"), style: .plain, target: self, action: #selector(StatusReleaseController.navLeftBtnPressed))
        leftBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.leftBarButtonItem = leftBtnItem
        
//        let rightBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 28, height: 16))
//        rightBtn.setTitle(LS("发布"), for: .normal)
//        rightBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
//        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
//        rightBtn.addTarget(self, action: #selector(StatusReleaseController.navRightBtnPressed), for: .touchUpInside)
        let rightBtnItem = UIBarButtonItem(title: LS("发布"), style: .done, target: self, action: #selector(navRightBtnPressed))
        rightBtnItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        
        self.navigationItem.rightBarButtonItem = rightBtnItem
        
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
        let content = (firstEditting ? "" : statusContentInput?.text ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
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
            self.presentingViewController?.dismiss(animated: true, completion: nil)
//            self.home?.followStatusCtrl.loadLatestData()
            self.hideToast(toast)
            self.pp_hideProgressView()
            self.navLeftBtnPressed()
            self.requesting = false
            let delay = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay, execute: {
                AppManager.sharedAppManager.showToast(LS("动态发布成功"))
                self.home?.followStatusCtrl.loadLatestData()
            })
            
            // send notificaiton to inform the presence of new status
            let status = try! MainManager.sharedManager.getOrCreate(json!) as Status
            // 将图片存入缓存：注意Key应当是包含了域名等部分的完整URL
//            KingfisherManager.sharedManager.cache.storeImage(self.selectedImage!, forKey: SF(status.image!)!)
            KingfisherManager.shared.cache.store(self.selectedImage!, forKey: status.coverURL!.absoluteString)
            /*
             注意这里发布Notification，主要是为了让『我的』页面中的动态列表及时进行更新，而『动态』中的列表不会接收这个Notification。
             */
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kStatusNewNotification), object: nil, userInfo: [kStatusKey: status])
            }, onError: { (code) -> () in
                self.requesting = false
                self.hideToast(toast)
                self.showToast(LS("发布失败，请检查网络设置"), onSelf: true)
                self.pp_hideProgressView()
            }) { (progress) -> () in
                DispatchQueue.main.async(execute: { () -> Void in
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        selectedImage = image
        addImageBtn?.setImage(image, for: .normal)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - About User Inform
extension StatusReleaseController {
    
    func userSelectCancelled() {
        // Do nothing
        self.dismiss(animated: true, completion: nil)
    }
    
    func userSelected(_ users: [User]) {
        informOfUsers.append(contentsOf: users)
        informOfUsers = $.uniq(informOfUsers, by: { return $0.ssid })
        informOfList?.users = informOfUsers
        informOfList?.collectionView?.reloadData()
        informOfListCountLbl?.text = "\(informOfUsers.count)/9"
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - About map
extension StatusReleaseController: BMKMapViewDelegate, BMKLocationServiceDelegate {
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
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
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        let view = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "user_location")
        view?.annotation = annotation
        return view
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locInput!.text = result.address
        } else {
            self.showToast(LS("无法获取当前位置信息"), onSelf: true)
        }
    }
    
    func locationSelectBtnPressed() {
        let locationSelect = LocationSelectController(currentLocation: self.userLocation, des: self.locInput.text)
        locationSelect.delegate = self
        self.present(locationSelect.toNavWrapper(), animated: true, completion: nil)
    }
    
    func locationSelectDidCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func locationSelectDidSelect(_ location: Location) {
        self.dismiss(animated: true, completion: nil)
        self.userLocation = location.location
        locInput.text = location.description
        mapView.setCenter(location.location, animated: true)
    }
    
}


// MARK: - About content input
extension StatusReleaseController {
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = statusContentInput!.text! as NSString
        let newText = curText.replacingCharacters(in: range, with: text) as String
        if newText.length > 140 {
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if firstEditting {
            statusContentInput?.text = ""
            statusContentInput?.textColor = UIColor.black
            firstEditting = false
            statusContentInput?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight)
        }
    }
    
    func changeLayoutWhenKeyboardAppears(_ notif: Foundation.Notification) {
        let userInfo = (notif as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue!
        if !locInput!.isEditing {
            if statusContentInput!.frame.origin.y < (keyboardFrame.height) {
                return
            }
        }

            board?.snp.updateConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(-(keyboardFrame.height))
            })
//        }
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutWhenKeyboardDisappears(_ notif: Foundation.Notification) {
        board?.snp.updateConstraints({ (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
}
