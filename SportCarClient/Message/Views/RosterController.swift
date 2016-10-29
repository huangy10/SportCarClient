//
//  RosterController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol RosterDataSource {
    func numberOfRosters() -> Int
    
    func rosterAt(_ index: Int) -> RosterItem
}


class RosterController: UITableViewController, FFSelectDelegate, GroupChatSetupDelegate {
    var data: MyOrderedDict<String, RosterItem> {
        return RosterManager.defaultManager.data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChatListCell.self, forCellReuseIdentifier: ChatListCell.reuseIdentifier)
        tableView.rowHeight = 75
        tableView.separatorStyle = .none
        
        RosterManager.defaultManager.rosterList = tableView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    /**
     上级的MessageController的导航栏右侧按钮按下之后调用这个来调出用户选择页面
     */
    func navRightBtnPressed() {
        showConfirmToast(LS("新建群聊"), message: LS("选择与朋友发起聊天或者群聊"), target: self, onConfirm: #selector(confirmNewChat))
    }
    
    func confirmNewChat() {
        let selector = FFSelectController()
        selector.delegate = self
        parent?.present(selector.toNavWrapper(), animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatListCell.reuseIdentifier, for: indexPath) as! ChatListCell
        let access = data.valueForIndex((indexPath as NSIndexPath).row)
        cell.data = access
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = ChatRoomController()
        guard let access = data.valueForIndex((indexPath as NSIndexPath).row) else {
            assertionFailure()
            return
        }
        detail.rosterItem = access
        detail.chatCreated = true
        parent?.navigationController?.pushViewController(detail, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let action = UITableViewRowAction(style: .default, title: "删除") { (action, indexPath) in
            
            RosterManager.defaultManager.removeLocalRosterItemStorage(at: (indexPath as NSIndexPath).row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        return [action]
    }
    
    // MARK: User select delegate
    func userSelected(_ users: [User]) {
        parent?.dismiss(animated: false, completion: nil)
        
        if users.count == 0 {
        }else if users.count == 1 {
            // 当选中的是一个人是，直接打开对话框
            let room = ChatRoomController()
            room.chatCreated = false
            room.targetUser = users.first
            parent?.navigationController?.pushViewController(room, animated: true)
            
        }else{
            // 创建群聊
            let detail = GroupChatSetupController()
            detail.users = users
            detail.delegate = self
            parent?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func userSelectCancelled() {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    func groupChatSetupControllerDidSuccessCreatingClub(_ newClub: Club) {
        // 群聊创建成功，打开聊天窗口
        _ = self.navigationController?.popViewController(animated: true)
        let chatRoom = ChatRoomController()
        chatRoom.targetClub = newClub
        
        chatRoom.chatCreated = false
        parent?.navigationController?.pushViewController(chatRoom, animated: true)
    }
}
