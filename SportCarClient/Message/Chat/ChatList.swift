//
//  ChatList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

class ChatListController: UITableViewController, FFSelectDelegate, GroupChatSetupDelegate {
    // 指向通用数据库
    let dataSource = ChatRecordDataSource.sharedDataSource
    var messageController: MessageController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.registerClass(ChatListCell.self, forCellReuseIdentifier: ChatListCell.reuseIdentifier)
        tableView.rowHeight = 75
        tableView.separatorStyle = .None
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        needUpdate()
    }
    
    /**
     上级的MessageController的导航栏右侧按钮按下之后调用这个来调出用户选择页面
     */
    func navRightBtnPressed() {
        let selector = FFSelectController()
        selector.delegate = self
        let nav = BlackBarNavigationController(rootViewController: selector)
        messageController.presentViewController(nav, animated: true, completion: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.chatRecords.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListCell.reuseIdentifier, forIndexPath: indexPath) as! ChatListCell
        let chatData = ChatRecordDataSource.sharedDataSource.chatRecords.valueForIndex(indexPath.row)
        cell.listItem = chatData?._item
        cell.setUnreadNumber(chatData!.unread)
        if let recentChat = chatData?.last(){
            cell.recentTalkLbl.text = recentChat.getDescription()
            cell.recentTalkTimeLbl.text = dateDisplay(recentChat.createdAt!)
        }else {
            cell.recentTalkTimeLbl.text = ""
            cell.recentTalkLbl.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detail = ChatRoomController()
        detail.chatList = self
        let chatData = ChatRecordDataSource.sharedDataSource.chatRecords.valueForIndex(indexPath.row)
        switch chatData!._item! {
        case .UserItem(let user):
            detail.targetUser = user
            break
        case .ClubItem(let club):
            detail.targetClub = club
            break
        }
        messageController.navigationController?.pushViewController(detail, animated: true)
    }
    
    func needUpdate() {
        tableView.reloadData()
    }
}

extension ChatListController {
    func userSelected(users: [User]) {
        messageController.dismissViewControllerAnimated(false, completion: nil)
        
        if users.count == 0 {
        }else if users.count == 1 {
            // 当选中的是一个人是，直接打开对话框
            let room = ChatRoomController()
            room.chatList = self
            room.targetUser = users.first
            messageController.navigationController?.pushViewController(room, animated: true)
            
        }else{
            // 创建群聊
            let detail = GroupChatSetupController()
            detail.users = users
            detail.delegate = self
            messageController.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func userSelectCancelled() {
        messageController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func groupChatSetupControllerDidSuccessCreatingClub(newClub: Club) {
        // 群聊创建成功，打开聊天窗口
        self.navigationController?.popViewControllerAnimated(true)
        let chatRoom = ChatRoomController()
        chatRoom.chatList = self
        chatRoom.targetClub = newClub
        messageController.navigationController?.pushViewController(chatRoom, animated: true)
    }
}
