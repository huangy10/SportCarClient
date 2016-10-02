//
//  GroupMemberSelecter.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar

protocol GroupMemberSelectDelegate: class {
    func groupMemberSelectControllerDidSelectUser(_ user: User)
    func groupMemberSelectControllerDidCancel()
}


class GroupMemberSelectController: UserSelectController {
    weak var delegate: GroupMemberSelectDelegate?
    
    var members: [User] = []
    
    override var users: [User] {
        return members
    }
    
    var club: Club
    
    weak var presenter: UIViewController?
    
    init (club: Club) {
        self.club = club
        self.members = club.members.filter({$0.ssid != club.founderUser!.ssid})
        super.init()
        self.forceSelectedUsers = [club.founderUser!]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func navTitle() -> String {
        return LS("选择一位新的群主")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView?.register(UserSelectCellUnselectable.self, forCellReuseIdentifier: "cell")
    }
    
    override func navLeftBtnPressed() {
        presenter?.dismiss(animated: true, completion: nil)
        delegate?.groupMemberSelectControllerDidCancel()
    }
    
    func presentFrom(_ presenter: UIViewController) {
        self.presenter = presenter
        let wrapper = BlackBarNavigationController(rootViewController: self)
        presenter.present(wrapper, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSelectCellUnselectable
        let user = users[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf.setImage(with: user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[(indexPath as NSIndexPath).row]
        presenter?.dismiss(animated: true, completion: nil)
        delegate?.groupMemberSelectControllerDidSelectUser(selectedUser)
    }
}
