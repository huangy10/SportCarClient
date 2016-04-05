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

class ClubDiscoverController: UIViewController, UITableViewDataSource, UITableViewDelegate, ClubBubbleViewDelegate, RadarFilterDelegate {
    
    weak var radarHome: RadarHomeController?
    
    var bubbles: ClubBubbleView!
    var clubs: [Club] = []
    
    var clubList: UITableView!
    var clubFilter: ClubFilterController!
    var clubWrapper: BlackBarNavigationController!
    var clubFilterView: UIView!
    var showClubListBtn: UIButton!
    var showClubListBtnIcon: UIImageView!
    var shadowLine: UIView!
    
    var firstShow = false
    var allowToShow = false
    
    deinit {
        bubbles.endUpdate()
        print("deinit club discover")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubviews()

        let requester = ChatRequester.requester
        requester.discoverClub("nearby", skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.bubbles.clubs = self.clubs
            self.bubbles.reloadBubble()
            self.bubbles.startUpdate()
            self.bubbles.updator?.paused = true
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        bubbles.updator?.paused = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        bubbles.updator?.paused = true
    }

    func createSubviews() {
        let superview = self.view
        superview.clipsToBounds = true

        bubbles = ClubBubbleView()
        bubbles.delegate = self
        superview.addSubview(bubbles)
        bubbles.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview).offset(100)
            make.height.equalTo(250)
        }

        clubList = UITableView(frame: CGRectZero, style: .Plain)
        clubList.separatorStyle = .None
        clubList.rowHeight = 90
        clubList.delegate = self
        clubList.dataSource = self
        self.view.addSubview(clubList)
        clubList.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.height.equalTo(self.view.frame.height - 250)
            make.top.equalTo(self.view.snp_bottom)
        }
        clubList.registerClass(ClubDiscoverCell.self, forCellReuseIdentifier: "cell")
        shadowLine = UIView()
        shadowLine.backgroundColor = UIColor.whiteColor()
        shadowLine.clipsToBounds = false
        shadowLine.layer.shadowRadius = 3
        shadowLine.layer.shadowOpacity = 0.3
        shadowLine.layer.shadowColor = UIColor.blackColor().CGColor
        shadowLine.layer.shadowOffset = CGSizeMake(0, -2)
        superview.addSubview(shadowLine)
        shadowLine.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(clubList)
        }
        superview.sendSubviewToBack(shadowLine)
        //
        showClubListBtn = UIButton()
        showClubListBtn.tag = 0
        showClubListBtn.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        showClubListBtn.layer.shadowColor = UIColor.blackColor().CGColor
        showClubListBtn.layer.shadowRadius = 2
        showClubListBtn.layer.shadowOpacity = 0.3
        showClubListBtn.layer.shadowOffset = CGSizeMake(0, 4)
        showClubListBtn.layer.cornerRadius = 4
        showClubListBtn.clipsToBounds = false
        showClubListBtn.addTarget(self, action: #selector(ClubDiscoverController.showClubBtnPressed), forControlEvents: .TouchUpInside)
        self.view.addSubview(showClubListBtn)
        showClubListBtn.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(clubList.snp_top).offset(-15)
            make.right.equalTo(self.view).offset(-15)
            make.size.equalTo(CGSizeMake(125, 50))
        }
        //
        showClubListBtnIcon = UIImageView(image: UIImage(named: "user_list_invoke"))
        showClubListBtn.addSubview(showClubListBtnIcon)
        showClubListBtnIcon.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
        showClubListBtnIcon.bounds = CGRectMake(0, 0, 20, 20)
        showClubListBtnIcon.center = CGPointMake(27, 25)
        //
        let btnLbl = UILabel()
        showClubListBtn.addSubview(btnLbl)
        btnLbl.text = LS("浏览列表")
        btnLbl.textColor = UIColor.whiteColor()
        btnLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        btnLbl.frame = CGRectMake(47.5, 0, 60, 50)
        //
        clubFilter = ClubFilterController()
        clubFilter.selectedRow = 0
        clubFilter.delegate = self
        clubWrapper = BlackBarNavigationController(rootViewController: clubFilter)
        clubFilterView = clubWrapper.view
        clubFilterView.layer.shadowRadius = 4
        clubFilterView.layer.shadowColor = UIColor.blackColor().CGColor
        clubFilterView.layer.shadowOffset = CGSizeMake(0, 3)
        clubFilterView.layer.shadowOpacity = 0.4
        superview.addSubview(clubFilterView)
        clubFilterView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view).offset(10)
            make.left.equalTo(self.view).offset(15)
            make.size.equalTo(CGSizeMake(124, 41))
        }
        let mapFilterToggleBtn = UIButton()
        self.view.addSubview(mapFilterToggleBtn)
        mapFilterToggleBtn.addTarget(self, action: #selector(ClubDiscoverController.toggleMapFilter), forControlEvents: .TouchUpInside)
        mapFilterToggleBtn.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(clubFilterView)
            make.left.equalTo(self.view).offset(15)
            make.size.equalTo(CGSizeMake(124, 41))
        }
    }
    
    func showClubBtnPressed() {
        if showClubListBtn.tag == 0 {
            clubList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 250)
                make.bottom.equalTo(self.view.snp_bottom)
            }
            bubbles.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view).offset(0)
            })
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.showClubListBtnIcon.transform = CGAffineTransformIdentity
            })
            clubList.reloadData()
            showClubListBtn.tag = 1
        }else {
            clubList.snp_remakeConstraints { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.height.equalTo(self.view.frame.height - 250)
                make.top.equalTo(self.view.snp_bottom)
            }
            bubbles.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view).offset(100)
            })
            SpringAnimation.spring(0.6, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.showClubListBtnIcon.transform = CGAffineTransformMakeRotation(CGFloat( M_PI))
            })
            showClubListBtn.tag = 0
        }
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
                make.top.equalTo(self.view).offset(10)
                make.left.equalTo(self.view).offset(15)
                make.size.equalTo(CGSizeMake(124, 41))
            })
        }else {
            clubFilterView.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(self.view).offset(10)
                make.left.equalTo(self.view).offset(15)
                make.size.equalTo(CGSizeMake(124, 42 * 7))
            })
        }
        clubFilter.expanded = !clubFilter.expanded
        UIView.animateWithDuration(0.3) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
        
        if !clubFilter.dirty {
            return
        }
        let requester = ChatRequester.requester
        let opType = ["nearby", "value", "average", "members", "beauty", "recent"][clubFilter.selectedRow]
        requester.discoverClub(opType, skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.bubbles.clubs = self.clubs
            self.bubbles.reloadBubble()
            self.bubbles.startUpdate()
            self.clubList.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
}
