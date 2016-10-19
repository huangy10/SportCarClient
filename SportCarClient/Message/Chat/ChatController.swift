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

protocol ChatRoomDataSource {
    func willEnter(_ room: ChatRoomController)
    
    func numberOfChats() -> Int
    
    func chatAt(_ index: Int) -> ChatRecord
}

enum ChatRoomType {
    case club
    case `private`
}


class ChatRoomController: InputableViewController, ChatOpPanelDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ChatAudioRecordDelegate, ChatCellDelegate {
    
    // 从chatlist之外的地方进入聊天时，设置这个属性为false
    var chatCreated = true
    var rosterItem: RosterItem! {
        didSet {
            if rosterItem == nil {
                targetUser = nil
                targetClub = nil
                return
            }
            chatCreated = true
            switch rosterItem!.data! {
            case .user(let user):
                targetUser = user
                targetClub = nil
            case .club(let club):
                targetClub = club
                targetUser = nil
            }
        }
    }
    
    var targetUser: User?
    var targetClub: Club?
    
    @available(*, deprecated: 1)
    var distinct_identifier: String!
    
    var chats: [ChatRecord] = []
    
    var navTitle: String? {
        if !chatCreated {
            return targetUser?.nickName ?? targetClub?.name
        }
        switch rosterItem.data! {
        case .user(let chater):
            return chater.chatName
        case .club(let  club):
            return club.name
        }
    }
    
    var navRightBtnImageURLStr: String? {
        if targetUser != nil {
            return targetUser?.avatar
        }else if targetClub != nil{
            return targetClub?.logo
        }
        return nil
    }
    
    var viewingHistory: Bool {
        return talkBoard!.contentOffset.y <= talkBoard!.contentSize.height - talkBoard!.frame.height - 60
    }
    
    var talkBoard: UITableView?
    var refresh: UIRefreshControl!
    // 下方的输入面板
    var chatOpPanelController: ChatOpPanelController?
    
    var opPanelView: UIView? {
        return chatOpPanelController?.view
    }
    
    var accessoryBoard: ChatAccessoryBoard?
    var displayAccessoryBoard: Bool = false
    var firstShowFlag: Bool = false
    
    var firstMessageSent: Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        navSettings()
        super.viewDidLoad()
        //
        ChatCell.registerCellForTableView(talkBoard!)
        talkBoard?.register(UITableViewCell.self, forCellReuseIdentifier: "invisible_cell")
        // 添加键盘出现时时间的监听
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomController.changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatRoomController.changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatHostoryCleared(_:)), name: NSNotification.Name(rawValue: kMessageChatHistoryCleared), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        ChatRecordDataSource.sharedDataSource.curRoom = self
        MessageManager.defaultManager.enterRoom(self)
        // 重新载入club的信息
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = navTitle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MessageManager.defaultManager.leaveRoom()
        
        NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kMessageStopAllVoicePlayNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if chatRecords?.unread > 0 && firstShowFlag {
//            self.talkBoard?.reloadData()
//        }
//        firstShowFlag = true
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        //
        chatOpPanelController = ChatOpPanelController()
        superview.addSubview(chatOpPanelController!.view)
        chatOpPanelController?.view.snp.makeConstraints { (make) -> Void in
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
        talkBoard = UITableView(frame: CGRect.zero, style: .plain)
        talkBoard?.separatorStyle = .none
        superview.addSubview(talkBoard!)
        talkBoard?.dataSource = self
        talkBoard?.delegate = self
        talkBoard?.contentInset = UIEdgeInsetsMake(0, 0, 15, 0)
        talkBoard?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(chatOpPanelController!.view.snp.top)
            make.top.equalTo(superview)
        })
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(ChatRoomController.loadChatHistory as (ChatRoomController) -> () -> ()), for: .valueChanged)
        talkBoard?.addSubview(refresh)
        
        self.view.bringSubview(toFront: opPanelView!)
    }
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = navTitle
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        navLeftBtn.addTarget(self, action: #selector(ChatRoomController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        
        let navRightBtn = UIButton()
        let navRightBtnIconURLStr = navRightBtnImageURLStr
        navRightBtn.kf.setImage(with: SFURL(navRightBtnIconURLStr!)!, for: .normal)
        navRightBtn.addTarget(self, action: #selector(ChatRoomController.navRightBtnPressed), for: .touchUpInside)
        navRightBtn.layer.cornerRadius = 17.5
        navRightBtn.clipsToBounds = true
        navRightBtn.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
    }
    
    func navLeftBtnPressed() {
//        ChatRecordDataSource.sharedDataSource.curRoom = nil
//        chatList?.needUpdate()
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        if let rosterItem = rosterItem {
            switch rosterItem.data! {
            case .user(_):
                let detail = PrivateChatSettingController(rosterItem: rosterItem)
                self.navigationController?.pushViewController(detail, animated: true)
            case .club(_):
                if targetClub!.founderUser!.isHost {
                    let detail = GroupChatSettingHostController(targetClub: targetClub!)
                    self.navigationController?.pushViewController(detail, animated: true)
                } else {
                    let detail = GroupChatSettingController(targetClub: targetClub!)
                    self.navigationController?.pushViewController(detail, animated: true)
                }
            }
        }
        // 调出个人信息
//        switch roomType {
//        case .Private:
//            let detail = PrivateChatSettingController(targetUser: self.targetUser!)
//            self.navigationController?.pushViewController(detail, animated: true)
//            break
//        case .Club:
//            if targetClub!.founderUser!.isHost {
//                let detail = GroupChatSettingHostController(targetClub: targetClub!)
//                self.navigationController?.pushViewController(detail, animated: true)
//                break
//            }
//            let detail = GroupChatSettingController(targetClub: self.targetClub!)
//            self.navigationController?.pushViewController(detail, animated: true)
//            break
//        }
    }
    
    func needsUpdate() {
        var needScrollToBottom = false
        if talkBoard!.contentOffset.y + talkBoard!.frame.height >= talkBoard!.contentSize.height - 1 && talkBoard!.contentSize.height > talkBoard!.frame.height {
            needScrollToBottom = true
        }
        self.talkBoard?.reloadData()
        if needScrollToBottom {
            talkBoard!.setContentOffset(CGPoint(x: 0, y: talkBoard!.contentSize.height - talkBoard!.frame.height), animated: true)
        }
    }
    
    func onChatHostoryCleared(_ notification: Foundation.Notification) {
        if let relatedRoster = (notification as NSNotification).userInfo?[kRosterItemKey] as? RosterItem , relatedRoster == rosterItem {
            DispatchQueue.main.async(execute: { 
                self.chats.removeAll()
                self.talkBoard?.reloadData()
            })
        }
    }
}

// MARK: - 数据
extension ChatRoomController {
    
    func loadChatHistory() {
        loadChatHistoryMannually(false)
    }
    
    func loadChatHistoryMannually(_ autoScrollToBottom: Bool = false) {
        MessageManager.defaultManager.loadHistory(self) { (chats) in
            if let chats = chats {
                self.chats.insert(contentsOf: chats, at: 0)
                self.talkBoard?.beginUpdates()
                let indexes = (0..<chats.count).map { IndexPath(row: $0, section: 0)}
                self.talkBoard?.insertRows(at: indexes, with: .automatic)
                self.talkBoard?.reloadData()
                self.talkBoard?.endUpdates()
                if autoScrollToBottom {
                    self.talkBoard?.scrollToRow(at: IndexPath(row: self.chats.count - 1, section: 0)
                        , at: .top, animated: false)
                }
            }
            self.refresh.endRefreshing()
        }
    }
}


// MARK: - tableView代理
extension ChatRoomController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
//        return chatRecords!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let record = chats[(indexPath as NSIndexPath).row]
        record.read = true
        let messageType = record.messageType!
        let cell = tableView.dequeueReusableCell(withIdentifier: messageType, for: indexPath) as! ChatCell
        cell.delegate = self
        let displayTimeMark: Bool = {
            if (indexPath as NSIndexPath).row == 0 {
                return true
            }else{
//                let formerRecord = chatRecords![indexPath.row - 1]
                let formerRecord = chats[(indexPath as NSIndexPath).row - 1]
                let timedelta = record.createdAt!.timeIntervalSince(formerRecord.createdAt!)
                return timedelta > 600
            }
        }()
        record.displayTimeMark = displayTimeMark
        cell.displayTimeMarker = displayTimeMark
        cell.chat = record
        cell.selectionStyle = .none
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let record = chatRecords![indexPath.row]
        let record = chats[(indexPath as NSIndexPath).row]
//        if record.messageType == "placeholder" {
//            return 0
//        }
        return ChatCell.getContentHeightForChatRecord(record)
    }
}

extension ChatRoomController {
    
    func confirmSendChatMessage(_ text: String? = nil, image: UIImage? = nil, audio: URL? = nil, messageType: String="text") {
        
        guard self.chatCreated else {
            self.showToast(LS("无法连接到服务器"))
            return
        }
        let newChat: ChatRecord = try! ChatModelManger.sharedManager.createNew()
        newChat.initForPost(messageType, textContent: text, image: image, audio: audio)
        newChat.rosterID = rosterItem.ssid
        switch rosterItem.data! {
        case .user(_):
            newChat.targetID = targetUser!.ssid
            
            newChat.targetUser = targetUser!
            newChat.chatType = "user"
        case .club(_):
            newChat.targetID = targetClub!.ssid
            if let club = targetClub!.toContext(ChatModelManger.sharedManager.getOperationContext()) as? Club {
                newChat.targetClub = club
            } else {
                assertionFailure()
            }
            newChat.chatType = "club"
        }
//        switch chatRecords!._item! {
//        case .UserItem(let user):
//            newChat.targetID = user.ssid
//            
//            newChat.targetUser = user
//            newChat.chatType = "private"
//            break
//        case .ClubItem(let club):
//            newChat.targetID = club.ssid
//            if let club = club.toContext(ChatModelManger.sharedManager.getOperationContext()) as? Club {
//                newChat.targetClub = club
//            } else {
//                assertionFailure()
//            }
//            newChat.chatType = "group"
//            break
//        }
//        let dataSource = ChatRecordDataSource.sharedDataSource
//        let identifier = getIdentiferForChatRecord(newChat)
//        dataSource.chatRecords[identifier]?.append(newChat)
        chats.append(newChat)
        //
        if messageType == "audio" {
            let analyzer = AudioWaveDrawEngine(audioFileURL: audio!, preferredSampleNum: 30, onFinished: { (engine) -> () in
                }, async: false)
            newChat.cachedWaveData = analyzer.sampledata
            newChat.audioLength = analyzer.lengthInSec
            newChat.audioReady = true
        }
        //
        talkBoard?.beginUpdates()
//        talkBoard?.reloadData()
//        talkBoard?.insertRowsAtIndexPaths([NSIndexPath(forRow: chatRecords!.count-1, inSection: 0)], withRowAnimation: .Fade)
//        talkBoard?.endUpdates()
//        let targetPath = NSIndexPath(forRow: self.chatRecords!.count - 1, inSection: 0)
        talkBoard?.insertRows(at: [IndexPath(row: chats.count-1, section: 0)], with: .fade)
        talkBoard?.endUpdates()
        let targetPath = IndexPath(row: self.chats.count - 1, section: 0)
        talkBoard?.scrollToRow(at: targetPath, at: .top, animated: false)
        self.chatOpPanelController?.contentInput?.text = ""
        ChatRequester2.sharedInstance.postNewChatRecord(newChat.chatType!, messageType: messageType, targetID: newChat.targetIDString, image: image, audio: audio, textContent: text, onSuccess: { (json) -> () in
            let newID = json!["chatID"].int32Value
            newChat.confirmSent(newID, image: json!["image"].string, audio: json!["audio"].string)
            if messageType == "image" {
                let imageURL = SFURL(newChat.image!)!
                let cache = KingfisherManager.shared.cache
                cache.store(image!, forKey: imageURL.absoluteString)
            } else if messageType == "audio" {
                newChat.audioCaches = json!["audio_wave_data"].stringValue
                newChat.audioLength = json!["audio_length"].doubleValue
            }
            self.rosterItem.recentChatDes = newChat.summary
            MessageManager.defaultManager.newMessageSent(newChat)
//            let identifier = getIdentifierForChatRoom(self)
//            ChatRecordDataSource.sharedDataSource.chatRecords.bringKeyToFront(identifier)
            }) { (code) -> () in
//                print(code)
                self.showToast(LS("消息发送失败"))
        }
        
        if !firstMessageSent {
            firstMessageSent = true
            RosterManager.defaultManager.data.resortRosters()
        }
    }
    
    func opPanelDidSwitchInputModel(_ opPanel: ChatOpPanelController) {

    }
    
    func opPanelWillSwitchInputMode(_ opPanel: ChatOpPanelController) {
        opPanelView?.snp.updateConstraints({ (make) -> Void in
            make.height.equalTo(45)
        })
    }
    
    func needInvokeAccessoryView() {
        let accessoryBoardHeight = UIScreen.main.bounds.width * kChatAccessoryBoardSizeRatio
        if accessoryBoard == nil {
            accessoryBoard = ChatAccessoryBoard()
            accessoryBoard?.chatRoomController = self
            self.view.addSubview(accessoryBoard!)
            accessoryBoard?.snp.makeConstraints({ (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.top.equalTo(self.view.snp.bottom).offset(0)
                make.height.equalTo(accessoryBoardHeight)
            })
            self.view.layoutIfNeeded()
        }
        // 当这个切换按钮按下时，总是剥夺文本输入框的first responder地位
        chatOpPanelController?.contentInput?.resignFirstResponder()
        
        if displayAccessoryBoard {
            displayAccessoryBoard = false
            // 隐藏accessory面板
            accessoryBoard?.snp.updateConstraints({ (make) -> Void in
                make.top.equalTo(self.view.snp.bottom).offset(0)
            })
            opPanelView?.snp.updateConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(0)
            })
        }else {
            displayAccessoryBoard = true
            // 显示accessory面板
            self.tapper?.isEnabled = true
            accessoryBoard?.snp.updateConstraints({ (make) -> Void in
                make.top.equalTo(self.view.snp.bottom).offset(-accessoryBoardHeight)
            })
            opPanelView?.snp.updateConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(-accessoryBoardHeight)
            })
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func needInvokeEmojiView() {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            let commentText = textView.text ?? ""
            if commentText.length > 0 {
                opPanelView?.snp.updateConstraints({ (make) -> Void in
                    make.height.equalTo(45)
                })
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
        let newText = curText.replacingCharacters(in: range, with: text) as String
        if newText.length > 140 {
            // 当输入的长度超过了140时禁止修改
            return false
        }
        return true
    }
    
    // 动态调整输入框的高度
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        opPanelView?.snp.updateConstraints({ (make) -> Void in
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
    func changeLayoutWhenKeyboardAppears(_ notif: Foundation.Notification) {
        let userInfo = (notif as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue!
        opPanelView?.snp.updateConstraints({ (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
//        let allChatRecordCount = chatRecords!.count
        let allChatRecordCount = chats.count
        if allChatRecordCount > 0 {
            let targetPath = IndexPath(row: allChatRecordCount - 1, section: 0)
            talkBoard?.scrollToRow(at: targetPath, at: .top, animated: true)
        }
        // talkBoard?.setContentOffset(CGPointMake(0, CGFloat.max), animated: true)
        
        
        // 当键盘出现时将accessoryBoard的显示状态设置为false
        displayAccessoryBoard = false
        accessoryBoard?.snp.updateConstraints({ (make) -> Void in
            make.top.equalTo(self.view.snp.bottom).offset(0)
        })
    }
    
    func changeLayoutWhenKeyboardDisappears(_ notif: Foundation.Notification) {
        opPanelView?.snp.updateConstraints({ (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        if displayAccessoryBoard {
            accessoryBoard?.snp.updateConstraints({ (make) -> Void in
                make.top.equalTo(self.view.snp.bottom).offset(0)
            })
            opPanelView?.snp.updateConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(0)
            })
            displayAccessoryBoard = false
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
}

// MARK: - 图片选择器的代理
extension ChatRoomController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismiss(animated: true, completion: nil)
        self.confirmSendChatMessage(nil, image: image, audio: nil, messageType: "image")
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
        // Do nothing when cancelled
    }
}

// MARK: - 录音的代理
extension ChatRoomController {
    
    func audioDidCancelRecording() {
        
    }
    
    func audioDidFinishRecording(_ audioURL: URL?) {
        if audioURL != nil {
            confirmSendChatMessage(nil, image: nil, audio: audioURL, messageType: "audio")
        }else {
            showToast(LS("说话时间太短"))
        }
    }
    
    func audioFailToRecord(_ errorMessage: String) {
        
    }
    
    func audioWillStartRecording() {
        
    }
}

extension ChatRoomController {
    func avatarPressed(_ chatRecord: ChatRecord) {
        if let user = chatRecord.senderUser {
            if user.isHost {
                let detail = PersonBasicController(user: user)
                self.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = PersonOtherController(user: user)
                self.navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            assertionFailure()
        }
    }
}
