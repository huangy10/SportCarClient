//
//  MapOperationView.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol MapOperationDelegate: class {
    func mapOperationGetUserLocation() -> CLLocationCoordinate2D?
}

class MapOpertaionView: UIView {
    var locateBtn: UIButton!
    var zoomInBtn: UIButton!
    var zoomOutBtn: UIButton!
    weak var map: BMKMapView!
    weak var delegate: MapOperationDelegate!
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 40, height: 153)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureLocateBtn()
        configureZoomBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureLocateBtn() {
        locateBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(locateBtnPressed))
            .layout({ (mk) in
                mk.bottom.equalToSuperview()
                mk.centerX.equalToSuperview()
                mk.size.equalTo(40)
            })
        locateBtn.backgroundColor = .white
        locateBtn.layer.cornerRadius = 20
        locateBtn.setImage(#imageLiteral(resourceName: "locate_btn"), for: .normal)
        locateBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        locateBtn.addShadow()
    }
    
    func configureZoomBtn() {
        let container = addSubview(UIView.self).config(.white)
            .layout { (mk) in
                mk.centerX.equalToSuperview()
                mk.top.equalToSuperview()
                mk.width.equalTo(40)
                mk.height.equalTo(100)
        }
        container.layer.cornerRadius = 20
        container.addShadow()
        
        container.addSubview(UIView.self).config(UIColor(white: 0, alpha: 0.12))
            .layout { (mk) in
                mk.center.equalTo(container)
                mk.height.equalTo(0.5)
                mk.width.equalTo(25)
        }
        
        zoomInBtn = container.addSubview(UIButton.self)
            .config(self, selector: #selector(zoomBtnPressed(_:)))
            .layout({ (mk) in
                mk.left.equalToSuperview()
                mk.right.equalToSuperview()
                mk.top.equalToSuperview()
                mk.height.equalToSuperview().dividedBy(2)
            })
        zoomInBtn.tag = 1
//        zoomInBtn.addTarget(self, action: #selector(zoomBtnHoldBegin(_:)), for: .touchDown)
//        zoomInBtn.addTarget(self, action: #selector(zoomBtnHoldStop(_:)), for: .touchDragExit)
        
        zoomOutBtn = container.addSubview(UIButton.self)
            .config(self, selector: #selector(zoomBtnPressed(_:)))
            .layout({ (mk) in
                mk.left.equalToSuperview()
                mk.right.equalToSuperview()
                mk.bottom.equalToSuperview()
                mk.height.equalToSuperview().dividedBy(2)
            })
        zoomOutBtn.tag = -1
        
//        zoomOutBtn.addTarget(self, action: #selector(zoomBtnHoldBegin(_:)), for: .touchDown)
//        zoomOutBtn.addTarget(self, action: #selector(zoomBtnHoldStop(_:)), for: .touchDragExit)
        
        container.addSubview(UILabel.self)
            .config(32, fontWeight: UIFontWeightUltraLight, textColor: .black, textAlignment: .center, text: "+")
            .layout { (mk) in
                mk.centerX.equalToSuperview()
                mk.centerY.equalTo(container.snp.top).offset(22)
        }
        
        container.addSubview(UILabel.self)
            .config(40, fontWeight: UIFontWeightUltraLight, textColor: .black, textAlignment: .center, text: "-")
            .layout { (mk) in
                mk.centerX.equalToSuperview()
                mk.centerY.equalTo(container.snp.bottom).offset(-22)
        }
    }
    
    func locateBtnPressed() {
        if let location = delegate.mapOperationGetUserLocation() {
            let region = BMKCoordinateRegionMakeWithDistance(location, 3000, 5000)
            map.setRegion(region, animated: true)
        } else if let vc = delegate as? UIViewController {
            vc.showToast(LS("无法定位当前位置"))
        }
    }
    
    var isZoomHolding: Bool = false
    var timer: Timer?
    var zoomDir: Float = 0
    var contineousZoomed: Bool = false
    
    func zoomBtnPressed(_ sender: UIButton) {
        if !contineousZoomed {
            map.zoomLevel += Float(sender.tag)
        }
        isZoomHolding = false
        timer?.invalidate()
        timer = nil
    }
    
    func zoomBtnHoldBegin(_ sender: UIButton) {
        isZoomHolding = true
        contineousZoomed = false
        zoomDir = Float(sender.tag)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.contineousZoom), userInfo: nil, repeats: true)
        })
    }
    
    func zoomBtnHoldStop(_ sender: UIButton) {
        isZoomHolding = false
        timer?.invalidate()
        timer = nil
    }
    
    func contineousZoom() {
        if !isZoomHolding {
            timer?.invalidate()
            timer = nil
            return
        }
        DispatchQueue.main.async {
            self.contineousZoomed = true
            self.map.zoomLevel += self.zoomDir * 0.2
        }
    }
}
