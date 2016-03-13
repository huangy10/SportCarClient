//
//  InlineUserDeletable.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/8.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

//protocol InlineUserSelectDeletableDelegate: InlineUserSelectDelegate {
//    
//    /**
//     When delete button is pressed
//     */
//    func inlineUserSelectShouldDeleteUser(user: User)
//}

extension InlineUserSelectDelegate {
    func inlineUserSelectShouldDeleteUser(user: User) {}
}


class InlineUserSelectDeletable: InlineUserSelectController {
    
    var showCellDeleteBtn: Bool = false
    /**
     Register cells here
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClass(InlineUserSelectDeletableCell.self, forCellWithReuseIdentifier: "deletable_cell")
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row >= users.count {
            return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("deletable_cell", forIndexPath: indexPath) as! InlineUserSelectDeletableCell
        let user = users[indexPath.row]
        if relatedClub != nil && relatedClub?.host?.userID == user.userID {
            // Owner of this club/group chat
            cell.nameLbl.textColor = kHighlightedRedTextColor
            cell.showDeleteBtn = false
        } else {
            // Normal members
            cell.nameLbl.textColor = UIColor.blackColor()
            cell.showDeleteBtn = showCellDeleteBtn
            cell.onDeletion = { () -> () in
                self.delegate?.inlineUserSelectShouldDeleteUser(user)
            }
        }
        cell.avatarImg.kf_setImageWithURL(SFURL(user.avatarUrl!)!)
        if let carURL = user.profile?.avatarCarLogo {
            cell.avatarCarLogo.kf_setImageWithURL(SFURL(carURL)!)
        } else {
            cell.avatarCarLogo.image = nil
        }
        let userNickName = user.remarkName ?? user.nickName!
        cell.nameLbl.text = userNickName
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == users.count + 1 {
            showCellDeleteBtn = !showCellDeleteBtn
            collectionView.reloadData()
        } else if indexPath.row == users.count {
            delegate?.inlineUserSelectNeedAddMembers()
        }
    }
}


class InlineUserSelectDeletableCell: InlineUserSelectCell {
    // Button on the upper left of the avatar which
    var deleteBtn: UIButton!
    var showDeleteBtn: Bool = true {
        didSet {
            deleteBtn.hidden = !showDeleteBtn
        }
    }
    
    var onDeletion: (()->())?
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.contentView
        
        deleteBtn = UIButton()
        deleteBtn.setImage(UIImage(named: "status_delete_image_btn"), forState: .Normal)
        deleteBtn.addTarget(self, action: "deleteBtnPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(deleteBtn)
        deleteBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(avatarImg)
            make.top.equalTo(avatarImg)
            make.size.equalTo(25)
        }
    }
    
    func deleteBtnPressed() {
        if onDeletion == nil {
            assertionFailure("Delete event not handled")
        }
        
        onDeletion!()
    }
}
