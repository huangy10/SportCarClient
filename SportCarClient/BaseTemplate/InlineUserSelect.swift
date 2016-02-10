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
    
    // 显示的用户列表
    var users: [User] = []
    var relatedClub: Club?
    // 是否显示删除按钮---注：添加按钮总是显示
    var showDeleteBtn: Bool = false
    // 最大可以显示的用户的数量，设置为0表示没有限制
    var maxUserNum: Int = 0
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectCell
        let user = users[indexPath.row]
        if relatedClub != nil && relatedClub?.host?.userID == user.userID {
            cell.nameLbl.textColor = kHighlightedRedTextColor
        }else {
            cell.nameLbl.textColor = UIColor.blackColor()
        }
        cell.avatarImg.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
        if let carURL = user.avatarCar?.logo {
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
    }
}

class InlineUserSelectCell: UICollectionViewCell {
    static let reuseIdentifier = "inline_user_select_cell"

    let avatarSizeRatio = 0.7
    let avatarCarLogoSizeRatio = 0.38
    
    var avatarImg: UIImageView!
    var avatarCarLogo: UIImageView!
    var nameLbl: UILabel!
    
    var user: User? {
        didSet {
            if user == nil {
                return
            }
            avatarImg.kf_setImageWithURL(SFURL(user!.avatarUrl!)!)
            if let avatarCarURLStr = user?.avatarCar?.logo {
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
            make.center.equalTo(superview)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImg.layer.cornerRadius = avatarImg.frame.size.width / 2
        avatarCarLogo.layer.cornerRadius = avatarCarLogo.frame.size.width / 2
    }
}
