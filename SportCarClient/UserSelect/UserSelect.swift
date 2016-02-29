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

/// 用户选择界面
class UserSelectController: InputableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDataSource {
    /// 用户列表
    var users: [User] {
        get {
            return [User]()
        }
    }
    /// 被选中的用户列表
    var selectedUsers: [User] = []
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
    /// 在地图上选人
    var findOnMapBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        searchBar = UISearchBar()
        superview.addSubview(searchBar!)
        searchBar?.delegate = self
        searchBar?.searchBarStyle = .Minimal
        searchBar?.translucent = true
        searchBar?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview).offset(-90)
            make.top.equalTo(superview)
            make.height.equalTo(44)
        })
        searchBar?.returnKeyType = .Search
        self.inputFields.append(searchBar)
        //
        findOnMapBtn = UIButton()
        findOnMapBtn?.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        findOnMapBtn?.setTitle(LS("在地图上选人"), forState: .Normal)
        findOnMapBtn?.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(findOnMapBtn!)
        findOnMapBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(searchBar!)
            make.width.equalTo(72)
            make.height.equalTo(searchBar!)
        })
        findOnMapBtn?.addTarget(self, action: "findOnMapBtnPressed", forControlEvents: .TouchUpInside)
        //
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(35, 35)
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .Horizontal
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        selectedUserList = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        selectedUserList?.registerClass(UserSelectedcell.self, forCellWithReuseIdentifier: UserSelectedcell.reuseIdentifier)
        selectedUserList?.backgroundColor = UIColor.whiteColor()
        selectedUserList?.dataSource = self
        superview.addSubview(selectedUserList!)
        selectedUserList?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(selectedUsers.count > 0 ? 65 : 0)
            make.top.equalTo(searchBar!.snp_bottom)
        })
        //
        userTableView = UITableView(frame: CGRectZero, style: .Plain)
        userTableView?.delegate = self
        userTableView?.dataSource = self
        userTableView?.separatorStyle = .None
        superview.addSubview(userTableView!)
        userTableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(selectedUserList!.snp_bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
        })
        userTableView?.registerClass(UserSelectCell.self, forCellReuseIdentifier: UserSelectCell.reuseIdentifier)
    }
    
    internal func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = self.navTitle()
        let leftBtn = UIButton()
        leftBtn.frame = CGRectMake(0, 0, 10.5, 18)
        leftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        leftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
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
    
    func setSelectedUserListHiddenAnimated(hidden: Bool){
        if hidden {
            selectedUserList?.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(0)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (_) -> Void in
//                    self.selectedUserList?.hidden = true
            })
        }else{
//            selectedUserList?.hidden = false
            selectedUserList?.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(65)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
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
    func userSelectionShouldChange(user: User, addOrDelete: Bool) -> Bool{
        return true
    }
}

// MARK: - TableView和SearchBar的代理
extension UserSelectController {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(UserSelectCell.reuseIdentifier, forIndexPath: indexPath) as! UserSelectCell
        let user = users[indexPath.row]
        cell.avatarImg?.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
        cell.nickNameLbl?.text = user.nickName
        cell.recentStatusLbL?.text = user.recentStatusDes
        
        cell.selectBtn?.tag = indexPath.row
        if selectedUsers.contains(user) {
            cell.selectBtn?.selected = true
        }else{
            cell.selectBtn?.selected = false
        }
        cell.onSelect = { (let sender) in
            let row = sender.tag
            let targetUser = self.users.fetch(row)
            
            if !self.userSelectionShouldChange(targetUser, addOrDelete: !sender.selected) {
                return
            }
            
            if sender.selected {
                self.selectedUsers.remove(targetUser)
                if self.selectedUsers.count == 0 {
                    self.selectedUserList?.reloadData()
                    self.setSelectedUserListHiddenAnimated(true)
                }
            }else{
                self.selectedUsers.append(targetUser)
                if self.selectedUsers.count == 1{
                    self.setSelectedUserListHiddenAnimated(false)
                    self.userSelectionDidChange()
                    return
                }
            }
            self.selectedUserList?.reloadData()
            self.userSelectionDidChange()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // cell的高度固定为90
        return 90
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchText = searchBar.text
        searchUserUsingSearchText()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.tapper?.enabled = true
        return true
    }
}

// MARK: - Collection Delegate functions
extension UserSelectController {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(UserSelectedcell.reuseIdentifier, forIndexPath: indexPath) as! UserSelectedcell
        let user = selectedUsers[indexPath.row]
        cell.imageView?.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
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
    var onSelect: ((sender: UIButton)->())?
    /// 用户头像
    var avatarImg: UIImageView?
    /// 昵称
    var nickNameLbl: UILabel?
    /// 签名
    var recentStatusLbL: UILabel?
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        selectBtn = UIButton()
        selectBtn?.setImage(UIImage(named: "status_photo_unselected_small"), forState: .Normal)
        selectBtn?.setImage(UIImage(named: "status_photo_selected_small"), forState: .Selected)
        selectBtn?.addTarget(self, action: "selectBtnPressed", forControlEvents: .TouchUpInside)
        selectBtn?.selected = false
        superview.addSubview(selectBtn!)
        selectBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(superview).offset(15)
            make.size.equalTo(22.5)
        })
        //
        avatarImg = UIImageView()
        avatarImg?.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(avatarImg!)
        avatarImg?.layer.cornerRadius = 35 / 2
        avatarImg?.clipsToBounds = true
        avatarImg?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(superview)
            make.left.equalTo(selectBtn!.snp_right).offset(10)
            make.size.equalTo(35)
        })
        //
        nickNameLbl = UILabel()
        nickNameLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        nickNameLbl?.textColor = UIColor.blackColor()
        superview.addSubview(nickNameLbl!)
        nickNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarImg!.snp_right).offset(12)
            make.top.equalTo(avatarImg!)
            make.height.equalTo(avatarImg!).multipliedBy(0.5)
        })
        //
        recentStatusLbL = UILabel()
        recentStatusLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        recentStatusLbL?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(recentStatusLbL!)
        recentStatusLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nickNameLbl!)
            make.bottom.equalTo(avatarImg!)
            make.height.equalTo(17)
        })
        //
        let rightArrowImg = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        superview.addSubview(rightArrowImg)
        rightArrowImg.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(9, 15))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview .addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(0.5)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
        }
    }
    
    func selectBtnPressed() {
        if let handler = onSelect {
            handler(sender: selectBtn!)
        }else{
            assertionFailure()
        }
        selectBtn?.selected = !selectBtn!.selected
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
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(self.contentView)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
