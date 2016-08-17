//
//  Billboard.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON


struct BillboardItem {
    var club: Club!
    var newToList: Bool
    var order: Int
    var orderChange: Int
}


class BillboardController: UIViewController, RadarFilterDelegate, CityElementSelectDelegate, UITableViewDataSource, UITableViewDelegate {
    var data: [BillboardItem] = []
    var scope: String = "全国"
    var filterType: String = "total"
    let limitPerRequest: Int = 20
    
    weak var homeDelegate: HomeDelegate!
    
    var tableView: UITableView!
    
    var clubFilter: ClubFilterForBillboardController!
    var clubWrapper: BlackBarNavigationController!
    var clubFilterView: UIView!
    
    var cityFilter: UIButton!
    var cityFilterLbl: UILabel!
    var homeBtn: BackToHomeBtn!
    var refreshControl: UIRefreshControl!
    
    weak var ongoingRequest: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        configureTableView()
        configureClubFilter()
        configureCityFilter()
        configureNavigationBar()
        configureRefreshControl()
        loadMoreClubData(0, limit: limitPerRequest, scope: "全国", filterType: "total")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        homeBtn.unreadStatusChanged()
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
    }
    
    func refresh() {
        data.removeAll()
        loadMoreClubData(0, limit: 20, scope: scope, filterType: filterType, alwaysReload: true)
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("排行榜")
        homeBtn = BackToHomeBtn()
        homeBtn.addTarget(self, action: #selector(navLeftBtnPressed), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: homeBtn)
    }
    
    func navLeftBtnPressed() {
        homeDelegate.backToHome(nil)
    }
    
    func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(white: 0, alpha: 0.06)
        tableView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        view.addSubview(tableView)
        tableView.registerClass(BillboardCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(BillboardFirstThree.self, forCellReuseIdentifier: "first_three")
        tableView.separatorStyle = .None
    }
    
    func configureCityFilter() {
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
    
    func configureClubFilter() {
        let superview = view
        clubFilter = ClubFilterForBillboardController()
        clubFilter.selectedRow = 0
        clubFilter.delegate = self
        clubWrapper = clubFilter.toNavWrapper()
        view.addSubview(clubWrapper.view)
        
        clubFilter.view.toRound(20)
        clubFilterView = clubWrapper.view.addShadow()
        clubFilterView.snp_makeConstraints { (make) in
            make.bottom.equalTo(superview).offset(-25)
            make.right.equalTo(superview).offset(-20)
            make.size.equalTo(CGSizeMake(115, 40))
        }
        self.view.addSubview(UIButton.self).config(self, selector: #selector(clubFilterPressed))
            .layout { (make) in
                make.top.equalTo(clubFilterView)
                make.left.equalTo(clubFilterView)
                make.size.equalTo(CGSizeMake(115, 40))
        }
    }
    
    func clubFilterPressed() {
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
                make.size.equalTo(CGSizeMake(115, 40 * 5))
            })
            UIView.animateWithDuration(0.3) { () -> Void in
                self.clubFilter.view.toRound(5)
                self.view.layoutIfNeeded()
                self.clubFilter.marker.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
            }
        }
        clubFilter.expanded = !clubFilter.expanded
    }
    
    func cityFilterPressed() {
        let cityPicker = CityElementSelectController()
        cityPicker.maxLevel = 1
        cityPicker.showAllContry = true
        cityPicker.delegate = self
        presentViewController(cityPicker.toNavWrapper(), animated: true, completion: nil)
    }
    
    func loadMoreClubData(skip: Int, limit: Int, scope: String, filterType: String, alwaysReload: Bool = false) {
        if let req = ongoingRequest {
            req.cancel()
        }
        ongoingRequest = ClubRequester.sharedInstance.clubBillboard(skip, limit: limit, scope: scope, filterType: filterType, onSuccess: { (json) in
            print(json!)
            self.parseServerData(json!.arrayValue, alwaysReload: alwaysReload)
            self.refreshControl.endRefreshing()
            }) { (code) in
                self.showToast(LS("访问错误"))
                self.refreshControl.endRefreshing()
        }
    }
    
    func parseServerData(data: [JSON], alwaysReload: Bool) {
        for item in data {
            let clubJson = item["club"]
            let club = try! MainManager.sharedManager.getOrCreate(clubJson) as Club
            let order = item["order"].intValue
//            let version = clubJson["version"].intValue
            let newToList = item["new_to_list"].boolValue
            let orderChange = item["order_change"].intValue
            let billboardItem = BillboardItem(club: club, newToList: newToList, order: order, orderChange: orderChange)
            self.data.append(billboardItem)
        }
        if data.count > 0 || alwaysReload {
            tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        let item = data[row]
        if row >= 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! BillboardCell
            cell.setData(item.club, order: item.order, orderChange: item.orderChange, new: item.newToList)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("first_three", forIndexPath: indexPath) as! BillboardFirstThree
            cell.setData(item.club, order: item.order, orderChange: item.orderChange, new: item.newToList)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let row = indexPath.row
        if row >= 3 {
            return 80
        } else {
            return 85
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let club = data[indexPath.row].club
        if club.attended {
            if club.founderUser!.isHost {
                let detail = GroupChatSettingHostController(targetClub: club)
                navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = GroupChatSettingController(targetClub: club)
                navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            let detail = ClubBriefInfoController()
            detail.targetClub = club
            navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let height = scrollView.contentSize.height
        let y = scrollView.contentOffset.y
        if height + y >= height {
            let skip = data.count
            loadMoreClubData(skip, limit: limitPerRequest, scope: scope, filterType: filterType)
        }
    }
    
    func radarFilterDidChange() {
        clubFilterPressed()
        
        if !clubFilter.dirty {
            return
        } else {
            filterType = ["total", "average", "members", "female"][clubFilter.selectedRow]
        }

        data.removeAll()
        loadMoreClubData(0, limit: limitPerRequest, scope: scope, filterType: filterType, alwaysReload: true)
    }
    
    func cityElementSelectDidSelect(dataSource: CityElementSelectDataSource) {
        dismissViewControllerAnimated(true, completion: nil)
        scope = dataSource.selectedCity ?? "全国"
        cityFilterLbl.text = scope
        data.removeAll()
        loadMoreClubData(0, limit: 20, scope: scope, filterType: filterType, alwaysReload: true)
    }
    
    func cityElementSelectDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
