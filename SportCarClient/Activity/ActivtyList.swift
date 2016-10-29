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
    
    @available(*, deprecated: 1)
    weak var home: ActivityHomeController!
    
    var data: [Activity] = []
    var loading: Bool = false
    var refreshControl: UIRefreshControl!
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: screenWidth / 2 - 17.5, height: 200)
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        self.init(collectionViewLayout: layout)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onActivityManuallyEnded(_:)), name: NSNotification.Name(rawValue: kActivityManualEndedNotification), object: nil)
        //
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(10, 12.5, 10, 12.5)
        collectionView?.register(ActivityCell.self, forCellWithReuseIdentifier: ActivityCell.reuseIdentifier)
        collectionView?.backgroundColor = kGeneralTableViewBGColor
        refreshControl = collectionView?.addSubview(UIRefreshControl.self)
            .config(self, selector: #selector(getLatestActData))
        getMoreActData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCell.reuseIdentifier, for: indexPath) as! ActivityCell
        cell.act = data[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detail = ActivityDetailController(act: data[(indexPath as NSIndexPath).row])
        detail.parentCollectionView = self.collectionView
        parent?.navigationController?.pushViewController(detail, animated: true)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
        let requester = ActivityRequester.sharedInstance
        let dateThreshold = data.first?.createdAt ?? Date()
        _ = requester.getMineActivityList(dateThreshold, op_type: "latest", limit: 10, onSuccess: { (json) -> () in
            var i = 0
            let curIdList = self.data.map({return $0.ssid})
            for data in json!.arrayValue {
                let id = data["actID"].int32Value
                if curIdList.contains(id) {
                    continue
                }
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data)
                self.data.insert(act, at: i)
                i += 1
            }
            if json!.arrayValue.count > 0 {
                self.data = $.uniq(self.data, by: { $0.ssid })
            }
            self.loading = false
            self.collectionView?.reloadData()
            self.refreshControl?.endRefreshing()
            }) { (code) -> () in
                self.loading = false
                self.refreshControl?.endRefreshing()
        }
    }
    
    func getMoreActData() {
        if loading {
            return 
        }
        loading = true
        let requester = ActivityRequester.sharedInstance
        let dateThreshold = data.last?.createdAt ?? Date()

        _ = requester.getMineActivityList(dateThreshold, op_type: "more", limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let act: Activity = try! MainManager.sharedManager.getOrCreate(data, overwrite: true)
                self.data.append(act)
            }
            if json!.arrayValue.count > 0 {
                self.data = $.uniq(self.data, by: { $0.ssid })
            }
            self.loading = false
            self.collectionView?.reloadData()
            }) { (code) -> () in
                self.loading = false
        }
    }
    
    func onActivityManuallyEnded(_ notification: Foundation.Notification) {
        let name = notification.name.rawValue
        if name == kActivityManualEndedNotification {
            if let act = (notification as NSNotification).userInfo?[kActivityKey] as? Activity,
                let targetIndex = data.findIndex(callback: { $0.ssid == act.ssid}) {
                // reload the specific cell
                collectionView?.reloadItems(at: [IndexPath(row: targetIndex, section: 0)])
            }
        }
    }
}
