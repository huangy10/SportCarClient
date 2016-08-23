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
        if relatedClub != nil && relatedClub?.founderUser?.ssid == user.ssid {
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
        cell.avatarImg.kf_setImageWithURL(user.avatarURL!)
        if let carURL = user.avatarCarModel?.logoURL {
            cell.avatarCarLogo.kf_setImageWithURL(carURL)
        } else {
            cell.avatarCarLogo.image = nil
        }
        let userNickName = showClubName ? user.clubNickName : user.nickName!
        cell.nameLbl.text = userNickName
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == users.count + 1 {
            showCellDeleteBtn = !showCellDeleteBtn
            collectionView.reloadData()
        } else if indexPath.row == users.count {
            delegate?.inlineUserSelectNeedAddMembers()
        } else {
            let user = users[indexPath.row]
            if user.isHost {
                let detail = PersonBasicController(user: user)
                parentController?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = PersonOtherController(user: user)
                parentController?.navigationController?.pushViewController(detail, animated: false)
            }
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
        deleteBtn.addTarget(self, action: #selector(InlineUserSelectDeletableCell.deleteBtnPressed), forControlEvents: .TouchUpInside)
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
