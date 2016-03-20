//
//  RadarClubFilter.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol RadarClubFilterDelegate: class {
    func radarClubFilterDidChange(controller: RadarClubFilterController)
}


class RadarClubFilterController: UITableViewController {
    weak var delegate: RadarClubFilterDelegate?
    
    var clubs: [Club] = []
    var selectdClubID: String?
    var selectdClub: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.layer.cornerRadius = 4
        tableView.registerClass(RadarClubFilterHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.registerClass(RadarFilterCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 42
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        self.getClubList()
    }
    
    func getClubList() {
        let requester = ChatRequester.requester
        requester.getClubList({ (json) -> () in
            for data in json!.arrayValue {
                let club = Club.objects.getOrCreate(data["club"])
                self.clubs.append(club)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let club = clubs[indexPath.row]
        if club.clubID != selectdClubID {
            selectdClubID = club.clubID
            delegate?.radarClubFilterDidChange(self)
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RadarFilterCell
        cell.titleLbl.text = clubs[indexPath.row].name
        cell.marker.hidden = clubs[indexPath.row].clubID != selectdClubID
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! RadarClubFilterHeader
        header.titleLbl.text = LS("返回")
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
}


class RadarClubFilterHeader: RadarFilterHeader {
    
    override func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        //
        marker = UIImageView(image: UIImage(named: "account_header_back_btn"))
        superview.addSubview(marker)
        marker.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(6, 13))
            make.left.equalTo(superview).offset(25)
        }
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        titleLbl.textColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(superview)
        }
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.27, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.height.equalTo(1)
            make.bottom.equalTo(superview)
        }
    }
    
}