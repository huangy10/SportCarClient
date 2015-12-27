//
//  News.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/26.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit


/// 资讯页面的入口
class NewsController: UITableViewController {
    /// 指向Home
    var homeDelegate: HomeDelegate?
    
    /// 展示的资讯的内容
    var news: [News] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置导航栏
        navigationBarSettings()
        // 注册news的cell
        tableView.registerClass(NewsCell.self, forCellReuseIdentifier: NewsCell.reusableIdentifier)
    }
    
}

extension NewsController {
    /**
     总是只有一个Section
     */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /**
     返回news的个数
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    /**
     cell的高度是固定的
     */
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenWidth = self.tableView.frame.width
        return screenWidth * 0.5773
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NewsCell.reusableIdentifier, forIndexPath: indexPath) as! NewsCell
        cell.news = news[indexPath.row]
        return cell
    }
}

// MARK: - 设置导航栏
extension NewsController {
    /**
     导航栏的设置，负责设置标题以及创建按钮
     */
    func navigationBarSettings() {
        self.navigationItem.title = self.navigationBarTitle()
        self.navigationItem.leftBarButtonItem = leftBarBtn()
    }
    
    /**
     导航栏标题
     
     - returns: 标题内容，已经经过了
     */
    func navigationBarTitle() -> String? {
        return LS("资讯")
    }
    
    func leftBarBtn() -> UIBarButtonItem? {
        let homeBtn = UIButton()
        homeBtn.setBackgroundImage(UIImage(named: "home_back"), forState: .Normal)
        homeBtn.addTarget(self, action: "backToHomePressed", forControlEvents: .TouchUpInside)
        homeBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        homeBtn.imageEdgeInsets = UIEdgeInsets(top: 14.5, left: 14.5, bottom: 14.5, right: 14.5)
        let leftBtnItem = UIBarButtonItem(customView: homeBtn)
        return leftBtnItem
    }
    
    func backToHomePressed() {
        self.homeDelegate?.backToHome(nil)
    }
}


