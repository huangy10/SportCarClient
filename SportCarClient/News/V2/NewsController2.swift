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
        homeBtn.addTarget(self, action: #selector(backToHomeBtnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = homeBtn.wrapToBarBtn()
    }
    
    func backToHomeBtnPressed() {
        homeDelegate?.backToHome(nil)
    }
    
    func configureTableView() {
        tableView.register(NewsCell2.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.separatorStyle = .none
        tableView.rowHeight = UIScreen.main.bounds.width * 0.573
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: .touchUpInside)
        tableView.addSubview(refreshControl!)
        refreshControl?.isEnabled = true
    }
    
    func pullToRefresh() {
        guard let firstNews = news.first else {
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
            
            self.news.append(contentsOf: newNews)
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
        let lastNewsDate = news.last?.createdAt ?? Date()
        onGoingRequest = NewsRequester.sharedInstance.getMoreNewsList(lastNewsDate, onSuccess: { (json) -> () in
            guard let data = json else{
                self.refreshControl?.endRefreshing()
                return
            }
            var newNews: [News] = []
            for newsJSON in data.arrayValue {
                newNews.append(try! News().loadDataFromJSON(newsJSON))
            }
            self.news.append(contentsOf: newNews)
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
        news.sort { (news1 , news2) -> Bool in
            switch news1.createdAt!.compare(news2.createdAt! as Date) {
            case .orderedDescending:
                return true
            default:
                return false
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsCell2
        let data = news[(indexPath as NSIndexPath).row]
        cell.setData(data.coverURL!, title: data.title, likeNum: Int(data.likeNum), commentNum: Int(data.commentNum), shareNum: Int(data.shareNum), liked: data.liked)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = news[(indexPath as NSIndexPath).row]
        let detail = NewsDetailController2()
        detail.news = data
        
        selectedCell = tableView.cellForRow(at: indexPath) as? NewsCell2
        navigationController?.pushViewController(detail, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height {
            loadMoreNews()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .pop:
            if toVC == self {
                return dismissAnimation
            } else{
                return nil
            }
        case .push:
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
            let result = cell.convert(cell.bounds, to: navigationController!.view)
            return result
        } else {
            assertionFailure()
            return CGRect.zero
        }
    }
    
}
