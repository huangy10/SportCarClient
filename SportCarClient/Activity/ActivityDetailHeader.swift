//
//  ActivityDetailHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/5.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol ActivityDetailHeaderDelegate: class {
    func detailHeaderEditBtnPressed()
    func detailHeaderLikeBtnPressed()
    func detailHeaderShowAllMemberBtnPressed()
    func detailHeaderUserSelected(_ user: User)
    func detailHeaderShowInvite()
    func detailHeaderShowLikeList()
}

class ActivityDetailHeaderView: UIView {
    var act: Activity
    weak var delegate: ActivityDetailHeaderDelegate!
    
    let coverHeightRatio: CGFloat = 0.588
    let coverExtraHeightRatio: CGFloat = 1.2
    var cover: UIImageView!
    var coverContainer: UIView!
    var backMask: BackMaskView!
    var editBtn: UIButton!
    var actNameLbl: UILabel!
    var releaseDateLbl: UILabel!
    var avatarImg: UIImageView!
    var hostNameLbl: UILabel!
    var desLbl: UILabel!
    var likeInfoLbl: UILabel!
    var opsView: SmallOperationBoard!
    
    var extraInfoStack: UIStackView!
    var actLocLbl: UILabel!
    var actTimeLbl: UILabel!
    var actMemberNumLbl: UILabel!
    var actMembersList: UICollectionView!
    var showAllMemberBtn: UIButton!
    
    init(activity: Activity) {
        act = activity
        super.init(frame: .zero)
        
        configureCover()
        configureEditBtn()
        configureActNameLbl()
        configureHostInfo()
        configureActReleaseDate()
        configureDesLbl()
        configureOpsView()
        configureLikeInfoLbl()
        configureExtraInfoSepLine()
        configureExtraInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureCover() {
        coverContainer = addSubview(UIView.self).config(.clear)
            .layout({ (make) in
                make.top.equalTo(self)
                make.width.equalTo(self)
                make.right.equalTo(self)
                make.height.equalTo(self.snp.width).multipliedBy(coverHeightRatio)
            })
        cover = coverContainer.addSubview(UIImageView.self)
            .layout({ (make) in
                make.left.equalTo(coverContainer)
                make.right.equalTo(coverContainer)
                make.top.equalTo(coverContainer).offset(0)
                make.height.equalTo(coverContainer).multipliedBy(coverExtraHeightRatio)
            })
        cover.contentMode = .scaleAspectFill
        
        backMask = BackMaskView()
        backMask.centerHegiht = 28
        backMask.ratio = -0.15
        backMask.backgroundColor = .clear
        backMask.isUserInteractionEnabled = false
        addSubview(backMask)
        backMask.snp.makeConstraints { (make) in
            make.edges.equalTo(coverContainer)
        }
        backMask.addShadow(opacity: 0.2, offset: CGSize(width: 0, height: -3))
        
        // 加一块白色的遮罩将cover底部超出的部分挡住
        addSubview(UIView.self).config(.white)
            .layout { (make) in
                make.top.equalTo(coverContainer.snp.bottom)
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.bottom.equalTo(cover)
        }
    }
    
    func configureEditBtn() {
        editBtn = addSubview(UIButton.self).config(self, selector: #selector(editBtnPressed), title: LS("编辑"))
            .layout({ (make) in
                make.right.equalTo(self).offset(-15)
                make.top.equalTo(self).offset(14)
                make.width.equalTo(30)
                make.height.equalTo(20)
            })
    }
    
    func configureActNameLbl() {
        actNameLbl = addSubview(UILabel.self).config(21, fontWeight: UIFontWeightSemibold, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(self).offset(20)
                make.top.equalTo(coverContainer.snp.bottom)
                make.width.equalTo(self).multipliedBy(0.6)
            })
    }
    
    func configureHostInfo() {
        avatarImg = addSubview(UIImageView.self)
            .layout({ (make) in
                make.left.equalTo(actNameLbl)
                make.top.equalTo(actNameLbl.snp.bottom).offset(9)
                make.size.equalTo(20)
            }).toRound(10)
        
        hostNameLbl = addSubview(UILabel.self).config(14)
            .layout({ (make) in
                make.left.equalTo(avatarImg.snp.right).offset(7)
                make.bottom.equalTo(avatarImg)
            })
    }
    
    func configureActReleaseDate() {
        releaseDateLbl = addSubview(UILabel.self).config(12, textColor: kTextGray28)
            .layout({ (make) in
                make.left.equalTo(hostNameLbl.snp.right).offset(8)
                make.bottom.equalTo(avatarImg)
            })
    }
    
    func configureDesLbl() {
        desLbl = addSubview(UILabel.self).config(15, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(avatarImg)
                make.right.equalTo(self).offset(-20)
                make.top.equalTo(avatarImg.snp.bottom).offset(18)
            })
        desLbl.numberOfLines = 0
        desLbl.lineBreakMode = .byCharWrapping
    }
    
    func configureLikeInfoLbl() {
        likeInfoLbl = addSubview(UILabel.self)
            .layout({ (mk) in
                mk.centerY.equalTo(opsView)
                mk.left.equalTo(desLbl)
                mk.right.equalTo(opsView.snp.left)
            })
        addSubview(UIButton.self).config(self, selector: #selector(showLikeListPressed))
            .layout { (mk) in
                mk.right.equalTo(likeInfoLbl)
                mk.left.equalTo(likeInfoLbl)
                mk.centerY.equalTo(likeInfoLbl)
                mk.height.equalTo(40)
        }
    }
    
    func configureOpsView() {
        opsView = SmallOperationBoard(delegate: self)
        addSubview(opsView)
        opsView.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.top.equalTo(desLbl.snp.bottom).offset(20)
            make.width.equalTo(opsView.requiredWidth())
            make.height.equalTo(18)
        }
    }
    
    func configureExtraInfoSepLine() {
        let line = addSubview(UIView.self).config(kTextGray28)
            .layout { (make) in
                make.right.equalTo(self).offset(-15)
                make.left.equalTo(self).offset(15)
                make.top.equalTo(opsView.snp.bottom).offset(30)
                make.height.equalTo(0.5)
        }
        
        addSubview(UILabel.self).config(textColor: kTextGray28, textAlignment: .center, text: LS("评论")).config(.white)
            .layout { (make) in
                make.center.equalTo(line)
                make.width.equalTo(70)
        }
    }
    
    func configureExtraInfo() {
        extraInfoStack = UIStackView()
        addSubview(extraInfoStack)
        extraInfoStack.axis = .vertical
        extraInfoStack.alignment = .center
        extraInfoStack.distribution = .equalSpacing
        extraInfoStack.spacing = 0
        extraInfoStack.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(opsView.snp.bottom).offset(55)
//            make.height.equalTo(300)
//            make.bottom.equalTo(self)
        }
        
        var infoLbls: [UILabel] = []
        var bubbles: [UIView] = []
        ["活动地点", "活动时间", "活动人数", "活动成员"].enumerated().forEach { (idx, text) in
            let container = UIView()
            extraInfoStack.addArrangedSubview(container)
            container.heightAnchor.constraint(equalToConstant: 75).isActive = true
            container.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
            
            let bubble = container.addSubview(UIView.self).config(kHighlightedRedTextColor)
                .layout({ (make) in
                    make.top.equalTo(container)
                    make.left.equalTo(container).offset(25)
                    make.size.equalTo(10)
                })
            bubble.layer.cornerRadius = 5
            bubbles.append(bubble)
            
            let sLbl = container.addSubview(UILabel.self).config(textColor: kTextGray28, text: LS(text))
                .layout({ (make) in
                    make.left.equalTo(bubble.snp.right).offset(20)
                    make.top.equalTo(bubble)
                })
            
            if idx < 3 {
                let infoLbl = container.addSubview(UILabel.self).config(14).layout({ (make) in
                    make.left.equalTo(sLbl)
                    make.top.equalTo(sLbl.snp.bottom).offset(10)
                })
                infoLbls.append(infoLbl)
            } else {
                let layout = UICollectionViewFlowLayout()
                layout.itemSize = CGSize(width: 35, height: 35)
                layout.minimumInteritemSpacing = 5
                layout.minimumLineSpacing = 5
                layout.scrollDirection = .vertical
                actMembersList = UICollectionView(frame: .zero, collectionViewLayout: layout)
                actMembersList.backgroundColor = .white
                actMembersList.delegate = self
                actMembersList.dataSource = self
                container.addSubview(actMembersList)
                actMembersList.snp.makeConstraints({ (make) in
                    make.left.equalTo(sLbl)
                    make.top.equalTo(sLbl.snp.bottom).offset(10)
                    make.width.equalTo(35)
                    make.height.equalTo(35)
                })
                
                actMembersList.register(InlineUserSelectMiniCell.self, forCellWithReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier)
                
                showAllMemberBtn = container.addSubview(UIButton.self)
                    .config(self, selector: #selector(showAllMemberBtnPressed))
                    .layout({ (make) in
                        make.left.equalTo(actMembersList.snp.right).offset(5)
                        make.height.equalTo(35)
                        make.width.equalTo(60)
                        make.centerY.equalTo(actMembersList)
                    })
                showAllMemberBtn.setTitle(LS("全部"), for: .normal)
                showAllMemberBtn.setTitleColor(kHighlightRed, for: .normal)
                showAllMemberBtn.layer.borderColor = kHighlightRed.cgColor
                showAllMemberBtn.layer.borderWidth = 0.5
                showAllMemberBtn.layer.cornerRadius = 17.5
            }
        }
        extraInfoStack.addSubview(UIView.self).config(kHighlightedRedTextColor)
            .layout { (make) in
                make.top.equalTo(bubbles.first()!)
                make.bottom.equalTo(bubbles.last()!)
                make.centerX.equalTo(bubbles.first()!)
                make.width.equalTo(0.5)
        }
        
        actLocLbl = infoLbls[0]
        actTimeLbl = infoLbls[1]
        actMemberNumLbl = infoLbls[2]
    }
    
    func editBtnPressed() {
        delegate.detailHeaderEditBtnPressed()
    }
    
    func likeBtnPressed() {
        delegate.detailHeaderLikeBtnPressed()
    }
    
    func showAllMemberBtnPressed() {
        delegate.detailHeaderShowAllMemberBtnPressed()
    }
    
    func showLikeListPressed() {
        delegate.detailHeaderShowLikeList()
    }
    
    func loadDataAndUpdateUI() {
        cover.kf.setImage(with: act.posterURL!, placeholder: nil, options: nil, progressBlock: nil) { (image, _, _, _) in
            self.cover.setupForImageViewer(nil, backgroundColor: UIColor.black, fadeToHide: true)
        }
        editBtn.isHidden = !act.user!.isHost
        actNameLbl.text = act.name
        desLbl.text = act.actDescription
        avatarImg.kf.setImage(with: act.user!.avatarURL!)
        hostNameLbl.text = act.user!.nickName
        releaseDateLbl.text = dateDisplay(act.createdAt!)
        actLocLbl.text = act.location!.descr
        opsView.reloadAll()
        let attendNumDes = "要求人数:\(act.maxAttend) 已报名:\(act.applicants.count)"
        if act.authedUserOnly {
            actMemberNumLbl.text = "\(attendNumDes)(\(LS("仅认证用户")))"
        } else {
            actMemberNumLbl.text = attendNumDes
        }
        actTimeLbl.text = act.timeDes
        reloadMemberList()
        
        updateLikeInfoLbl()
    }
    
    func updateLikeInfoLbl() {
        if let recentLike = act.recentLikeUserName {
            likeInfoLbl.attributedText = makeLikeInfoText(recentLikeUserName: recentLike, likeNum: Int(act.likeNum))
        } else {
            likeInfoLbl.attributedText = nil
        }
    }
    
    func makeLikeInfoText(recentLikeUserName: String, likeNum: Int) -> NSAttributedString {
        if likeNum == 0 {
            return NSAttributedString(string: "还没有人点赞", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)])
        }
        let result: NSMutableAttributedString
        if likeNum == 1 {
            result = NSMutableAttributedString(string: "\(recentLikeUserName)赞了")
        } else {
            result = NSMutableAttributedString(string: "\(recentLikeUserName)和其他\(likeNum - 1)人赞了")
        }
        result.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular), range: NSRange(location: 0, length: result.length))
        result.addAttribute(NSForegroundColorAttributeName, value: kTextGray54, range: NSRange(location: recentLikeUserName.length, length: result.length - recentLikeUserName.length))
        result.addAttribute(NSForegroundColorAttributeName, value: kHighlightRed, range: NSRange(location: 0, length:recentLikeUserName.length))
        return result
    }
    
    func reloadMemberList() {
        actMembersList.reloadData()
        let cellNum = min(estimatedDisplayCellNumber(), act.applicants.count + 1)
        actMembersList.snp.updateConstraints { (make) in
            make.width.equalTo(CGFloat(cellNum) * 40 - 5)
        }
        setNeedsLayout()
    }
    
    func requiredHeight() -> CGFloat {
        frame = UIScreen.main.bounds
        layoutIfNeeded()
        
        var rect: CGRect = .zero
        for view in subviews {
            rect = rect.union(view.frame)
        }
        return rect.height + 20
    }
    
    func estimatedDisplayCellNumber() -> Int {
        let screenWidth = UIScreen.main.bounds.width
        let leftOffset: CGFloat = 25 + 10 + 20
        let rightOffset: CGFloat = 15 + (act.user!.isHost ? (60 + 5) : 0)
        let maxWidth = screenWidth - leftOffset - rightOffset
        let cellWidth: CGFloat = 35
        let cellInterval: CGFloat = 5
        
        return Int((maxWidth + cellInterval) / (cellWidth + cellInterval))
    }
    
    func adjustCoverScaleAccordingToTableOffset(_ offset: CGFloat) {
        let coverHeight = UIScreen.main.bounds.width * 0.588
        let extraHeight = coverHeight * (coverExtraHeightRatio - 1)
        if offset >= 0 {
            cover.transform = CGAffineTransform.identity
            if offset <= coverHeight {
                let relativeMove = extraHeight * (offset / coverHeight)
                setCoverRelativeMove(relativeMove)
            }
        } else if offset < 0 {
            let scaleFactor = (-offset) / coverContainer.frame.height + 1
            cover.snp.remakeConstraints({ (make) in
                make.centerX.equalTo(coverContainer)
                make.bottom.equalTo(coverContainer).offset(extraHeight)
                make.width.equalTo(coverContainer).multipliedBy(scaleFactor)
                make.height.equalTo(coverContainer).multipliedBy(scaleFactor * coverExtraHeightRatio)
            })
        }
    }
    
    func setCoverRelativeMove(_ y: CGFloat) {
        cover.snp.remakeConstraints { (make) in
            make.left.equalTo(coverContainer)
            make.right.equalTo(coverContainer)
            make.height.equalTo(coverContainer).multipliedBy(coverExtraHeightRatio)
            make.top.equalTo(coverContainer).offset(-y)
        }
        layoutIfNeeded()
    }
}

extension ActivityDetailHeaderView: SmallOpertaionDelegate {
    func smallOperationBtnPressed(atIdx idx: Int) {
        if idx == 0 {
            likeBtnPressed()
        }
    }
    
    func smallOperationIconImage(forIdx idx: Int) -> UIImage? {
        if idx == 0 && act.liked {
            return UIImage(named: "news_like_liked")
        } else if idx == 0 {
            return UIImage(named: "news_like_unliked")
        } else if idx == 1 {
            return UIImage(named: "news_comment")
        } else {
            fatalError()
        }
    }
    
    func numberOfBtnsInSmallOperationBoard() -> Int {
        return 2
    }
    
    func smallOperationLblVal(foridx idx: Int) -> Int {
        if idx == 0 {
            return Int(act.likeNum)
        } else if idx == 1 {
            return Int(act.commentNum)
        } else {
            fatalError()
        }
    }
}

extension ActivityDetailHeaderView: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return getCellNumbers()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier, for: indexPath) as! InlineUserSelectMiniCell
        
        let cellCount = min(estimatedDisplayCellNumber(), act.applicants.count + 1)
        if (indexPath as NSIndexPath).row < cellCount - 1 {
            cell.user = act.applicants[indexPath.row]
        } else {
            cell.imageView.image = UIImage(named: "chat_settings_add_person")
        }
        return cell
    }
    
    func getCellNumbers() -> Int {
        return min(estimatedDisplayCellNumber(), act.applicants.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row < getCellNumbers() - 1 {
            let user = act.applicants[indexPath.row]
            delegate.detailHeaderUserSelected(user)
        } else {
            delegate.detailHeaderShowInvite()
        }
    }
}

//
//
//class ActivityDetailHeaderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, ActivityMemberDelegate {
//    var act: Activity!
//    weak var parentController: ActivityDetailController?
//    
//    var cover: UIImageView!
//    fileprivate var coverContainer: UIView!
//    var backMaskView: BackMaskView!
//    var actNameLbl: UILabel!
//    var editBtn: UIButton!
//    var desLbl: UILabel!
//    
//    var hostAvatar: UIButton!
//    var hostNameLbl: UILabel!
//    var releaseDateLbl: UILabel!
//    
//    var likeIcon: UIImageView!
//    var likeBtn: UIButton!
//    var likeNumLbl: UILabel!
//    var commentIcon: UIImageView!
//    var commentNumLbl: UILabel!
//    
//    var locationLbl: UILabel!
//    var actDateLbl: UILabel!
//    var attendNumLbl: UILabel!
//    var inlineMiniUserSelect: UICollectionView!
//    var showAllMemberBtn: UIButton!
//    
//    var preferedHeight: CGFloat = 0
//    
//    
//    //
//    let coverExtraHeightRatio: CGFloat = 1.4
//    
//    init (act: Activity) {
//        super.init(frame: CGRect.zero)
//        self.act = act
//        
//        createSubviews()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func setCoverRelativeMove(_ y: CGFloat) {
//        cover.snp.remakeConstraints { (make) in
//            make.left.equalTo(coverContainer)
//            make.right.equalTo(coverContainer)
//            make.height.equalTo(coverContainer).multipliedBy(coverExtraHeightRatio)
//            make.top.equalTo(coverContainer).offset(-y)
//        }
//        layoutIfNeeded()
//    }
//    
//    fileprivate func createSubviews() {
//        let superview = self.config(UIColor.white)
//        
//        coverContainer = superview.addSubview(UIView.self).config(UIColor.clear)
//            .layout({ (make) in
//                make.top.equalTo(superview)
//                make.centerX.equalTo(superview)
//                make.width.equalTo(superview)
//                make.height.equalTo(superview.snp.width).multipliedBy(0.588)
//            })
//        
//        cover = coverContainer.addSubview(UIImageView.self).config(nil)
//            .layout({ (make) in
//                make.left.equalTo(coverContainer)
//                make.right.equalTo(coverContainer)
//                make.top.equalTo(coverContainer).offset(0)
//                make.height.equalTo(coverContainer).multipliedBy(coverExtraHeightRatio)
//            })
//        cover.contentMode = .scaleAspectFill
//        
//        backMaskView = BackMaskView()
//        backMaskView.centerHegiht = 28
//        backMaskView.ratio = -0.15
//        backMaskView.backgroundColor = UIColor.clear
//        backMaskView.isUserInteractionEnabled = false
//        superview.addSubview(backMaskView)
//        backMaskView.snp.makeConstraints { (make) in
//            make.edges.equalTo(coverContainer)
//        }
//        backMaskView.addShadow(opacity: 0.1, offset: CGSize(width: 0, height: -3))
//        
//        superview.addSubview(UIView.self).config(UIColor.white)
//            .layout { (make) in
//                make.top.equalTo(coverContainer.snp.bottom)
//                make.left.equalTo(superview)
//                make.right.equalTo(superview)
//                make.bottom.equalTo(cover)
//        }
//        editBtn = superview.addSubview(UIButton.self)
//            .config(self, selector: #selector(editBtnPressed), title: LS("编辑"))
//            .layout({ (make) in
//                make.right.equalTo(superview).offset(-15)
//                make.top.equalTo(superview).offset(14)
//                make.size.equalTo(CGSize(width: 30, height: 20))
//            })
//        actNameLbl = superview.addSubview(UILabel.self)
//            .config(21, fontWeight: UIFontWeightSemibold, multiLine: true)
//            .layout({ (make) in
//                make.left.equalTo(superview).offset(20)
//                make.top.equalTo(coverContainer.snp.bottom)
//                make.width.equalTo(superview).multipliedBy(0.6)
//            })
//        hostAvatar = superview.addSubview(UIButton.self)
//            .config(self, selector: #selector(hostAvatarPressed))
//            .layout({ (make) in
//                make.left.equalTo(actNameLbl)
//                make.top.equalTo(actNameLbl.snp.bottom).offset(9)
//                make.size.equalTo(20)
//            }).toRoundButton(10)
//        hostNameLbl = superview.addSubview(UILabel.self)
//            .config(14).layout({ (make) in
//                make.left.equalTo(hostAvatar.snp.right).offset(7)
//                make.bottom.equalTo(hostAvatar)
//            })
//        releaseDateLbl = superview.addSubview(UILabel.self)
//            .config(12, textColor: kTextGray28)
//            .layout({ (make) in
//                make.left.equalTo(hostNameLbl.snp.right).offset(8)
//                make.bottom.equalTo(hostNameLbl)
//            })
//        desLbl = superview.addSubview(UILabel.self)
//            .config(15, multiLine: true).layout({ (make) in
//                make.left.equalTo(hostAvatar)
//                make.right.equalTo(superview).offset(-20)
//                make.top.equalTo(hostAvatar.snp.bottom).offset(18)
//            })
//        desLbl.numberOfLines = 0
//        desLbl.lineBreakMode = .byCharWrapping
//        
//        commentNumLbl = superview.addSubview(UILabel.self)
//            .config(12, textColor: kTextGray28, textAlignment: .right)
//            .layout({ (make) in
//                make.right.equalTo(superview).offset(-20)
//                make.top.equalTo(desLbl.snp.bottom).offset(10)
//            })
//        commentIcon = superview.addSubview(UIImageView.self)
//            .config(UIImage(named: "news_comment"), contentMode: .scaleAspectFit)
//            .layout({ (make) in
//                make.centerY.equalTo(commentNumLbl)
//                make.right.equalTo(commentNumLbl.snp.left).offset(-4)
//                make.size.equalTo(15)
//            })
//        likeNumLbl = superview.addSubview(UILabel.self)
//            .styleCopy(commentNumLbl).layout({ (make) in
//                make.right.equalTo(commentIcon).offset(-22.5)
//                make.centerY.equalTo(commentIcon)
//            })
//        likeIcon = superview.addSubview(UIImageView.self)
//            .config(UIImage(named: "news_like_unliked"), contentMode: .scaleAspectFit)
//            .layout({ (make) in
//                make.centerY.equalTo(likeNumLbl)
//                make.right.equalTo(likeNumLbl.snp.left).offset(-4)
//                make.size.equalTo(15)
//            })
//        likeBtn = superview.addSubview(UIButton.self)
//            .layout({ (make) in
//                make.center.equalTo(likeIcon)
//                make.size.equalTo(30)
//            })
//        let sepLine = superview.addSubview(UIView.self).config(UIColor(white: 0.8, alpha: 1))
//            .layout { (make) in
//                make.left.equalTo(superview).offset(15)
//                make.right.equalTo(superview).offset(-15)
//                make.height.equalTo(0.5)
//                make.top.equalTo(commentNumLbl.snp.bottom).offset(30)
//        }
//        superview.addSubview(UILabel.self).config(textColor: kTextGray28, textAlignment: .center, text: LS("详情"))
//            .layout { (make) in
//                make.center.equalTo(sepLine)
//                make.width.equalTo(70)
//        }.customize { (view) in
//            view.backgroundColor = UIColor.white
//        }
//        
//        let bubble1 = superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
//            .layout { (make) in
//                make.top.equalTo(sepLine.snp.bottom).offset(25)
//                make.left.equalTo(superview).offset(25)
//                make.size.equalTo(10)
//        }.toRound(5)
//        let static1 = superview.addSubview(UILabel.self)
//            .config(textColor: kTextGray28, text: LS("活动地点"))
//            .layout { (make) in
//                make.left.equalTo(bubble1.snp.right).offset(20)
//                make.top.equalTo(bubble1)
//        }
//        locationLbl = superview.addSubview(UILabel.self)
//            .config(14).layout({ (make) in
//                make.left.equalTo(static1)
//                make.top.equalTo(static1.snp.bottom).offset(10)
//            })
//        let bubble2 = superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
//            .layout { (make) in
//                make.left.equalTo(bubble1)
//                make.top.equalTo(bubble1.snp.bottom).offset(65)
//                make.size.equalTo(10)
//        }.toRound(5)
//        let static2 = superview.addSubview(UILabel.self).styleCopy(static1, text: LS("活动时间"))
//            .layout { (make) in
//                make.top.equalTo(bubble2)
//                make.left.equalTo(static1)
//        }
//        actDateLbl = superview.addSubview(UILabel.self).styleCopy(locationLbl)
//            .layout({ (make) in
//                make.left.equalTo(locationLbl)
//                make.top.equalTo(static2.snp.bottom).offset(10)
//            })
//        let bubble3 = superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
//            .layout { (make) in
//                make.left.equalTo(bubble1)
//                make.top.equalTo(bubble2.snp.bottom).offset(65)
//                make.size.equalTo(10)
//        }.toRound(5)
//        let static3 = superview.addSubview(UILabel.self).styleCopy(static2, text: LS("活动人数"))
//            .layout { (make) in
//                make.top.equalTo(bubble3)
//                make.left.equalTo(static2)
//        }
//        attendNumLbl = superview.addSubview(UILabel.self).styleCopy(locationLbl)
//            .layout({ (make) in
//                make.left.equalTo(actDateLbl)
//                make.top.equalTo(static3.snp.bottom).offset(10)
//            })
//        let bubble4 = superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
//            .layout { (make) in
//                make.left.equalTo(bubble3)
//                make.top.equalTo(bubble3.snp.bottom).offset(65)
//                make.size.equalTo(10)
//        }.toRound(5)
//        let static4 = superview.addSubview(UILabel.self).styleCopy(static3, text: LS("活动成员"))
//            .layout { (make) in
//                make.left.equalTo(static3)
//                make.top.equalTo(bubble4)
//        }
//        let layout = UICollectionViewFlowLayout()
//        layout.itemSize = CGSize(width: 35, height: 35)
//        layout.minimumInteritemSpacing = 5
//        layout.minimumLineSpacing = 5
//        layout.scrollDirection = .vertical
//        inlineMiniUserSelect = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout).config(UIColor.white)
//        inlineMiniUserSelect.dataSource = self
//        inlineMiniUserSelect.delegate = self
//        superview.addSubview(inlineMiniUserSelect)
//        inlineMiniUserSelect.layout { (make) in
//            make.left.equalTo(static4)
//            make.top.equalTo(static4.snp.bottom).offset(10)
////            make.right.equalTo(superview).offset(-75)
//            make.width.equalTo(35)
//            make.height.equalTo(35)
//        }
//        inlineMiniUserSelect.register(InlineUserSelectMiniCell.self, forCellWithReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier)
//        
//        showAllMemberBtn = superview.addSubview(UIButton.self)
//            .config(self, selector: #selector(showAllMemberBtnPressed))
//            .layout({ (make) in
//                make.left.equalTo(inlineMiniUserSelect.snp.right).offset(5)
//                make.height.equalTo(35)
//                make.centerY.equalTo(inlineMiniUserSelect)
//                make.width.equalTo(60)
//            })
//        showAllMemberBtn.setTitle(LS("全部"), for: .normal)
//        showAllMemberBtn.setTitleColor(kHighlightRed, for: .normal)
//        showAllMemberBtn.layer.borderColor = kHighlightRed.cgColor
//        showAllMemberBtn.layer.borderWidth = 0.5
//        showAllMemberBtn.layer.cornerRadius = 17.5
//        
//        superview.addSubview(UIView.self).config(kHighlightedRedTextColor)
//            .layout { (make) in
//                make.top.equalTo(bubble1.snp.centerY)
//                make.bottom.equalTo(bubble4.snp.centerY)
//                make.centerX.equalTo(bubble1)
//                make.width.equalTo(0.5)
//        }
//        
//        let sepLine2 = superview.addSubview(UIView.self).config(UIColor(white: 0.8, alpha: 1))
//            .layout { (make) in
//                make.left.equalTo(superview).offset(15)
//                make.right.equalTo(superview).offset(-15)
//                make.height.equalTo(0.5)
//                make.top.equalTo(inlineMiniUserSelect.snp.bottom).offset(30)
//        }
//        superview.addSubview(UILabel.self)
//            .config(UIColor.white)
//            .config(textColor: kTextGray28, textAlignment: .center, text: LS("评论"))
//            .layout { (make) in
//                make.center.equalTo(sepLine2)
//                make.width.equalTo(70)
//            }
//    }
//    
//    func loadDataAndUpdateUI() -> CGFloat {
//        cover.kf.setImage(with: act.posterURL!, placeholder: nil, options: nil, progressBlock: nil) { (image, _, _, _) in
//            self.cover.setupForImageViewer(nil, backgroundColor: UIColor.black, fadeToHide: true)
//        }
//        editBtn.isHidden = !act.user!.isHost
//        actNameLbl.text = act.name
//        desLbl.text = act.actDescription
//        hostAvatar.kf.setImage(with: act.user!.avatarURL!, for: .normal)
//        hostNameLbl.text = act.user?.nickName
//        releaseDateLbl.text = dateDisplay(act.createdAt!)
//        locationLbl.text = act.location!.descr
//        commentNumLbl.text = "\(act.commentNum)"
//        likeNumLbl.text = "\(act.likeNum)"
//        setLikeIconState(act.liked)
//        let attendNumDes = "要求人数:\(act.maxAttend) 已报名:\(act.applicants.count)"
//        if act.authedUserOnly {
//            attendNumLbl.text = "\(attendNumDes)(\(LS("仅认证用户")))"
//        } else {
//            attendNumLbl.text = attendNumDes
//        }
//        actDateLbl.text = act.timeDes!
//        
//        inlineMiniUserSelect.reloadData()
////        let inlineUserSelectHeight = max(35, inlineMiniUserSelect.contentSize.height)
////        let rows = CGFloat((act.applicants.count) / 7 + 1)
////        let inlineUserSelectHeight = rows * 35 + (rows - 1) * 5
////        inlineMiniUserSelect.snp.updateConstraints { (make) in
////            make.height.equalTo(inlineUserSelectHeight)
////        }
//        let cellNum = min(estimatedDisplayCellNumber(), act.applicants.count + 1)
//        inlineMiniUserSelect.snp.updateConstraints { (make) in
//            make.width.equalTo(CGFloat(cellNum) * 40 - 5)
//        }
////        showAllMemberBtn.hidden = !act.user!.isHost
//        
//        self.frame = UIScreen.main.bounds
//        self.updateConstraints()
//        self.layoutIfNeeded()
//        var contentRect = CGRect.zero
//        for view in self.subviews {
//            contentRect = contentRect.union(view.frame)
//        }
//        preferedHeight = contentRect.height + 20
//        self.snp.updateConstraints { (make) in
//            make.height.equalTo(preferedHeight)
//        }
//        return contentRect.height + 20
//    }
//    
//    func adjustCoverScaleAccordingToTableOffset(_ offset: CGFloat) {
//        let coverHeight = UIScreen.main.bounds.width * 0.588
//        let extraHeight = coverHeight * (coverExtraHeightRatio - 1)
//        if offset >= 0 {
//            cover.transform = CGAffineTransform.identity
//            if offset <= coverHeight {
//                let relativeMove = extraHeight * (offset / coverHeight)
//                setCoverRelativeMove(relativeMove)
//            }
//        } else if offset < 0 {
//            let scaleFactor = (-offset) / coverContainer.frame.height + 1
//            cover.snp.remakeConstraints({ (make) in
//                make.centerX.equalTo(coverContainer)
//                make.bottom.equalTo(coverContainer).offset(extraHeight)
//                make.width.equalTo(coverContainer).multipliedBy(scaleFactor)
//                make.height.equalTo(coverContainer).multipliedBy(scaleFactor * coverExtraHeightRatio)
//            })
//        }
//    }
//    
//    // MARK: CollectionView
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return min(estimatedDisplayCellNumber(), act.applicants.count + 1)
////        return act.applicants.count + 1
//    }
//    
//    func estimatedDisplayCellNumber() -> Int {
//        let screenWidth = UIScreen.main.bounds.width
//        let leftOffset: CGFloat = 25 + 10 + 20
//        let rightOffset: CGFloat = 15 + (act.user!.isHost ? (60 + 5) : 0)
//        let maxWidth = screenWidth - leftOffset - rightOffset
//        let cellWidth: CGFloat = 35
//        let cellInterval: CGFloat = 5
//        
//        return Int((maxWidth + cellInterval) / (cellWidth + cellInterval))
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InlineUserSelectMiniCell.reuseIdentifier, for: indexPath) as! InlineUserSelectMiniCell
//        
//        let cellCount = min(estimatedDisplayCellNumber(), act.applicants.count + 1)
//        if (indexPath as NSIndexPath).row < cellCount - 1 {
//            cell.user = act.applicants[(indexPath as NSIndexPath).row]
//        } else {
//            cell.imageView.image = UIImage(named: "chat_settings_add_person")
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if (indexPath as NSIndexPath).row < act.applicants.count {
//            let user = act.applicants[(indexPath as NSIndexPath).row]
//            parentController?.navigationController?.pushViewController(user.showDetailController(), animated: true)
//        } else {
//            var forceUsers = act.applicants
//            forceUsers.append(act.user!)
//            let select = FFSelectController(maxSelectNum: 0, preSelectedUsers: forceUsers, preSelect: false, authedUserOnly: act.authedUserOnly)
//            select.delegate = parentController
//            parentController?.present(select.toNavWrapper(), animated: true, completion: nil)
//        }
//    }
//    
//    func editBtnPressed() {
//        if act.finished {
//            parentController?.showToast(LS("活动已结束，不能编辑"))
//        } else {
//            let detail = ActivityEditController()
//            detail.act = act
//            parentController?.navigationController?.pushViewController(detail, animated: true)
//        }
//    }
//    
//    func hostAvatarPressed() {
//        parentController?.navigationController?.pushViewController(act.user!.showDetailController(), animated: true)
//    }
//    
//    func setLikeIconState(_ flag: Bool) {
//        likeIcon.image = flag ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
//    }
//    
//    func showAllMemberBtnPressed() {
//        let membersDisplay = ActivityMembersController()
//        membersDisplay.act = act
//        membersDisplay.delegate = self
//        parentController?.navigationController?.pushViewController(membersDisplay, animated: true)
//    }
//    
//    func activityMemberControllerDidRemove(_ user: User) {
//        inlineMiniUserSelect.reloadData()
//        let cellNum = min(estimatedDisplayCellNumber(), act.applicants.count + 1)
//        inlineMiniUserSelect.snp.updateConstraints { (make) in
//            make.width.equalTo(CGFloat(cellNum) * 40 - 5)
//        }
//        layoutIfNeeded()
//    }
//}
