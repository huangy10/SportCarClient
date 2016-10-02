//
//  ActivityDetailBoard.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class ActivityDetailBoardView: UIView {
    var act: Activity!
    var showEditBtn: Bool = true {
        didSet {
            editBtn.isHidden = !showEditBtn
        }
    }
    
    var actCover: UIImageView!
    var backMaskView: BackMaskView!
    var actNameLbl: UILabel!
    var editBtn: UIButton!
    var desLbl: UILabel!
    
    var doneIcon: UIImageView!
    var hostAvatar: UIButton!
    var hostNameLbL: UILabel!
    var releaseDateLbl: UILabel!
    var avatarCarLogo: UIImageView!
    var avatarCarNameLbl: UILabel!
    
    var locationLbl: UILabel!
    var attendNumLbl: UILabel!  // 已报名
    var actTimeLbl: UILabel!
    var likeNumLbl: UILabel!
    var likeIcon: UIImageView!
    var commentNumLbl: UILabel!
    var memberDisplay: InlineUserSelectController!
    
    weak var parentController: UIViewController? {
        didSet {
            memberDisplay.parentController = parentController
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        superview.backgroundColor = UIColor.white
        //
        actCover = UIImageView()
        actCover.contentMode = .scaleAspectFill
        actCover.clipsToBounds = true
        superview.addSubview(actCover)
        actCover.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(actCover.snp.width).multipliedBy(0.5733)
        }
        actCover.isHighlighted = true
        //
        backMaskView = BackMaskView()
        backMaskView.centerHegiht = 28
        backMaskView.ratio = -0.15
        backMaskView.backgroundColor = UIColor.clear
        superview.addSubview(backMaskView)
        backMaskView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(actCover)
        }
        editBtn = UIButton()
        editBtn.isHidden = !showEditBtn
        editBtn.setTitle(LS("编辑"), for: UIControlState())
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        editBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        superview.addSubview(editBtn)
        editBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.bottom.equalTo(actCover).offset(-16)
            make.size.equalTo(CGSize(width: 30, height: 20))
        }
        //
        actNameLbl = UILabel()
        actNameLbl.font = UIFont.systemFont(ofSize: 21, weight: UIFontWeightSemibold)
        actNameLbl.textColor = UIColor.black
        actNameLbl.numberOfLines = 0
        superview.addSubview(actNameLbl)
        actNameLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.centerY.equalTo(actCover.snp.bottom)
            make.width.equalTo(superview).multipliedBy(0.5)
        }
        // 
        desLbl = UILabel()
        desLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        desLbl.textColor = UIColor.black
        superview.addSubview(desLbl)
        desLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(actNameLbl)
            make.top.equalTo(actNameLbl.snp.bottom).offset(10)
        }
        //
        doneIcon = UIImageView(image: UIImage(named: "activity_done_2"))
        superview.addSubview(doneIcon)
        doneIcon.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(actNameLbl.snp.bottom)
            make.right.equalTo(superview).offset(-29)
            make.size.equalTo(CGSize(width: 100, height: 85))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.94, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(desLbl.snp.bottom).offset(27.5)
            make.height.equalTo(0.5)
        }
        //
        hostAvatar = UIButton()
        hostAvatar.layer.cornerRadius = 17.5
        hostAvatar.clipsToBounds = true
        superview.addSubview(hostAvatar)
        hostAvatar.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.top.equalTo(sepLine).offset(27.5)
            make.size.equalTo(35)
        }
        //
        hostNameLbL = UILabel()
        hostNameLbL.textColor = UIColor.black
        hostNameLbL.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        superview.addSubview(hostNameLbL)
        hostNameLbL.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(hostAvatar.snp.right).offset(13)
            make.bottom.equalTo(hostAvatar.snp.centerY)
        }
        //
        releaseDateLbl = UILabel()
        releaseDateLbl.textColor = UIColor(white: 0.72, alpha: 1)
        releaseDateLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(releaseDateLbl)
        releaseDateLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(hostNameLbL)
            make.top.equalTo(hostNameLbL.snp.bottom).offset(3)
        }
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl.textColor = UIColor(white: 0.72, alpha: 1)
        avatarCarNameLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(avatarCarNameLbl)
        avatarCarNameLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(hostAvatar)
        }
        //
        avatarCarLogo = superview.addSubview(UIImageView.self)
            .config(nil)
            .layout(10.5, closurer: { (make) in
                make.right.equalTo(avatarCarNameLbl.snp.left).offset(-2)
                make.centerY.equalTo(avatarCarNameLbl)
                make.size.equalTo(21)
            })
        //
        let locIcon = UIImageView(image: UIImage(named: "status_location_icon"))
        superview.addSubview(locIcon)
        locIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(hostAvatar.snp.bottom).offset(27)
            make.size.equalTo(CGSize(width: 13.5, height: 18))
        }
        //
        locationLbl = UILabel()
        locationLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        locationLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(locationLbl)
        locationLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(locIcon.snp.right).offset(11)
            make.centerY.equalTo(locIcon)
        }
        //
        attendNumLbl = UILabel()
        attendNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        attendNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        attendNumLbl.textAlignment = .right
        superview.addSubview(attendNumLbl)
        attendNumLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(locationLbl)
        }
        // 
        let timeIcon = UIImageView(image: UIImage(named: "time_icon"))
        superview.addSubview(timeIcon)
        timeIcon.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(locationLbl.snp.bottom).offset(20)
            make.size.equalTo(14)
        }
        //
        actTimeLbl = UILabel()
        actTimeLbl.textColor = UIColor(white: 0.72, alpha: 1)
        actTimeLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(actTimeLbl)
        actTimeLbl.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(timeIcon.snp.right).offset(11)
            make.centerY.equalTo(timeIcon)
        }
        //
        commentNumLbl = UILabel()
        commentNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(commentNumLbl)
        commentNumLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(actTimeLbl)
        }
        //
        let commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        superview.addSubview(commentIcon)
        commentIcon.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(commentNumLbl.snp.left).offset(-4)
            make.centerY.equalTo(commentNumLbl)
            make.size.equalTo(15)
        }
        //
        likeNumLbl = UILabel()
        likeNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        likeNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(likeNumLbl)
        likeNumLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(commentIcon.snp.left).offset(-32)
            make.centerY.equalTo(commentIcon)
        }
        //
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        superview.addSubview(likeIcon)
        likeIcon.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(likeNumLbl.snp.left).offset(-4)
            make.centerY.equalTo(likeNumLbl)
            make.size.equalTo(15)
        }
        //
        memberDisplay = InlineUserSelectController()
        superview.addSubview(memberDisplay.view)
        memberDisplay.view.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(timeIcon.snp.bottom).offset(23)
            make.height.equalTo(70)
        }
        memberDisplay.parentController = parentController
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(sepLine2)
        sepLine2.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(memberDisplay.view.snp.bottom).offset(33)
            make.height.equalTo(0.5)
        }
        //
        let commentStaticLbl = UILabel()
        commentStaticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentStaticLbl.text = LS("评论")
        commentStaticLbl.textAlignment = .center
        superview.addSubview(commentStaticLbl)
        commentStaticLbl.backgroundColor = UIColor.white
        commentStaticLbl.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(75)
            make.center.equalTo(sepLine2)
        }
        superview.bringSubview(toFront: doneIcon)
    }
    
    func loadDataAndUpdateUI() -> CGFloat{
        // 活动海报
        actCover.kf.setImage(with: act.posterURL!)
        // 是否显示编辑按钮
        if act.user!.isHost {
            showEditBtn = true
        }else{
            showEditBtn = false
        }
        // 活动名称
        actNameLbl.text = act.name
        // 活动描述
        desLbl.text = act.actDescription
        // 完成标签
        let endAt = act.endAt
        doneIcon.isHidden = endAt!.compare(Date()) == ComparisonResult.orderedDescending
        // 举办者的信息
        let host = act.user
        hostAvatar.kf.setImage(with: host!.avatarURL!, for: .normal)
        hostNameLbL.text = host?.nickName
        if let avatarCarURL = host?.avatarCarModel?.logoURL {
            avatarCarLogo.kf.setImage(with: avatarCarURL)
            avatarCarNameLbl.text = host?.avatarCarModel?.name
        }
        // 活动发布时间
        releaseDateLbl.text = dateDisplay(act.createdAt!)
        // 地址
        locationLbl.text = act.location?.descr
        // 评论数量
        commentNumLbl.text = "\(act.commentNum)"
        // 点赞数量
        likeNumLbl.text = "\(act.likeNum)"
        setLikeIconState(act.liked)
        // 
        let users = act.applicants
        memberDisplay.users = users
        memberDisplay.collectionView?.reloadData()
//        let memberDisplayHeight = UIScreen.main.bounds.width / 4 * CGFloat((users.count + (memberDisplay.showDeleteBtn ? 2 : 1) - 1) / 4 + 1)
        
        let memberDisplayCount = users.count + (memberDisplay.showDeleteBtn ? 2 : 1)
        let memberDisplayRows = (memberDisplayCount - 1) / 4 + 1
        let memberDisplayHeight = UIScreen.main.bounds.width / 4 * CGFloat(memberDisplayRows)
        memberDisplay.view.snp.updateConstraints { (make) -> Void in
            make.height.equalTo(memberDisplayHeight)
        }
        // 人数要求
        attendNumLbl.text = "要求人数:\(act.maxAttend) 已报名:\(users.count)"
        // 
        actTimeLbl.text = act.timeDes
        //
        self.updateConstraints()
        self.layoutIfNeeded()
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        return contentRect.height + 20
    }
    
    func setLikeIconState(_ flag: Bool) {
        likeIcon.image = flag ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
    }
    
    func editBtnPressed() {
        
    }
}
