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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RadarFilterCell
        cell.titleLbl.text = [LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多"), LS("新近成立")][(indexPath as NSIndexPath).row]
        cell.marker.isHidden = selectedRow != (indexPath as NSIndexPath).row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! RadarFilterHeader
        marker = header.marker
        header.titleLbl.text = [LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多"), LS("新近成立")][selectedRow]
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRow != (indexPath as NSIndexPath).row {
            dirty = true
        }
        selectedRow = (indexPath as NSIndexPath).row
        self.tableView.reloadData()
        delegate?.radarFilterDidChange()
    }
}


class ClubFilterForBillboardController: ClubFilterController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RadarFilterCell
        cell.titleLbl.text = [LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多")][(indexPath as NSIndexPath).row]
        cell.marker.isHidden = selectedRow != (indexPath as NSIndexPath).row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! RadarFilterHeader
        marker = header.marker
        header.titleLbl.text = [LS("总价最高"), LS("均价最高"), LS("成员最多"), LS("美女最多")][selectedRow]
        return header
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedRow != (indexPath as NSIndexPath).row {
            dirty = true
        }
        selectedRow = (indexPath as NSIndexPath).row
        tableView.reloadData()
        delegate?.radarFilterDidChange()
    }
}
