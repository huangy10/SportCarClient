//
//  ActivityDetailHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityDetailHeaderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var act: Activity!
    weak var parentController: ActivityDetailController?
    
    var cover: UIImageView!
    private var coverContainer: UIView!
    var backMaskView: BackMaskView!
    var actNameLbl: UILabel!
    var editBtn: UIButton!
    var desLbl: UILabel!
    
    var hostAvatar: UIButton!
    var hostNameLbl: UILabel!
    var releaseDateLbl: UILabel!
    
    var likeIcon: UIImageView!
    var likeNumLbl: UILabel!
    var commentIcon: UIImageView!
    var commentNumLbl: UILabel!
    
    var locationLbl: UILabel!
    var actDateLbl: UILabel!
    var attendNumLbl: UILabel!
    var inlineMiniUserSelect: UICollectionView!
    
    var preferedHeight: CGFloat = 0
    
    init (act: Activity) {
        super.init(frame: CGRectZero)
        self.act = act
        
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createSubviews() {
        let superview = self.config(UIColor.whiteColor())
        
        coverContainer = superview.addSubview(UIView).config(UIColor.clearColor())
            .layout({ (make) in
                make.top.equalTo(superview)
                make.centerX.equalTo(superview)
                make.width.equalTo(superview)
                make.height.equalTo(superview.snp_width).multipliedBy(0.588)
            })
        
        cover = coverContainer.addSubview(UIImageView).config(nil)
            .layout({ (make) in
                make.edges.equalTo(coverContainer)
            })
        
        backMaskView = BackMaskView()
        backMaskView.centerHegiht = 28
        backMaskView.ratio = -0.15
        backMaskView.backgroundColor = UIColor.clearColor()
        backMaskView.userInteractionEnabled = false
        superview.addSubview(backMaskView)
        backMaskView.snp_makeConstraints { (make) in
            make.edges.equalTo(cover)
        }
        editBtn = superview.addSubview(UIButton.self)
            .config(self, selector: #selector(editBtnPressed), title: LS("编辑"))
            .layout({ (make) in
                make.right.equalTo(superview).offset(-15)
                make.top.equalTo(superview).offset(14)
                make.size.equalTo(CGSizeMake(30, 20))
            })
        actNameLbl = superview.addSubview(UILabel.self)
            .config(21, fontWeight: UIFontWeightSemibold, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(superview).offset(20)
                make.top.equalTo(cover.snp_bottom)
                make.width.equalTo(superview).multipliedBy(0.5)
            })
        hostAvatar = superview.addSubview(UIButton.self)
            .config(self, selector: #selector(hostAvatarPressed))
            .layout({ (make) in
                make.left.equalTo(actNameLbl)
                make.top.equalTo(actNameLbl.snp_bottom).offset(9)
                make.size.equalTo(20)
            }).toRoundButton(10)
        hostNameLbl = superview.addSubview(UILabel.self)
            .config(14).layout({ (make) in
                make.left.equalTo(hostAvatar.snp_right).offset(7)
                make.bottom.equalTo(hostAvatar)
            })
        releaseDateLbl = superview.addSubview(UILabel.self)
            .config(12, textColor: UIColor(white: 0.72, alpha: 1))
            .layout({ (make) in
                make.left.equalTo(hostNameLbl.snp_right).offset(8)
                make.bottom.equalTo(hostNameLbl)
            })
        desLbl = superview.addSubview(UILabel.self)
            .config(15, multiLine: true).layout({ (make) in
                make.left.equalTo(hostAvatar)
                make.top.equalTo(hostAvatar.snp_bottom).offset(18)
            })
        commentNumLbl = superview.addSubview(UILabel.self)
            .config(12, textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Right)
            .layout({ (make) in
                make.right.equalTo(superview).offset(-20)
                make.top.equalTo(desLbl.snp_bottom).offset(10)
            })
        commentIcon = superview.addSubview(UIImageView.self)
            .config(UIImage(named: "news_comment"), contentMode: .ScaleAspectFit)
            .layout({ (make) in
                make.centerY.equalTo(commentNumLbl)
                make.right.equalTo(commentNumLbl.snp_left).offset(-4)
                make.size.equalTo(15)
            })
        likeNumLbl = superview.addSubview(UILabel.self)
            .styleCopy(commentNumLbl).layout({ (make) in
                make.right.equalTo(commentIcon).offset(-22.5)
                make.centerY.equalTo(commentIcon)
            })
        likeIcon = superview.addSubview(UIImageView.self)
            .config(UIImage(named: "news_like_unliked"), contentMode: .ScaleAspectFit)
            .layout({ (make) in
                make.centerY.equalTo(likeNumLbl)
                make.right.equalTo(likeNumLbl.snp_left).offset(-4)
                make.size.equalTo(15)
            })
        let sepLine = superview.addSubview(UIView.self).config(UIColor(white: 0.945, alpha: 1))
            .layout { (make) in
                make.left.equalTo(superview).offset(15)
                make.right.equalTo(superview).offset(-15)
                make.height.equalTo(0.5)
                make.top.equalTo(commentNumLbl.snp_bottom).offset(30)
        }
        superview.addSubview(UILabel).config(textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("详情"))
            .layout { (make) in
                make.center.equalTo(sepLine)
                make.width.equalTo(70)
        }.customize { (view) in
            view.backgroundColor = UIColor.whiteColor()
        }
        
        let bubble1 = superview.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.top.equalTo(sepLine.snp_bottom).offset(25)
                make.left.equalTo(superview).offset(25)
                make.size.equalTo(10)
        }.toRound(5)
        let static1 = superview.addSubview(UILabel)
            .config(textColor: UIColor(white: 0.72, alpha: 1), text: LS("活动地点"))
            .layout { (make) in
                make.left.equalTo(bubble1.snp_right).offset(20)
                make.top.equalTo(bubble1)
        }
        locationLbl = superview.addSubview(UILabel)
            .config(14).layout({ (make) in
                make.left.equalTo(static1)
                make.top.equalTo(static1.snp_bottom).offset(10)
            })
        let bubble2 = superview.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.left.equalTo(bubble1)
                make.top.equalTo(bubble1.snp_bottom).offset(65)
                make.size.equalTo(10)
        }.toRound(5)
        let static2 = superview.addSubview(UILabel).styleCopy(static1, text: LS("活动时间"))
            .layout { (make) in
                make.top.equalTo(bubble2)
                make.left.equalTo(static1)
        }
        actDateLbl = superview.addSubview(UILabel).styleCopy(locationLbl)
            .layout({ (make) in
                make.left.equalTo(locationLbl)
                make.top.equalTo(static2.snp_bottom).offset(10)
            })
        let bubble3 = superview.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.left.equalTo(bubble1)
                make.top.equalTo(bubble2.snp_bottom).offset(65)
                make.size.equalTo(10)
        }.toRound(5)
        let static3 = superview.addSubview(UILabel).styleCopy(static2, text: LS("活动人数"))
            .layout { (make) in
                make.top.equalTo(bubble3)
                make.left.equalTo(static2)
        }
        attendNumLbl = superview.addSubview(UILabel).styleCopy(locationLbl)
            .layout({ (make) in
                make.left.equalTo(actDateLbl)
                make.top.equalTo(static3.snp_bottom).offset(10)
            })
        let bubble4 = superview.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.left.equalTo(bubble3)
                make.top.equalTo(bubble3.snp_bottom).offset(65)
                make.size.equalTo(10)
        }.toRound(5)
        let static4 = superview.addSubview(UILabel).styleCopy(static3, text: LS("活动成员"))
            .layout { (make) in
                make.left.equalTo(static3)
                make.top.equalTo(bubble4)
        }
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSizeMake(35, 35)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .Vertical
        inlineMiniUserSelect = UICollectionView(frame: CGRectZero, collectionViewLayout: layout).config(UIColor.whiteColor())
        inlineMiniUserSelect.dataSource = self
        inlineMiniUserSelect.delegate = self
        superview.addSubview(inlineMiniUserSelect)
        inlineMiniUserSelect.layout { (make) in
            make.left.equalTo(static4)
            make.top.equalTo(static4.snp_bottom).offset(10)
            make.right.equalTo(superview).offset(-20)
            make.height.equalTo(35)
        }
        inlineMiniUserSelect.registerClass(InlineUserSelectMiniCell.self, forCellWithReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier)
        
        superview.addSubview(UIView).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.top.equalTo(bubble1.snp_centerY)
                make.bottom.equalTo(bubble4.snp_centerY)
                make.centerX.equalTo(bubble1)
                make.width.equalTo(0.5)
        }
        
        let sepLine2 = superview.addSubview(UIView.self).config(UIColor(white: 0.945, alpha: 1))
            .layout { (make) in
                make.left.equalTo(superview).offset(15)
                make.right.equalTo(superview).offset(-15)
                make.height.equalTo(0.5)
                make.top.equalTo(inlineMiniUserSelect.snp_bottom).offset(30)
        }
        superview.addSubview(UILabel)
            .config(UIColor.whiteColor())
            .config(textColor: UIColor(white: 0.72, alpha: 1), textAlignment: .Center, text: LS("评论"))
            .layout { (make) in
                make.center.equalTo(sepLine2)
                make.width.equalTo(70)
            }
    }
    
    func loadDataAndUpdateUI() -> CGFloat {
        cover.kf_setImageWithURL(act.posterURL!, placeholderImage: nil, optionsInfo: nil) { (image, error, cacheType, imageURL) in
            self.cover.setupForImageViewer(backgroundColor: UIColor.blackColor(), fadeToHide: true)
        }
        editBtn.hidden = !act.user!.isHost
        actNameLbl.text = act.name
        desLbl.text = act.actDescription
        hostAvatar.kf_setImageWithURL(act.user!.avatarURL!, forState: .Normal)
        hostNameLbl.text = act.user?.nickName
        releaseDateLbl.text = dateDisplay(act.createdAt!)
        locationLbl.text = act.location!.descr
        commentNumLbl.text = "\(act.commentNum)"
        likeNumLbl.text = "\(act.likeNum)"
        setLikeIconState(act.liked)
        attendNumLbl.text = "要求人数:\(act.maxAttend) 已报名:\(act.applicants.count)"
        actDateLbl.text = act.timeDes!
        
        inlineMiniUserSelect.reloadData()
        let inlineUserSelectHeight = max(35, inlineMiniUserSelect.contentSize.height)
        inlineMiniUserSelect.snp_updateConstraints { (make) in
            make.height.equalTo(inlineUserSelectHeight)
        }
        
        self.frame = UIScreen.mainScreen().bounds
        self.updateConstraints()
        self.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in self.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        preferedHeight = contentRect.height + 20
        self.snp_updateConstraints { (make) in
            make.height.equalTo(preferedHeight)
        }
        return contentRect.height + 20
    }
    
    func adjustCoverScaleAccordingToTableOffset(offset: CGFloat) {
        if offset >= 0 && offset < 10 {
            cover.transform = CGAffineTransformIdentity
            cover.snp_remakeConstraints(closure: { (make) in
                make.edges.equalTo(coverContainer)
            })
        } else if offset < 0 {
            let scaleFactor = (-offset) / coverContainer.frame.height + 1
            cover.snp_remakeConstraints(closure: { (make) in
                make.centerX.equalTo(coverContainer)
                make.bottom.equalTo(coverContainer)
                make.size.equalTo(coverContainer).multipliedBy(scaleFactor)
            })
        }
    }
    
    // MARK: CollectionView

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return act.applicants.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(InlineUserSelectMiniCell.reuseIdentifier, forIndexPath: indexPath) as! InlineUserSelectMiniCell
        if indexPath.row < act.applicants.count {
            cell.user = act.applicants[indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "chat_settings_add_person")
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < act.applicants.count {
            let user = act.applicants[indexPath.row]
            parentController?.navigationController?.pushViewController(user.showDetailController(), animated: true)
        } else {
            var forceUsers = act.applicants
            forceUsers.append(act.user!)
            let select = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: forceUsers, preSelect: false)
            select.delegate = parentController
            parentController?.presentViewController(select.toNavWrapper(), animated: true, completion: nil)
        }
    }
    
    func editBtnPressed() {
        if act.finished {
            parentController?.showToast(LS("活动已结束，不能编辑"))
        } else {
            let detail = ActivityEditController()
            detail.act = act
            parentController?.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func hostAvatarPressed() {
        parentController?.navigationController?.pushViewController(act.user!.showDetailController(), animated: true)
    }
    
    func setLikeIconState(flag: Bool) {
        likeIcon.image = flag ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
    }
}
