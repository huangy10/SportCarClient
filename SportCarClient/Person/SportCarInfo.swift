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


protocol SportCarInfoCellDelegate: class {
    func carNeedEdit(own: SportCar)
}


class SportCarInfoCell: UICollectionViewCell, SportCarGallaryDataSource {
    static let reuseIdentifier = "sport_car_info_cell"
    
    weak var delegate: SportCarInfoCellDelegate?
    var car: SportCar!
    var mine: Bool = false
    
    @available(*, deprecated=1)
    var carCover: UIImageView!
    var carGallary: SportCarGallary!
    
    var carNameLbl: UILabel!
    var carAuthIcon: UIImageView!
    var carEditBtn: UIButton!
    var carSignatureLbl: UILabel!
    var carParamBoard: UIView!
    var carPrice: UILabel!
    var carEngine: UILabel!
    var carTorque: UILabel!
    var carBody: UILabel!
    var carSpeed: UILabel!
    var carAcce: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
//        carCover = UIImageView()
//        carCover.contentMode = .ScaleAspectFill
//        carCover.clipsToBounds = true
//        superview.addSubview(carCover)
//        carCover.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(superview)
//            make.height.equalTo(carCover.snp_width).multipliedBy(0.588)
//        }
        carGallary = SportCarGallary(dataSource: self)
        superview.addSubview(carGallary)
        carGallary.snp_makeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(carGallary.snp_width).multipliedBy(0.588)
        }
        //
        carNameLbl = UILabel()
        carNameLbl.font = UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)
        carNameLbl.textColor = UIColor.blackColor()
        carNameLbl.numberOfLines = 0
        superview.addSubview(carNameLbl)
        carNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.top.equalTo(carGallary.snp_bottom).offset(15)
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
        carEditBtn.setTitle(LS("认证"), forState: .Normal)
        carEditBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        carEditBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        carEditBtn.addTarget(self, action: #selector(carEditBtnPressed), forControlEvents: .TouchUpInside)
        superview.addSubview(carEditBtn)
        carEditBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(carAuthIcon)
            make.size.equalTo(CGSizeMake(56, 32))
        }
        //
        let sepLineBackgroundColor = UIColor(white: 0.1, alpha: 1)
//        let sepLine = UIView()
//        sepLine.backgroundColor = sepLineBackgroundColor
//        superview.addSubview(sepLine)
//        sepLine.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(carNameLbl.snp_bottom).offset(12.5)
//            make.left.equalTo(carNameLbl)
//            make.width.equalTo(carNameLbl)
//            make.height.equalTo(0.5)
//        }
        //
        carSignatureLbl = superview.addSubview(UILabel.self)
            .config(14, textColor: UIColor(white: 0, alpha: 0.58), multiLine: true)
            .layout({ (make) in
                make.left.equalTo(superview).offset(20)
                make.top.equalTo(carNameLbl.snp_bottom).offset(20)
                make.width.equalTo(carNameLbl)
            })
        //
        carParamBoard = superview.addSubview(UIView.self)
            .config(UIColor(red: 0.145, green: 0.161, blue: 0.173, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(superview)
                make.right.equalTo(superview)
                make.top.equalTo(carSignatureLbl.snp_bottom).offset(22.5)
                make.height.equalTo(250)
            })
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
        sepLine2.backgroundColor = sepLineBackgroundColor
        carParamBoard.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(carParamBoard).offset(84)
            make.left.equalTo(carParamBoard)
            make.right.equalTo(carParamBoard)
            make.height.equalTo(0.5)
        }
        //
        let staticTransLbl = getCarParamStaticLabel()
        staticTransLbl.text = LS("扭矩")
        carParamBoard.addSubview(staticTransLbl)
        staticTransLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(sepLine2).offset(20)
        }
        //
        carTorque = getCarParamContentLbl()
        carParamBoard.addSubview(carTorque)
        carTorque.snp_makeConstraints { (make) -> Void in
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
        sepLine3.backgroundColor = sepLineBackgroundColor
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
        // 设置跑车名
        carNameLbl.text = car.name
        // 设置封面图
//        carCover.kf_setImageWithURL(car.imageArray[0])
        carGallary.reloadData()
        // 设置认证标签
        if car.identified {
            carAuthIcon.image = UIImage(named: "auth_status_authed")
        }else {
            carAuthIcon.image = UIImage(named: "auth_status_unauthed")
        }
        // 跑车签名
        carSignatureLbl.text = car.signature
        // 跑车性能指标设置
        carPrice.text = car.price
        carEngine.text = car.engine
        carTorque.text = car.torque
        carBody.text = car.body
        carSpeed.text = car.maxSpeed
        carAcce.text = car.zeroTo60
        carEditBtn.hidden = !mine

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
        delegate?.carNeedEdit(car)
    }
    
    class func getPreferredSizeForSignature(signature: String, carName: String) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let coverHeight = screenWidth * 0.588
        let designTotalHeight: CGFloat = 634
        let staticHeight = designTotalHeight - 216 - 52 - 52
        let signatureLblWidth = screenWidth * 0.55
        let signatureLblHeight = signature.boundingRectWithSize(CGSizeMake(signatureLblWidth, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)], context: nil).height
        let carNameHeight = carName.boundingRectWithSize(CGSizeMake(signatureLblWidth, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(19, weight: UIFontWeightSemibold)], context: nil).height
        return CGSizeMake(screenWidth, signatureLblHeight + staticHeight + coverHeight + carNameHeight)
    }
    
    func numberOfItems() -> Int {
        let imageNum = car.imageArray.count
        let videoNum = car.videoURL == nil ? 0 : 1
        return imageNum + videoNum
    }
    
    func itemSize() -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.width
        return CGSizeMake(screenWidth, screenWidth * 0.588)
    }
    
    func itemForPage(pageNum: Int) -> SportCargallaryItem {
        let imageNum = car.imageArray.count
        if pageNum < imageNum {
            let image = car.imageArray[pageNum]
            return SportCargallaryItem(itemType: "image", resource: image)
        } else {
            return SportCargallaryItem(itemType: "video", resource: car.videoURL!)
        }
    }
    
    func configCarAudioWave() {
        // 配置跑车声浪
        
    }
}

class CarWaveView: UIView {
    var playBtn: UIButton!
    var isPlaying: Bool = false
    var remainingTimeLbl: UILabel!
    var processView: WideProcessView!
    var wavMask: UIImageView!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    var audioURL: NSURL!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configPlayBtn()
        configProcessView()
        configWaveMask()
        configRemainingTimeLbl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configPlayBtn() {
        playBtn = addSubview(UIButton)
            .config(self, selector: #selector(playBtnPressed(_:)), image: UIImage(named: "chat_voice_play"), contentMode: .ScaleAspectFit)
            .layout({ (make) in
                make.left.equalTo(self)
                make.centerY.equalTo(self)
                make.size.equalTo(25)
            })
    }
    
    func configProcessView() {
        processView = addSubview(WideProcessView).layout({ (make) in
            make.left.equalTo(playBtn.snp_right).offset(15)
            make.height.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(167)
        })
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func configWaveMask() {
    }
    
    func configRemainingTimeLbl() {
        remainingTimeLbl = addSubview(UILabel).config(10, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0.58, alpha: 1), textAlignment: .Left, text: "--:--")
            .layout({ (make) in
                make.centerY.equalTo(self)
                make.left.equalTo(processView.snp_right).offset(10)
            })
    }
    
    func playBtnPressed(sender: UIButton) {
        wavMask = UIImageView()
        wavMask.frame = processView.bounds
        wavMask.backgroundColor = UIColor(white: 1, alpha: 0)
        processView.maskView = wavMask
    }
    
    func onLongPressed(gesture: UILongPressGestureRecognizer) {
        
    }
    
    func stopPlayerAnyWay() {
        if isPlaying {
            playBtnPressed(playBtn)
        }
    }
    
    func getRemainingTimeString(process: Double, duration: Double) -> String{
        let leftTime = Int(duration * (1 - process))
        let min = leftTime / 60
        let sec = leftTime - 60 * min
        return "-\(min):\(sec)"
    }
    
    func getRequiredWidth() -> CGFloat {
        var contentRect = CGRectZero
        for view in self.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        return contentRect.width
    }
}

