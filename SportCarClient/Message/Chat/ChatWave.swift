//
//  ChatWave.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class ChatWaveView: UIView, UniversalAudioPlayerDelegate, UIPopoverPresentationControllerDelegate {
    
    weak var delegate: ChatCellDelegate?
    
    var chatRecord: ChatRecord? {
        didSet {
//
//            let b = UIView(frame: CGRectMake(0, 0, 100, 100))
//            b.backgroundColor = UIColor(white: 1, alpha: 0.2)
//            let c = UIView(frame: CGRectMake(5, 5, 50, 50))
//            c.backgroundColor = UIColor(white: 1, alpha: 1)
//            b.addSubview(c)
            
            waveMask = ChatWaveMaskView()
            waveMask?.frame = CGRect(x: 0, y: 0, width: 167, height: 30)
            waveMask?.chat = chatRecord
            waveMask?.backgroundColor = UIColor(white: 1, alpha: 0)
            
            processView?.mask = waveMask
//            processView?.addSubview(mask)
//            waveMask = ChatWaveMaskView(chatRecord: chatRecord!)
//            waveMask?.frame = CGRectMake(0, 0, 167, 30)
//            processView?.maskView = waveMask
            processView?.setNeedsDisplay()
            remainingTimeLbl?.text = getRemainingTimeString(0)
        }
    }
    
    var playBtn: UIButton?
    
    var isPlaying: Bool {
        get {
            return playBtn!.tag == 1
        }
        
        set {
            playBtn?.tag = newValue ? 1 : 0
        }
    }
    
    var remainingTimeLbl: UILabel?
    var processView: WideProcessView?
    var waveMask: ChatWaveMaskView?
    
    var longPressGestureRecognizer: UILongPressGestureRecognizer!
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStopAllVoicePlay(_:)), name: NSNotification.Name(rawValue: kMessageStopAllVoicePlayNotification), object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        //
        playBtn = UIButton()
        playBtn?.setImage(UIImage(named: "chat_voice_play"), for: .normal)
        playBtn?.addTarget(self, action: #selector(ChatWaveView.playBtnPressed), for: .touchUpInside)
        playBtn?.imageView?.contentMode = .scaleAspectFit
        playBtn?.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        playBtn?.tag = 0
        superview.addSubview(playBtn!)
        playBtn?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(25)
        })
        //
        processView = WideProcessView()
        superview.addSubview(processView!)
        processView?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(playBtn!.snp.right).offset(15)
            make.height.equalTo(superview)
            make.centerY.equalTo(superview)
            make.width.equalTo(167)
        })
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onChatBubbleLongPressed(_:)))
        self.addGestureRecognizer(longPressGestureRecognizer)
        
        //
        remainingTimeLbl = UILabel()
        remainingTimeLbl?.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        remainingTimeLbl?.textColor = UIColor.white
        superview.addSubview(remainingTimeLbl!)
        remainingTimeLbl?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(superview)
            make.height.equalTo(superview)
            make.left.equalTo(processView!.snp.right).offset(10)
        })
    }
    
    func getRemainingTimeString(_ process: Double) -> String {
        guard let duration = chatRecord?.audioLength else{
            return "--:--"
        }
        let leftTime = Int(duration * (1 - process))
        let min = leftTime / 60
        let sec = leftTime - 60 * min
        return "-\(min):\(sec)"
    }
    
    func playBtnPressed() {
        guard let audioURL = chatRecord?.audio else {
            return
        }
        let player = UniversalAudioPlayer.sharedPlayer
        
        // TODO: use isPlaying property instead of operating on `tag` directly
        
        if playBtn?.tag == 0 {
            playBtn?.setImage(UIImage(named: "chat_voice_pause"), for: .normal)
            player.play(SFURL(audioURL)!, newDelegate: self)
            playBtn?.tag = 1
        }else{
            if player.isPlayingURLStr(SFURL(audioURL)!.absoluteString){
                player.stop()
                remainingTimeLbl?.text = getRemainingTimeString(0)
            }
            playBtn?.tag = 0
            playBtn?.setImage(UIImage(named: "chat_voice_play"), for: .normal)
        }
    }
    
    func getRequiredWidth() -> CGFloat {
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        return contentRect.width
    }
    
    func onChatBubbleLongPressed(_ gesture: UILongPressGestureRecognizer) {
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
        let presenter = delegate as? UIViewController
        presenter?.present(ctrl, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
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
        let controller = delegate as? UIViewController
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
        playBtnPressed()
    }
    
    func onStopAllVoicePlay(_ notification: Foundation.Notification) {
        DispatchQueue.main.async { 
            self.stopPlayerAnyway()
        }
    }
    
    func stopPlayerAnyway() {
        if isPlaying {
            playBtnPressed()
        }
    }
}


extension ChatWaveView {
    func willPlayAnotherAudioFile() {
        playBtn?.setImage(UIImage(named: "chat_voice_play"), for: .normal)
        playBtn?.tag = 0
        remainingTimeLbl?.text = getRemainingTimeString(0)
    }
    
    func willStartPlaying() {
        playBtn?.setImage(UIImage(named: "chat_voice_pause"), for: .normal)
        processView?.process = 0
        remainingTimeLbl?.text = getRemainingTimeString(0)
        chatRecord?.read = true
    }
    
    func playProcessUpdate(_ process: Double) {
        processView?.process = process
        remainingTimeLbl?.text = getRemainingTimeString(process)
    }
    
    func playDidFinished() {
        processView?.process = 1
        playBtn?.setImage(UIImage(named: "chat_voice_play"), for: .normal)
        playBtn?.tag = 0
        remainingTimeLbl?.text = getRemainingTimeString(0)
    }
    
    func getIdentifier() -> String {
        return chatRecord!.audio!
    }
    
    func failToPlay() {
        playDidFinished()
    }
}

class ChatWaveMaskView: UIView {
    var chat: ChatRecord? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let data = chat?.cachedWaveData else {
            return
        }
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.saveGState()
        let contextSize = self.frame.size
        // 将背景填充成为黑色
//        CGContextClearRect(ctx, self.bounds)
//        CGContextSetFillColorWithColor(ctx, UIColor(white: 1, alpha: 0).CGColor)
//        CGContextFillRect(ctx, self.bounds)
        // 绘制水平线
        let horizontalLine = CGMutablePath()
        horizontalLine.move(to: CGPoint(x: 0, y: contextSize.height / 2))
        horizontalLine.addLine(to: CGPoint(x: contextSize.width, y: contextSize.height / 2))
        ctx?.addPath(horizontalLine)
        ctx?.setStrokeColor(UIColor.white.cgColor)
        ctx?.setLineWidth(0.5)
        ctx?.strokePath()
        
//        CGPathMoveToPoint(horizontalLine, nil, 0, contextSize.height / 2)
//        CGPathAddLineToPoint(horizontalLine, nil, contextSize.width, contextSize.height / 2)
//        ctx?.addPath(horizontalLine)
//        ctx?.setStrokeColor(UIColor(white: 1, alpha: 1).cgColor)
//        ctx?.setLineWidth(0.5)
//        ctx?.strokePath()
        // 绘制波形图
        let waveShape = CGMutablePath()
        var trans = CGAffineTransform.identity
        trans = trans.translatedBy(x: 0, y: contextSize.height/2)
        trans = trans.scaledBy(x: 1, y: contextSize.height/2)
        waveShape.move(to: CGPoint(x: 0, y: 0), transform: trans)
//        CGPathMoveToPoint(waveShape, &trans, 0, 0)
        var pos: CGFloat = 1.5
        let interval = (contextSize.width - 3) / CGFloat(data.count - 1)
        for point in data{
            let y = CGFloat(point)
            waveShape.move(to: CGPoint(x: pos, y: y), transform: trans)
            waveShape.addLine(to: CGPoint(x: pos, y: -y), transform: trans)
//            CGPathMoveToPoint(waveShape, &trans, pos, y)
//            CGPathAddLineToPoint(waveShape, &trans, pos, -y)
            pos += interval
        }
        ctx?.addPath(waveShape)
        ctx?.setLineWidth(2)
        ctx?.strokePath()
        ctx?.restoreGState()
    }
}

class WideProcessView: UIView {
    
    var barView: UIView = UIView()
    
    var process: Double=0 {
        didSet {
            barView.snp.remakeConstraints { (make) -> Void in
                make.left.equalTo(self)
                make.top.equalTo(self)
                make.bottom.equalTo(self)
                make.width.equalTo(self).multipliedBy(process)
            }
            self.layoutIfNeeded()
        }
    }
    
    var foregroundColor: UIColor = kHighlightedRedTextColor{
        didSet {
            barView.backgroundColor = self.foregroundColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = kTextGray28
        self.addSubview(barView)
        barView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(self).multipliedBy(0)
        }
        barView.backgroundColor = foregroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
