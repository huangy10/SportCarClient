//
//  RadarClubFilter.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol RadarClubFilterDelegate: class {
    func radarClubFilterDidChange(_ controller: RadarClubFilterController)
}


class RadarClubFilterController: UITableViewController {
    weak var delegate: RadarClubFilterDelegate?
    
    var clubs: [Club] = []
    var selectdClubID: Int32?
    var selectdClub: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 4
        tableView.register(RadarClubFilterHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(RadarFilterCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 42
        tableView.backgroundColor = UIColor.white
        self.getClubList()
    }
    
    func getClubList() {
        let requester = ClubRequester.sharedInstance
        _ = requester.getClubList({ (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data["club"])
                self.clubs.append(club)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let club = clubs[(indexPath as NSIndexPath).row]
        if club.ssid != selectdClubID {
            selectdClubID = club.ssid
            selectdClub = club.name
            delegate?.radarClubFilterDidChange(self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RadarFilterCell
        cell.titleLbl.text = clubs[(indexPath as NSIndexPath).row].name
        cell.marker.isHidden = clubs[(indexPath as NSIndexPath).row].ssid != selectdClubID
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! RadarClubFilterHeader
        header.titleLbl.text = LS("返回")
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
}


class RadarClubFilterHeader: RadarFilterHeader {
    
    override func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor.white
        //
        marker = UIImageView(image: UIImage(named: "account_header_back_btn"))
        superview.addSubview(marker)
        marker.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSize(width: 6, height: 13))
            make.left.equalTo(superview).offset(25)
        }
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        titleLbl.textColor = UIColor(white: 0, alpha: 0.87)
        superview.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(superview)
        }
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0, alpha: 0.12)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(10)
            make.right.equalTo(superview).offset(-10)
            make.height.equalTo(1)
            make.bottom.equalTo(superview)
        }
    }
    
}
