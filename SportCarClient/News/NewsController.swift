//
//  News.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/26.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


/// 资讯页面的入口
class NewsController: UITableViewController {
    /// 指向Home
    weak var homeDelegate: HomeDelegate?
    
    /// 展示的资讯的内容
    var news: [News] = []
    
    var homeBtn: BackToHomeBtn!
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 设置导航栏
        navigationBarSettings()
        // 注册news的cell
        tableView.registerClass(NewsCell.self, forCellReuseIdentifier: NewsCell.reusableIdentifier)
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.separatorStyle = .None
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(NewsController.handleRefreshing), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        refreshControl?.enabled = true
        // 开始准备获取数据
        self.loadMoreNewsBelow()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        tableView.reloadData()
        homeBtn.unreadStatusChanged()
    }
}


// MARK: - Table相关
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
        return screenWidth * 0.573
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NewsCell.reusableIdentifier, forIndexPath: indexPath) as! NewsCell
        cell.news = news[indexPath.row]
        cell.selectionStyle = .None
        // 自动载入更多news
        if indexPath.row == news.count-1 {
            self.loadMoreNewsBelow()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // 选中cell后弹出的详情页面
        let detailCtrl = NewsDetailController()
        detailCtrl.news = news[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let initPos = cell.frame.origin.y - tableView.contentOffset.y
        detailCtrl.initPos = initPos
        detailCtrl.initBgImg = self.getScreenShotBlurred(false)
        self.navigationController?.pushViewController(detailCtrl, animated: false)
        
    }
}

// MARK: - 设置导航栏
extension NewsController {
    /**
     导航栏的设置，负责设置标题以及创建按钮
     */
    func navigationBarSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
//        let homeBtn = UIButton()
//        homeBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
//        homeBtn.addTarget(self, action: #selector(NewsController.backToHomePressed), forControlEvents: .TouchUpInside)
//        homeBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 13.5)
//        let leftBtnItem = UIBarButtonItem(customView: homeBtn)
        homeBtn = BackToHomeBtn()
        homeBtn.addTarget(self, action: #selector(backToHomePressed), forControlEvents: .TouchUpInside)
        return homeBtn.wrapToBarBtn()
    }
    
    func backToHomePressed() {
        self.homeDelegate?.backToHome(nil)
    }
}

// MARK: - 新数据的loading
extension NewsController {
    /**
     处理下拉刷新
     */
    func handleRefreshing() {
        updateToFetchLatestNews()
    }
    
    /**
     获取最新的资讯
     */
    func updateToFetchLatestNews() {
        
        guard let firstNews = news.first() else {
            loadMoreNewsBelow()
            return
        }
        let requester = NewsRequester.sharedInstance
        requester.getLatestNewsList(firstNews.createdAt!, onSuccess: { (json) -> () in
            guard let data = json else{
                self.refreshControl?.endRefreshing()
                return
            }
            var newNews: [News] = []
            for newsJSON in data.arrayValue {
                newNews.append(try! News().loadDataFromJSON(newsJSON))
            }
            self.news.appendContentsOf(newNews)
            self.reorganizeNews()
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            }) { (code) -> () in
                self.showToast(LS("刷新失败"))
                self.refreshControl?.endRefreshing()
        }
    }
    
    /**
     载入更早的资讯
     */
    func loadMoreNewsBelow() {
        let lastNewsDate = news.last()?.createdAt ?? NSDate()
        NewsRequester.sharedInstance.getMoreNewsList(lastNewsDate, onSuccess: { (json) -> () in
            guard let data = json else{
                self.refreshControl?.endRefreshing()
                return
            }
            var newNews: [News] = []
            for newsJSON in data.arrayValue {
                newNews.append(try! News().loadDataFromJSON(newsJSON))
            }
            self.news.appendContentsOf(newNews)
            self.reorganizeNews()
            self.refreshControl?.endRefreshing()
            if newNews.count > 0{
                self.tableView.reloadData()
            }
            }) { (code) -> () in
                self.refreshControl?.endRefreshing()
                self.showToast(LS("网络访问错误"))
        }
    }
    
    /**
     重新整理资讯，避免重复以及的保证排序
     */
    func reorganizeNews() {
        news = $.uniq(news, by: {return $0.ssidString})
        news.sortInPlace { (news1 , news2) -> Bool in
            switch news1.createdAt!.compare(news2.createdAt!) {
            case .OrderedDescending:
                return true
            default:
                return false
            }
        }
    }
}

