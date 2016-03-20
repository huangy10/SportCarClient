//
//  InlineUserSelect.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

protocol InlineUserSelectDelegate: class {
    func inlineUserSelectNeedAddMembers()
}

class InlineUserSelectController: UICollectionViewController {
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let screenWidth = UIScreen.mainScreen().bounds.width
        layout.itemSize = CGSizeMake(screenWidth / 4, screenWidth / 4)
        self.init(collectionViewLayout: layout)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    weak var delegate: InlineUserSelectDelegate?
    // 显示的用户列表
    var users: [User] = []
    var relatedClub: Club?
    // 是否显示删除按钮---注：添加按钮总是显示
    var showDeleteBtn: Bool = false
    var showAddBtn: Bool = true
    // 最大可以显示的用户的数量，设置为0表示没有限制
    var maxUserNum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(InlineUserSelectBtnCell.self, forCellWithReuseIdentifier: InlineUserSelectBtnCell.reuseIdentifier)
        collectionView?.registerClass(InlineUserSelectCell.self, forCellWithReuseIdentifier: InlineUserSelectCell.reuseIdentifier)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showDeleteBtn && showAddBtn {
            return users.count + 2
        }else if showAddBtn{
            return users.count + 1
        }
        return users.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < users.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectCell
            let user = users[indexPath.row]
            if relatedClub != nil && relatedClub?.host?.userID == user.userID {
                cell.nameLbl.textColor = kHighlightedRedTextColor
            }else {
                cell.nameLbl.textColor = UIColor.blackColor()
            }
            cell.avatarImg.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
            if let carURL = user.profile?.avatarCarLogo {
                cell.avatarCarLogo.kf_setImageWithURL(SFURL(carURL)!)
            }else {
                cell.avatarCarLogo.image = nil
            }
            var userNickName = user.remarkName ?? user.nickName!
            if userNickName.length > 5 {
                userNickName = userNickName[0..<5]
            }
            cell.nameLbl.text = userNickName
            return cell
        }else if indexPath.row == users.count{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectBtnCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectBtnCell
            cell.type = "add"
            return cell
        }else{
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectBtnCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectBtnCell
            cell.type = "remove"
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == users.count {
            delegate?.inlineUserSelectNeedAddMembers()
        }
    }
}

class InlineUserSelectBtnCell: UICollectionViewCell  {
    static let reuseIdentifier = "inline_user_select_btn_cell"
    
    let btnSizeRatio: CGFloat = 0.7
    
    var btnImage: UIImageView!
    
    var type: String = "add" {
        didSet {
            if type == "add" {
                btnImage.image = UIImage(named: "chat_settings_add_person")
            }else{
                btnImage.image = UIImage(named: "auth_remove_item_btn")
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        btnImage = UIImageView(image: UIImage(named: "chat_settings_add_person"))
        self.contentView.addSubview(btnImage)
        btnImage.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.width.equalTo(self.contentView).multipliedBy(btnSizeRatio)
            make.height.equalTo(btnImage.snp_width)
        }
    }
}

class InlineUserSelectCell: UICollectionViewCell {
    static let reuseIdentifier = "inline_user_select_cell"

    let avatarSizeRatio: CGFloat = 0.7
    let avatarCarLogoSizeRatio: CGFloat = 0.38
    
    var avatarImg: UIImageView!
    var avatarCarLogo: UIImageView!
    var nameLbl: UILabel!
    
    var user: User? {
        didSet {
            if user == nil {
                return
            }
            avatarImg.kf_setImageWithURL(SFURL(user!.avatarUrl!)!)
            if let avatarCarURLStr = user?.profile?.avatarCarLogo {
                avatarCarLogo.hidden = false
                avatarCarLogo.kf_setImageWithURL(SFURL(avatarCarURLStr)!)
            }else{
                avatarCarLogo.hidden = true
            }
            let name = user?.nickName
            if name!.length > 5{
                nameLbl.text = name![0..<6]
            }else{
                nameLbl.text = name
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.whiteColor()
        //
        avatarImg = UIImageView()
        superview.addSubview(avatarImg)
        avatarImg.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(superview)
            make.width.equalTo(superview).multipliedBy(avatarSizeRatio)
            make.height.equalTo(avatarImg.snp_width)
        }
        //
        avatarCarLogo = UIImageView()
        superview.addSubview(avatarCarLogo)
        avatarCarLogo.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(avatarImg)
            make.bottom.equalTo(avatarImg)
            make.width.equalTo(avatarImg).multipliedBy(avatarCarLogoSizeRatio)
            make.height.equalTo(avatarCarLogo.snp_width)
        }
        avatarImg.layer.cornerRadius = superview.frame.width * avatarSizeRatio / 2
        avatarImg.clipsToBounds = true
        avatarCarLogo.layer.cornerRadius = superview.frame.width * avatarSizeRatio / 2 * avatarCarLogoSizeRatio
        avatarCarLogo.clipsToBounds = true
        //
        nameLbl = UILabel()
        nameLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        nameLbl.textColor = UIColor.blackColor()
        nameLbl.textAlignment = .Center
        superview.addSubview(nameLbl)
        nameLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(avatarImg)
            make.top.equalTo(avatarImg.snp_bottom).offset(8)
        }
    }
}
