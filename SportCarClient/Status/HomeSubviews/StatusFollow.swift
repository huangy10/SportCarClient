//
//  StatusFollow.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/21.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class StatusFollowController: StatusBasicController {
    
    override func loadMoreData() {
        // 获取关注对象的状态（自己的状态也会返回）
        let dateThreshold = (status.last?.createdAt ?? Date())
        let requester = StatusRequester.sharedInstance
        _ = requester.getMoreStatusList(dateThreshold, queryType: "follow", onSuccess: { (data) -> () in
            if self.jsonDataHandler(data!) > 0{
                self.tableView.reloadData()
            }
            }) { (code) -> () in
        }
    }
    
    override func loadLatestData() {
        let dateThreshold = status.first?.createdAt ?? Date()
        let requester = StatusRequester.sharedInstance
        _ = requester.getLatestStatusList(dateThreshold, queryType: "follow", onSuccess: { (data) -> () in
            self.myRefreshControl?.endRefreshing()
            if self.jsonDataHandler(data!) > 0 {
                self.tableView.reloadData()
            }
            }) { (code) -> () in
        }
    }
    
    func getScreenShot() -> UIImage{
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: 0, y: -self.tableView.contentOffset.y)
        self.view.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
