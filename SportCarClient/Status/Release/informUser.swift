//
//  informUser.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/18.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class InformOtherUserController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var users: [User] = []
    /// at按钮，表现在UI上面是『@提醒谁看』
    var atBtn: UIButton?
    /// 选中的用户显示在这个横向列表中
    var collectionView: UICollectionView?
    /// 这里采用closure来传递消息
    var onInvokeUserSelectController: ((_ sender: InformOtherUserController)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSubviews()
    }
    
    internal func createSubviews() {
        let superview = self.view!
        self.view.backgroundColor = UIColor.white
        //
        atBtn = UIButton()
        superview.addSubview(atBtn!)
        atBtn?.setTitle(LS("@ 提醒谁看"), for: .normal)
        atBtn?.setTitleColor(UIColor.black, for: .normal)
        atBtn?.titleLabel?.textAlignment = .center
        atBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        atBtn?.addTarget(self, action: #selector(InformOtherUserController.atBtnPressed), for: .touchUpInside)
        atBtn?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.centerY.equalTo(superview)
            make.size.equalTo(CGSize(width: 75, height: 35))
        })
        //
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 35, height: 35)
        flowLayout.minimumInteritemSpacing = 5
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.delegate = self
        collectionView?.dataSource = self
        superview.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(atBtn!.snp.right).offset(15)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.right.equalTo(superview).offset(-15)
        })
        
        collectionView?.register(InformOtherUserCell.self, forCellWithReuseIdentifier: InformOtherUserCell.reuseIdentifier)
    }
    
    func atBtnPressed() {
        if let handler = onInvokeUserSelectController {
            handler(self)
        }else{
            assertionFailure()
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InformOtherUserCell.reuseIdentifier, for: indexPath) as! InformOtherUserCell
        let user = users[(indexPath as NSIndexPath).row]
        cell.user = user
        cell.imageView?.kf.setImage(with: user.avatarURL!)
        return cell
    }
}


class InformOtherUserCell: UICollectionViewCell {
    static let reuseIdentifier = "inform_other_user_cell"
    /// 显示用户头像
    var imageView: UIImageView?
    /// 本cell绑定的用户
    var user: User?
    
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
        imageView = UIImageView()
        imageView?.layer.cornerRadius = 17.5
        imageView?.clipsToBounds = true
        imageView?.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(imageView!)
        imageView?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(superview)
        })
    }
}
