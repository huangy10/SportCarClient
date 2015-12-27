	//
//  Person.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/17.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import Mapbox


/// 个人中心
class PersonController: UICollectionViewController, UICollectionViewDelegateFlowLayout{
    /// 当前关联的用户
    var user: User?
    /// 是否动态的载入
    var loadAnimated: Bool = false
    /// 是否显示自己的map，当设置为false时，将会将原来的地图区域设置为透明
    var showMap: Bool = false
    /// home代理
    var delegate: HomeDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    /**
     构造函数
     
     - parameter delegate: 代理，指向homeController
     - parameter animated: 是否启用载入动画
     - parameter showMap:  是否显示地下的地图
     
     - returns: -
     */
    convenience init(delegate: HomeDelegate, animated: Bool = false, showMap: Bool = false){
        let layout = UICollectionViewLayout()
        self.init(collectionViewLayout: layout)
        self.loadAnimated = animated
        self.delegate = delegate
        self.showMap = showMap
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.createSubviews()
    }
    
    var personInfoView: PersonInfoView?
    
    func createSubviews() {
        //
        let collectionView = self.collectionView
        let screenWidth = self.view.frame.width
        let boardHeight = 1.13 * screenWidth
        collectionView?.contentInset = UIEdgeInsets(top: boardHeight, left: 0, bottom: 0, right: 0)
        //
        self.personInfoView = PersonInfoView(frame: CGRectMake(0, -boardHeight, screenWidth, boardHeight), user: user!, animated: false, showMap: true, backgroundImage: nil)
        self.view.addSubview(personInfoView!)
        collectionView?.addSubview(personInfoView!)
    }
}

// MARK: - navigationbar按钮的响应
extension PersonController {
    
    /**
     左侧navigationbar按钮被按下
     */
    func backBtnPressed() {
        guard self.delegate != nil else{
            return
        }
        
        delegate?.backToHome(nil)
    }
    
    /**
     右侧设置按钮被按下
     */
    func settingBtnPressed() {
        
    }
}

// MARK: - 这个extension放置collectionview的控制
extension PersonController {
}
