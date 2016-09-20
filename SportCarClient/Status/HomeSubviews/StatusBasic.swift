//
//  StatusBasic.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/21.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import Alamofire
import Dollar
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}



class StatusBasicController: UITableViewController {
    /*
    由于动态页面分成了三个tag，区别只是数据的不同，故我们这里首先构造一个完成页面布局的基类，然后派生出去实现数据获取
    */
    /// 状态数据
    var status: [Status] = []
    
    var myRefreshControl: UIRefreshControl?
    
    weak var homeController: StatusHomeController?
    
    weak var requestOnFly: Request?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func loadMoreData() {
        assertionFailure("Not Implemented")
    }
    
    func loadLatestData() {
        assertionFailure("Not Implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StatusBasicController.onStatusDelete(_:)), name: NSNotification.Name(rawValue: kStatusDidDeletedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserBlacklisted(_:)), name: NSNotification.Name(rawValue: kUserBlacklistedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserBlacklisted(_:)), name: NSNotification.Name(rawValue: kUserUnBlacklistedNotification), object: nil)
        
        tableView.register(StatusCell.self, forCellReuseIdentifier: StatusCell.reuseIdentifier)
        myRefreshControl = UIRefreshControl()
        tableView.addSubview(myRefreshControl!)
        tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0)
        myRefreshControl?.addTarget(self, action: #selector(StatusBasicController.loadLatestData), for: .valueChanged)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = kGeneralTableViewBGColor
        loadMoreData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return status.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StatusCell.reuseIdentifier, for: indexPath) as! StatusCell
        cell.parent = homeController
        cell.status = status[(indexPath as NSIndexPath).row]
        cell.selectionStyle = .none
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let curStatus = status[(indexPath as NSIndexPath).row]
        if curStatus.image?.split(";").count <= 1{
            return 420
        }else{
            return 520
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return StatusCell.heightForStatus(status[(indexPath as NSIndexPath).row])
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.height) - 1 {
            loadMoreData()
        }
    }
    
//    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return false
//    }
}

// MARK: - Utilities
extension StatusBasicController {
    
    /**
     将状态数据按照时间顺序进行排序，最近发的在最前面
     */
    func statusDataSort() {
        status.sort { (s1, s2) -> Bool in
            switch s1.createdAt!.compare(s2.createdAt!) {
            case .orderedAscending:
                return false
            default:
                return true
            }
        }
    }
    
    /**
     这个函数处理来自服务器返回的json数组，将产生的数据
     
     - parameter json: 输入的JSON数据
     
     - return: 返回生成的status的数量
     */
    func jsonDataHandler(_ json: JSON) -> Int{
        let statusJSONData = json.arrayValue
        for statusJSON in statusJSONData {
            let newStatus: Status = try! MainManager.sharedManager.getOrCreate(statusJSON)
            self.status.append(newStatus)
        }
        status = $.uniq(status, by: { $0.ssid })
        statusDataSort()
        return statusJSONData.count
    }
    
    func onStatusDelete(_ notification: Foundation.Notification) {
        if let statusID = (notification as NSNotification).userInfo![kStatusDidDeletedStatusIDKey] as? String{
            if let index = status.findIndex({$0.ssidString == statusID}) {
                status.remove(at: index)
                tableView.reloadData()
            }
        } else {
            assertionFailure()
        }
    }
    
    func onUserBlacklisted(_ notification: Foundation.Notification) {
        let name  = notification.name
        if let user = (notification as NSNotification).userInfo?[kUserKey] as? User {
            if name == kUserBlacklistedNotification {
                status = status.filter({$0.user!.ssid != user.ssid})
                tableView.reloadData()
            }
        } else if let users = (notification as NSNotification).userInfo?[kUserListKey] as? [User] {
            if name == kUserBlacklistedNotification {
                let blIDs = users.map { $0.ssid }
                status = status.filter { !blIDs.contains($0.ssid) }
                tableView.reloadData()
            }
        }
        
    }
}
