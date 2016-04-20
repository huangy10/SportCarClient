//
//  ChatTestTableViewController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

class ChatTestTableViewController: UITableViewController {
    
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
}
