//
//  NewsController2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar
import Alamofire

class NewsController2: UITableViewController, UINavigationControllerDelegate {
    weak var homeDelegate: HomeDelegate?
    
    var news: [News] = []
    
    var homeBtn: BackToHomeBtn!
    
    weak var onGoingRequest: Request?
    
    let entryAnimation = NewsDetailEntranceAnimation()
    let dismissAnimation = NewsDetailDismissAnimation()
    
    weak var selectedCell: NewsCell2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        navigationController?.delegate = self
        configureTableView()
        
        refreshControl?.beginRefreshing()
        pullToRefresh()
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("资讯")
        homeBtn = BackToHomeBtn()
        homeBtn.addTarget(self, action: #selector(backToHomeBtnPressed), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = homeBtn.wrapToBarBtn()
    }
    
    func backToHomeBtnPressed() {
        homeDelegate?.backToHome(nil)
    }
    
    func configureTableView() {
        tableView.registerClass(NewsCell2.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.separatorStyle = .None
        tableView.rowHeight = UIScreen.mainScreen().bounds.width * 0.573
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullToRefresh), forControlEvents: .TouchUpInside)
        tableView.addSubview(refreshControl!)
        refreshControl?.enabled = true
    }
    
    func pullToRefresh() {
        guard let firstNews = news.first() else {
            loadMoreNews()
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
    
    func loadMoreNews() {
        if let req = onGoingRequest {
            req.cancel()
        }
        let lastNewsDate = news.last()?.createdAt ?? NSDate()
        onGoingRequest = NewsRequester.sharedInstance.getMoreNewsList(lastNewsDate, onSuccess: { (json) -> () in
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewsCell2
        let data = news[indexPath.row]
        cell.setData(data.coverURL!, title: data.title, likeNum: Int(data.likeNum), commentNum: Int(data.commentNum), shareNum: Int(data.shareNum), liked: data.liked)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = news[indexPath.row]
        let detail = NewsDetailController2()
        detail.news = data
        
        selectedCell = tableView.cellForRowAtIndexPath(indexPath) as? NewsCell2
        navigationController?.pushViewController(detail, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            loadMoreNews()
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .Pop:
            if toVC == self {
                return dismissAnimation
            } else{
                return nil
            }
        case .Push:
            if fromVC == self {
                return entryAnimation
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    func getSelectedNewsCellFrame() -> CGRect{
        if let cell = selectedCell {
            let result = cell.convertRect(cell.bounds, toView: navigationController!.view)
            return result
        } else {
            assertionFailure()
            return CGRectZero
        }
    }
    
}
