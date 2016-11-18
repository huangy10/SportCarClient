//
//  PersonHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/4.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol PersonHeaderDelegate: class {
    
}

protocol PersonHeaderCarListDatasource: class {
    func personHeaderCarList() -> [SportCar]
    func personHeaderSportCarSelectionChanged(intoCar newCar: SportCar?)
    func personHeaderNeedAddCar()
    func personHeaderCarNeedEdit()
}


class PersonHeaderView: UIView {
    var user: User
    var car: SportCar? {
        didSet {
            configureCarProfile()
        }
    }
    weak var delegate: PersonHeaderDelegate!
    weak var dataSource: PersonHeaderCarListDatasource!
    
    var userProfileView: PersonProfileView!
    var carProfileView: PersonCarProfileView?
    var carList: UICollectionView!
    
    var needsReload: Bool = false
    private var subviewsCreated: Bool = false
    
    init (user: User) {
        self.user = user
        super.init(frame: UIScreen.main.bounds)
        
        configureUserProfileView()
        configureCarList()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureUserProfileView() {
        userProfileView = PersonProfileView()
        
        addSubview(userProfileView)
        
        userProfileView.snp.makeConstraints { (mk) in
            mk.left.equalTo(self)
            mk.right.equalTo(self)
            mk.top.equalTo(self)
            mk.height.equalTo(387 - 62)
        }
        
        userProfileView.user = user
    }
    
    func configureCarList() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 9, 0, 9)
        layout.minimumInteritemSpacing = 9
        layout.scrollDirection = .horizontal
        carList = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(carList)
        carList.snp.makeConstraints { (mk) in
            mk.left.equalTo(self)
            mk.right.equalTo(self)
            mk.top.equalTo(userProfileView.snp.bottom)
            mk.height.equalTo(62)
        }
        
        carList.register(SportscarViewListCarCell.self, forCellWithReuseIdentifier: "cell")
        carList.register(SportCarViewListAddBtnCell.self, forCellWithReuseIdentifier: "add")
        carList.backgroundColor = .white
        
        carList.delegate = self
        carList.dataSource = self
    }
    
    func configureCarProfile() {
        guard let car = self.car else {
            carProfileView?.isHidden = true
            return
        }
        
        if let view = carProfileView {
            view.isHidden = false
            view.car = car
        } else {
            let view = PersonCarProfileView(car: car, user: user)
            view.user = user
            view.delegate = self
            addSubview(view)
            view.snp.makeConstraints({ (mk) in
                mk.left.equalTo(self)
                mk.right.equalTo(self)
                mk.top.equalTo(carList.snp.bottom)
                mk.bottom.equalTo(self)
            })
            carProfileView = view
        }
    }
    
    func loadDataAndUpdateUI() {
        userProfileView.loadDataAndUpdateUI()
        carList.reloadData()
        carProfileView?.loadDataAndUpdateUI()
    }
    
    func requiredHeight() -> CGFloat {
        layoutIfNeeded()
        let result = userProfileView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height + 62
        if let carView = carProfileView, !carView.isHidden {
            return result + carView.requiredHeight()
        }
        return result
    }
}

extension PersonHeaderView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.personHeaderCarList().count + (user.isHost ? 2 : 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let num = dataSource.personHeaderCarList().count
        if indexPath.row == num + 1 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath) as! SportCarViewListAddBtnCell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SportscarViewListCarCell
        if indexPath.row == 0 {
            cell.set(car: nil)
            cell.set(selected: car == nil)
        } else  {
            let car = dataSource.personHeaderCarList()[indexPath.row - 1]
            cell.set(car: car)
            cell.set(selected: self.car?.ssid == car.ssid)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cars = dataSource.personHeaderCarList()
        if indexPath.row >= cars.count + 1 || indexPath.row == 0 {
            return CGSize(width: 120, height: 62)
        } else {
            return SportscarViewListCarCell.getRequiredSize(forGivenCar: cars[indexPath.row - 1])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            dataSource.personHeaderSportCarSelectionChanged(intoCar: nil)
        } else if indexPath.row == dataSource.personHeaderCarList().count + 1 {
            dataSource.personHeaderNeedAddCar()
        } else {
            let car = dataSource.personHeaderCarList()[indexPath.row - 1]
            dataSource.personHeaderSportCarSelectionChanged(intoCar: car)
        }
    }
}

extension PersonHeaderView: PersonCarProfileDelegate {
    func carProfileEditBtnPressed() {
        dataSource.personHeaderCarNeedEdit()
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
            .config(14, fontWeight: UIFontWeightSemibold, textColor: kTextGray38, textAlignment: .left, text: LS("添加爱车"))
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
        carNameLbl.textColor = kTextGray87
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
            carNameLbl.textColor = kTextGray38
        }
    }
    
    func setAuthStatus(_ isAuthed: Bool) {
        authIcon.isHidden = !isAuthed
    }
    
    class func fontForNameLbl() -> UIFont {
        return UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
    }
    
    class func getRequiredSize(forGivenCar car: SportCar?) -> CGSize {
        let height = 62 as CGFloat
        let font = fontForNameLbl()
        let text = car?.name ?? LS("动态")
        let requiredWidth = text.sizeWithFont(font, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)).width
        return CGSize(width: requiredWidth + 40, height: height)
    }
}

