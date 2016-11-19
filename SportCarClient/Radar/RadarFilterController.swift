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
    var selectedClubID: Int32?
    
    var expanded: Bool = false
    
    var marker: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 4
        tableView.register(RadarFilterHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(RadarFilterCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 40
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.white
    }
    
    let titles = [LS("附近热门"), LS("我关注的"), LS("我的粉丝"), LS("互相关注"), LS("仅男性"), LS("仅女性"), LS("仅认证车主"), LS("群组")]
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RadarFilterCell
        cell.titleLbl.text = titles[indexPath.row]
        cell.marker.isHidden = selectedRow != (indexPath as NSIndexPath).row
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! RadarFilterHeader
        marker = header.marker
        if selectedRow < 7 {
            header.titleLbl.text = titles[selectedRow]
        }else {
            header.titleLbl.text = selectedClub
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 7 {
            let detail = RadarClubFilterController()
            detail.selectdClubID = self.selectedClubID
            detail.selectdClub = self.selectedClub
            detail.delegate = self
            selectedRow = indexPath.row
            self.navigationController?.pushViewController(detail, animated: true)
            return
        }
        
        if indexPath.row != selectedRow {
            selectedRow = (indexPath as NSIndexPath).row
            tableView.reloadData()
            delegate?.radarFilterDidChange()
        }
    }
    
    func radarClubFilterDidChange(_ controller: RadarClubFilterController) {
        selectedClub = controller.selectdClub
        selectedClubID = controller.selectdClubID
        _ = self.navigationController?.popViewController(animated: true)
        tableView.reloadData()
        delegate?.radarFilterDidChange()
    }
    
    func getFitlerTypeString() -> String {
        return ["distance", "follows", "fans", "friends", "club"][selectedRow]
    }
    
    func getFilterParam() -> [String: AnyObject]? {
        if let selectedClubID = selectedClubID , selectedRow == 4 {
            return ["club_id": "\(selectedClubID)" as AnyObject]
        } else {
            return nil
        }
    }
}

class RadarFilterCell: UITableViewCell {
    var titleLbl: UILabel!
    var marker: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.clear
        superview.backgroundColor = UIColor.clear
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        titleLbl.textColor = UIColor(white: 0, alpha: 0.87)
        superview.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(10)
            make.centerY.equalTo(superview)
        }
        //
        marker = UIImageView(image: UIImage(named: "hook"))
        superview.addSubview(marker)
        marker.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-10)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSize(width: 17, height: 12))
        }
        marker.isHidden = true
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
        superview.backgroundColor = UIColor.white
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        titleLbl.textColor = UIColor(white: 0, alpha: 0.87)
        superview.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.centerY.equalTo(superview)
        }
        let markerContainer = superview.addSubview(UIView.self)
            .layout { (make) in
                make.right.equalTo(superview).offset(-20)
                make.centerY.equalTo(superview)
                make.size.equalTo(CGSize(width: 13, height: 8))
        }
        //
        marker = markerContainer.addSubview(UIImageView.self).config(UIImage(named: "up_arrow"))
            .setFrame(CGRect(x: 0, y: 0, width: 13, height: 8))
//        marker = UIImageView(image: UIImage(named: "down_arrow"))
//        superview.addSubview(marker)
//        marker.snp.makeConstraints { (make) -> Void in
//            make.right.equalTo(superview).offset(-20)
//            make.centerY.equalTo(superview)
//            make.size.equalTo(CGSizeMake(13, 8))
//        }
        //
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
