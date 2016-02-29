//
//  ChatController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

enum ChatRoomType {
    case Club
    case Private
}


class ChatRoomController: InputableViewController, UITableViewDataSource, UITableViewDelegate, ChatOpPanelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatAudioRecordDelegate {
    
    var chatList: ChatListController?
    
    var roomType: ChatRoomType = .Private
    var targetUser: User? {
        didSet {
            roomType = .Private
        }
    }
    var targetClub: Club? {
        didSet {
            roomType = .Club
        }
    }
    
    var chatRecords: ChatRecordList? {
        let identifier = getIdentifierForRoomController(self)
        if let records = ChatRecordDataSource.sharedDataSource.chatRecords[identifier] {
            return records
        }
        let newRecordList = ChatRecordList()
        ChatRecordDataSource.sharedDataSource.chatRecords[identifier] = newRecordList
        switch roomType {
        case .Private:
            newRecordList._item = ChatRecordListItem.UserItem(self.targetUser!)
            break
        case .Club:
            newRecordList._item = ChatRecordListItem.ClubItem(self.targetClub!)
            break
        }
        return newRecordList
    }
    
    var navTitle: String? {
        if targetUser != nil {
            return targetUser?.nickName
        }else if targetClub != nil{
            return targetClub?.name
        }
        return nil
    }
    
    var navRightBtnImageURLStr: String? {
        if targetUser != nil {
            return targetUser?.avatarUrl
        }else if targetClub != nil{
            return targetClub?.logo_url
        }
        return nil
    }
    
    var talkBoard: UITableView?
    // 下方的输入面板
    var chatOpPanelController: ChatOpPanelController?
    
    var opPanelView: UIView? {
        return chatOpPanelController?.view
    }
    
    var accessoryBoard: ChatAccessoryBoard?
    var displayAccessoryBoard: Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        navSettings()
        super.viewDidLoad()
//        ChatRecordDataSource.sharedDataSource.chatRecords[getIdentifierForRoomController(self)] = []
        
        ChatCell.registerCellForTableView(talkBoard!)
        
        // 添加键盘出现时时间的监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardAppears:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardDisappears:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ChatRecordDataSource.sharedDataSource.curRoom = self
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        chatOpPanelController = ChatOpPanelController()
        superview.addSubview(chatOpPanelController!.view)
        chatOpPanelController?.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview).offset(0)
            make.height.equalTo(45)
        }
        self.inputFields.append(chatOpPanelController?.contentInput)
        // 将文字输入框的代理设置给了本controller
        chatOpPanelController?.delegate = self
        chatOpPanelController?.contentInput?.delegate = self
        //
        talkBoard = UITableView(frame: CGRectZero, style: .Plain)
        talkBoard?.separatorStyle = .None
        superview.addSubview(talkBoard!)
        talkBoard?.dataSource = self
        talkBoard?.delegate = self
        talkBoard?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(chatOpPanelController!.view.snp_top)
//            make.height.equalTo(UIScreen.mainScreen().bounds.height - self.navigationController!.navigationBar.frame.height - 20 - 45)
            make.top.equalTo(superview)
        })
        
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = navTitle
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 10.5, 18)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        let navRightBtn = UIButton()
        let navRightBtnIconURLStr = navRightBtnImageURLStr
        navRightBtn.kf_setImageWithURL(SFURL(navRightBtnIconURLStr!)!, forState: .Normal)
        navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        navRightBtn.layer.cornerRadius = 17.5
        navRightBtn.clipsToBounds = true
        navRightBtn.frame = CGRectMake(0, 0, 35, 35)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func navLeftBtnPressed() {
        ChatRecordDataSource.sharedDataSource.curRoom = nil
        chatList?.needUpdate()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func navRightBtnPressed() {
        // 调出个人信息
        switch roomType {
        case .Private:
            let detail = PrivateChatSettingController(targetUser: self.targetUser!)
            self.navigationController?.pushViewController(detail, animated: true)
            break
        case .Club:
            break
        }
    }
    
    func needsUpdate() {
        var needScrollToBottom = false
        if talkBoard!.contentOffset.y + talkBoard!.frame.height >= talkBoard!.contentSize.height - 1 && talkBoard!.contentSize.height > talkBoard!.frame.height {
            needScrollToBottom = true
        }
        self.talkBoard?.reloadData()
        if needScrollToBottom {
            talkBoard!.setContentOffset(CGPointMake(0, talkBoard!.contentSize.height - talkBoard!.frame.height), animated: true)
        }
    }
}


// MARK: - tableView代理
extension ChatRoomController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRecords!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let record = chatRecords![indexPath.row]
        record.read = true
        let messageType = record.messageType!
        let cell = tableView.dequeueReusableCellWithIdentifier(messageType, forIndexPath: indexPath) as! ChatCell
        let displayTimeMark: Bool = {
            if indexPath.row == 0 {
                return true
            }else{
                let formerRecord = chatRecords![indexPath.row - 1]
                let timedelta = record.createdAt!.timeIntervalSinceDate(formerRecord.createdAt!)
                return timedelta > 600
            }
        }()
        record.displayTimeMark = displayTimeMark
        cell.displayTimeMarker = displayTimeMark
        cell.chat = record
        cell.selectionStyle = .None
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let record = chatRecords![indexPath.row]
        return ChatCell.getContentHeightForChatRecord(record)
    }
}

extension ChatRoomController {
    
    func confirmSendChatMessage(text: String? = nil, image: UIImage? = nil, audio: NSURL? = nil, messageType: String="text") {
        var chatType = ""
        var targetID = ""
        switch roomType {
        case .Club:
            chatType = "group"
            targetID = targetClub!.clubID!
            break
        case .Private:
            chatType = "private"
            targetID = targetUser!.userID!
            break
        }
//        targetID = "28"
        let newChat = ChatRecord.objects.postNewChatRecord(chatType, messageType: messageType, targetID: targetID, textContent: text, image: image, audio: audio, relatedID: nil)
        let dataSource = ChatRecordDataSource.sharedDataSource
        let identifier = getIdentifierForRoomController(self)
        dataSource.chatRecords[identifier]?.append(newChat)
        //
        if messageType == "audio" {
            let analyzer = AudioWaveDrawEngine(audioFileURL: audio!, preferredSampleNum: 30, onFinished: { (engine) -> () in
                }, async: false)
            newChat.cachedWaveData = analyzer.sampledata
            newChat.audioLengthInSec = analyzer.lengthInSec
            newChat.readyForDisplay = true
        }
        //
        talkBoard?.reloadData()
        let targetPath = NSIndexPath(forRow: self.chatRecords!.count - 1, inSection: 0)
        talkBoard?.scrollToRowAtIndexPath(targetPath, atScrollPosition: .Top, animated: false)
        self.chatOpPanelController?.contentInput?.text = ""
        ChatRequester.requester.postNewChatRecord(chatType, messageType: messageType, targetID: targetID, image: image, audio: audio, textContent: text, onSuccess: { (json) -> () in
            let newID = json!["chatID"].stringValue
            ChatRecord.objects.confirmSent(newChat, chatRecordID: newID, image: json!["image"].string, audio: json!["audio"].string)
            }) { (code) -> () in
                print(code)
        }
        
    }
    
    func opPanelDidSwitchInputModel(opPanel: ChatOpPanelController) {

    }
    
    func opPanelWillSwitchInputMode(opPanel: ChatOpPanelController) {
        opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(45)
        })
    }
    
    func needInvokeAccessoryView() {
        let accessoryBoardHeight = UIScreen.mainScreen().bounds.width * kChatAccessoryBoardSizeRatio
        if accessoryBoard == nil {
            accessoryBoard = ChatAccessoryBoard()
            accessoryBoard?.chatRoomController = self
            self.view.addSubview(accessoryBoard!)
            accessoryBoard?.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.top.equalTo(self.view.snp_bottom).offset(0)
                make.height.equalTo(accessoryBoardHeight)
            })
            self.view.layoutIfNeeded()
        }
        // 当这个切换按钮按下时，总是剥夺文本输入框的first responder地位
        chatOpPanelController?.contentInput?.resignFirstResponder()
        
        if displayAccessoryBoard {
            displayAccessoryBoard = false
            // 隐藏accessory面板
            accessoryBoard?.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view.snp_bottom).offset(0)
            })
            opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(0)
            })
        }else {
            displayAccessoryBoard = true
            // 显示accessory面板
            self.tapper?.enabled = true
            accessoryBoard?.snp_makeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view.snp_bottom).offset(-accessoryBoardHeight)
            })
            opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(-accessoryBoardHeight)
            })
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func needInvokeEmojiView() {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            let commentText = textView.text
            if commentText.length > 0 {
                confirmSendChatMessage(commentText, image: nil)
            }
            return false
        }
        // 限制输入字符的长度
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = textView.text as NSString
        let newText = curText.stringByReplacingCharactersInRange(range, withString: text) as String
        if newText.length > 140 {
            // 当输入的长度超过了140时禁止修改
            return false
        }
        return true
    }
    
    // 动态调整输入框的高度
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(max(45, newSize.height))
        })
        self.view.layoutIfNeeded()
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = textView.text ?? ""
        if text.length > 140 {
            textView.text = text[0..<140]
        }
    }
    
    /**
     当键盘出现时自动调整输入空间和表格的布局
     
     - parameter notif:
     */
    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
        let userInfo = notif.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
        let allChatRecordCount = chatRecords!.count
        if allChatRecordCount > 0 {
            let targetPath = NSIndexPath(forRow: allChatRecordCount - 1, inSection: 0)
            talkBoard?.scrollToRowAtIndexPath(targetPath, atScrollPosition: .Top, animated: true)
        }
        // talkBoard?.setContentOffset(CGPointMake(0, CGFloat.max), animated: true)
        
        
        // 当键盘出现时将accessoryBoard的显示状态设置为false
        displayAccessoryBoard = false
        accessoryBoard?.snp_updateConstraints(closure: { (make) -> Void in
            make.top.equalTo(self.view.snp_bottom).offset(0)
        })
    }
    
    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
        opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        if displayAccessoryBoard {
            accessoryBoard?.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view.snp_bottom).offset(0)
            })
            opPanelView?.snp_updateConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(0)
            })
            displayAccessoryBoard = false
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
}

// MARK: - 图片选择器的代理
extension ChatRoomController {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.confirmSendChatMessage(nil, image: image, audio: nil, messageType: "image")
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        // Do nothing when cancelled
    }
}

// MARK: - 录音的代理
extension ChatRoomController {
    
    func audioDidCancelRecording() {
        
    }
    
    func audioDidFinishRecording(audioURL: NSURL?) {
        if audioURL != nil {
            confirmSendChatMessage(nil, image: nil, audio: audioURL, messageType: "audio")
        }else {
            displayAlertController("错误", message: "说话的时间太短")
        }
    }
    
    func audioFailToRecord(errorMessage: String) {
        
    }
    
    func audioWillStartRecording() {
        
    }
}