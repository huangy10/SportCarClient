//
//  ActivtyList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/13.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Dollar


class ActivityHomeMineListController: UICollectionViewController {
    
    weak var home: ActivityHomeController!
    
    var data: [Activity] = []
    var loading: Bool = false
    var refreshControl: UIRefreshControl!
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.mainScreen().bounds.width
        layout.itemSize = CGSizeMake(screenWidth / 2 - 17.5, 200)
        layout.scrollDirection = .Vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(10, 12.5, 10, 12.5)
        collectionView?.registerClass(ActivityCell.self, forCellWithReuseIdentifier: ActivityCell.reuseIdentifier)
        collectionView?.backgroundColor = UIColor.RGB(39, 39, 39)
        refreshControl = collectionView?.addSubview(UIRefreshControl.self)
            .config(self, selector: #selector(getLatestActData))
        getMoreActData()
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ActivityCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityCell
        cell.act = data[indexPath.row]
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detail = ActivityDetailController(act: data[indexPath.row])
        detail.parentCollectionView = self.collectionView
        home.navigationController?.pushViewController(detail, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            getMoreActData()
        }
    }

    func getLatestActData() {
        if loading {
            refreshControl.endRefreshing()
            return
        }
        loading = true
        let requester = ActivityRequester.requester
        let dateThreshold = data.first()?.createdAt ?? NSDate()
        requester.getMineActivityList(dateThreshold, op_type: "latest", limit: 10, onSuccess: { (json) -> () in
            var i = 0
            let curIdList = self.data.map({return $0.ssid})
            for data in json!.arrayValue {
                let id = data["actID"].int32Value
                if curIdList.contains(id) {
                    continue
                }
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
                self.data.insert(act, atIndex: i)
                i += 1
            }
            if json!.arrayValue.count > 0 {
                self.data = $.uniq(self.data, by: { $0.ssid })
            }
            self.loading = false
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
            }) { (code) -> () in
                print(code)
                self.loading = false
                self.refreshControl?.endRefreshing()
        }
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
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
                self.data.append(act)
            }
            if json!.arrayValue.count > 0 {
                self.data = $.uniq(self.data, by: { $0.ssid })
            }
            self.loading = false
            self.collectionView?.reloadData()
            }) { (code) -> () in
                print(code)
                self.loading = false
        }
    }
}
