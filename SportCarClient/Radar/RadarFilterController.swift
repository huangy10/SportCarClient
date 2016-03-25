//
//  RadarFilterController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/28.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol RadarFilterDelegate: class {
    func radarFilterDidChange()
}


class RadarFilterController: UITableViewController, RadarClubFilterDelegate {
    
    weak var delegate: RadarFilterDelegate?
    
    var selectedRow: Int = 0
    var selectedClub: String?
    var selectedClubID: String?
    
    var expanded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.separatorStyle = .None
        tableView.layer.cornerRadius = 4
        tableView.registerClass(RadarFilterHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.registerClass(RadarFilterCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 42
        tableView.scrollEnabled = false
        tableView.backgroundColor = kBarBgColor
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! RadarFilterCell
        cell.titleLbl.text = [LS("附近热门"), LS("我关注的"), LS("我的粉丝"), LS("互相关注"), LS("群组")][indexPath.row]
        cell.marker.hidden = selectedRow != indexPath.row
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! RadarFilterHeader
        if selectedRow < 4 {
            header.titleLbl.text = [LS("附近热门"), LS("我关注的"), LS("我的粉丝"), LS("互相关注")][selectedRow]
        }else {
            header.titleLbl.text = selectedClub
        }
        return header
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 42
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            let detail = RadarClubFilterController()
            detail.selectdClubID = self.selectedClubID
            detail.selectdClub = self.selectedClub
            detail.delegate = self
            selectedRow = 5
            self.navigationController?.pushViewController(detail, animated: true)
            return
        }
        
        if indexPath.row != selectedRow {
            selectedRow = indexPath.row
            tableView.reloadData()
            delegate?.radarFilterDidChange()
        }
    }
    
    func radarClubFilterDidChange(controller: RadarClubFilterController) {
        selectedClub = controller.selectdClub
        selectedClubID = controller.selectdClubID
        self.navigationController?.popViewControllerAnimated(true)
        delegate?.radarFilterDidChange()
    }
}

class RadarFilterCell: UITableViewCell {
    var titleLbl: UILabel!
    var marker: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.clearColor()
        superview.backgroundColor = UIColor.clearColor()
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        titleLbl.textColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(10)
            make.centerY.equalTo(superview)
        }
        //
        marker = UIImageView(image: UIImage(named: "hook"))
        superview.addSubview(marker)
        marker.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-10)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(17, 12))
        }
        marker.hidden = true
    }
}

class RadarFilterHeader: UITableViewHeaderFooterView {
    var titleLbl: UILabel!
    var marker: UIImageView!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = kBarBgColor
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        titleLbl.textColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.centerY.equalTo(superview)
        }
        //
        marker = UIImageView(image: UIImage(named: "down_arrow"))
        superview.addSubview(marker)
        marker.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-20)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSizeMake(13, 8))
        }
        //
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
