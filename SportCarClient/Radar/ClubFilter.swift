//
//  ClubFilter.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/7.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ClubFilterController: RadarFilterController {
    
    var dirty = false
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RadarFilterCell
        cell.titleLbl.text = [LS("附近"), LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多"), LS("新近成立")][indexPath.row]
        cell.marker.hidden = selectedRow != indexPath.row
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! RadarFilterHeader
        header.titleLbl.text = [LS("附近"), LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多"), LS("新近成立")][selectedRow]
        return header
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if selectedRow != indexPath.row {
            dirty = true
        }
        selectedRow = indexPath.row
        self.tableView.reloadData()
        delegate?.radarFilterDidChange()
    }
}