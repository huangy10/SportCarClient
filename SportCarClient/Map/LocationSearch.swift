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
    
    func locationSelectDidSelect(_ location: Location)
    
    func locationSelectDidCancel()
    
}

class LocationSelectController: InputableViewController, UITableViewDataSource, UITableViewDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate, BMKPoiSearchDelegate {
    
    weak var delegate: LocationSelectDelegate!
    
    var mapView: BMKMapView!
    
    var keywordInput: UITextField!
    var confirmBtn: UIButton!
    var tableView: UITableView!
    
    fileprivate var locationService: BMKLocationService!
    fileprivate var geoSearch: BMKGeoCodeSearch!
    fileprivate var searcher: BMKPoiSearch!
    
    fileprivate var data: [BMKPoiInfo] = []
    fileprivate var selectedPoi: BMKPoiInfo? {
        didSet {
            location = selectedPoi?.pt
            locDescription = selectedPoi?.name
            city = selectedPoi?.city
        }
    }
    
    var location: CLLocationCoordinate2D?
    var city: String?
    fileprivate var userLocation: BMKUserLocation? {
        didSet {
            self.location = userLocation?.location.coordinate
        }
    }
    var locDescription: String?
    
//    convenience init() {
//        self.init (currentLocation: nil, des: nil)
//    }
    
    init (currentLocation: CLLocationCoordinate2D?, des: String?) {
        super.init()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView.viewWillAppear()
        mapView.delegate = self
        geoSearch.delegate = self
        searcher.delegate = self
        locationService.delegate = self
        locationService.startUserLocationService()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapView.viewWillDisappear()
        mapView.delegate = nil
        geoSearch.delegate = nil
        searcher.delegate = nil
        locationService.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keywordInput.becomeFirstResponder()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        
        mapView = BMKMapView()
        mapView.zoomLevel = 16
        superview.addSubview(mapView)
        mapView.snp.makeConstraints { (make) in
            make.edges.equalTo(superview)
        }
        
        if let loc = self.location {
            mapView.setCenter(loc, animated: false)
        }
        
        let container = superview.addSubview(UIView.self)
            .config(UIColor.white)
            .addShadow()
            .layout { (make) in
                make.top.equalTo(superview).offset(40)
                make.left.equalTo(superview).offset(50)
                make.right.equalTo(superview).offset(-50)
                make.height.equalTo(50)
        }
        
        keywordInput = container.addSubview(UITextField.self)
            .config(14, text: self.locDescription)
            .layout({ (make) in
                make.edges.equalTo(container).inset(UIEdgeInsetsMake(5, 15, 5, 15))
            })
        keywordInput.delegate = self
        self.inputFields.append(keywordInput)
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LocationSelectCell.self, forCellReuseIdentifier: "cell")
        superview.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalTo(container)
            make.right.equalTo(container)
            make.top.equalTo(container.snp.bottom).offset(15)
            make.bottom.equalTo(superview).offset(-30)
        }
        tableView.isHidden = true
    }
    
    func navSettings() {
        navigationItem.title = LS("选择地点")
//        let navLeftBtn = UIButton()
//            .config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .ScaleAspectFit)
//            .setFrame(CGRectMake(0, 0, 15, 15))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        let navLeftBtn = UIBarButtonItem(title: LS("取消"), style: .done, target: self, action: #selector(navLeftBtnPressed))
        navLeftBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        navigationItem.leftBarButtonItem = navLeftBtn
        
        let navRightBtn = UIBarButtonItem(title: LS("确认"), style: .done, target: self, action: #selector(navRightBtnPressed))
        navRightBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        navigationItem.rightBarButtonItem = navRightBtn
    }
    
    func navLeftBtnPressed() {
        delegate.locationSelectDidCancel()
    }
    
    func navRightBtnPressed() {
        keywordInput.resignFirstResponder()
        if let location = location, let locDescription = locDescription {
            delegate.locationSelectDidSelect(Location(location: location, description: locDescription, city: city ?? ""))
        } else {
            showToast(LS("请选择一个地点"), onSelf: true)
        }
//        guard let poi = self.selectedPoi else {
//            self.showToast(LS("请选择一个地点"), onSelf: true)
//            return
//        }
//        delegate.locationSelectDidSelect(Location(location: poi.pt, description: poi.name))
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
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textField.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = (textField.text ?? "") as NSString
        let newText = curText.replacingCharacters(in: range, with: string) as String
        searchLocName(newText)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchLocName(textField.text!)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        searchLocName(textField.text!)
    }
    
    // MARK: - Map utilities
    
    func searchForLocation(_ loc: CLLocationCoordinate2D) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = loc
        let res = geoSearch.reverseGeoCode(option)
        if !res {
            self.showToast(LS("无法获取位置信息"))
        }
    }
    
    func searchLocName(_ name: String) {
        locDescription = name
        if name.length == 0 {
            return
        }
        let option = BMKNearbySearchOption()
        option.pageIndex = 0
        option.pageCapacity = 10
        option.keyword = name
        if let loc = self.location {
            option.location = loc
        }
        let res = searcher.poiSearchNear(by: option)
        if !res {
            showToast(LS("检索失败"))
        }
    }
    
    // MARK: - BMK delegates
    
    func didUpdate(_ userLocation: BMKUserLocation!) {
        locationService.stopUserLocationService()
        locationService.delegate = nil
        self.userLocation = userLocation
        mapView.setCenter(userLocation.location.coordinate, animated: true)
        mapView.zoomLevel = 16
        mapView.delegate = self
        
        let anno = BMKPointAnnotation()
        anno.coordinate = userLocation.location.coordinate
        mapView.addAnnotation(anno)
        
        searchForLocation(userLocation.location.coordinate)
    }
    
    func mapView(_ mapView: BMKMapView!, viewFor annotation: BMKAnnotation!) -> BMKAnnotationView! {
        guard let anno = mapView.dequeueReusableAnnotationView(withIdentifier: "anno") as? UserSelectAnnotationView else {
            let anno = UserSelectAnnotationView(annotation: annotation, reuseIdentifier: "anno")
            return anno
        }
        anno.annotation = annotation
        return anno
    }
    
    func onGetGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        print(error)
        print(result.address)
        print(result.location)
    }
    
    func onGetReverseGeoCodeResult(_ searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        
    }
    
    func onGetPoiResult(_ searcher: BMKPoiSearch!, result poiResult: BMKPoiResult!, errorCode: BMKSearchErrorCode) {
        if errorCode == BMK_SEARCH_NO_ERROR {
            if let data = poiResult.poiInfoList as? [BMKPoiInfo] , data.count > 0{
                self.data = data
                
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        } else if errorCode == BMK_SEARCH_RESULT_NOT_FOUND {
//            self.showToast(LS("没有找到结果"), onSelf: true)
        } else {
            self.showToast(LS("查找过程中出错"))
        }
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LocationSelectCell
        let d = data[(indexPath as NSIndexPath).row]
        cell.titleLbl.text = d.name
        cell.detailLbl.text = d.address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapView.removeAnnotations(mapView.annotations)

        let d = data[(indexPath as NSIndexPath).row]
        keywordInput.text = d.name
        mapView.setCenter(d.pt, animated: true)
        let anno = BMKPointAnnotation()
        anno.coordinate = d.pt
        mapView.addAnnotation(anno)
        selectedPoi = d
        tableView.isHidden = true
    }
}
