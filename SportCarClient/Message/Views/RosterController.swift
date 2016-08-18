//
//  RosterController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class RosterController: UITableViewController, FFSelectDelegate, GroupChatSetupDelegate {
    var data: MyOrderedDict<String, RosterItem> {
        return RosterManager.defaultManager.data
    }
    
    weak var messageController: MessageController!
    weak var toast: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(ChatListCell.self, forCellReuseIdentifier: ChatListCell.reuseIdentifier)
        tableView.rowHeight = 75
        tableView.separatorStyle = .None
        
        RosterManager.defaultManager.rosterList = tableView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    /**
     上级的MessageController的导航栏右侧按钮按下之后调用这个来调出用户选择页面
     */
    func navRightBtnPressed() {
        toast = messageController.showConfirmToast(LS("新建群聊?"), message: LS("选择与朋友发起聊天或者群聊"), target: self, confirmSelector: #selector(confirmNewChat), cancelSelector: #selector(hideToast as ()->()))
    }
    
    func confirmNewChat() {
        let selector = FFSelectController()
        selector.delegate = self
        messageController.presentViewController(selector.toNavWrapper(), animated: true, completion: nil)
        hideToast()
    }
    
    func hideToast() {
        if let toast = toast {
            hideToast(toast)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ChatListCell.reuseIdentifier, forIndexPath: indexPath) as! ChatListCell
        let access = data.valueForIndex(indexPath.row)
        cell.data = access
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detail = ChatRoomController()
        guard let access = data.valueForIndex(indexPath.row) else {
            assertionFailure()
            return
        }
        detail.rosterItem = access
        detail.chatCreated = true
        messageController.navigationController?.pushViewController(detail, animated: true)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .Default, title: "删除") { (action, indexPath) in
            
            RosterManager.defaultManager.removeLocalRosterItemStorage(at: indexPath.row)
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        return [action]
    }
    
    // MARK: User select delegate
    func userSelected(users: [User]) {
        messageController.dismissViewControllerAnimated(false, completion: nil)
        
        if users.count == 0 {
        }else if users.count == 1 {
            // 当选中的是一个人是，直接打开对话框
            let room = ChatRoomController()
            room.chatCreated = false
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
        chatRoom.targetClub = newClub
        
        chatRoom.chatCreated = false
        messageController.navigationController?.pushViewController(chatRoom, animated: true)
    }
}
