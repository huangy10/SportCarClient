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
    
    var clubs: [Club] = []
    
    var clubList: UITableView!
    var clubFilter: ClubFilterController!
    var clubWrapper: BlackBarNavigationController!
    var clubFilterView: UIView!
    
    var cityFilter: UIButton!
    var cityFilterLbl: UILabel!
    
    var clubFilterType: String = "nearby"
    var cityFilterType: String = "全国"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubviews()

        let requester = ClubRequester.sharedInstance
        _ = requester.discoverClub("value", cityLimit: "全国", skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
            }) { (code) -> () in
                self.showToast(LS("网络访问错误:\(code)"))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clubList.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func createSubviews() {
        let superview = self.view!
        superview.clipsToBounds = true

        clubList = UITableView(frame: CGRect.zero, style: .plain)
        clubList.separatorStyle = .none
        clubList.rowHeight = 90
        clubList.delegate = self
        clubList.dataSource = self
        self.view.addSubview(clubList)
        clubList.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        clubList.register(ClubDiscoverCell.self, forCellReuseIdentifier: "cell")

        clubFilter = ClubFilterController()
        clubFilter.selectedRow = 0
        clubFilter.delegate = self
        clubWrapper = clubFilter.toNavWrapper()
        self.view.addSubview(clubWrapper.view)
        
        clubFilter.view.toRound(20)
        clubFilterView = clubWrapper.view.addShadow().layout({ (make) in
            make.bottom.equalTo(superview).offset(-25)
            make.right.equalTo(superview).offset(-20)
            make.size.equalTo(CGSize(width: 115, height: 40))
        })
        self.view.addSubview(UIButton.self).config(self, selector: #selector(toggleMapFilter))
            .layout { (make) in
                make.top.equalTo(clubFilterView)
                make.left.equalTo(clubFilterView)
                make.size.equalTo(CGSize(width: 115, height: 40))
        }
        
        cityFilter = self.view.addSubview(UIButton.self)
            .config(self, selector: #selector(cityFilterPressed))
            .config(UIColor.white)
            .toRound(20).addShadow()
            .layout({ (make) in
                make.right.equalTo(clubFilterView.snp.left).offset(-10)
                make.bottom.equalTo(clubFilterView)
                make.size.equalTo(CGSize(width: 120, height: 40))
            })
        let icon = cityFilter.addSubview(UIImageView.self)
            .config(UIImage(named: "up_arrow"))
            .layout { (make) in
                make.centerY.equalTo(cityFilter)
                make.right.equalTo(cityFilter).offset(-20)
                make.size.equalTo(CGSize(width: 13, height: 9))
        }
        cityFilterLbl = cityFilter.addSubview(UILabel.self)
            .config(14, textColor: UIColor(white: 0, alpha: 0.87), text: LS("全国"))
            .layout({ (make) in
                make.left.equalTo(cityFilter).offset(20)
                make.right.equalTo(icon.snp.left).offset(-10)
                make.centerY.equalTo(cityFilter)
            })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clubs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClubDiscoverCell
        cell.club = clubs[(indexPath as NSIndexPath).row]
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let club = clubs[(indexPath as NSIndexPath).row]
        if club.attended {
            if club.founderUser!.isHost {
                let detail = GroupChatSettingHostController(targetClub: club)
                parent?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = GroupChatSettingController(targetClub: club)
                parent?.navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            let detail = ClubBriefInfoController()
            detail.targetClub = club
            parent?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height >= scrollView.contentSize.height {
            sendRequest()
        }
    }
    
    func clubBubbleDidClickOn(_ club: Club) {
        if club.attended {
            if club.founderUser!.isHost {
                let detail = GroupChatSettingHostController(targetClub: club)
                parent?.navigationController?.pushViewController(detail, animated: true)
            } else {
                let detail = GroupChatSettingController(targetClub: club)
                parent?.navigationController?.pushViewController(detail, animated: true)
            }
        } else {
            let detail = ClubBriefInfoController()
            detail.targetClub = club
            parent?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func toggleMapFilter() {
        
        if clubFilter.expanded {
            clubFilterView.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSize(width: 115, height: 40))
            })
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.clubFilter.view.toRound(20)
                self.view.layoutIfNeeded()
                self.clubFilter.marker.transform = CGAffineTransform.identity
            }) 
        }else {
            clubFilterView.snp.remakeConstraints({ (make) -> Void in
                make.bottom.equalTo(self.view).offset(-25)
                make.right.equalTo(self.view).offset(-20)
                make.size.equalTo(CGSize(width: 115, height: 40 * 6))
            })
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.clubFilter.view.toRound(5)
                self.view.layoutIfNeeded()
                self.clubFilter.marker.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
            }) 
        }
        clubFilter.expanded = !clubFilter.expanded
    }
    
    func sendRequest(_ reload: Bool = false) {
        let opType = ["value", "average", "members", "beauty", "recent"][clubFilter.selectedRow]
        _ = ClubRequester.sharedInstance.discoverClub(opType, cityLimit: self.cityFilterType, skip: clubs.count, limit: 10, onSuccess: { (json) -> () in
            if reload {
                self.clubs.removeAll()
            }
            for data in json!.arrayValue {
    
                let club: Club = try! MainManager.sharedManager.getOrCreate(data)
                self.clubs.append(club)
            }
            self.clubs = $.uniq(self.clubs, by: { $0.ssid })
            self.clubList.reloadData()
        }) { (code) -> () in
            self.showToast(LS("网络访问错误:\(code)"))
        }
    }
    
    func radarFilterDidChange() {
        toggleMapFilter()
        
        if !clubFilter.dirty {
            return
        }
        self.clubs.removeAll()
        sendRequest(true)
    }
    
    func cityFilterPressed() {
        let select = CityElementSelectController()
        select.maxLevel = 1
        select.showAllContry = true
        select.delegate = self
        self.parent?.present(select.toNavWrapper(), animated: true, completion: nil)
    }
    
    // MARK: City Element Select
    
    func cityElementSelectDidSelect(_ dataSource: CityElementSelectDataSource) {
        self.parent?.dismiss(animated: true, completion: nil)
        cityFilterType = dataSource.selectedCity ?? "全国"
        cityFilterLbl.text = cityFilterType
        sendRequest(true)
    }
    
    func cityElementSelectDidCancel() {
        parent?.dismiss(animated: true, completion: nil)
    }
}
