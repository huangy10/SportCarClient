//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class PersonBasicController: UICollectionViewController, SportCarViewListDelegate {
    // 显示的用户的信息
    var data: PersonDataSource!
    
    var header: PersonHeaderMine!
    
    var carsViewList: SportsCarViewListController!
    
    init(user: User) {
        let flowLayout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: flowLayout)
        
        data = PersonDataSource()
        data.user = user
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func createSubviews() {
        let superview = self.view
        //
        header = PersonHeaderMine()
        collectionView?.addSubview(header)
        header.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(collectionView!)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(header.snp_width).multipliedBy(0.968)
        }
        //
        carsViewList = SportsCarViewListController()
        let carsView = carsViewList.view
        collectionView?.addSubview(carsView)
        carsView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(header.snp_bottom)
            make.height.equalTo(62)
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carsView.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carsView)
            make.right.equalTo(carsView)
            make.top.equalTo(carsView)
            make.height.equalTo(0.5)
        }
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        carsView.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(carsView)
            make.right.equalTo(carsView)
            make.bottom.equalTo(carsView)
            make.height.equalTo(0.5)
        }
        //
        collectionView?.contentInset = UIEdgeInsetsMake(848.0 / 750 * self.view.frame.width, 0, 0, 0)
        collectionView?.registerClass(PersonStatusListCell.self, forCellWithReuseIdentifier: PersonStatusListCell.reuseIdentifier)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if data.selectedCar == nil {
            return 1
        }else {
            return 2
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if data.selectedCar == nil {
            return data.statusList.count
        }else {
            if section == 0 {
                return 1
            }else {
                return data.statusDict[data.selectedCar!.carID!]!.count
            }
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if data.selectedCar == nil {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PersonStatusListCell.reuseIdentifier, forIndexPath: indexPath) as! PersonStatusListCell
            let status = data.statusList[indexPath.row]
            cell.cover.kf_setImageWithURL(SFURL(status.image!)!)
            return cell
        }else {
            
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
}

extension PersonBasicController {
    
    func didSelectSportCar(car: SportCar?) {
        data.selectedCar = car
        // 当car是nil时，代表显示所有的动态，直接
        collectionView?.reloadData()
    }
    
    func needAddSportCar() {
        
    }
}

class PersonStatusListCell: UICollectionViewCell {
    static let reuseIdentifier = "person_status_list_cell"
    var cover: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        cover = UIImageView()
        self.contentView.addSubview(cover)
        cover.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView)
        }
    }
}
