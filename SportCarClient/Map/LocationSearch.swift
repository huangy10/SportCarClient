//
//  File.swift
//  SportCarClient
//
//  Created by 黄延 on 16/5/14.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationSelectDelegate: class {
    
    func locationSelectDidSelect(location: Location)
    
    func locationSelectDidCancel()
    
}

class LocationSelectController: InputableViewController, UITableViewDataSource, UITableViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, BMKPoiSearchDelegate {
    
    weak var delegate: LocationSelectDelegate!
    
    var mapView: BMKMapView!
    
    var keywordInput: UITextField!
    var confirmBtn: UIButton!
    var tableView: UITableView!
    
    private var locationService: BMKLocationService!
    private var geoSearch: BMKGeoCodeSearch!
    private var searcher: BMKPoiSearch!
    
    private var data: [BMKPoiInfo] = []
    private var selectedPoi: BMKPoiInfo?
    
    var location: CLLocationCoordinate2D?
    private var userLocation: BMKUserLocation? {
        didSet {
            self.location = userLocation?.location.coordinate
        }
    }
    var locDescription: String?
    
    convenience init() {
        self.init (currentLocation: nil, des: nil)
    }
    
    init (currentLocation: CLLocationCoordinate2D?, des: String?) {
        super.init(nibName: nil, bundle: nil)
        self.location = currentLocation
        self.locDescription = des
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationService = BMKLocationService()
        geoSearch = BMKGeoCodeSearch()
        searcher = BMKPoiSearch()
        navSettings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
        mapView.delegate = self
        geoSearch.delegate = self
        searcher.delegate = self
        locationService.delegate = self
        locationService.startUserLocationService()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
        mapView.delegate = nil
        geoSearch.delegate = nil
        searcher.delegate = nil
        locationService.delegate = nil
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        keywordInput.becomeFirstResponder()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        
        mapView = BMKMapView()
        mapView.zoomLevel = 16
        superview.addSubview(mapView)
        mapView.snp_makeConstraints { (make) in
            make.edges.equalTo(superview)
        }
        
        if let loc = self.location {
            mapView.setCenterCoordinate(loc, animated: false)
        }
        
        let container = superview.addSubview(UIView)
            .config(UIColor.whiteColor())
            .addShadow()
            .layout { (make) in
                make.top.equalTo(superview).offset(40)
                make.left.equalTo(superview).offset(50)
                make.right.equalTo(superview).offset(-50)
                make.height.equalTo(50)
        }
        
        keywordInput = container.addSubview(UITextField)
            .config(14, text: self.locDescription)
            .layout({ (make) in
                make.edges.equalTo(container).inset(UIEdgeInsetsMake(5, 15, 5, 15))
            })
        keywordInput.delegate = self
        self.inputFields.append(keywordInput)
        
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(LocationSelectCell.self, forCellReuseIdentifier: "cell")
        superview.addSubview(tableView)
        tableView.snp_makeConstraints { (make) in
            make.left.equalTo(container)
            make.right.equalTo(container)
            make.top.equalTo(container.snp_bottom).offset(15)
            make.bottom.equalTo(superview).offset(-30)
        }
        tableView.hidden = true
    }
    
    func navSettings() {
        navigationItem.title = LS("选择地点")
//        let navLeftBtn = UIButton()
//            .config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .ScaleAspectFit)
//            .setFrame(CGRectMake(0, 0, 15, 15))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        let navLeftBtn = UIBarButtonItem(title: LS("取消"), style: .Done, target: self, action: #selector(navLeftBtnPressed))
        navLeftBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        navigationItem.leftBarButtonItem = navLeftBtn
        
        let navRightBtn = UIBarButtonItem(title: LS("确认"), style: .Done, target: self, action: #selector(navRightBtnPressed))
        navRightBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        navigationItem.rightBarButtonItem = navRightBtn
    }
    
    func navLeftBtnPressed() {
        delegate.locationSelectDidCancel()
    }
    
    func navRightBtnPressed() {
        guard let poi = self.selectedPoi else {
            self.showToast(LS("请选择一个地点"))
            return
        }
        delegate.locationSelectDidSelect(Location(location: poi.pt, description: poi.name))
    }
    
    // MARK: - TextField delegate
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        if let locDes = textField.text {
//            searchLocName(locDes)
//        }
//        return true
//    }
//    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textField.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = (textField.text ?? "") as NSString
        let newText = curText.stringByReplacingCharactersInRange(range, withString: string) as String
        searchLocName(newText)
        return true
    }
    
    // MARK: - Map utilities
    
    func searchForLocation(loc: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = loc
        let res = geoSearch.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取位置信息"))
        }
    }
    
    func searchLocName(name: String) {
        let option = BMKNearbySearchOption()
        option.pageIndex = 0
        option.pageCapacity = 10
        option.keyword = name
        if let loc = self.location {
            option.location = loc
        }
        let res = searcher.poiSearchNearBy(option)
        if !res {
            showToast(LS("检索失败"))
        }
    }
    
    // MARK: - BMK delegates
    
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        locationService.delegate = nil
        self.userLocation = userLocation
        mapView.setCenterCoordinate(userLocation.location.coordinate, animated: true)
        mapView.zoomLevel = 16
        mapView.delegate = self
        
        let anno = BMKPointAnnotation()
        anno.coordinate = userLocation.location.coordinate
        mapView.addAnnotation(anno)
        
        searchForLocation(userLocation.location.coordinate)
    }
    
    func mapView(mapView: BMKMapView!, viewForAnnotation annotation: BMKAnnotation!) -> BMKAnnotationView! {
        guard let anno = mapView.dequeueReusableAnnotationViewWithIdentifier("anno") as? UserSelectAnnotationView else {
            let anno = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "anno")
            return anno
        }
        anno.annotation = annotation
        return anno
    }
    
    func onGetGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print(error)
        print(result.address)
        print(result.location)
    }
    
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
    }
    
    func onGetPoiResult(searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            if let data = poiResult.poiInfoList as? [BMKPoiInfo] where data.count > 0{
                self.data = data
                data.each({ print($0.name) })
                self.tableView.hidden = false
                self.tableView.reloadData()
            } else {
                self.showToast(LS("没有找到结果"), onSelf: true)
            }
        } else if errorCode == BMK_SEARCH_RESULT_NOT_FOUND {
            self.showToast(LS("没有找到结果"), onSelf: true)
        } else {
            self.showToast(LS("查找过程中出错"))
        }
    }
    
    // MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! LocationSelectCell
        let d = data[indexPath.row]
        cell.titleLbl.text = d.name
        cell.detailLbl.text = d.address
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        mapView.removeAnnotations(mapView.annotations)

        let d = data[indexPath.row]
        keywordInput.text = d.name
        mapView.setCenterCoordinate(d.pt, animated: true)
        let anno = BMKPointAnnotation()
        anno.coordinate = d.pt
        mapView.addAnnotation(anno)
        selectedPoi = d
        tableView.hidden = true
    }
}
