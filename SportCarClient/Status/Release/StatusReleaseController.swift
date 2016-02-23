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
import Mapbox
import Cent


class StatusReleaseController: InputableViewController, StatusReleasePhotoSelectDelegate, CLLocationManagerDelegate, MGLMapViewDelegate, FFSelectDelegate {
    /*
    ================================================================================================ 子控件
    */
    ///
    weak var home: StatusHomeController?
    /// 面板
    var board: UIScrollView?
    /// 添加图片的操作面板
    var addImagePanel: UICollectionView?
    var addImagePanelDataSource: StatusReleaseAddImagePanelDataSource?
    /// 图片数量计数标签
    var imageCountLbl: UILabel?
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
    var mapView: MGLMapView?
    var locationDesInput: UITextField?
    
    var locationManager: CLLocationManager?
    var userLocAnn: MGLPointAnnotation?
    
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
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardAppears:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardDisappears:", name: UIKeyboardWillHideNotification, object: nil)
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
        //
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Vertical
        let screenWidth = UIScreen.mainScreen().bounds.width
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSizeMake(screenWidth / 3, screenWidth / 3)
        addImagePanel = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        // 开始时没有选中图片，传入空的数据
        addImagePanelDataSource = StatusReleaseAddImagePanelDataSource(newImages: [])
        addImagePanelDataSource?.controller = self
        addImagePanel?.dataSource = addImagePanelDataSource
        board?.addSubview(addImagePanel!)
        addImagePanel?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(board!)
            make.height.equalTo(120)
        })
        addImagePanel?.backgroundColor = UIColor.whiteColor()
        addImagePanel?.registerClass(StatusReleaseAddImageCell.self, forCellWithReuseIdentifier: StatusReleaseAddImageCell.reuseIdentifier)
        addImagePanel?.registerClass(StatusReleaseAddImageBtnCell.self, forCellWithReuseIdentifier: StatusReleaseAddImageBtnCell.reuseIdentifier)
        // 图片数量计数
        imageCountLbl = UILabel()
        imageCountLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        imageCountLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        imageCountLbl?.textAlignment = .Right
        imageCountLbl?.text = "0/\(addImagePanelDataSource!.maxImageNum)"
        board?.addSubview(imageCountLbl!)
        imageCountLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(addImagePanel!.snp_bottom)
            make.height.equalTo(17)
        })
        // 状态内容
        statusContentInput = UITextView()
        statusContentInput?.text = LS("有什么想说的呢...")
        statusContentInput?.delegate = self
        inputFields.append(statusContentInput)
        statusContentInput?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        statusContentInput?.textColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(statusContentInput!)
        statusContentInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(imageCountLbl!.snp_bottom).offset(15)
            make.height.equalTo(150)
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
        informOfList?.onInvokeUserSelectController = { (sender: InformOtherUserController) in
            // 在这里弹出用户选择页面
            let userSelect = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: self.informOfUsers)
            userSelect.delegate = self
            let nav = BlackBarNavigationController(rootViewController: userSelect)
            self.presentViewController(nav, animated: true, completion: nil)
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
            make.bottom.equalTo(informOfListView!)
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
        mapView = MGLMapView(frame: CGRectZero, styleURL: kMapStyleURL)
        mapView?.allowsScrolling = false
        mapView?.allowsZooming = false
        mapView?.allowsRotating = false
        mapView?.delegate = self
        board?.addSubview(mapView!)
        mapView?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(sportCarListView.snp_bottom)
            make.left.equalTo(superview)
            make.height.equalTo(250)
        })
        //
        let locDesContainer = UIView()
        locDesContainer.backgroundColor = UIColor.whiteColor()
        locDesContainer.layer.cornerRadius = 4
        locDesContainer.layer.shadowColor = UIColor.blackColor().CGColor
        locDesContainer.layer.shadowOpacity = 0.5
        locDesContainer.layer.shadowOffset = CGSizeMake(1, 1.5)
        board?.addSubview(locDesContainer)
        locDesContainer.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.height.equalTo(50)
            make.width.equalTo(superview).multipliedBy(0.776)
            make.top.equalTo(mapView!).offset(22)
        }
        let locDesIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        locDesContainer.addSubview(locDesIcon)
        locDesIcon.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(20)
            make.left.equalTo(locDesContainer).offset(20)
            make.centerY.equalTo(locDesContainer)
        }
        //
        locationDesInput = UITextField()
        self.inputFields.append(locationDesInput)
        locationDesInput?.delegate = self
        locDesContainer.addSubview(locationDesInput!)
        locationDesInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(locDesIcon.snp_right).offset(25)
            make.height.equalTo(locDesIcon)
            make.centerY.equalTo(locDesContainer)
            make.right.equalTo(locDesContainer).offset(-20)
        })
        //
        autoSetBoardContentSize()
    }
    
    func autoSetBoardContentSize() {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in board!.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        board?.contentSize = CGSizeMake(self.view.frame.width, contentRect.height - 60)
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("发布动态")
        let leftBtn = UIButton(frame: CGRectMake(0, 0, 10.5, 18))
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
        
        let rightBtn = UIButton(frame: CGRectMake(0, 0, 28, 16))
        rightBtn.setTitle(LS("发布"), forState: .Normal)
        rightBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        rightBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        rightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBtn)
    }
    
    func navRightBtnPressed() {
        // 发布这条状态
        let content = statusContentInput?.text ?? ""
        let selectedImages = addImagePanelDataSource!.images
        let car_id = sportCarList?.selectedCar?.carID
        let lat: Double? = userLocAnn?.coordinate.latitude
        let lon: Double? = userLocAnn?.coordinate.longitude
        let loc_description = locationDesInput?.text == "" ? "未知未知" : locationDesInput!.text
        let requester = StatusRequester.SRRequester
        requester.postNewStatus(content, images: selectedImages, car_id: car_id, lat: lat, lon: lon, loc_description: loc_description, onSuccess: { (let data) -> () in
            print(data)
            self.home?.dismissViewControllerAnimated(true, completion: nil)
            self.home?.followStatusCtrl.loadLatestData()
            }) { (code) -> () in
                print(code)
                self.displayAlertController(nil, message: LS("发送失败"))
        }
    }
    
    func navLeftBtnPressed() {
        home?.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - About photo Select
extension StatusReleaseController {
    
    func photoSelected(images: [UIImage]) {
        self.dismissViewControllerAnimated(true, completion: {
            
        })
        addImagePanelDataSource?.images.appendContentsOf(images)
        imageCountLbl?.text = "\(addImagePanelDataSource!.images.count)/\(addImagePanelDataSource!.maxImageNum)"
        addImagePanel?.reloadData()
        self.autoSetImageSelectPanelSize()
    }
    
    func autoSetImageSelectPanelSize() {
//        print(addImagePanel?.collectionViewLayout.collectionViewContentSize())
        addImagePanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(addImagePanel!.collectionViewLayout.collectionViewContentSize())
        })
        autoSetBoardContentSize()
    }
    
    func photeSelectCancelled() {
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - About map
extension StatusReleaseController {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        print(status)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        mapView?.setCenterCoordinate(center, zoomLevel: 12, animated: true)
        if userLocAnn == nil {
            userLocAnn = MGLPointAnnotation()
            userLocAnn?.title = "hahahhaha"
            userLocAnn?.coordinate = center
            mapView?.addAnnotation(userLocAnn!)
        }
        locationManager?.stopUpdatingLocation()
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        return nil
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("user_current_location")
        
        if annotationImage == nil {
            annotationImage = MGLAnnotationImage(image: UIImage(named: "map_default_marker")!, reuseIdentifier: "user_current_location")
        }
        
        return annotationImage
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
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
        }
    }
    
    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
        let userInfo = notif.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        if !locationDesInput!.editing {
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


class StatusReleaseAddImagePanelDataSource: NSObject, UICollectionViewDataSource{
    /// 最大的可选图像
    let maxImageNum: Int = 9
    var images: [UIImage]
    
    var controller: StatusReleaseController?
    
    
    init(newImages: [UIImage]) {
        if newImages.count > maxImageNum{
            assertionFailure()
        }
        self.images = newImages
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imageNum = self.images.count
        if imageNum == maxImageNum {
            return maxImageNum
        }
        return imageNum + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let imageCount = images.count
        if imageCount != maxImageNum && indexPath.row == imageCount {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusReleaseAddImageBtnCell.reuseIdentifier, forIndexPath: indexPath) as! StatusReleaseAddImageBtnCell
            cell.onAddImagePressed = { (let sender) in
                let photoPicker = StatusReleasePhotoAlbumListController(maxSelectLimit: kMaxPhotoSelect - self.images.count)
                photoPicker.delegate = self.controller
                let nav = BlackBarNavigationController(rootViewController: photoPicker)
                self.controller?.presentViewController(nav, animated: true, completion: nil)
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusReleaseAddImageCell.reuseIdentifier, forIndexPath: indexPath) as! StatusReleaseAddImageCell
        cell.deleteBtn?.tag = indexPath.row
        cell.imageView?.image = images[indexPath.row]
        cell.onDeletePressed = { (sender: UIButton) in
            let row = sender.tag
            self.images.removeAtIndex(row)
            self.controller?.addImagePanel?.reloadData()
            self.controller?.autoSetImageSelectPanelSize()
        }
        return cell
    }
}


class StatusReleaseAddImageCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "status_release_add_image_cell"
    
    /// 显示选中的图像
    var imageView: UIImageView?
    /// 左上角的删除按钮
    var deleteBtn: UIButton?
    /// 为了简化结构，这里用closure来传递消息
    var onDeletePressed: ((sender: UIButton)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = self.contentView
        //
        imageView = UIImageView()
        imageView?.contentMode = .ScaleAspectFill
        imageView?.clipsToBounds = true
        superview.addSubview(imageView!)
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(superview).inset(7.5)
        })
        //
        deleteBtn = UIButton()
        deleteBtn?.setImage(UIImage(named: "status_delete_image_btn"), forState: .Normal)
        deleteBtn?.addTarget(self, action: "deletePressed", forControlEvents: .TouchUpInside)
        superview.addSubview(deleteBtn!)
        deleteBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.size.equalTo(25)
        })
    }
    
    /**
     删除按钮按的响应函数
     */
    func deletePressed() {
        if let handler = onDeletePressed {
            handler(sender: deleteBtn!)
        }else{
            assertionFailure("Event handler not found")
        }
    }
}


class StatusReleaseAddImageBtnCell: UICollectionViewCell {
    
    static let reuseIdentifier = "status_release_add_image_btn_cell"
    
    /// 添加按钮
    var addBtn: UIButton?
    
    var onAddImagePressed: ((sender: UIButton)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        //
        addBtn = UIButton()
        superview.addSubview(addBtn!)
        addBtn?.setImage(UIImage(named: "status_add_image_btn"), forState: .Normal)
        addBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(superview).inset(7.5)
        })
        addBtn?.addTarget(self, action: "addImagePressed", forControlEvents: .TouchUpInside)
    }
    
    func addImagePressed() {
        if let handler = onAddImagePressed {
            handler(sender: addBtn!)
        }else{
            assertionFailure("Event handler not found")
        }
    }
}
