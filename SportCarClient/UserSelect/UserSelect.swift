//
//  UserSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Dollar

/// 用户选择界面
class UserSelectController: InputableViewController, UISearchBarDelegate {
    /// 用户列表
    var users: [User] {
        get {
            return [User]()
        }
    }
    /// 被选中的用户列表
    var selectedUsers: [User] = []
    //  强制预先选中的
    var forceSelectedUsers: [User] = []
    /// 搜索关键词
    var searchText: String?
    /*
     subviews
    */
    var selectedUserList: UICollectionView?
    /// 用户列表
    var userTableView: UITableView?
    /// 搜索栏
    var searchBar: UISearchBar?
    
    override init () {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view!
        superview.backgroundColor = UIColor.white
        //
        searchBar = UISearchBar()
        superview.addSubview(searchBar!)
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .minimal
        searchBar?.isTranslucent = true
        searchBar?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(44)
        })
        searchBar?.returnKeyType = .search
        self.inputFields.append(searchBar)
        //
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 35, height: 35)
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        selectedUserList = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        selectedUserList?.register(UserSelectedcell.self, forCellWithReuseIdentifier: UserSelectedcell.reuseIdentifier)
        selectedUserList?.backgroundColor = UIColor.white
        selectedUserList?.dataSource = self
        superview.addSubview(selectedUserList!)
        selectedUserList?.snp.makeConstraints({ (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(selectedUsers.count > 0 ? 65 : 0)
            make.top.equalTo(searchBar!.snp.bottom)
        })
        //
        userTableView = UITableView(frame: CGRect.zero, style: .plain)
        userTableView?.delegate = self
        userTableView?.dataSource = self
        userTableView?.separatorStyle = .none
        superview.addSubview(userTableView!)
        userTableView?.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(selectedUserList!.snp.bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
        })
        userTableView?.register(UserSelectCell.self, forCellReuseIdentifier: UserSelectCell.reuseIdentifier)
    }
    
    internal func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = self.navTitle()
        let leftBtn = UIButton()
        leftBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        leftBtn.addTarget(self, action: #selector(UserSelectController.navLeftBtnPressed), for: .touchUpInside)
        let leftBtnItem = UIBarButtonItem(customView: leftBtn)
        self.navigationItem.leftBarButtonItem = leftBtnItem
    }
    
    func navTitle() -> String {
        assertionFailure("Not Implemented Error")
        return ""
    }
    
    func navLeftBtnPressed() {
        assertionFailure("Not Implemented Error")
    }
    
    func findOnMapBtnPressed() {
        
    }
    
    func setSelectedUserListHiddenAnimated(_ hidden: Bool){
        if hidden {
            selectedUserList?.snp.updateConstraints({ (make) -> Void in
                make.height.equalTo(0)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (_) -> Void in
//                    self.selectedUserList?.hidden = true
            })
        }else{
//            selectedUserList?.hidden = false
            selectedUserList?.snp.updateConstraints({ (make) -> Void in
                make.height.equalTo(65)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (_) -> Void in
                    self.selectedUserList?.reloadData()
            })
        }
    }
    
    /**
     留给子类实现，这个函数在用户选择情况发生变化之后调用
     */
    func userSelectionDidChange() {
        assertionFailure("Not Implemented.")
    }
    
    /**
     在选择用户操作之前调用，返回结果控制这个选择是否生效
     
     - parameter user:        涉及的用户
     - parameter addOrDelete: 操作类型：true为添加，false为删除
     
     - returns: 选择是否生效
     */
    func userSelectionShouldChange(_ user: User, addOrDelete: Bool) -> Bool{
        return true
    }
}

// MARK: - TableView和SearchBar的代理
extension UserSelectController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserSelectCell.reuseIdentifier, for: indexPath) as! UserSelectCell
        let user = users[(indexPath as NSIndexPath).row]
        cell.avatarImg?.kf.setImage(with: user.avatarURL!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        
        cell.selectBtn?.tag = (indexPath as NSIndexPath).row
        if forceSelectedUsers.findIndex(callback: {$0.ssid == user.ssid}) != nil {
            cell.forceSelected = true
            cell.selectBtn?.isSelected = true
        } else {
            cell.forceSelected = false
            if selectedUsers.filter({$0.ssid == user.ssid}).count > 0 {
                cell.selectBtn?.isSelected = true
            } else {
                cell.selectBtn?.isSelected = false
            }
        }
        cell.onSelect = { [weak self] (sender) -> Bool in
            guard let sSelf = self else {
                return false
            }
            let row = sender.tag
            let targetUser = sSelf.users.fetch(index: row)!
            
            if !sSelf.userSelectionShouldChange(targetUser, addOrDelete: !sender.isSelected) {
                return false
            }
            
            if sender.isSelected {
                sSelf.selectedUsers = $.remove(sSelf.selectedUsers, value: targetUser)
                if sSelf.selectedUsers.count == 0 {
                    sSelf.selectedUserList?.reloadData()
                    sSelf.setSelectedUserListHiddenAnimated(true)
                }
            }else{
                sSelf.selectedUsers.append(targetUser)
                if sSelf.selectedUsers.count == 1{
                    sSelf.setSelectedUserListHiddenAnimated(false)
                    sSelf.userSelectionDidChange()
                    return true
                }
            }
            sSelf.selectedUserList?.reloadData()
            sSelf.userSelectionDidChange()
            return true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // cell的高度固定为90
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[(indexPath as NSIndexPath).row]
        if user.isHost {
            let detail = PersonBasicController(user: user)
            navigationController?.pushViewController(detail, animated: true)
        } else {
            let detail = PersonOtherController(user: user)
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchText != searchBar.text {
            searchText = searchBar.text
            searchUserUsingSearchText()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.tapper?.isEnabled = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.searchText != searchText {
            self.searchText = searchText
            searchUserUsingSearchText()
        }
    }
    
}

// MARK: - Collection Delegate functions
extension UserSelectController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserSelectedcell.reuseIdentifier, for: indexPath) as! UserSelectedcell
        let user = selectedUsers[(indexPath as NSIndexPath).row]
        cell.imageView?.kf.setImage(with: user.avatarURL!)
        return cell
    }
}


extension UserSelectController {
    func searchUserUsingSearchText() {
        assertionFailure("Not implememnted")
    }
}


class UserSelectCell: UITableViewCell {
    static let reuseIdentifier = "user_select_cell"
    /// 选择按钮
    var selectBtn: UIButton?
    var onSelect: ((_ sender: UIButton)->Bool)?
    /// 用户头像
    var avatarImg: UIImageView?
    /// 昵称
    var nickNameLbl: UILabel?
    /// 签名
    var recentStatusLbL: UILabel?
    //
    var rightArrowImg: UIImageView!
    /// 强制选中
    var forceSelected: Bool = false {
        didSet {
            if forceSelected {
                selectBtn?.setImage(UIImage(named: "status_photo_selected_forced"), for: .selected)
            } else {
                selectBtn?.setImage(UIImage(named: "status_photo_selected_small"), for: .selected)
            }
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        selectBtn = UIButton()
        selectBtn?.setImage(UIImage(named: "status_photo_unselected_small"), for: UIControlState())
        selectBtn?.setImage(UIImage(named: "status_photo_selected_small"), for: .selected)
        selectBtn?.addTarget(self, action: #selector(UserSelectCell.selectBtnPressed), for: .touchUpInside)
        selectBtn?.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
        selectBtn?.isSelected = false
        superview.addSubview(selectBtn!)
        selectBtn?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(32.5)
        })
        //
        avatarImg = UIImageView()
        avatarImg?.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(avatarImg!)
        avatarImg?.layer.cornerRadius = 35 / 2
        avatarImg?.clipsToBounds = true
        avatarImg?.snp.makeConstraints({ (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(selectBtn!.snp.right).offset(5)
            make.size.equalTo(35)
        })
        //
        nickNameLbl = UILabel()
        nickNameLbl?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        nickNameLbl?.textColor = UIColor.black
        superview.addSubview(nickNameLbl!)
        nickNameLbl?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(avatarImg!.snp.right).offset(12)
            make.top.equalTo(avatarImg!)
            make.height.equalTo(avatarImg!).multipliedBy(0.5)
        })
        //
        recentStatusLbL = UILabel()
        recentStatusLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        recentStatusLbL?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(recentStatusLbL!)
        recentStatusLbL?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(nickNameLbl!)
            make.bottom.equalTo(avatarImg!)
            make.height.equalTo(17)
        })
        //
        rightArrowImg = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(rightArrowImg)
        rightArrowImg.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSize(width: 9, height: 15))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview .addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(0.5)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
        }
    }
    
    func selectBtnPressed() {
        if forceSelected {
            // 强制选中情况下不调用回调closure
            return
        }
        if let handler = onSelect {
            if handler(selectBtn!) {
                selectBtn?.isSelected = !selectBtn!.isSelected
            }
        }else{
            assertionFailure()
        }
    }
}


class UserSelectedcell: UICollectionViewCell {
    
    static let reuseIdentifier = "user_selected_cell"
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        imageView?.layer.cornerRadius = 17.5
        imageView?.clipsToBounds = true
        self.contentView.addSubview(imageView!)
        imageView?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(self.contentView)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
