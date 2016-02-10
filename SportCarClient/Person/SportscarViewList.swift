//
//  SportscarViewList.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//
//  个人中心中的跑车浏览选择页面，除了跑车按钮意外，最前有一个『动态』按钮以显示所有动态，最后有一个添加按钮以添加认证车辆
//

import UIKit
import SnapKit


protocol SportCarViewListDelegate {
    /**
     选中了一个车辆，当参数是nil时表示选择的是最前面的『动态』按钮
     
     - parameter car: 选中的车辆
     */
    func didSelectSportCar(car: SportCar?)
    
    /**
     按下了最后的添加按钮
     */
    func needAddSportCar()
}


class SportsCarViewListController: UICollectionViewController {
    
    var cars: [SportCar] = []
    
    var selectedCar: SportCar?
    
    var delegate: SportCarViewListDelegate?
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(120, 62)
        layout.sectionInset = UIEdgeInsetsMake(0, 9, 0, 9)
        layout.minimumInteritemSpacing = 9
        self.init(collectionViewLayout: layout)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count + 2
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < cars.count + 1 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SportCarViewListTextCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarViewListTextCell
            if indexPath.row == 0{
                cell.titleLbl.text = LS("动态")
                if selectedCar == nil {
                    cell.setCellSelected(true)
                }else {
                    cell.setCellSelected(false)
                }
            }else {
                let car = cars[indexPath.row - 1]
                cell.titleLbl.text = car.name
                if car.carID == selectedCar?.carID {
                    cell.setCellSelected(true)
                }else {
                    cell.setCellSelected(false)
                }
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(SportCarViewListAddBtnCell.reuseIdentifier, forIndexPath: indexPath) as! SportCarViewListAddBtnCell
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            selectedCar = nil
            delegate?.didSelectSportCar(selectedCar)
        } else if indexPath.row < cars.count + 1 {
            selectedCar = cars[indexPath.row - 1]
            delegate?.didSelectSportCar(selectedCar)
        } else {
            delegate?.needAddSportCar()
        }
        collectionView.reloadData()
    }
    
}

class SportCarViewListTextCell: UICollectionViewCell {
    static let reuseIdentifier = "sport_car_view_list_text_cell"
    
    var titleLbl: UILabel!
    var selectedBg: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor(white: 0.945, alpha: 1)
        //
        selectedBg = UIView()
        selectedBg.backgroundColor = UIColor(white: 0.878, alpha: 1)
        selectedBg.layer.cornerRadius = 6.5
        superview.addSubview(selectedBg)
        selectedBg.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview).inset(8)
        }
        //
        titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        titleLbl.textColor = UIColor(white: 0.72, alpha: 1)
        titleLbl.textAlignment = .Center
        superview.addSubview(titleLbl)
        titleLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(superview)
        }
    }
    
    func setCellSelected(flag: Bool) {
        selectedBg.hidden = !flag
        titleLbl.textColor = flag ? UIColor.blackColor() : UIColor(white: 0.72, alpha: 1)
    }
}

class SportCarViewListAddBtnCell: UICollectionViewCell {
    
    static let reuseIdentifier = "sport_car_view_list_add_btn_cell"
    
    var addBtn: UIButton!
    
    var onAddBtnPressed: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self.contentView
        superview.backgroundColor = UIColor(white: 0.945, alpha: 1)
        //
        addBtn = UIButton()
        addBtn.setImage(UIImage(named: "person_add_more"), forState: .Normal)
        super.addSubview(addBtn)
        addBtn.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(superview)
            make.size.equalTo(18)
        }
    }
}