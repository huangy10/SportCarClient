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
        if loading {
            return
        }
        loading = true
        //
        let requester = ActivityRequester.requester
        let dateThreshold = data.last()?.createdAt ?? NSDate()
        requester.getActivityApplied(dateThreshold, op_type: "more", limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let act = Activity.objects.getOrCreate(data)
                self.data.append(act)
            }
            }) { (code) -> () in
                print(code)
        }
    }
}