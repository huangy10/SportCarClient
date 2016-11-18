//
//  CarWaveView.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


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

