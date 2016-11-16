//
//  StatusHot.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Dollar

class StatusHotController: UICollectionViewController {
    var status: [Status] = []
    var myRefreshControl: UIRefreshControl?
    weak var homeController: StatusHomeController?
    
    weak var selectedCell: UICollectionViewCell?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init () {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: screenWidth / 3 - 5, height: screenWidth/3 - 5)
        layout.minimumLineSpacing = 2.5
        layout.minimumInteritemSpacing = 2.5
        self.init(collectionViewLayout: layout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.alwaysBounceVertical = true
        collectionView?.contentInset = UIEdgeInsetsMake(5, 5, 5, 5)
        collectionView?.register(StatusHotCell.self, forCellWithReuseIdentifier: "cell")
        collectionView?.backgroundColor = kGeneralTableViewBGColor
        myRefreshControl = UIRefreshControl()
        myRefreshControl?.addTarget(self, action: #selector(loadLatestStatusData), for: .valueChanged)
        collectionView?.addSubview(myRefreshControl!)
        loadMoreStatusData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onStatusDeleted(notification:)), name: NSNotification.Name(rawValue: kStatusDidDeletedNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectedCell = nil
    }
    
    func onStatusDeleted(notification: NSNotification) {
        if let statusID = (notification as NSNotification).userInfo![kStatusDidDeletedStatusIDKey] as? String{
            status = $.remove(status, callback: { $0.ssidString == statusID })
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        } else {
            assertionFailure()
        }
    }
    
    // MARK: Data Fetching
    func loadMoreStatusData(_ limit: Int = 12) {
        let threshold = status.last?.createdAt ?? Date()
        _ = StatusRequester.sharedInstance.getMoreStatusList(threshold, queryType: "hot", onSuccess: { (json) -> () in
            if self.jsonDataHandler(json!) > 0 {
                self.collectionView?.reloadData()
            }
            }) { (code) -> () in
        }
    }
    
    func loadLatestStatusData() {
        let threshold = status.first?.createdAt ?? Date()
        _ = StatusRequester.sharedInstance.getLatestStatusList(threshold, queryType: "hot", onSuccess: { (json) -> () in
            if self.jsonDataHandler(json!) > 0 {
                self.collectionView?.reloadData()
            }
            self.myRefreshControl?.endRefreshing()
            }) { (code) -> () in
                self.myRefreshControl?.endRefreshing()
        }
    }
    
    /**
     将状态数据按照时间顺序进行排序，最近发的在最前面
     */
    func statusDataSort() {
        status.sort { (s1, s2) -> Bool in
            switch s1.createdAt!.compare(s2.createdAt!) {
            case .orderedAscending:
                return false
            default:
                return true
            }
        }
    }
    
    /**
     这个函数处理来自服务器返回的json数组，将产生的数据
     
     - parameter json: 输入的JSON数据
     
     - return: 返回生成的status的数量
     */
    func jsonDataHandler(_ json: JSON) -> Int{
        let statusJSONData = json.arrayValue
        for statusJSON in statusJSONData {
            let newStatus = try! MainManager.sharedManager.getOrCreate(statusJSON) as Status
            self.status.append(newStatus)
        }
        status = $.uniq(status, by: { $0.ssid })
        statusDataSort()
        return statusJSONData.count
    }
    
    // MARK: Delegate function of collections
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return status.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! StatusHotCell
        cell.status = status[(indexPath as NSIndexPath).row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = collectionView.cellForItem(at: indexPath)
        parent?.navigationController?.delegate = self
        let s = status[(indexPath as NSIndexPath).row]
//        let detail = StatusDetailController(status: s)
//        detail.loadAnimated = false
//        parent?.navigationController?.pushViewController(detail, animated: true)
        let detail = StatusDetailController(status: s)
        parent?.navigationController?.pushViewController(detail, animated: true)
    }
}

extension StatusHotController: StatusCoverPresentable {
    func initialCoverPosition() -> CGRect {
        return selectedCell!.convert(selectedCell!.bounds, to: navigationController!.view)
    }
}

extension StatusHotController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push where fromVC.isKind(of: StatusHomeController.self):
            let res = StatusCoverPresentAnimation()
            res.delegate = self
            return res
        case .pop where (toVC.isKind(of: StatusHomeController.self) && fromVC.isKind(of: StatusDetailController.self)):
            let res = StatusCoverDismissAnimation()
            res.delegate = self
            return res
        default:
            return nil
        }
    }
}


class StatusHotCell: UICollectionViewCell {
    var status: Status! {
        didSet {
            cover.kf.setImage(with: status.coverURL!)
        }
    }
    
    var cover: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        cover = UIImageView()
        superview.addSubview(cover)
        cover.contentMode = .scaleAspectFill
        cover.clipsToBounds = true
        cover.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
    }
}
