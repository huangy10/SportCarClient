//
//  SportCarInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/10.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


protocol SportCarInfoCelLDelegate {
    func carNeedEdit()
}


class SportCarInfoCell: UICollectionViewCell, UIPageViewControllerDataSource {
    var car: SportCar!
    
    var carImages: [String] = []
    var carImagesDisplay: UIPageViewController!
    var carNameLbl: UILabel!
    var carAuthIcon: UIImageView!
    var carEditBtn: UIButton!
    var carSignatureLbl: UILabel!
    var carParamBoard: UIView!
    var carPrice: UILabel!
    var carEngine: UILabel!
    var carTrans: UILabel!
    var carBody: UILabel!
    var carSpeed: UILabel!
    var carAcce: UILabel!
    
    func createSubviews() {
        let superview = self.contentView
        //
        carImagesDisplay = UIPageViewController(transitionStyle: .PageCurl, navigationOrientation: .Horizontal, options: nil)
        carImagesDisplay.dataSource = self
        let carImagesDisplayView = carImagesDisplay.view
        superview.addSubview(carImagesDisplayView)
        carImagesDisplayView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(carImagesDisplayView.snp_width)
        }
        //
        carNameLbl = UILabel()
        carNameLbl.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        carNameLbl.textColor = UIColor.blackColor()
        superview.addSubview(carNameLbl)
        carNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.top.equalTo(carImagesDisplayView).offset(15)
            make.width.equalTo(superview).multipliedBy(0.55)
        }
        //
        carAuthIcon = UIImageView()
        superview.addSubview(carAuthIcon)
        carAuthIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carNameLbl.snp_right).offset(5)
            make.top.equalTo(carNameLbl).offset(5)
            make.size.equalTo(CGSizeMake(44, 18.5))
        }
        //
        carEditBtn = UIButton()
        carEditBtn.setTitle(LS("编辑"), forState: .Normal)
        carEditBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        carEditBtn.addTarget(self, action: "carEditBtnPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(carEditBtn)
        carEditBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(carEditBtn)
            make.size.equalTo(CGSizeMake(56, 32))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(carNameLbl.snp_bottom).offset(12.5)
            make.left.equalTo(carNameLbl)
            make.width.equalTo(carNameLbl)
            make.height.equalTo(0.5)
        }
        //
        carSignatureLbl = UILabel()
        carSignatureLbl.textColor = UIColor(white: 0.72, alpha: 1)
        carSignatureLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(carSignatureLbl)
        carSignatureLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.top.equalTo(sepLine).offset(12)
            make.width.equalTo(carNameLbl)
        }
        //
        carParamBoard = UIView()
        carParamBoard.backgroundColor = UIColor(red: 0.145, green: 0.161, blue: 0.173, alpha: 1)
        superview.addSubview(carParamBoard)
        carParamBoard.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(carSignatureLbl.snp_bottom).offset(22.5)
            make.height.equalTo(250)
        }
        //
        let staticCarPriceLbl = getCarParamStaticLabel()
        carParamBoard.addSubview(staticCarPriceLbl)
        staticCarPriceLbl.text = LS("价格")
        staticCarPriceLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(carParamBoard).offset(20)
        }
        //
        carPrice = getCarParamContentLbl()
        carParamBoard.addSubview(carPrice)
        carPrice.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarPriceLbl)
            make.top.equalTo(staticCarPriceLbl.snp_bottom)
        }
        //
        let staticCarEngineLbl = getCarParamStaticLabel()
        carParamBoard.addSubview(staticCarEngineLbl)
        staticCarEngineLbl.text = LS("发动机")
        staticCarEngineLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview.snp_centerX).offset(20)
            make.top.equalTo(carParamBoard).offset(20)
        }
        //
        carEngine = getCarParamContentLbl()
        carParamBoard.addSubview(carEngine)
        carEngine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarEngineLbl)
            make.top.equalTo(staticCarEngineLbl.snp_bottom)
        }
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carParamBoard.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(carParamBoard).offset(84)
            make.left.equalTo(carParamBoard)
            make.right.equalTo(carParamBoard)
            make.height.equalTo(0.5)
        }
        //
        let staticTransLbl = getCarParamStaticLabel()
        staticTransLbl.text = LS("变速箱")
        carParamBoard.addSubview(staticTransLbl)
        staticTransLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(sepLine2).offset(20)
        }
        //
        carTrans = getCarParamContentLbl()
        carParamBoard.addSubview(carTrans)
        carTrans.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticTransLbl)
            make.top.equalTo(staticTransLbl.snp_bottom)
        }
        //
        let staticCarBody = getCarParamStaticLabel()
        staticCarBody.text = LS("车身结构")
        carParamBoard.addSubview(staticCarBody)
        staticCarBody.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard.snp_centerX).offset(20)
            make.top.equalTo(sepLine2).offset(20)
        }
        //
        carBody = getCarParamContentLbl()
        carParamBoard.addSubview(carBody)
        carBody.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarBody)
            make.top.equalTo(staticCarBody.snp_bottom)
        }
        //
        let sepLine3 = UIView()
        sepLine3.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carParamBoard.addSubview(sepLine3)
        sepLine3.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard)
            make.right.equalTo(carParamBoard)
            make.top.equalTo(sepLine2).offset(82)
            make.height.equalTo(0.5)
        }
        //
        let staticCarSpeed = getCarParamStaticLabel()
        staticCarSpeed.text = LS("最高车速")
        carParamBoard.addSubview(staticCarSpeed)
        staticCarSpeed.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(sepLine3).offset(20)
        }
        //
        carSpeed = getCarParamContentLbl()
        carParamBoard.addSubview(carSpeed)
        carSpeed.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarSpeed)
            make.top.equalTo(staticCarSpeed.snp_bottom)
        }
        //
        let staticCarAcce = getCarParamStaticLabel()
        staticCarAcce.text = LS("百公里加速")
        carParamBoard.addSubview(staticCarAcce)
        staticCarAcce.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard.snp_centerX).offset(20)
            make.top.equalTo(sepLine3).offset(20)
        }
        // 
        carAcce = getCarParamContentLbl()
        carParamBoard.addSubview(carAcce)
        carAcce.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarAcce)
            make.top.equalTo(staticCarAcce.snp_bottom)
        }
    }
    
    func loadDataAndUpdateUI() {
        // 设置数据
    }
    
    func getCarParamStaticLabel() -> UILabel {
        let staticLbl = UILabel()
        staticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        return staticLbl
    }
    
    func getCarParamContentLbl() -> UILabel {
        let contentLbl = UILabel()
        contentLbl.font = UIFont.systemFontOfSize(17, weight: UIFontWeightSemibold)
        contentLbl.textColor = UIColor.whiteColor()
        return contentLbl
    }
    
    func carEditBtnPressed() {
        
    }
}
