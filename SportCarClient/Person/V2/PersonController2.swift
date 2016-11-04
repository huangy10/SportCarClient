//
//  PersonController.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher


class PersonController: UIViewController, RequestManageMixin {
    
    weak var homeDelegate: HomeDelegate?
    
    var header: PersonHeaderView!
    var tableView: UITableView!
    
    var data: PersonDataSource!
    var user: User {
        return data.user
    }
    
    var onGoingRequest: [String : Request] = [:]
    var isRoot: Bool {
        return homeDelegate != nil
    }
    var homeBtn: BackToHomeBtn!
    weak var oldNavDelegate: UINavigationControllerDelegate?
    
    init (user: User) {
        data = PersonDataSource()
        data.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        clearAllRequest()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        configureTableView()
        configureHeader()
    }
    
    func configureNavBar() {
        navigationItem.title = getNavTitle()
        navigationItem.leftBarButtonItem = getNavLeftBtn()
        navigationItem.rightBarButtonItem = getNavRightBtn()
        oldNavDelegate = navigationController?.delegate
    }
    
    func getNavLeftBtn() -> UIBarButtonItem? {
        if isRoot {
            homeBtn = BackToHomeBtn()
            homeBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
            return homeBtn.wrapToBarBtn()
        } else {
            let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed))
            backBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
            backBtn.imageView?.contentMode = .scaleAspectFit
            backBtn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
            return UIBarButtonItem(customView: backBtn)
        }
    }
    
    func getNavRightBtn() -> UIBarButtonItem? {
        let setting = UIButton().config(self, selector: #selector(navRightBtnPressed))
            .setFrame(CGRect(x: 0, y: 0, width: 44, height: 44))
        setting.addSubview(UIImageView.self).config(UIImage(named: "person_setting"), contentMode: .scaleAspectFit)
            .layout { (make) in
                make.centerY.equalTo(setting)
                make.right.equalTo(setting)
                make.size.equalTo(20)
        }
        setting.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7)
        return UIBarButtonItem(customView: setting)
    }
    
    func getNavTitle() -> String {
        return LS(user.isHost ? "我" : "个人信息")
    }
    
    func configureTableView() {
        tableView = UITableView()
        tableView.backgroundColor = kGeneralTableViewBGColor
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.register(PersonStatusListGroupCell.self, forCellReuseIdentifier: "cell")
        tableView.contentInset = UIEdgeInsetsMake(9, 0, 0, 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (mk) in
            mk.edges.equalTo(view)
        }
    }
    
    func configureHeader() {
        header = PersonHeaderView(frame: .zero)
        header.dataSource = self
        header.user = user
        
        let container = UIView()
        container.addSubview(header)
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.requiredHeight())

        tableView.tableHeaderView = container

        header.snp.makeConstraints { (mk) in
            mk.centerX.equalTo(container)
            mk.top.equalTo(container)
            mk.bottom.equalTo(container)
            mk.width.equalTo(view)
        }
        
    }
    
    func navRightBtnPressed() {
        let settings = PersonMineSettings()
        navigationController?.pushViewController(settings, animated: true)
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil)
        }else {
            navigationController?.delegate = oldNavDelegate
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

extension PersonController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let statusNum = data.statusCellNumber()
        if statusNum == 0 {
            return 0
        }
        return (statusNum - 1) / 3 + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PersonStatusListGroupCell
        cell.indexPath = indexPath
        let rangeMin = indexPath.row * 3
        let rangeMax = min(rangeMin + 3, data.statusCellNumber())
        (rangeMin..<rangeMax).forEach({ cell.setImage(data.getStatus(atIdx: $0)?.coverURL!, atIdx: $0) })
        return cell
    }
}
//
//extension PersonController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return data.statusCellNumber()
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if let status = data.getStatus(atIdx: indexPath.row) {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! PersonStatusListCell
//            cell.cover.kf.setImage(with: status.coverURL!)
//            return cell
//        } else {
//            return collectionView.dequeueReusableCell(withReuseIdentifier: "add", for: indexPath)
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        
//        header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! PersonHeaderView
//        print(indexPath.row, indexPath.section)
//        header.user = user
//        header.dataSource = self
//        return header
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
////        header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: IndexPath(row: 0, section: 0)) as! PersonHeaderView
////        header.dataSource = self
//        
//        return CGSize(width: UIScreen.main.bounds.width, height: 0)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header", for: IndexPath(row: 0, section: 0)) as! PersonHeaderView
//        header.user = user
//        header.dataSource = self
//        return CGSize(width: UIScreen.main.bounds.width, height: header.requiredHeight())
//    }
//}

extension PersonController: PersonHeaderCarListDatasource {
    func personHeaderCarList() -> [SportCar] {
        return data.cars
    }
    
    func personHeaderSportCarSelectionChanged(intoCar newCar: SportCar) {
        
    }
}

extension PersonController: PersonStatusListGroupCellDelegate {
    func statusPressed(at idx: Int) {
        
    }
}

protocol PersonStatusListGroupCellDelegate: class {
    func statusPressed(at idx: Int)
}


class PersonStatusListGroupCell: UITableViewCell {
    var btns: [UIButton] = []
    var indexPath: IndexPath!
    weak var delegate: PersonStatusListGroupCellDelegate!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureBtns()
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureBtns() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 9
        stack.distribution = .fillEqually
        stack.alignment = .center
        contentView.addSubview(stack)
        stack.snp.makeConstraints { (mk) in
            mk.edges.equalTo(UIEdgeInsetsMake(0, 9, 9, 9))
        }
        for idx in 0..<2 {
            let btn = UIButton()
            btn.addTarget(self, action: #selector(btnPressed(sender:)), for: .touchUpInside)
//            btn.snp.makeConstraints({ $0.height.equalTo(btn.snp.width) })
            btn.tag = idx
            stack.addArrangedSubview(btn)
            btns.append(btn)
        }
    }
    
    func setImage(_ im: URL?, atIdx idx: Int) {
        if im != nil {
            btns[idx % 3].kf.setImage(with: im!, for: .normal)
        } else {
            btns[idx % 3].setImage(UIImage(named: "release_status_in_person"), for: .normal)
        }
    }
    
    func setImages(_ images: [UIImage?]) {
        for (idx, im) in images.enumerated() {
            if im != nil {
                btns[idx].setImage(im, for: .normal)
            } else {
                btns[idx].setImage(UIImage(named: "release_status_in_person"), for: .normal)
            }
        }
    }
    
    func btnPressed(sender: UIButton) {
        let idx = indexPath.row * 3 + sender.tag
        delegate.statusPressed(at: idx)
    }
}
