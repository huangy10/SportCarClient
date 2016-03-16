//
//  PersonOtherInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonOtherInfoController: PersonMineInfoController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(PrivateChatSettingsAvatarCell.reuseIdentifier, forIndexPath: indexPath) as! PrivateChatSettingsAvatarCell
            cell.avatarImage.kf_setImageWithURL(SFURL(user.avatarUrl!)!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                if error == nil {
                    cell.avatarImage.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
                }
            })
            return cell
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                break
            case 2:
                if let clubID = user.profile?.avatarClubID {
                    let club = Club.objects.getOrLoad(clubID)
                    club?.logo_url = user.profile?.avatarClubLogo
                    club?.name = user.profile?.avatarClubName
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
