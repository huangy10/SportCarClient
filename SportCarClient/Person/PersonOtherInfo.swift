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
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                let commentCell = cell as! PersonMineInfoCell
                commentCell.staticLbl.text = LS("备注")
                commentCell.infoLbl.text = user.remarkName ?? user.nickName
                break
            default:
                break
            }
            break
        default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
