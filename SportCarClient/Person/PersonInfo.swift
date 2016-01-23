//
//  PersonInfo.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/22.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Mapbox
import Kingfisher
import Cent

protocol PersonInfoViewDelegate {
    func backBtnPressed()
    
    func settingBtnPresseed()
}

class PersonInfoView: UIView {
    
    var user: User? {
        didSet {
            // 自动在设置user之后更新UI
            setUserAndUpdateUI()
        }
    }
    var delegate: PersonInfoViewDelegate?
    
    /*
     ========================================================================================================================
     下面这些是画面中涉及的view
    */
    
    var mapView: MGLMapView?
    var avatar: UIImageView?
    var avatarCar: UIImageView?
    var nameLbl: UILabel?
    var avatarClub: UIImageView?
    var genderAgeLbl: UILabel?
    var avatarCarNameLbl: UILabel?
    var statusNumLbl: UILabel?
    var fansNumLbl: UILabel?
    var followNumLbl: UILabel?
    
    /// 下方选择显示全部动态还是具体的跑车的横向滚动条
    var slctBoard: UIScrollView?
    /// 对应的按钮
    var carBtns: [UIButton] = []
    
    //========================================================================================================================
    
    var showMap: Bool = false
    var aniamted: Bool = false
    
    var tasks: [Kingfisher.RetrieveImageTask?] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, user: User, animated: Bool, showMap: Bool, backgroundImage: UIImage?) {
        self.init(frame: frame)
        self.user = user
        self.showMap = showMap
        self.createSubviews(backgroundImage)
    }
    
    func createSubviews(backgroundImage: UIImage?) {
        
        self.backgroundColor = UIColor.whiteColor()
        if self.showMap {
            mapView = MGLMapView(frame: self.bounds, styleURL: kMapStyleURL)
            // TODO: 配置地图位置
            self.addSubview(mapView!)
        }else{
            let bg = UIImageView(image: backgroundImage)
            self.addSubview(bg)
            bg.snp_makeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(self)
            })
        }
        // 头像图片
        avatar = UIImageView()
        let task = avatar?.kf_setImageWithURL(SFURL(user?.avatarUrl ?? "")!, placeholderImage: UIImage(named: "account_profile_avatar_btn"))
        self.tasks.append(task)
        self.addSubview(avatar!)
        avatar?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(125)
        })
        // 头像右下角的跑车标识
        let profile = user?.profile
        avatarCar =  UIImageView()
        self.tasks.append(avatarCar?.kf_setImageWithURL(SFURL(profile?.avatarCarImage ?? "")!))
        self.addSubview(avatarCar!)
        avatarCar?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(avatar!)
            make.bottom.equalTo(avatar!)
            make.size.equalTo(33)
        })
        // 跑车名称
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl?.text = user?.profile?.avatarCarName
        avatarCarNameLbl?.font = UIFont.systemFontOfSize(14)
        avatarCarNameLbl?.textColor = UIColor.blackColor()
        self.addSubview(avatarCarNameLbl!)
        avatarCarNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatar!.snp_right).offset(15)
            make.bottom.equalTo(avatar!)
            make.right.equalTo(self)
            make.height.equalTo(16)
        })
        
        // 性别年龄
        let genderText = (user?.gender == "男") ? "♀":"♂"
        let genderColor = (user?.gender == "男") ? UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1) : UIColor(red: 0.686, green: 0.227, blue: 0.490, alpha: 1)
        genderAgeLbl = UILabel()
        genderAgeLbl?.text = "\(genderText)\(user?.age)"
        genderAgeLbl?.textColor = UIColor.whiteColor()
        genderAgeLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        genderAgeLbl?.backgroundColor = genderColor
        self.addSubview(genderAgeLbl!)
        genderAgeLbl?.translatesAutoresizingMaskIntoConstraints = true
        genderAgeLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(avatarCarNameLbl!.snp_top).offset(-12)
            make.left.equalTo(avatarCarNameLbl!)
            make.height.equalTo(17)
            make.width.equalTo(33).priorityLow()
        })
        genderAgeLbl?.setContentHuggingPriority(1000, forAxis: UILayoutConstraintAxis.Horizontal)
        genderAgeLbl?.sizeToFit()
        // 姓名
        nameLbl = UILabel()
        let name = user?.nickName
        nameLbl?.text = name?.length < 4 ? name : name![0..<4] + "..."
        nameLbl?.font = UIFont.systemFontOfSize(19, weight: UIFontWeightLight)
        nameLbl?.textColor = UIColor.blackColor()
        self.addSubview(nameLbl!)
        nameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(genderAgeLbl!)
            make.bottom.equalTo(genderAgeLbl!.snp_top).offset(-5)
            make.height.equalTo(27)
            make.right.lessThanOrEqualTo(self).offset(-25)
        })
        nameLbl?.sizeToFit()
        // 头像俱乐部
        avatarClub = UIImageView()
        self.addSubview(avatarClub!)
        avatarClub?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nameLbl!.snp_right).offset(5)
            make.centerY.equalTo(genderAgeLbl!)
            make.height.equalTo(genderAgeLbl!)
            make.width.equalTo(avatarClub!.snp_height)
        })
        self.tasks.append(avatarClub?.kf_setImageWithURL(SFURL(profile?.avatarClubLogo ?? "")!))
        
        let showDetail = UIImageView(image: UIImage(named: "account_btn_next_icon"))
        self.addSubview(showDetail)
        showDetail.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 10, height: 17))
            make.right.equalTo(self).offset(12)
            make.centerY.equalTo(genderAgeLbl!).offset(2)
        }
        // 粉丝数量
        let numFont = UIFont.systemFontOfSize(17, weight: UIFontWeightBold)
        fansNumLbl = UILabel()
        fansNumLbl?.font = numFont
        fansNumLbl?.textColor = UIColor.blackColor()
        self.addSubview(fansNumLbl!)
        fansNumLbl?.text = "\(profile?.fansNum)"
        fansNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(avatar!.snp_bottom).offset(35)
        })
        let fansLbl = UILabel()
        let lblTextColor = UIColor(white: 0.72, alpha: 1)
        let lblFont = UIFont.systemFontOfSize(12, weight: UIFontWeightLight)
        fansLbl.textColor = lblTextColor
        fansLbl.text = LS("粉丝")
        fansLbl.font = lblFont
        self.addSubview(fansLbl)
        fansLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(fansNumLbl!)
            make.top.equalTo(fansNumLbl!.snp_bottom).offset(2)
        }
        // 
        statusNumLbl = UILabel()
        statusNumLbl?.font = numFont
        statusNumLbl?.textColor = UIColor.blackColor()
        statusNumLbl?.text = "\(profile?.statusNum)"
        self.addSubview(statusNumLbl!)
        let screenWidth = self.bounds.width
        statusNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(fansNumLbl!)
            make.centerX.equalTo(self).offset(-0.24 * screenWidth)
        })
        //
        let statusLbl = UILabel()
        statusLbl.font = lblFont
        statusLbl.textColor = lblTextColor
        statusLbl.text = LS("动态")
        self.addSubview(statusLbl)
        statusLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(statusNumLbl!)
            make.top.equalTo(fansLbl)
        }
        // 
        followNumLbl = UILabel()
        followNumLbl?.font = numFont
        followNumLbl?.textColor = UIColor.blackColor()
        followNumLbl?.text = "\(profile?.followNum)"
        self.addSubview(followNumLbl!)
        followNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(fansNumLbl!)
            make.centerX.equalTo(self).offset(0.24 * screenWidth)
        })
        // 
        let followLbl = UILabel()
        followLbl.text = LS("关注")
        followLbl.font = lblFont
        followLbl.textColor = lblTextColor
        self.addSubview(followLbl)
        followLbl.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(followNumLbl!)
            make.top.equalTo(fansLbl)
        })
    }
    
    deinit {
        for task in self.tasks {
            task?.cancel()
        }
    }
}


// MARK: - 数据设置
extension PersonInfoView {
    
    /**
     重新读取user数据然后更新UI
     */
    func setUserAndUpdateUI() {
        // 头像
        let avatarURL = SFURL(user?.avatarUrl ?? "")
        avatar?.kf_setImageWithURL(avatarURL!)
        // 头像旁边的认证车辆的标识
        let profile = user?.profile
        let avatarCarURL = SFURL(profile?.avatarCarImage ?? "")
        avatarCar?.kf_setImageWithURL(avatarCarURL!)
        // 认证俱乐部的标识
        let avatarClubURL = SFURL(profile?.avatarClubLogo ?? "")
        avatarClub?.kf_setImageWithURL(avatarClubURL!)
        // 跑车名称
        avatarCarNameLbl?.text = profile?.avatarCarName
        // 性别年龄标签
        let genderText = (user?.gender == "男") ? "♀":"♂"
        let genderColor = (user?.gender == "男") ? UIColor(red: 0.227, green: 0.439, blue: 0.686, alpha: 1) : UIColor(red: 0.686, green: 0.227, blue: 0.490, alpha: 1)
        genderAgeLbl?.text = "\(genderText)\(user?.age)"
        genderAgeLbl?.backgroundColor = genderColor
        // 用户昵称
        let name = user?.nickName
        nameLbl?.text = name?.length < 4 ? name : name![0..<4] + "..."
        // 
        fansNumLbl?.text = "\(profile?.fansNum)"
        statusNumLbl?.text = "\(profile?.statusNum)"
        followNumLbl?.text = "\(profile?.followNum)"
//         self.layoutIfNeeded()
//         self.setNeedsDisplay()
    }
    
    
    /**
     根据当前设置的用户的数据创建下面的选择跑车的按钮
     */
    func createButtons() {
        // 清除现在已经有的buttons
        for btn in self.carBtns {
            btn.removeFromSuperview()
        }
        // 首先获取的用户拥有的车辆
        let ownership = user?.ownership
        //
        let font = UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        let btnBGColor = UIColor(white: 0.878, alpha: 1)
        let roundCornerRadius = 6.5
        let screenWidth = self.frame.width
        //
        let firstBtn = UIButton()
        firstBtn.setTitle(LS("动态"), forState: .Normal)
        slctBoard?.addSubview(firstBtn)
        firstBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(slctBoard!)
            make.width.equalTo(slctBoard!).multipliedBy(0.333)
            make.height.equalTo(slctBoard!)
            make.centerY.equalTo(slctBoard!)
        }
        firstBtn.tag = 0
        carBtns.append(firstBtn)
        
        var lstBtn: UIButton = firstBtn
        if ownership != nil {
            for o in ownership! {
                let newBtn = UIButton()
                newBtn.setTitle(o.car?.name, forState: .Normal)
                newBtn.tag = 1  // 这里tag只是用来区分按钮的类型，-1为添加新的车辆，0为添加
                slctBoard?.addSubview(newBtn)
                newBtn.snp_makeConstraints(closure: { (make) -> Void in
                    make.left.equalTo(lstBtn)
                    make.height.equalTo(slctBoard!)
                    make.width.equalTo(slctBoard!).multipliedBy(0.333)
                    make.centerY.equalTo(slctBoard!)
                })
                lstBtn = newBtn
            }
        }
        let addCarsBtn = UIButton()
        slctBoard?.addSubview(addCarsBtn)
        addCarsBtn.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(lstBtn)
            make.height.equalTo(slctBoard!)
            make.width.equalTo(slctBoard!).multipliedBy(0.333)
            make.centerY.equalTo(slctBoard!)
        }
        slctBoard?.tag = -1
        slctBoard?.contentSize = CGSize(width: screenWidth * CGFloat(carBtns.count), height: slctBoard!.frame.height)

    }
    
    func slctBtnPressed() {
        
    }
    
}
