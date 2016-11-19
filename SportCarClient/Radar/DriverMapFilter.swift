//
//  DriverMapFilter.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire
import Dollar


protocol DriverMapFilterDelegate: class {
    func driverMapFilterUpdate(_ filter: String, display: String, withClub club: Club?)
}


class DriverMapFilterPickController: UIViewController {
    
    weak var delegate: DriverMapFilterDelegate!
    
    var tableView: UITableView!
    // Always keep "club" last
    let filterTypes = ["distance", "follows", "fans", "friends", "male", "female", "auth", "club"]
    let filterDisplayMap = [
        "distance": "附近热门",
        "follows": "我关注的",
        "fans": "我的粉丝",
        "friends": "互相关注",
        "male": "仅男性",
        "female": "仅女性",
        "auth": "认证用户",
        "club": "群组"
    ]
    let curFilterType: String
    let curFilterClub: Club?
    
    var dirty: Bool = false
    var newFilterType: String = ""
    var newFilterClub: Club?
    
    init(curFilterType: String, curFilterClub: Club?) {
        self.curFilterType = curFilterType
        self.curFilterClub = curFilterClub
        super.init(nibName: nil, bundle: nil)
        
        assert(filterTypes.contains(value: curFilterType))
        newFilterType = curFilterType
        newFilterClub = curFilterClub
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureTableView()
    }
    
    func configureNavBar() {
        if curFilterType == filterTypes.last()! {
            navigationItem.title = curFilterClub?.name
        } else {
            navigationItem.title = LS(filterDisplayMap[curFilterType]!)
        }
        let titleBtnLblStyle = [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightRed]
        let leftBtn = UIBarButtonItem(title: LS("取消"), style: .done, target: self, action: #selector(navLeftBtnPressed))
        leftBtn.setTitleTextAttributes(titleBtnLblStyle, for: .normal)
        navigationItem.leftBarButtonItem = leftBtn
        //
        //        let rightBtn = UIBarButtonItem(title: LS("确定"), style: .done, target: self, action: #selector(navRightBtnPressed))
        //        rightBtn.setTitleTextAttributes(titleBtnLblStyle, for: .normal)
    }
    
    func navLeftBtnPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    func navRightBtnPressed() {
        dismiss(animated: true, completion: {
            if self.dirty {
                self.delegate.driverMapFilterUpdate(self.newFilterType, display: self.filterDisplayMap[self.newFilterType]!, withClub: self.newFilterClub)
            }
        })
    }
    
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (mk) in
            mk.edges.equalTo(view)
        }
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 50
        
        tableView.register(SSPropertyBaseCell.self, forCellReuseIdentifier: "mark")
    }
}

extension DriverMapFilterPickController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mark", for: indexPath) as! SSPropertyBaseCell
        let filter = filterTypes[indexPath.row]
        cell.staticLbl.text = filterDisplayMap[filter]
        cell.setMarked(filter == newFilterType, arrowForHide: indexPath.row == (filterTypes.count - 1))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row < filterTypes.count - 1 {
            newFilterType = filterTypes[row]
            tableView.reloadData()
            
            dirty = (newFilterType != curFilterType)
            navRightBtnPressed()
        } else {
            let select = AvatarClubSelectController()
            select.preSelectID = curFilterClub?.ssid
            select.authed_only = false
            select.delegate = self
            navigationController?.pushViewController(select, animated: true)
        }
    }
}


extension DriverMapFilterPickController: AvatarClubSelectDelegate {
    func avatarClubSelectDidFinish(_ selectedClub: Club) {
        newFilterClub = selectedClub
        newFilterType = filterTypes.last()!
        dirty = (newFilterClub?.ssid != curFilterClub?.ssid)
        // disable interaction to avoid misoperation
        view.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.navRightBtnPressed()
        })
    }
    
    func avatarClubSelectDidCancel() {
        
    }
}
