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
    func carNeedEdit(_ own: SportCar)
}


class SportCarInfoCell: UICollectionViewCell, SportCarGallaryDataSource {
    static let reuseIdentifier = "sport_car_info_cell"
    
    weak var delegate: SportCarInfoCellDelegate?
    var car: SportCar!
    var mine: Bool = false
    
    var carGallary: SportCarGallary!
    var carAudioWave: CarWaveView?
    
    var carNameLbl: UILabel!
    
    @available(*, deprecated: 1)
    var carAuthIcon: UIImageView!
    var carEditBtn: UIButton!
    var carSignatureLbl: UILabel!
    var carParamBoard: UIView!
    var carPrice: UILabel!
    var carEngine: UILabel!
    var carSubname: UILabel!
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
        superview.backgroundColor = UIColor.white
        //
//        carCover = UIImageView()
//        carCover.contentMode = .ScaleAspectFill
//        carCover.clipsToBounds = true
//        superview.addSubview(carCover)
//        carCover.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(superview)
//            make.height.equalTo(carCover.snp.width).multipliedBy(0.588)
//        }
        carGallary = SportCarGallary(dataSource: self)
        superview.addSubview(carGallary)
        carGallary.snp.makeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(carGallary.snp.width).multipliedBy(0.588)
        }
        //
        carNameLbl = UILabel()
        carNameLbl.font = UIFont.systemFont(ofSize: 19, weight: UIFontWeightSemibold)
        carNameLbl.textColor = UIColor.black
        carNameLbl.numberOfLines = 0
        superview.addSubview(carNameLbl)
        carNameLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.top.equalTo(carGallary.snp.bottom).offset(15)
            make.width.equalTo(superview).multipliedBy(0.55)
        }
        //
        carEditBtn = UIButton()
        carEditBtn.setTitle(LS("设置/认证"), for: .normal)
        carEditBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        carEditBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        carEditBtn.addTarget(self, action: #selector(carEditBtnPressed), for: .touchUpInside)
        superview.addSubview(carEditBtn)
        carEditBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(carNameLbl).offset(2)
            make.size.equalTo(CGSize(width: 70, height: 32))
        }
        //
        let sepLineBackgroundColor = UIColor(white: 0.1, alpha: 1)
//        let sepLine = UIView()
//        sepLine.backgroundColor = sepLineBackgroundColor
//        superview.addSubview(sepLine)
//        sepLine.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(carNameLbl.snp.bottom).offset(12.5)
//            make.left.equalTo(carNameLbl)
//            make.width.equalTo(carNameLbl)
//            make.height.equalTo(0.5)
//        }
        //
        carSignatureLbl = superview.addSubview(UILabel.self)
            .config(14, textColor: UIColor(white: 0, alpha: 0.58), multiLine: true)
            .layout({ (make) in
                make.left.equalTo(superview).offset(20)
                make.top.equalTo(carNameLbl.snp.bottom).offset(20)
                make.width.equalTo(carNameLbl)
            })
        carAudioWave = CarWaveView()
        superview.addSubview(carAudioWave!)
        carAudioWave!.snp.makeConstraints({ (make) in
            make.top.equalTo(carSignatureLbl.snp.bottom).offset(22.5)
            make.left.equalTo(carSignatureLbl)
            make.size.equalTo(CGSize(width: 270, height: 50))
        })
        
        carParamBoard = superview.addSubview(UIView.self)
            .config(UIColor(red: 0.145, green: 0.161, blue: 0.173, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(superview)
                make.right.equalTo(superview)
                make.top.equalTo(carSignatureLbl.snp.bottom).offset(22.5)
                make.height.equalTo(250)
            })

        //
        let staticSubtypeLbl = getCarParamStaticLabel()
        carParamBoard.addSubview(staticSubtypeLbl)
        staticSubtypeLbl.text = LS("型号")
        staticSubtypeLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(carParamBoard).offset(20)
        }
        //
        carSubname = getCarParamContentLbl()
        carParamBoard.addSubview(carSubname)
        carSubname.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticSubtypeLbl)
            make.top.equalTo(staticSubtypeLbl.snp.bottom)
        }
        //
        let staticPriceLbl = getCarParamStaticLabel()
        carParamBoard.addSubview(staticPriceLbl)
        staticPriceLbl.text = LS("价格")
        staticPriceLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview.snp.centerX).offset(20)
            make.top.equalTo(carParamBoard).offset(20)
        }
        //
        carPrice = getCarParamContentLbl()
        carParamBoard.addSubview(carPrice)
        carPrice.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticPriceLbl)
            make.top.equalTo(staticPriceLbl.snp.bottom)
        }
                //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = sepLineBackgroundColor
        carParamBoard.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(carParamBoard).offset(84)
            make.left.equalTo(carParamBoard)
            make.right.equalTo(carParamBoard)
            make.height.equalTo(0.5)
        }
        //
        let staticEngineLbl = getCarParamStaticLabel()
        staticEngineLbl.text = LS("发动机")
        carParamBoard.addSubview(staticEngineLbl)
        staticEngineLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(sepLine2).offset(20)
        }
        //
        
        carEngine = getCarParamContentLbl()
        carParamBoard.addSubview(carEngine)
        carEngine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticEngineLbl)
            make.top.equalTo(staticEngineLbl.snp.bottom)
        }

        //
        let staticCarBody = getCarParamStaticLabel()
        staticCarBody.text = LS("车身结构")
        carParamBoard.addSubview(staticCarBody)
        staticCarBody.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard.snp.centerX).offset(20)
            make.top.equalTo(sepLine2).offset(20)
        }
        //
        carBody = getCarParamContentLbl()
        carParamBoard.addSubview(carBody)
        carBody.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarBody)
            make.top.equalTo(staticCarBody.snp.bottom)
        }
        //
        let sepLine3 = UIView()
        sepLine3.backgroundColor = sepLineBackgroundColor
        carParamBoard.addSubview(sepLine3)
        sepLine3.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard)
            make.right.equalTo(carParamBoard)
            make.top.equalTo(sepLine2).offset(82)
            make.height.equalTo(0.5)
        }
        //
        let staticCarSpeed = getCarParamStaticLabel()
        staticCarSpeed.text = LS("最高车速")
        carParamBoard.addSubview(staticCarSpeed)
        staticCarSpeed.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard).offset(20)
            make.top.equalTo(sepLine3).offset(20)
        }
        //
        carSpeed = getCarParamContentLbl()
        carParamBoard.addSubview(carSpeed)
        carSpeed.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarSpeed)
            make.top.equalTo(staticCarSpeed.snp.bottom)
        }
        //
        let staticCarAcce = getCarParamStaticLabel()
        staticCarAcce.text = LS("百公里加速")
        carParamBoard.addSubview(staticCarAcce)
        staticCarAcce.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(carParamBoard.snp.centerX).offset(20)
            make.top.equalTo(sepLine3).offset(20)
        }
        // 
        carAcce = getCarParamContentLbl()
        carParamBoard.addSubview(carAcce)
        carAcce.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(staticCarAcce)
            make.top.equalTo(staticCarAcce.snp.bottom)
        }
    }
    
    func showAudioWave() {
        let superview = self.contentView
        carAudioWave?.isHidden = false
        carParamBoard.snp.remakeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(carAudioWave!.snp.bottom).offset(22.5)
            make.height.equalTo(250)
        }
        superview.layoutIfNeeded()
    }
    
    func hideAudioWave() {
        let superview = self.contentView
        carAudioWave?.isHidden = true
        carParamBoard.snp.remakeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(carSignatureLbl.snp.bottom).offset(22.5)
            make.height.equalTo(250)
        }
    }
    
    func loadDataAndUpdateUI() {
        // 设置数据
        // 设置跑车名
        carNameLbl.text = car.name
        // 设置封面图
//        carCover.kf_setImageWithURL(car.imageArray[0])
        carGallary.reloadData()
        if let audioURL = car.audioURL {
            carAudioWave?.audioURL = audioURL as URL!
            showAudioWave()
        } else {
            hideAudioWave()
        }
        // 跑车签名
        carSignatureLbl.text = car.signature
        // 跑车性能指标设置
        carPrice.text = car.price
        carEngine.text = car.engine
        carSubname.text = car.subname ?? car.name!
        carBody.text = car.body
        carSpeed.text = car.maxSpeed
        carAcce.text = car.zeroTo60
        carEditBtn.isHidden = !mine

    }
    
    func getCarParamStaticLabel() -> UILabel {
        let staticLbl = UILabel()
        staticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        staticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        return staticLbl
    }
    
    func getCarParamContentLbl() -> UILabel {
        let contentLbl = UILabel()
        contentLbl.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
        contentLbl.textColor = UIColor.white
        return contentLbl
    }
    
    func carEditBtnPressed() {
        delegate?.carNeedEdit(car)
    }
    
    class func getPreferredSizeForSignature(_ signature: String, carName: String, withAudioWave: Bool) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        let coverHeight = screenWidth * 0.588
        let designTotalHeight: CGFloat = 634
        let staticHeight = designTotalHeight - 216 - 52 - 52
        let signatureLblWidth = screenWidth * 0.55
        
        let signatureLblHeight: CGFloat
        if signature == "" {
            signatureLblHeight = 0
        } else {
            signatureLblHeight = signature.boundingRect(with: CGSize(width: signatureLblWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)], context: nil).height
        }
        let carNameHeight = carName.boundingRect(with: CGSize(width: signatureLblWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 19, weight: UIFontWeightSemibold)], context: nil).height
        let audioWaveHeight: CGFloat = withAudioWave ? 72.5 : 0
        return CGSize(width: screenWidth, height: signatureLblHeight + staticHeight + coverHeight + carNameHeight + audioWaveHeight)
    }
    
    func numberOfItems() -> Int {
        let imageNum = car.imageArray.count
        let videoNum = car.video == nil ? 0 : 1
        return imageNum + videoNum
    }
    
    func itemSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: screenWidth * 0.588)
    }
    
    func itemForPage(_ pageNum: Int) -> SportCargallaryItem {
        let imageNum = car.imageArray.count
        if pageNum < imageNum {
            let image = car.imageArray[pageNum]
            return SportCargallaryItem(itemType: "image", resource: image.absoluteString)
        } else {
            return SportCargallaryItem(itemType: "video", resource: car.video!)
        }
    }
}

class CarWaveView: UIView, UIPopoverPresentationControllerDelegate, UniversalAudioPlayerDelegate {
    var playBtn: UIButton!
    var isPlaying: Bool = false {
        didSet {
            if isPlaying {
                playBtn.setImage(UIImage(named: "chat_voice_pause"), for: .normal)
            } else {
                playBtn.setImage(UIImage(named: "chat_voice_play"), for: .normal)
            }
        }
    }
    var remainingTimeLbl: UILabel!
    var processView: WideProcessView!
    var wavMask: UIImageView!
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    var audioURL: URL!
    var audioDuration: Double = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.945, alpha: 1)
        configPlayBtn()
        configProcessView()
        configWaveMask()
        configRemainingTimeLbl()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configPlayBtn() {
        playBtn = addSubview(UIButton.self)
            .config(self, selector: #selector(playBtnPressed(_:)), image: UIImage(named: "chat_voice_play"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.left.equalTo(self).offset(15)
                make.centerY.equalTo(self)
                make.size.equalTo(25)
            })
        playBtn.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
    }
    
    func configProcessView() {
        processView = addSubview(WideProcessView.self).layout({ (make) in
            make.left.equalTo(playBtn.snp.right).offset(15)
            make.height.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(167)
        })
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(_:)))
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func configWaveMask() {
        wavMask = UIImageView(image: UIImage(named: "static_wave_mask"))
        wavMask.frame = CGRect(x: 0, y: 8, width: 167, height: 34)
        wavMask.backgroundColor = UIColor.clear
        processView.mask = wavMask
    }
    
    func configRemainingTimeLbl() {
        remainingTimeLbl = addSubview(UILabel.self).config(10, fontWeight: UIFontWeightRegular, textColor: UIColor(white: 0.58, alpha: 1), textAlignment: .left, text: "--:--")
            .layout({ (make) in
                make.centerY.equalTo(self)
                make.left.equalTo(processView.snp.right).offset(10)
            })
    }
    
    func playBtnPressed(_ sender: UIButton) {
        let player = UniversalAudioPlayer.sharedPlayer
        if !isPlaying {
            isPlaying = true
            player.play(audioURL, newDelegate: self)
        } else {
            if player.isPlayingURLStr(audioURL.absoluteString) {
                player.stop()
                remainingTimeLbl.text = getRemainingTimeString(0)
            }
            isPlaying = false
        }
    }
    
    func onLongPressed(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            showAudioPlayerOutputTypeSelector()
        default:
            break
        }
    }
    
    func showAudioPlayerOutputTypeSelector() {
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kMessageStopAllVoicePlayNotification), object: nil)
        let ctrl = getPopoverContronllerForOutputSelection()
        ctrl.modalPresentationStyle = .popover
        let popover = ctrl.popoverPresentationController
        popover?.sourceView = self
        popover?.sourceRect = self.bounds
        popover?.permittedArrowDirections = [.down, .up]
        popover?.delegate = self
        popover?.backgroundColor = UIColor.black
    }
    
    func getPopoverContronllerForOutputSelection() -> UIViewController {
        let controller = UIViewController()
        controller.preferredContentSize = CGSize(width: 100, height: 44)
        let player = UniversalAudioPlayer.sharedPlayer
        if player.isOnSpeaker() {
            let btn = controller.view.addSubview(UIButton.self)
                .config(self, selector: #selector(onAudioPlayerOutputTypeSwitchBtnPressed(_:)), title: LS("听筒播放"), titleColor: UIColor.white, titleSize: 14, titleWeight: UIFontWeightRegular)
                .layout({ (make) in
                    make.edges.equalTo(controller.view)
                })
            btn.tag = 0
        } else {
            let btn = controller.view.addSubview(UIButton.self)
                .config(self, selector: #selector(onAudioPlayerOutputTypeSwitchBtnPressed(_:)), title: LS("扬声器播放"), titleColor: UIColor.white, titleSize: 14, titleWeight: UIFontWeightRegular)
                .layout({ (make) in
                    make.edges.equalTo(controller.view)
                })
            btn.tag = 1
        }
        return controller
    }
    
    func onAudioPlayerOutputTypeSwitchBtnPressed(_ sender: UIButton) {
        let player = UniversalAudioPlayer.sharedPlayer
        let controller = UIApplication.shared.keyWindow?.rootViewController
        if sender.tag == 1 {
            do {
                try player.setPlayFromSpeaker()
            } catch {
                controller?.showToast(LS("无法从听筒播放"))
                controller?.dismiss(animated: true, completion: nil)
                return
            }
        } else {
            do {
                try player.setToUseDefaultOutputType()
            } catch {
                controller?.showToast(LS("无法从扬声器播放"))
                controller?.dismiss(animated: true, completion: nil)
                return
            }
        }
        controller?.dismiss(animated: true, completion: nil)
        playBtnPressed(playBtn)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func onStopAllVoicePlay(_ notification: Foundation.Notification) {
        DispatchQueue.main.async {
            self.stopPlayerAnyway()
        }
    }
    
    func stopPlayerAnyway() {
        if isPlaying {
            playBtnPressed(playBtn)
        }
    }
    
    func getRemainingTimeString(_ process: Double) -> String{
        let leftTime = Int(audioDuration * (1 - process))
        let min = leftTime / 60
        let sec = leftTime - 60 * min
        return "-\(min):\(sec)"
    }
    
    func getRequiredWidth() -> CGFloat {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        return contentRect.width
    }
    
    // MARK: - 播放器代理
    
    func willPlayAnotherAudioFile() {
        isPlaying = false
        remainingTimeLbl.text = getRemainingTimeString(0)
    }
    
    func willStartPlaying() {
        isPlaying = true
        audioDuration = UniversalAudioPlayer.sharedPlayer.player!.duration
        remainingTimeLbl.text = getRemainingTimeString(0)
        processView.process = 0
    }
    
    func playProcessUpdate(_ process: Double) {
        processView.process  = process
        remainingTimeLbl.text = getRemainingTimeString(process)
    }
    
    func playDidFinished() {
        processView.process = 1
        isPlaying = false
        remainingTimeLbl.text = getRemainingTimeString(0)
    }
    
    func getIdentifier() -> String {
        return audioURL.absoluteString
    }
    
    func failToPlay() {
        playDidFinished()
    }
}

