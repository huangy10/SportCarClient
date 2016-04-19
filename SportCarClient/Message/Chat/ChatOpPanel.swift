//
//  ChatOpPanel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


let kMaxChatWordCount = 140

enum ChatOpPanelInputMode {
    case Text
    case Voice
}


protocol ChatOpPanelDelegate: class {
    func opPanelWillSwitchInputMode(opPanel: ChatOpPanelController)
    func opPanelDidSwitchInputModel(opPanel: ChatOpPanelController)
    /**
     调出accessory面板
     */
    func needInvokeAccessoryView()
    
    func needInvokeEmojiView()
}


class ChatOpPanelController: UIViewController {
    static let barHeight: CGFloat = 45
    var inputMode = ChatOpPanelInputMode.Text
    
    weak var delegate: ChatOpPanelDelegate?

    
    /// 输入方式切换按钮
    var inputToggleBtn: UIButton?
    /// 文字输入框
    var contentInput: UITextView?
    var voiceInputBtn: UIButton?
    var recording: Bool = false
    var recorder: ChatAudioRecorder?
    
    var voiceAnimationView: UIImageView!
    var timeCountLbl: UILabel!
    var startRecordDate: NSDate?
    var timer: NSTimer?
    
    var accessoryBtn: UIButton?
    
    var expandBoardHeight: CGFloat = 250
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    internal func createSubviews() {
        let superview = self.view
        superview.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.layer.shadowColor = UIColor.blackColor().CGColor
        superview.layer.shadowOffset = CGSizeMake(0, -1)
        superview.layer.shadowOpacity = 0.2
        
        let contentHeight: CGFloat = 34
        let edgeInset: CGFloat = 5
        // 创建左侧按钮
        inputToggleBtn = UIButton()
        inputToggleBtn?.backgroundColor = UIColor.clearColor()
        inputToggleBtn?.setImage(UIImage(named: "chat_voice_input_btn"), forState: .Normal)
        superview.addSubview(inputToggleBtn!)
        inputToggleBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(superview).offset(-edgeInset)
            make.left.equalTo(superview).offset(15)
        })
        inputToggleBtn?.addTarget(self, action: #selector(ChatOpPanelController.inputToggleBtnPressed), forControlEvents: .TouchUpInside)
        // 创建右侧按钮
        accessoryBtn = UIButton()
        accessoryBtn?.setImage(UIImage(named: "chat_add_asscessory"), forState: .Normal)
        superview.addSubview(accessoryBtn!)
        accessoryBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(superview).offset(-edgeInset)
        })
        accessoryBtn?.addTarget(self, action: #selector(ChatOpPanelController.accessoryBtnPressed), forControlEvents: .TouchUpInside)
        //
        let contentInputContainer = UIView()
        contentInputContainer.layer.cornerRadius = contentHeight / 2
        contentInputContainer.clipsToBounds = true
        contentInputContainer.backgroundColor = UIColor.whiteColor()
        superview.addSubview(contentInputContainer)
        contentInputContainer.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(-edgeInset)
            make.right.equalTo(accessoryBtn!.snp_left).offset(-10)
            make.left.equalTo(inputToggleBtn!.snp_right).offset(10)
            make.top.equalTo(superview).offset(edgeInset)
        }
        
        let contentInputIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        contentInputContainer.addSubview(contentInputIcon)
        contentInputIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentInputContainer).offset(contentHeight / 2)
            make.bottom.equalTo(contentInputContainer).offset(-edgeInset)
            make.size.equalTo(20)
        }
        //
        contentInput = UITextView()
        contentInput?.textColor = UIColor(white: 0.72, alpha: 1)
        contentInput?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        contentInputContainer.addSubview(contentInput!)
        contentInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(contentInputContainer).offset(-contentHeight / 2)
            make.height.equalTo(contentInputContainer)
            make.left.equalTo(contentInputIcon.snp_right).offset(10)
            make.centerY.equalTo(contentInputContainer)
        })
        //
        voiceInputBtn = UIButton()
        voiceInputBtn?.backgroundColor = UIColor.whiteColor()
        voiceInputBtn?.layer.cornerRadius = contentHeight / 2
        voiceInputBtn?.setTitle(LS("按住 说话"), forState: .Normal)
        voiceInputBtn?.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        voiceInputBtn?.setTitleColor(UIColor.blackColor(), forState: .Highlighted)
        contentInputContainer.addSubview(voiceInputBtn!)
        voiceInputBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(contentInputContainer)
        })
        voiceInputBtn?.hidden = true
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.startRecording), forControlEvents: .TouchDown)
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.cancelRecording), forControlEvents: .TouchDragExit)
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.finishRecording), forControlEvents: .TouchUpInside)
        
        // 
        voiceAnimationView = UIImageView()
        voiceAnimationView.animationImages = $.map(0..<50, transform: { UIImage(named: String(format: "合成 1_%.5d", $0))! })
        superview.addSubview(voiceAnimationView)
        voiceAnimationView.startAnimating()
        voiceAnimationView.userInteractionEnabled = false
        voiceAnimationView.backgroundColor = UIColor.redColor()
        voiceAnimationView.snp_makeConstraints { (make) in
            make.centerX.equalTo(superview).offset(-20)
            make.bottom.equalTo(superview.snp_top)
            make.size.equalTo(CGSizeMake(150, 50))
        }
        voiceAnimationView.hidden = true
        
        timeCountLbl = superview.addSubview(UILabel).config(14, textColor: kHighlightedRedTextColor, text: "0.0").layout({ (make) in
            make.bottom.equalTo(voiceAnimationView).offset(-2)
            make.left.equalTo(voiceAnimationView.snp_right).offset(10)
        })
        timeCountLbl.hidden = true
    }
}


extension ChatOpPanelController {
    
    func startRecording() {
        recording = true
        voiceInputBtn?.backgroundColor = UIColor(white: 0.72, alpha: 1)
        if recorder == nil {
            recorder = ChatAudioRecorder(delegate: (delegate as! ChatRoomController))
        }
        recorder?.startRecording(nil)
        voiceAnimationView.hidden = false
        timeCountLbl.hidden = false
        startRecordDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    func cancelRecording() {
        recording = false
        voiceInputBtn?.backgroundColor = UIColor.whiteColor()
        recorder?.finishRecording(false)
        voiceAnimationView.hidden = true
        timeCountLbl.hidden = true
        timer?.invalidate()
    }
    
    func timerUpdate() {
        let duration = NSDate().timeIntervalSinceDate(startRecordDate!)
        timeCountLbl.text = String(format: "%1.1fs", duration)
    }
    
    func finishRecording() {
        if !recording {
            return
        }
        recording = false
        voiceInputBtn?.backgroundColor = UIColor.whiteColor()
        recorder?.finishRecording(true)
        voiceAnimationView.hidden = true
        timeCountLbl.hidden = true
        timer?.invalidate()
    }
    
    /**
     获取这个view需要的高度
     
     - returns: 高度值
     */
    func preferredHeight() -> CGFloat{
        switch inputMode {
        case .Text:
            let fixedWidth = contentInput!.frame.width
            let newSize = contentInput!.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
            return newSize.height + 10      // 10为上下的空隙的高度
        case .Voice:
            return ChatOpPanelController.barHeight
        }
    }
    
    /**
     inputToggle按钮的响应函数
     */
    func inputToggleBtnPressed() {
        switch inputMode {
        case .Text:
            // 改变inputmode，即将进入音频输入模式
            inputMode = .Voice
            // 告知代理输入状态即将发生改变，注意代理在这里需要及时调整opPanel的高度
            delegate?.opPanelWillSwitchInputMode(self)
            // 显示出音频输入按钮
            voiceInputBtn?.hidden = false
            // 更改toggle按钮图标
            inputToggleBtn?.setImage(UIImage(named: "chat_voice_input_btn"), forState: .Normal)
            // 取消contentInput的可能focused状态
            contentInput?.resignFirstResponder()
            // 完成状态转换后告知代理
            delegate?.opPanelDidSwitchInputModel(self)
            break
        case .Voice:
            inputMode = .Text
            delegate?.opPanelWillSwitchInputMode(self)
            voiceInputBtn?.hidden = true
            contentInput?.becomeFirstResponder()
            inputToggleBtn?.setImage(UIImage(named: "chat_text_input_btn"), forState: .Normal)
            break
        }
    }
    
    func accessoryBtnPressed() {
        delegate?.needInvokeAccessoryView()
    }
    
    func emojiBtnPressed() {
        delegate?.needInvokeEmojiView()
    }
}

