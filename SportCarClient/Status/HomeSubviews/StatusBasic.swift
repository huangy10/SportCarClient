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


class StatusBasicController: UITableViewController {
    /*
    由于动态页面分成了三个tag，区别只是数据的不同，故我们这里首先构造一个完成页面布局的基类，然后派生出去实现数据获取
    */
    /// 状态数据
    var status: [Status] = []
    
    var myRefreshControl: UIRefreshControl?
    
    weak var homeController: StatusHomeController?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func loadMoreData() {
        assertionFailure("Not Implemented")
    }
    
    func loadLatestData() {
        assertionFailure("Not Implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusBasicController.onStatusDelete(_:)), name: kStatusDidDeletedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onUserBlacklisted(_:)), name: kUserBlacklistedNotification, object: nil)
        
        tableView.registerClass(StatusCell.self, forCellReuseIdentifier: StatusCell.reuseIdentifier)
        myRefreshControl = UIRefreshControl()
        tableView.addSubview(myRefreshControl!)
        tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0)
        myRefreshControl?.addTarget(self, action: #selector(StatusBasicController.loadLatestData), forControlEvents: .ValueChanged)
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        loadMoreData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return status.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StatusCell.reuseIdentifier, forIndexPath: indexPath) as! StatusCell
        cell.parent = homeController
        cell.status = status[indexPath.row]
        cell.selectionStyle = .None
        cell.loadDataAndUpdateUI()
        return cell
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let curStatus = status[indexPath.row]
        if curStatus.image?.split(";").count <= 1{
            return 420
        }else{
            return 520
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return StatusCell.heightForStatus(status[indexPath.row])
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
        status.sortInPlace { (s1, s2) -> Bool in
            switch s1.createdAt!.compare(s2.createdAt!) {
            case .OrderedAscending:
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
    func jsonDataHandler(json: JSON) -> Int{
        let statusJSONData = json.arrayValue
        for statusJSON in statusJSONData {
            let newStatus: Status = try! MainManager.sharedManager.getOrCreate(statusJSON)
            self.status.append(newStatus)
        }
        statusDataSort()
        return statusJSONData.count
    }
    
    func onStatusDelete(notification: NSNotification) {
        // TODO: check id type
        if let statusID = notification.userInfo![kStatusDidDeletedStatusIDKey] as? String{
            if let index = status.findIndex({$0.ssidString == statusID}) {
                status.removeAtIndex(index)
                tableView.reloadData()
            }
        } else {
            assertionFailure()
        }
    }
    
    func onUserBlacklisted(notification: NSNotification) {
        if let userID = notification.userInfo?[kUserSSIDKey] as? String {
            status = status.filter({$0.ssidString != userID})
            tableView.reloadData()
        } else {
            assertionFailure()
        }
    }
}