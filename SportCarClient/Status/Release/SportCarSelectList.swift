//
//  SprotCarSelectList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class SportCarSelectListController: UICollectionViewController{
    
    var cars: [SportCar] = []
    
    var selectedCar: SportCar?
    private var _preSel: Int = -1
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    convenience init() {
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.itemSize = CGSizeMake(140, 60)
        flowlayout.minimumInteritemSpacing = 0.01
        flowlayout.scrollDirection = .Horizontal
        self.init(collectionViewLayout: flowlayout)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.registerClass(SportCarSelectListCell.self, forCellWithReuseIdentifier: SportCarSelectListCell.reuseIdentifier)
        collectionView?.registerClass(SportCarSelectListAddCell.self, forCellWithReuseIdentifier: SportCarSelectListAddCell.reuseIdentifier)
        
        collectionView?.backgroundColor = UIColor(white: 0.945, alpha: 1)
        collectionView?.layer.borderColor = UIColor(white: 0.72, alpha: 1).CGColor
        collectionView?.layer.borderWidth = 0.5
        
        getSportCarData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let carCount = cars.count
        if indexPath.row == carCount {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SportCarSelectListAddCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarSelectListAddCell
            cell.onAddPressed = { ()->() in
                
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SportCarSelectListCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarSelectListCell
        let car = cars[indexPath.row]
        cell.car = car
        cell.marked = (car.ssid == selectedCar?.ssid)
        cell.sportCarNameLbL?.text = car.name
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < cars.count{
            if indexPath.row != _preSel {
                selectedCar = cars[indexPath.row]
                if _preSel >= 0 {
                    collectionView.reloadItemsAtIndexPaths([indexPath, NSIndexPath(forItem: _preSel, inSection: 0)])
                } else {
                    collectionView.reloadItemsAtIndexPaths([indexPath])
                }
                _preSel = indexPath.row
            } else {
                selectedCar = nil
                collectionView.reloadItemsAtIndexPaths([indexPath])
                _preSel = -1
            }
        }
    }
    
    /**
     从服务器获取认证跑车信息
     */
    func getSportCarData() {
        let requester = SportCarRequester.sharedSCRequester
        requester.getAuthedCarsList(MainManager.sharedManager.hostUserIDString!, onSuccess: { (let data) -> () in
            for carOwnerShipJSON in data!.arrayValue {
                let carJSON = carOwnerShipJSON["car"]
                // TODO: json
                let car: SportCar = try! MainManager.sharedManager.getOrCreate(carJSON)
                car.mine = true
                self.cars.append(car)
            }
            self.collectionView?.reloadData()
            }) { (code) -> () in
        }
    }
    
}

class SportCarSelectListCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "sport_car_select_list_cell"
    
    var car: SportCar?
    var selectMarker: UIImageView?
    var sportCarNameLbL: UILabel?
    
    var marked: Bool = false {
        didSet {
            if marked {
                selectMarker?.image = UIImage(named: "status_add_sport_car_selected")
                sportCarNameLbL?.textColor = UIColor.blackColor()
            }else {
                selectMarker?.image = UIImage(named: "status_add_sport_car_unselected")
                sportCarNameLbL?.textColor = UIColor(white: 0.72, alpha: 1)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = self.contentView
        //
        selectMarker = UIImageView(image: UIImage(named: "status_add_sport_car_unselected"))
        superview.addSubview(selectMarker!)
        selectMarker?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.centerY.equalTo(superview)
            make.size.equalTo(22.5)
        })
        //
        sportCarNameLbL = UILabel()
        sportCarNameLbL?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        sportCarNameLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(sportCarNameLbL!)
        sportCarNameLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(selectMarker!.snp_right).offset(10)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.right.equalTo(superview).offset(-15)
        })
    }
    
}


class SportCarSelectListAddCell: UICollectionViewCell {
    static let reuseIdentifier: String = "sport_car_select_list_add_cell"
    var addBtn: UIButton?
    /// 用closure来传递
    var onAddPressed: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        //
        addBtn = UIButton()
        addBtn?.setImage(UIImage(named: "person_add_more"), forState: .Normal)
        addBtn?.addTarget(self, action: #selector(SportCarSelectListAddCell.addPressed), forControlEvents: .TouchUpInside)
        superview.addSubview(addBtn!)
        addBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(superview).offset(CGPointMake(-20, 0))
            make.size.equalTo(18)
        })
    }
    
    func addPressed() {
        if let handler = onAddPressed {
            handler()
        }else{
            assertionFailure()
        }
    }
}