//
//  ClubDiscover.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/6.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Spring
import SnapKit
import Dollar

class ClubDiscoverController: UIViewController, UITableViewDataSource, UITableViewDelegate, ClubBubbleViewDelegate, RadarFilterDelegate, CityElementSelectDelegate {
    
    weak var radarHome: RadarHomeController?
    
    var clubs: [Club] = []
    
    var clubList: UITableView!
    var clubFilter: ClubFilterController!
    var clubWrapper: BlackBarNavigationController!
    var clubFilterView: UIView!
    
    var cityFilter: UIButton!
    var cityFilterLbl: UILabel!
    
    var clubFilterType: String = "nearby"
    var cityFilterType: String = "全国"
    
    deinit {
        print("deinit club discover")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubviews()

        let requester = ClubRequester.sharedInstance
        requester.discoverClub("nearby", cityLimit: "全国", skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            print(json!)
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        clubList.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func createSubviews() {
        let superview = self.view
        superview.clipsToBounds = true

        clubList = UITableView(frame: CGRectZero, style: .Plain)
        clubList.separatorStyle = .None
        clubList.rowHeight = 90
        clubList.delegate = self
        clubList.dataSource = self
        self.view.addSubview(clubList)
        clubList.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        clubList.registerClass(ClubDiscoverCell.self, forCellReuseIdentifier: "cell")

        clubFilter = ClubFilterController()
        clubFilter.selectedRow = 0
        clubFilter.delegate = self
        clubWrapper = clubFilter.toNavWrapper()
        self.view.addSubview(clubWrapper.view)
        
        clubFilter.view.toRound(20)
        clubFilterView = clubWrapper.view.addShadow().layout({ (make) in
            make.bottom.equalTo(superview).offset(-25)
            make.right.equalTo(superview).offset(-20)
            make.size.equalTo(CGSizeMake(115, 40))
        })
        self.view.addSubview(UIButton.self).config(self, selector: #selector(toggleMapFilter))
            .layout { (make) in
                make.top.equalTo(clubFilterView)
                make.left.equalTo(clubFilterView)
                make.size.equalTo(CGSizeMake(115, 40))
        }
        
        cityFilter = self.view.addSubview(UIButton)
            .config(self, selector: #selector(cityFilterPressed))
            .config(UIColor.whiteColor())
            .toRound(20).addShadow()
            .layout({ (make) in
                make.right.equalTo(clubFilterView.snp_left).offset(-10)
                make.bottom.equalTo(clubFilterView)
                make.size.equalTo(CGSizeMake(120, 40))
            })
        let icon = cityFilter.addSubview(UIImageView)
            .config(UIImage(named: "up_arrow"))
            .layout { (make) in
                make.centerY.equalTo(cityFilter)
                make.right.equalTo(cityFilter).offset(-20)
                make.size.equalTo(CGSizeMake(13, 9))
        }
        cityFilterLbl = cityFilter.addSubview(UILabel)
            .config(14, textColor: UIColor(white: 0, alpha: 0.87), text: LS("全国"))
            .layout({ (make) in
                make.left.equalTo(cityFilter).offset(20)
                make.right.equalTo(icon.snp_left).offset(-10)
                make.centerY.equalTo(cityFilter)
            })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ClubDiscoverCell
        cell.club = clubs[indexPath.row]
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let club = clubs[indexPath.row]
        if club.attended {
            if club.founderUser!.isHost {
                let detail = GroupChatSettingHostController(targetClub: club)
                radarHome?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = GroupChatSettingController(targetClub: club)
                radarHome?.navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            let detail = ClubBriefInfoController()
            detail.targetClub = club
            radarHome?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func clubBubbleDidClickOn(club: Club) {
        if club.attended {
            if club.founderUser!.isHost {
                let detail = GroupChatSettingHostController(targetClub: club)
                radarHome?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = GroupChatSettingController(targetClub: club)
                radarHome?.navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            let detail = ClubBriefInfoController()
            detail.targetClub = club
            radarHome?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func toggleMapFilter() {
        
        if clubFilter.expanded {
            clubFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSizeMake(115, 40))
            })
            UIView.animateWithDuration(0.3) { () -> Void in
                self.clubFilter.view.toRound(20)
                self.view.layoutIfNeeded()
                self.clubFilter.marker.transform = CGAffineTransformIdentity
            }
        }else {
            clubFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.bottom.equalTo(self.view).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSizeMake(115, 40 * 7))
            })
            UIView.animateWithDuration(0.3) { () -> Void in
                self.clubFilter.view.toRound(5)
                self.view.layoutIfNeeded()
                self.clubFilter.marker.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
        }
        clubFilter.expanded = !clubFilter.expanded
    }
    
    func sendRequest() {
        let opType = ["nearby", "value", "average", "members", "beauty", "recent"][clubFilter.selectedRow]
        ClubRequester.sharedInstance.discoverClub(opType, cityLimit: self.cityFilterType, skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
    
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
        }) { (code) -> () in
            print(code)
        }
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
        
        if !clubFilter.dirty {
            return
        }
        self.clubs.removeAll()
        sendRequest()
    }
    
    func cityFilterPressed() {
        let select = CityElementSelectController()
        select.maxLevel = 0
        select.showAllContry = true
        select.delegate = self
        self.radarHome?.presentViewController(select.toNavWrapper(), animated: true, completion: nil)
    }
    
    // MARK: City Element Select
    
    func cityElementSelectDidSelect(dataSource: CityElementSelectDataSource) {
        self.radarHome?.dismissViewControllerAnimated(true, completion: nil)
        cityFilterType = dataSource.selectedProv ?? "全国"
        cityFilterLbl.text = cityFilterType
        sendRequest()
    }
    
    func cityElementSelectDidCancel() {
        self.radarHome?.dismissViewControllerAnimated(true, completion: nil)
    }
}
