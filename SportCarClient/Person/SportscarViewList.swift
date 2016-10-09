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
import Spring

protocol SportCarViewListDelegate: class {
    /**
     选中了一个车辆，当参数是nil时表示选择的是最前面的『动态』按钮
     
     - parameter car: 选中的车辆
     */
    func didSelect(sportCar car: SportCar?)
    
    /**
     按下了最后的添加按钮
     */
    func needAddSportCar()
}


class SportsCarViewListController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    static let requiredHeight: CGFloat = 62
    
    var cars: [SportCar] = []
    
    var selectedCar: SportCar?
    
    weak var delegate: SportCarViewListDelegate?
    
    var showAddBtn: Bool = true
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 9, 0, 9)
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .horizontal
        self.init(collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor.white
//        collectionView?.register(SportCarViewListTextCell.self, forCellWithReuseIdentifier: SportCarViewListTextCell.reuseIdentifier)
//        collectionView?.register(SportCarViewListAddBtnCell.self, forCellWithReuseIdentifier: SportCarViewListAddBtnCell.reuseIdentifier)
//        collectionView?.register(SportCarViewListTextCell.self, forCellWithReuseIdentifier: "all_status")
        registerReusableCells()
    }
    
    func registerReusableCells() {
        collectionView?.register(SportscarViewListCarCell.self, forCellWithReuseIdentifier: "car")
        collectionView?.register(SportCarViewListAddBtnCell.self, forCellWithReuseIdentifier: "add")
    }
    
    func selectAllStatus(_ pulse: Bool) {
        collectionView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
//        allStatusCell?.setCellSelected(true)
//        if pulse {
//            allStatusCell?.pulse()
//        }
        selectedCar = nil
        collectionView?.reloadData()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.count + (showAddBtn ? 2 : 1)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "car", for: indexPath) as! SportscarViewListCarCell
            cell.set(car: nil)
            cell.set(selected: selectedCar == nil)
            return cell
        } else if indexPath.row < cars.count + 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "car", for: indexPath) as! SportscarViewListCarCell
            let car = cars[indexPath.row - 1]
            cell.set(car: car)
            cell.set(selected: selectedCar == car)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath) as! SportCarViewListAddBtnCell
            return cell
        }
//        if (indexPath as NSIndexPath).row == 0 {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "all_status", for: indexPath) as! SportCarViewListTextCell
//            cell.titleLbl.text = LS("动态")
//            allStatusCell = cell
//            if selectedCar == nil {
//                cell.setCellSelected(true)
//            }else {
//                cell.setCellSelected(false)
//            }
//            return cell
//        } else if (indexPath as NSIndexPath).row < cars.count + 1 {
//            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportCarViewListTextCell.reuseIdentifier, for: indexPath) as! SportCarViewListTextCell
//            if (indexPath as NSIndexPath).row == 0{
//                cell.titleLbl.text = LS("动态")
//            }else {
//                let car = cars[(indexPath as NSIndexPath).row - 1]
//                cell.titleLbl.text = car.name
//                if car.ssid == selectedCar?.ssid {
//                    cell.setCellSelected(true)
//                }else {
//                    cell.setCellSelected(false)
//                }
//            }
//            return cell
//        }else {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SportCarViewListAddBtnCell.reuseIdentifier, for: indexPath) as! SportCarViewListAddBtnCell
//            return cell
//        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).row == 0 {
            selectedCar = nil
            delegate?.didSelect(sportCar: selectedCar)
        } else if (indexPath as NSIndexPath).row < cars.count + 1 {
            selectedCar = cars[(indexPath as NSIndexPath).row - 1]
            delegate?.didSelect(sportCar: selectedCar)
        } else {
            delegate?.needAddSportCar()
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if (indexPath as NSIndexPath).row >= cars.count + 1 || (indexPath as NSIndexPath).row == 0 {
//            return CGSize(width: 120, height: 62)
//        }
//        let car = cars[(indexPath as NSIndexPath).row - 1]
//        let name = car.name!
//        let size = name.sizeWithFont(UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold), boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
//        if size.width > 80 {
//            return CGSize(width: size.width + 40, height: 62)
//        } else {
//            return CGSize(width: 120, height: 62)
//        }
        
        if indexPath.row >= cars.count + 1 || indexPath.row == 0{
            return CGSize(width: 120, height: SportsCarViewListController.requiredHeight)
        } else {
            return SportscarViewListCarCell.getRequiredSize(forGivenCar: cars[indexPath.row - 1])
        }
    }
    
}

class SportCarViewListAddBtnCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        
        let desLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightBold, textColor: kTextLightGray, textAlignment: .left, text: LS("添加爱车"))
            .layout { (make) in
                make.centerX.equalTo(contentView).offset(18)
                make.centerY.equalTo(contentView)
        }
        
        let icon = UIImageView(image: UIImage(named: "person_add_more"))
        self.addSubview(icon)
        icon.snp.makeConstraints { (make) -> Void in
            make.centerY.equalTo(desLbl)
            make.right.equalTo(desLbl.snp.left).offset(-4)
            make.size.equalTo(12)
        }
        
    }
}


class SportscarViewListCarCell: UICollectionViewCell {
    weak var car: SportCar?
    var authIcon: UIImageView!
    var carNameLbl: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        configureNameLbl()
        configureAuthIcon()
    }
    
    func configureNameLbl() {
        carNameLbl = contentView.addSubview(UILabel.self)
            .layout({ (make) in
                make.center.equalTo(contentView)
            })
        carNameLbl.font = type(of: self).fontForNameLbl()
        carNameLbl.textAlignment = .center
        carNameLbl.textColor = kTextBlack
    }
    
    func configureAuthIcon() {
        authIcon = contentView.addSubview(UIImageView.self)
            .config(UIImage(named: "auth_status_authed"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.right.equalTo(carNameLbl)
                make.bottom.equalTo(carNameLbl.snp.top)
                make.width.equalTo(30)
                make.height.equalTo(13)
            })
        authIcon.isHidden = true
    }
    
    func set(car: SportCar?) {
        self.car = car
        if let car = car {
            carNameLbl.text = car.name
            setAuthStatus(car.identified)
        } else {
            carNameLbl.text = LS("动态")
            setAuthStatus(false)
        }
    }
    
    func set(selected isSelected: Bool) {
        if isSelected {
            carNameLbl.textColor = UIColor.black
        } else {
            carNameLbl.textColor = kTextLightGray
        }
    }
    
    func setAuthStatus(_ isAuthed: Bool) {
        authIcon.isHidden = !isAuthed
    }
    
    class func fontForNameLbl() -> UIFont {
        return UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold)
    }
    
    class func getRequiredSize(forGivenCar car: SportCar?) -> CGSize {
        let height = SportsCarViewListController.requiredHeight
        let font = fontForNameLbl()
        let text = car?.name ?? LS("动态")
        let requiredWidth = text.sizeWithFont(font, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return CGSize(width: requiredWidth + 40, height: height)
    }
}
