//
//  ActivtyList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityHomeMineListController: UITableViewController {
    
    var home: ActivityHomeController!
    
    var data: [Activity] = []
    var loading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        tableView.registerClass(ActivityHomeCell.self, forCellReuseIdentifier: ActivityHomeCell.reuseIdentifier)
        tableView.separatorStyle = .None
        tableView.rowHeight = 250
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0)
        tableView.backgroundColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        getMoreActData()
    }

    
    func getMoreActData() {
        if loading {
            return 
        }
        loading = true
        let requester = ActivityRequester.requester
        let dateThreshold = data.last()?.createdAt ?? NSDate()

        requester.getMineActivityList(dateThreshold, op_type: "more", limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let act = Activity.objects.getOrCreate(data)
                self.data.append(act)
            }
            self.loading = false
            self.tableView.reloadData()
            }) { (code) -> () in
                print(code)
                self.loading = false
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ActivityHomeCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityHomeCell
        let act = data[indexPath.row]
        cell.act = act
        cell.loadDataAndUpdateUI()
        let y = cell.frame.origin.y - tableView.contentOffset.y
        if y <= 0 {
            cell.setContentInset(10)
        }else if y >= tableView.frame.height{
            cell.setContentInset(2)
        }else{
            let insetRatio = y / tableView.frame.height
            let inset = 10 - insetRatio * insetRatio * 8
            cell.setContentInset(inset)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detail = ActivityDetailController(act: data[indexPath.row])
        home.navigationController?.pushViewController(detail, animated: true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let cells = tableView.visibleCells
        for cell in cells {
            let y = cell.frame.origin.y - scrollView.contentOffset.y
            let aCell = cell as! ActivityHomeCell
            if y <= 0 {
                aCell.setContentInset(10)
            }else if y >= tableView.frame.height{
                aCell.setContentInset(2)
            }else{
                let insetRatio = y / tableView.frame.height
                let inset = 10 - insetRatio * insetRatio * 8
                aCell.setContentInset(inset)
            }
        }
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreActData()
        }
    }
}
