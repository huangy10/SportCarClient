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
            editBtn.hidden = !showEditBtn
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
    var commentNumLbl: UILabel!
    var memberDisplay: InlineUserSelectController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        superview.backgroundColor = UIColor.whiteColor()
        //
        actCover = UIImageView()
        superview.addSubview(actCover)
        actCover.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(actCover.snp_width).multipliedBy(0.5733)
        }
        actCover.highlighted = true
        //
        backMaskView = BackMaskView()
        backMaskView.centerHegiht = 28
        backMaskView.ratio = -0.15
        backMaskView.backgroundColor = UIColor.clearColor()
        superview.addSubview(backMaskView)
        backMaskView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(actCover)
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.bottom.equalTo(actCover)
//            make.height.equalTo(56)
        }
        editBtn = UIButton()
        editBtn.hidden = !showEditBtn
        editBtn.setTitle(LS("编辑"), forState: .Normal)
        editBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        editBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        superview.addSubview(editBtn)
        editBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.bottom.equalTo(actCover).offset(-16)
            make.size.equalTo(CGSizeMake(30, 20))
        }
        //
        actNameLbl = UILabel()
        actNameLbl.font = UIFont.systemFontOfSize(21, weight: UIFontWeightSemibold)
        actNameLbl.textColor = UIColor.blackColor()
        superview.addSubview(actNameLbl)
        actNameLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.centerY.equalTo(actCover.snp_bottom)
            make.width.equalTo(superview).multipliedBy(0.5)
        }
        // 
        desLbl = UILabel()
        desLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        desLbl.textColor = UIColor.blackColor()
        superview.addSubview(desLbl)
        desLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(actNameLbl)
            make.top.equalTo(actNameLbl.snp_bottom).offset(10)
//            make.right.lessThanOrEqualTo(superview).offset(-20)
        }
        //
        doneIcon = UIImageView(image: UIImage(named: "activity_done"))
        superview.addSubview(doneIcon)
        doneIcon.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(actNameLbl.snp_bottom)
            make.right.equalTo(superview).offset(-29)
            make.size.equalTo(CGSizeMake(100, 85))
        }
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.94, alpha: 1)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(desLbl.snp_bottom).offset(27.5)
            make.height.equalTo(0.5)
        }
        //
        hostAvatar = UIButton()
        hostAvatar.layer.cornerRadius = 17.5
        hostAvatar.clipsToBounds = true
        superview.addSubview(hostAvatar)
        hostAvatar.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(20)
            make.top.equalTo(sepLine).offset(27.5)
            make.size.equalTo(35)
        }
        hostAvatar.addTarget(self, action: "hostAvatarPressed", forControlEvents: .TouchUpInside)
        //
        hostNameLbL = UILabel()
        hostNameLbL.textColor = UIColor.blackColor()
        hostNameLbL.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        superview.addSubview(hostNameLbL)
        hostNameLbL.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(hostAvatar.snp_right).offset(13)
            make.bottom.equalTo(hostAvatar.snp_centerY)
        }
        //
        releaseDateLbl = UILabel()
        releaseDateLbl.textColor = UIColor(white: 0.72, alpha: 1)
        releaseDateLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(releaseDateLbl)
        releaseDateLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(hostNameLbL)
            make.top.equalTo(hostNameLbL.snp_bottom).offset(3)
        }
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl.textColor = UIColor(white: 0.72, alpha: 1)
        avatarCarNameLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(avatarCarNameLbl)
        avatarCarNameLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(hostAvatar)
        }
        //
        avatarCarLogo = UIImageView()
        superview.addSubview(avatarCarLogo)
        avatarCarLogo.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(avatarCarNameLbl.snp_left).offset(-2)
            make.centerY.equalTo(avatarCarNameLbl)
            make.size.equalTo(21)
        }
        //
        let locIcon = UIImageView(image: UIImage(named: "status_location_icon"))
        superview.addSubview(locIcon)
        locIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(hostAvatar.snp_bottom).offset(27)
            make.size.equalTo(CGSizeMake(13.5, 18))
        }
        //
        locationLbl = UILabel()
        locationLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        locationLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(locationLbl)
        locationLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(locIcon.snp_right).offset(11)
            make.centerY.equalTo(locIcon)
        }
        //
        attendNumLbl = UILabel()
        attendNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        attendNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        attendNumLbl.textAlignment = .Right
        superview.addSubview(attendNumLbl)
        attendNumLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(locationLbl)
        }
        // 
        let timeIcon = UIImageView(image: UIImage(named: "time_icon"))
        superview.addSubview(timeIcon)
        timeIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(locationLbl.snp_bottom).offset(10)
            make.size.equalTo(14)
        }
        //
        actTimeLbl = UILabel()
        actTimeLbl.textColor = UIColor(white: 0.72, alpha: 1)
        actTimeLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(actTimeLbl)
        actTimeLbl.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(timeIcon.snp_right).offset(11)
            make.centerY.equalTo(timeIcon)
        }
        //
        commentNumLbl = UILabel()
        commentNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(commentNumLbl)
        commentNumLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(actTimeLbl)
        }
        //
        let commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        superview.addSubview(commentIcon)
        commentIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(commentNumLbl.snp_left).offset(-4)
            make.centerY.equalTo(commentNumLbl)
            make.size.equalTo(15)
        }
        //
        likeNumLbl = UILabel()
        likeNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        likeNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(likeNumLbl)
        likeNumLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(commentIcon.snp_left).offset(-32)
            make.centerY.equalTo(commentIcon)
        }
        //
        let likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        superview.addSubview(likeIcon)
        likeIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(likeNumLbl.snp_left).offset(-4)
            make.centerY.equalTo(likeNumLbl)
            make.size.equalTo(15)
        }
        //
        memberDisplay = InlineUserSelectController()
        superview.addSubview(memberDisplay.view)
        memberDisplay.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(timeIcon.snp_bottom).offset(23)
            make.height.equalTo(70)
        }
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(memberDisplay.view.snp_bottom).offset(33)
            make.height.equalTo(0.5)
        }
        //
        let commentStaticLbl = UILabel()
        commentStaticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentStaticLbl.text = LS("评论")
        commentStaticLbl.textAlignment = .Center
        superview.addSubview(commentStaticLbl)
        commentStaticLbl.backgroundColor = UIColor.whiteColor()
        commentStaticLbl.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(75)
            make.center.equalTo(sepLine2)
        }
    }
    
    func loadDataAndUpdateUI() -> CGFloat{
        // 活动海报
        actCover.kf_setImageWithURL(SFURL(act.poster!)!)
        // 是否显示编辑按钮
        let hostUser = User.objects.hostUser!
        if hostUser.userID == act.user?.userID {
            showEditBtn = true
            memberDisplay.showDeleteBtn = true
        }else{
            showEditBtn = false
            memberDisplay.showDeleteBtn = false
        }
        // 活动名称
        actNameLbl.text = act.name
        // 活动描述
        desLbl.text = act.actDescription
        // 完成标签
        let endAt = act.endAt
        doneIcon.hidden = endAt!.compare(NSDate()) == NSComparisonResult.OrderedDescending
        // 举办者的信息
        let host = act.user
        hostAvatar.kf_setImageWithURL(SFURL(host!.avatarUrl!)!, forState: .Normal)
        hostNameLbL.text = host?.nickName
        if let avatarCarURL = host?.profile?.avatarCarLogo {
            avatarCarLogo.kf_setImageWithURL(SFURL(avatarCarURL)!)
            avatarCarNameLbl.text = host?.profile?.avatarCarName
        }
        // 活动发布时间
        releaseDateLbl.text = STRDate(act.createdAt!)
        // 地址
        locationLbl.text = act.location_des
        // 评论数量
        commentNumLbl.text = "\(act.commentNum)"
        // 点赞数量
        likeNumLbl.text = "\(act.likeNum)"
        // 
        let joins = act.applicant
        var users = joins.map { (a) -> User in
            return a.user
        }
        users.insert(host!, atIndex: 0)
        memberDisplay.users = users
        memberDisplay.collectionView?.reloadData()
        let memberDisplayHeight = UIScreen.mainScreen().bounds.width / 4 * CGFloat((users.count + (memberDisplay.showDeleteBtn ? 2 : 1) + 1) / 4)
        memberDisplay.view.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(memberDisplayHeight)
        }
        // 人数要求
        attendNumLbl.text = "要求人数:\(act.maxAttend) 已报名:\(users.count)"
        // 
        actTimeLbl.text = activityTimeDes(act)
        //
        self.updateConstraints()
        self.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in self.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        return contentRect.height + 20
    }
    
    func editBtnPressed() {
        
    }
    
    func hostAvatarPressed() {
        
    }
}
