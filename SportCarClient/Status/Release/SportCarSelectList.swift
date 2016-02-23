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
        return cars.count + 1
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
        cell.sportCarNameLbL?.text = car.name
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < cars.count{
            selectedCar = cars[indexPath.row]
        }
    }
    
    /**
     从服务器获取认证跑车信息
     */
    func getSportCarData() {
        let requester = SportCarRequester.sharedSCRequester
        requester.getAuthedCarsList(User.objects.hostUser!.userID!, onSuccess: { (let data) -> () in
            let hostUser = User.objects.hostUser!
            for carOwnerShipJSON in data!.arrayValue {
                let carJSON = carOwnerShipJSON["car"]
                let car = SportCar.objects.create(carJSON).value
                SportCar.objects.getOrCreateOwnership(car!, user: hostUser, initail: carOwnerShipJSON)
                self.cars.append(car!)
            }
            self.collectionView?.reloadData()
            }) { (let code) -> () in
                print(code)
        }
    }
    
}

class SportCarSelectListCell: UICollectionViewCell {
    
    static let reuseIdentifier: String = "sport_car_select_list_cell"
    
    var car: SportCar?
    var selectMarker: UIImageView?
    var sportCarNameLbL: UILabel?
    
    override var selected: Bool {
        didSet {
            if selected {
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
        addBtn?.addTarget(self, action: "addPressed", forControlEvents: .TouchUpInside)
        superview.addSubview(addBtn!)
        addBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(superview)
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