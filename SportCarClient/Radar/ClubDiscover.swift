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

class ClubDiscoverController: UIViewController, UITableViewDataSource, UITableViewDelegate, ClubBubbleViewDelegate, RadarFilterDelegate {
    
    weak var radarHome: RadarHomeController?
    
    var clubs: [Club] = []
    
    var clubList: UITableView!
    var clubFilter: ClubFilterController!
    var clubWrapper: BlackBarNavigationController!
    var clubFilterView: UIView!
    
    deinit {
//        bubbles.endUpdate()
        print("deinit club discover")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubviews()

        let requester = ClubRequester.sharedInstance
        requester.discoverClub("nearby", skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
            }) { (code) -> () in
                
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func createSubviews() {
        let superview = self.view
        superview.clipsToBounds = true

//        bubbles = ClubBubbleView()
//        bubbles.delegate = self
//        superview.addSubview(bubbles)
//        bubbles.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(superview).offset(100)
//            make.height.equalTo(250)
//        }

        clubList = UITableView(frame: CGRectZero, style: .Plain)
        clubList.separatorStyle = .None
        clubList.rowHeight = 90
        clubList.delegate = self
        clubList.dataSource = self
        self.view.addSubview(clubList)
        clubList.snp_makeConstraints { (make) -> Void in
//            make.right.equalTo(self.view)
//            make.left.equalTo(self.view)
//            make.height.equalTo(self.view.frame.height - 250)
//            make.top.equalTo(self.view.snp_bottom)
            make.edges.equalTo(superview)
        }
        clubList.registerClass(ClubDiscoverCell.self, forCellReuseIdentifier: "cell")
//        shadowLine = UIView()
//        shadowLine.backgroundColor = UIColor.whiteColor()
//        shadowLine.clipsToBounds = false
//        shadowLine.layer.shadowRadius = 3
//        shadowLine.layer.shadowOpacity = 0.1
//        shadowLine.layer.shadowColor = UIColor.blackColor().CGColor
//        shadowLine.layer.shadowOffset = CGSizeMake(0, -2)
//        superview.addSubview(shadowLine)
//        shadowLine.snp_makeConstraints { (make) -> Void in
//            make.edges.equalTo(clubList)
//        }
//        superview.sendSubviewToBack(shadowLine)
        //
//        showClubListBtn = self.view.addSubview(UIButton.self)
//            .config(kBarBgColor)
//            .config(self, selector: #selector(showClubBtnPressed))
//            .toRound(20)
//            .addShadow().layout({ (make) in
//                make.bottom.equalTo(clubList.snp_top).offset(-25)
//                make.right.equalTo(self.view).offset(-20)
//                make.size.equalTo(40)
//            })
//        showClubListBtn.addSubview(UIImageView)
//            .config(UIImage(named: "view_list"), contentMode: .ScaleAspectFit)
//            .layout { (make) in
//                make.center.equalTo(showClubListBtn)
//                make.size.equalTo(showClubListBtn).dividedBy(2)
//        }
//
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
    }
//    
//    func showClubBtnPressed() {
//        if showClubListBtn.tag == 0 {
//            clubList.snp_remakeConstraints { (make) -> Void in
//                make.right.equalTo(self.view)
//                make.left.equalTo(self.view)
//                make.height.equalTo(self.view.frame.height - 250)
//                make.bottom.equalTo(self.view.snp_bottom)
//            }
//            bubbles.snp_updateConstraints(closure: { (make) -> Void in
//                make.top.equalTo(self.view).offset(0)
//            })
//            SpringAnimation.spring(0.6, animations: { () -> Void in
//                self.view.layoutIfNeeded()
//            })
//            clubList.reloadData()
//            showClubListBtn.tag = 1
//        }else {
//            clubList.snp_remakeConstraints { (make) -> Void in
//                make.right.equalTo(self.view)
//                make.left.equalTo(self.view)
//                make.height.equalTo(self.view.frame.height - 250)
//                make.top.equalTo(self.view.snp_bottom)
//            }
//            bubbles.snp_updateConstraints(closure: { (make) -> Void in
//                make.top.equalTo(self.view).offset(100)
//            })
//            SpringAnimation.spring(0.6, animations: { () -> Void in
//                self.view.layoutIfNeeded()
//            })
//            showClubListBtn.tag = 0
//        }
//    }
    
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
            detail.targetClub = clubs[indexPath.row]
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
            }
        }
        clubFilter.expanded = !clubFilter.expanded
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
        
        if !clubFilter.dirty {
            return
        }
        let requester = ClubRequester.sharedInstance
        let opType = ["nearby", "value", "average", "members", "beauty", "recent"][clubFilter.selectedRow]
        requester.discoverClub(opType, skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
            }) { (code) -> () in
                
        }
    }
}
