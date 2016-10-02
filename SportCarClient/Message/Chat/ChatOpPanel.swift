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
    case text
    case voice
}


protocol ChatOpPanelDelegate: class {
    func opPanelWillSwitchInputMode(_ opPanel: ChatOpPanelController)
    func opPanelDidSwitchInputModel(_ opPanel: ChatOpPanelController)
    /**
     调出accessory面板
     */
    func needInvokeAccessoryView()
    
    func needInvokeEmojiView()
}


class ChatOpPanelController: UIViewController {
    static let barHeight: CGFloat = 45
    var inputMode = ChatOpPanelInputMode.text
    
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
    var startRecordDate: Date?
    var timer: Timer?
    
    var accessoryBtn: UIButton?
    
    var expandBoardHeight: CGFloat = 250
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    internal func createSubviews() {
        let superview = self.view!
        superview.backgroundColor = UIColor(white: 0.92, alpha: 1)
//        superview.layer.shadowColor = UIColor.blackColor().CGColor
//        superview.layer.shadowOffset = CGSizeMake(0, -1)
//        superview.layer.shadowOpacity = 0.2
        
        let contentHeight: CGFloat = 34
        let edgeInset: CGFloat = 5
        // 创建左侧按钮
        inputToggleBtn = UIButton()
        inputToggleBtn?.backgroundColor = UIColor.clear
        inputToggleBtn?.setImage(UIImage(named: "chat_voice_input_btn"), for: UIControlState())
        superview.addSubview(inputToggleBtn!)
        inputToggleBtn?.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(superview).offset(-edgeInset)
            make.left.equalTo(superview).offset(15)
        })
        inputToggleBtn?.addTarget(self, action: #selector(ChatOpPanelController.inputToggleBtnPressed), for: .touchUpInside)
        // 创建右侧按钮
        accessoryBtn = UIButton()
        accessoryBtn?.setImage(UIImage(named: "chat_add_asscessory"), for: UIControlState())
        superview.addSubview(accessoryBtn!)
        accessoryBtn?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(superview).offset(-edgeInset)
        })
        accessoryBtn?.addTarget(self, action: #selector(ChatOpPanelController.accessoryBtnPressed), for: .touchUpInside)
        //
        let contentInputContainer = UIView()
        contentInputContainer.layer.cornerRadius = contentHeight / 2
        contentInputContainer.clipsToBounds = true
        contentInputContainer.backgroundColor = UIColor.white
        superview.addSubview(contentInputContainer)
        contentInputContainer.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(superview).offset(-edgeInset)
            make.right.equalTo(accessoryBtn!.snp.left).offset(-10)
            make.left.equalTo(inputToggleBtn!.snp.right).offset(10)
            make.top.equalTo(superview).offset(edgeInset)
        }
        //
        contentInput = UITextView()
        contentInput?.textColor = UIColor.black
        contentInput?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        contentInputContainer.addSubview(contentInput!)
        contentInput?.snp.makeConstraints( { (make) -> Void in
            make.right.equalTo(contentInputContainer).offset(-contentHeight / 2)
            make.height.equalTo(contentInputContainer)
            make.left.equalTo(contentInputContainer).offset(contentHeight / 2)
            make.centerY.equalTo(contentInputContainer)
        })
        //
        voiceInputBtn = UIButton()
        voiceInputBtn?.backgroundColor = UIColor.white
        voiceInputBtn?.layer.cornerRadius = contentHeight / 2
        voiceInputBtn?.setTitle(LS("按住 说话"), for: UIControlState())
        voiceInputBtn?.setTitleColor(UIColor(white: 0.72, alpha: 1), for: UIControlState())
        voiceInputBtn?.setTitleColor(UIColor.black, for: .highlighted)
        contentInputContainer.addSubview(voiceInputBtn!)
        voiceInputBtn?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(contentInputContainer)
        })
        voiceInputBtn?.isHidden = true
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.startRecording), for: .touchDown)
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.cancelRecording), for: .touchDragExit)
        voiceInputBtn?.addTarget(self, action: #selector(ChatOpPanelController.finishRecording), for: .touchUpInside)
        
        // 
        voiceAnimationView = UIImageView()
        voiceAnimationView.animationImages = $.map(0..<50, transform: { UIImage(named: String(format: "合成 1_%.5d", $0))! })
        superview.addSubview(voiceAnimationView)
        voiceAnimationView.startAnimating()
        voiceAnimationView.isUserInteractionEnabled = false
        voiceAnimationView.backgroundColor = UIColor.red
        voiceAnimationView.snp.makeConstraints { (make) in
            make.centerX.equalTo(superview).offset(-20)
            make.bottom.equalTo(superview.snp.top)
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
        voiceAnimationView.isHidden = true
        
        timeCountLbl = superview.addSubview(UILabel.self).config(14, textColor: kHighlightedRedTextColor, text: "0.0").layout({ (make) in
            make.bottom.equalTo(voiceAnimationView).offset(-2)
            make.left.equalTo(voiceAnimationView.snp.right).offset(10)
        })
        timeCountLbl.isHidden = true
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
        voiceAnimationView.isHidden = false
        timeCountLbl.isHidden = false
        startRecordDate = Date()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
    }
    
    func cancelRecording() {
        recording = false
        voiceInputBtn?.backgroundColor = UIColor.white
        recorder?.finishRecording(false)
        voiceAnimationView.isHidden = true
        timeCountLbl.isHidden = true
        timer?.invalidate()
    }
    
    func timerUpdate() {
        let duration = Date().timeIntervalSince(startRecordDate!)
        timeCountLbl.text = String(format: "%1.1fs", duration)
    }
    
    func finishRecording() {
        if !recording {
            return
        }
        recording = false
        voiceInputBtn?.backgroundColor = UIColor.white
        recorder?.finishRecording(true)
        voiceAnimationView.isHidden = true
        timeCountLbl.isHidden = true
        timer?.invalidate()
    }
    
    /**
     获取这个view需要的高度
     
     - returns: 高度值
     */
    func preferredHeight() -> CGFloat{
        switch inputMode {
        case .text:
            let fixedWidth = contentInput!.frame.width
            let newSize = contentInput!.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            return newSize.height + 10      // 10为上下的空隙的高度
        case .voice:
            return ChatOpPanelController.barHeight
        }
    }
    
    /**
     inputToggle按钮的响应函数
     */
    func inputToggleBtnPressed() {
        switch inputMode {
        case .text:
            // 改变inputmode，即将进入音频输入模式
            inputMode = .voice
            // 告知代理输入状态即将发生改变，注意代理在这里需要及时调整opPanel的高度
            delegate?.opPanelWillSwitchInputMode(self)
            // 显示出音频输入按钮
            voiceInputBtn?.isHidden = false
            // 更改toggle按钮图标
            inputToggleBtn?.setImage(UIImage(named: "chat_text_input_btn"), for: UIControlState())
            // 取消contentInput的可能focused状态
            contentInput?.resignFirstResponder()
            // 完成状态转换后告知代理
            delegate?.opPanelDidSwitchInputModel(self)
            break
        case .voice:
            inputMode = .text
            delegate?.opPanelWillSwitchInputMode(self)
            voiceInputBtn?.isHidden = true
            contentInput?.becomeFirstResponder()
            inputToggleBtn?.setImage(UIImage(named: "chat_voice_input_btn"), for: UIControlState())
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

