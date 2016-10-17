//
//  PersonOtherInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonOtherInfoController: PersonMineInfoController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath as NSIndexPath).section {
        case 0:
            return tableView.ss_reuseablePropertyCell(SSAvatarCell.self, forIndexPath: indexPath)
                .setData(user.avatarURL!, zoomable: true)
        case 1:
            let rawCell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            switch (indexPath as NSIndexPath).row {
            case 0:
                return rawCell.setData(LS("昵称"), propertyValue: user.nickName, editable: false)
            case 1:
                return rawCell.setData(
                    LS("签名车"),
                    propertyValue: user.avatarCarModel?.name,
                    propertyImageURL: user.avatarCarModel?.logoURL,
                    propertyEmptyPlaceHolder: LS("无签名车"),
                    editable: false)
            case 2:
                return rawCell.setData(
                    LS("签名俱乐部"),
                    propertyValue: user.avatarClubModel?.name,
                    propertyImageURL: user.avatarClubModel?.logoURL,
                    propertyEmptyPlaceHolder: LS("无签名俱乐部"),
                    editable: false
                )
            case 3:
                return rawCell.setData(LS("性别"), propertyValue: user.gender, editable: false)
            default:
                return rawCell.setData(LS("年龄"), propertyValue: "\(user.age)", editable: false)
            }
        default:
            let rawCell = tableView.ss_reuseablePropertyCell(SSPropertyCell.self, forIndexPath: indexPath)
            switch (indexPath as NSIndexPath).row {
            case 0:
                return rawCell.setData(LS("星座"), propertyValue: user.starSign, editable: false)
            case 1:
                return rawCell.setData(LS("职业"), propertyValue: user.job, editable: false)
            case 2:
                return rawCell.setData(LS("活跃地区"), propertyValue: user.district, editable: false)
            default:
                return rawCell.setData(LS("个性签名"), propertyValue: trancate(userSignature: user.signature!), editable: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            switch (indexPath as NSIndexPath).row {
            case 0:
                break
            case 2:
                if let club = user.avatarClubModel {
                    let detail = ClubBriefInfoController() 
                    detail.targetClub = club
                    self.navigationController?.pushViewController(detail, animated: true)
                }
                break
            default:
                break
            }
        }
    }
}
