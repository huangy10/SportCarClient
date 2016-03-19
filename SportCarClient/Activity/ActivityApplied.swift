//
//  ActivityApplied.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityAppliedController: ActivityHomeMineListController {
    
    override func getMoreActData() {
        let requester = ActivityRequester.requester
        let dateThreshold = data.last()?.applyAt ?? NSDate()
        requester.getActivityApplied(dateThreshold, op_type: "more", limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let act = Activity.objects.getOrCreate(data["activity"])
                self.data.append(act)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    override func getLatestActData() {
        let dateThreshold = data.last()?.applyAt ?? NSDate()
        ActivityRequester.requester.getActivityApplied(dateThreshold, op_type: "latest", limit: 10, onSuccess: { (json) -> () in
            self.refreshControl?.endRefreshing()
            var new = [Activity]()
            for data in json!.arrayValue {
                let act = Activity.objects.getOrCreate(data["activity"])
                act.applyAt = DateSTR(data["created_at"].stringValue)
                new.append(act)
            }
            self.data.insertContentsOf(new, at: 0)
            self.tableView.reloadData()
            }) { (code) -> () in
                self.refreshControl?.endRefreshing()
                print(code)
        }
    }
}