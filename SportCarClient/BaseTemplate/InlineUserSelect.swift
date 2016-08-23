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
    
    func inlineUserSelectShouldDeleteUser(user: User)
}

class InlineUserSelectController: UICollectionViewController {
    
    weak var parentController: UIViewController?
    
    var showAllMembersBtn: UIButton!
    
    let maxDispalyNum: Int = 12
    
    var showClubName: Bool = true {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let screenWidth = UIScreen.mainScreen().bounds.width
        layout.itemSize = CGSizeMake(screenWidth / 4, screenWidth / 4)
        self.init(collectionViewLayout: layout)
        
        collectionView?.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    weak var delegate: InlineUserSelectDelegate?
    // 显示的用户列表
    var users: [User] = [] {
        didSet {
            if users.count >= maxDispalyNum {
                showAllMembersBtn.hidden = false
            } else {
                showAllMembersBtn.hidden = true
            }
        }
    }
    var relatedClub: Club?
    // 是否显示删除按钮---注：添加按钮总是显示
    var showDeleteBtn: Bool = false
    var showAddBtn: Bool = true
    // 最大可以显示的用户的数量，设置为0表示没有限制
    var maxUserNum: Int = 0
    
    override func loadView() {
        super.loadView()
        configureShowAllMembersBtn()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.registerClass(InlineUserSelectBtnCell.self, forCellWithReuseIdentifier: InlineUserSelectBtnCell.reuseIdentifier)
        collectionView?.registerClass(InlineUserSelectCell.self, forCellWithReuseIdentifier: InlineUserSelectCell.reuseIdentifier)
    }
    
    class func preferedHeightFor(userNum: Int, showAddBtn: Bool, showDeleteBtn: Bool) -> CGFloat {
        let cellHeight = UIScreen.mainScreen().bounds.width / 4
        let cellNum = userNum + (showAddBtn ? 1 : 0) + (showDeleteBtn ? 1 : 0)
        let height = CGFloat((cellNum - 1) / 4 + 1) * cellHeight + 15
        return height
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
            if relatedClub != nil && relatedClub?.founderUser?.ssid == user.ssid {
                cell.nameLbl.textColor = kHighlightedRedTextColor
            } else {
                cell.nameLbl.textColor = UIColor.blackColor()
            }
            cell.avatarImg.kf_setImageWithURL(user.avatarURL!)
            if let carURL = user.avatarCarModel?.logoURL {
                cell.avatarCarLogo.kf_setImageWithURL(carURL)
            } else {
                cell.avatarCarLogo.image = nil
            }
            var userNickName = showClubName ? user.clubNickName : user.nickName!
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
        } else if indexPath.row < users.count{
            let user = users[indexPath.row]
            if user.isHost {
                let detail = PersonBasicController(user: user)
                parentController?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = PersonOtherController(user: user)
                parentController?.navigationController?.pushViewController(detail, animated: true)
            }
        }
    }
    
    // MARK: - 全部成员按钮
    
    func configureShowAllMembersBtn() {
        showAllMembersBtn = self.view.addSubview(UIButton)
            .config(self, selector: #selector(showAllMembersBtnPressed), title: LS("全部成员"), titleColor: kHighlightRed, titleSize: 14, titleWeight: UIFontWeightUltraLight)
            .layout({ (make) in
                make.right.equalTo(self.view).offset(-15)
                make.bottom.equalTo(self.view)
                make.size.equalTo(CGSizeMake(100, 44))
            })
        showAllMembersBtn.hidden = true
    }
    
    func showAllMembersBtnPressed() {
        let membersList = ClubMembersController()
        membersList.targetClub = relatedClub!
        parentController?.navigationController?.pushViewController(membersList, animated: true)
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
            avatarImg.kf_setImageWithURL(user!.avatarURL!)
            if let avatarCarURL = user?.avatarCarModel?.logoURL {
                avatarCarLogo.hidden = false
                avatarCarLogo.kf_setImageWithURL(avatarCarURL)
            } else {
                avatarCarLogo.hidden = true
                avatarCarLogo.image = nil
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
