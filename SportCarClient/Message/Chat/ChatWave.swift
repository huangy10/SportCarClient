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
            waveMask?.frame = CGRectMake(0, 0, 167, 30)
            waveMask?.chat = chatRecord
            waveMask?.backgroundColor = UIColor(white: 1, alpha: 0)
            
            processView?.maskView = waveMask
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
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onStopAllVoicePlay(_:)), name: kMessageStopAllVoicePlayNotification, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        //
        playBtn = UIButton()
        playBtn?.setImage(UIImage(named: "chat_voice_play"), forState: .Normal)
        playBtn?.addTarget(self, action: #selector(ChatWaveView.playBtnPressed), forControlEvents: .TouchUpInside)
        playBtn?.imageView?.contentMode = .ScaleAspectFit
        playBtn?.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        playBtn?.tag = 0
        superview.addSubview(playBtn!)
        playBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.size.equalTo(25)
        })
        //
        processView = WideProcessView()
        superview.addSubview(processView!)
        processView?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(playBtn!.snp_right).offset(15)
            make.height.equalTo(superview)
            make.centerY.equalTo(superview)
            make.width.equalTo(167)
        })
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onChatBubbleLongPressed(_:)))
        self.addGestureRecognizer(longPressGestureRecognizer)
        
        //
        remainingTimeLbl = UILabel()
        remainingTimeLbl?.font = UIFont.systemFontOfSize(10, weight: UIFontWeightRegular)
        remainingTimeLbl?.textColor = UIColor.whiteColor()
        superview.addSubview(remainingTimeLbl!)
        remainingTimeLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(superview)
            make.height.equalTo(superview)
            make.left.equalTo(processView!.snp_right).offset(10)
        })
    }
    
    func getRemainingTimeString(process: Double) -> String {
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
            playBtn?.setImage(UIImage(named: "chat_voice_pause"), forState: .Normal)
            player.play(SFURL(audioURL)!, newDelegate: self)
            playBtn?.tag = 1
        }else{
            if player.isPlayingURLStr(SFURL(audioURL)!.absoluteString){
                player.stop()
                remainingTimeLbl?.text = getRemainingTimeString(0)
            }
            playBtn?.tag = 0
            playBtn?.setImage(UIImage(named: "chat_voice_play"), forState: .Normal)
        }
    }
    
    func getRequiredWidth() -> CGFloat {
        var contentRect = CGRectZero
        for view in self.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        return contentRect.width
    }
    
    func onChatBubbleLongPressed(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .Began:
            showAudioPlayerOutputTypeSelector()
        default:
            break
        }
    }
    
    func showAudioPlayerOutputTypeSelector() {
        NSNotificationCenter.defaultCenter().postNotificationName(kMessageStopAllVoicePlayNotification, object: nil)
        let ctrl = getPopoverContronllerForOutputSelection()
        ctrl.modalPresentationStyle = .Popover
        let popover = ctrl.popoverPresentationController
        popover?.sourceView = self
        popover?.sourceRect = self.bounds
        popover?.permittedArrowDirections = [.Down, .Up]
        popover?.delegate = self
        popover?.backgroundColor = UIColor.blackColor()
        let presenter = delegate as? UIViewController
        presenter?.presentViewController(ctrl, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func getPopoverContronllerForOutputSelection() -> UIViewController {
        let controller = UIViewController()
        controller.preferredContentSize = CGSizeMake(100, 44)
        let player = UniversalAudioPlayer.sharedPlayer
        if player.isOnSpeaker() {
            let btn = controller.view.addSubview(UIButton)
                .config(self, selector: #selector(onAudioPlayerOutputTypeSwitchBtnPressed(_:)), title: LS("听筒播放"), titleColor: UIColor.whiteColor(), titleSize: 14, titleWeight: UIFontWeightRegular)
                .layout({ (make) in
                    make.edges.equalTo(controller.view)
                })
            btn.tag = 0
        } else {
            let btn = controller.view.addSubview(UIButton)
                .config(self, selector: #selector(onAudioPlayerOutputTypeSwitchBtnPressed(_:)), title: LS("扬声器播放"), titleColor: UIColor.whiteColor(), titleSize: 14, titleWeight: UIFontWeightRegular)
                .layout({ (make) in
                    make.edges.equalTo(controller.view)
                })
            btn.tag = 1
        }
        return controller
    }
    
    func onAudioPlayerOutputTypeSwitchBtnPressed(sender: UIButton) {
        let player = UniversalAudioPlayer.sharedPlayer
        let controller = delegate as? UIViewController
        if sender.tag == 1 {
            do {
                try player.setPlayFromSpeaker()
            } catch {
                controller?.showToast(LS("无法从听筒播放"))
                controller?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
        } else {
            do {
                try player.setToUseDefaultOutputType()
            } catch {
                controller?.showToast(LS("无法从扬声器播放"))
                controller?.dismissViewControllerAnimated(true, completion: nil)
                return
            }
        }
        controller?.dismissViewControllerAnimated(true, completion: nil)
        playBtnPressed()
    }
    
    func onStopAllVoicePlay(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { 
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
        playBtn?.setImage(UIImage(named: "chat_voice_play"), forState: .Normal)
        playBtn?.tag = 0
        remainingTimeLbl?.text = getRemainingTimeString(0)
    }
    
    func willStartPlaying() {
        playBtn?.setImage(UIImage(named: "chat_voice_pause"), forState: .Normal)
        processView?.process = 0
        remainingTimeLbl?.text = getRemainingTimeString(0)
        chatRecord?.read = true
    }
    
    func playProcessUpdate(process: Double) {
        processView?.process = process
        remainingTimeLbl?.text = getRemainingTimeString(process)
    }
    
    func playDidFinished() {
        processView?.process = 1
        playBtn?.setImage(UIImage(named: "chat_voice_play"), forState: .Normal)
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
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        guard let data = chat?.cachedWaveData else {
            return
        }
        self.backgroundColor = UIColor(white: 1, alpha: 0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSaveGState(ctx)
        let contextSize = self.frame.size
        // 将背景填充成为黑色
//        CGContextClearRect(ctx, self.bounds)
//        CGContextSetFillColorWithColor(ctx, UIColor(white: 1, alpha: 0).CGColor)
//        CGContextFillRect(ctx, self.bounds)
        // 绘制水平线
        let horizontalLine = CGPathCreateMutable()
        CGPathMoveToPoint(horizontalLine, nil, 0, contextSize.height / 2)
        CGPathAddLineToPoint(horizontalLine, nil, contextSize.width, contextSize.height / 2)
        CGContextAddPath(ctx, horizontalLine)
        CGContextSetStrokeColorWithColor(ctx, UIColor(white: 1, alpha: 1).CGColor)
        CGContextSetLineWidth(ctx, 0.5)
        CGContextStrokePath(ctx)
        // 绘制波形图
        let waveShape = CGPathCreateMutable()
        var trans = CGAffineTransformIdentity
        trans = CGAffineTransformTranslate(trans, 0, contextSize.height/2)
        trans = CGAffineTransformScale(trans, 1, contextSize.height/2)
        CGPathMoveToPoint(waveShape, &trans, 0, 0)
        var pos: CGFloat = 1.5
        let interval = (contextSize.width - 3) / CGFloat(data.count - 1)
        for point in data{
            let y = CGFloat(point)
            CGPathMoveToPoint(waveShape, &trans, pos, y)
            CGPathAddLineToPoint(waveShape, &trans, pos, -y)
            pos += interval
        }
        CGContextAddPath(ctx, waveShape)
        CGContextSetLineWidth(ctx, 2)
        CGContextStrokePath(ctx)
        CGContextRestoreGState(ctx)
    }
}

class WideProcessView: UIView {
    
    var barView: UIView = UIView()
    
    var process: Double=0 {
        didSet {
            barView.snp_remakeConstraints { (make) -> Void in
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
        super.init(frame: CGRectZero)
        self.backgroundColor = UIColor(white: 0.72, alpha: 1)
        self.addSubview(barView)
        barView.snp_makeConstraints { (make) -> Void in
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