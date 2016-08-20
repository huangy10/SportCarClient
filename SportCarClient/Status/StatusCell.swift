//
//  StatusCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/20.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Dollar

/// 状态页面的cell
class StatusCell: UITableViewCell, UICollectionViewDataSource{
    
    weak var parent: UIViewController?
    
    static let reuseIdentifier = "statuc_cell"
    
    var status: Status?
    // 拆分解析好的各个图片的url
    var statusImages: [String] = []
    
    var superContainer: UIView?
    /*
     封面顶部的这一栏
    */
    var headerContainer: UIView?
    var avatarBtn: UIButton?
    var nameLbl: UILabel?
    var avatarClubBtn: UIButton?
    var releaseDateLbl: UILabel?
    var avatarCarLogoIcon: UIImageView?
    var avatarCarNameLbl: UILabel?
    /* 
     中间图片和正文显示区
    */
    var mainCover: UIImageView?
    var otherImgList: UICollectionView?
    var contentLbl: UILabel?
    /*
     下方其他信息区域
    */
    var locationLbL: UILabel?
    var likeIcon: UIImageView?
    var likeNumLbl: UILabel?
    var commentIcon: UIImageView?
    var commentNumLbL: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubviews() {
        let superview = UIView()
        self.contentView.backgroundColor = kGeneralTableViewBGColor
        self.contentView.addSubview(superview)
        superview.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.contentView).inset(UIEdgeInsetsMake(5, 10, 5, 10))
        }
        superview.backgroundColor = UIColor.whiteColor()
        superview.addShadow()
        superContainer = superview
        /*
         header 区域的子空间创建
        */
        headerContainer = UIView()
        superview.addSubview(headerContainer!)
        headerContainer?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(70)
        })
        //
        avatarBtn = UIButton()
        headerContainer?.addSubview(avatarBtn!)
        avatarBtn?.layer.cornerRadius = 35 / 2.0
        avatarBtn?.clipsToBounds = true
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(headerContainer!).offset(15)
            make.centerY.equalTo(headerContainer!)
            make.size.equalTo(35)
        })
        avatarBtn?.addTarget(self, action: #selector(StatusCell.avatarBtnPressed), forControlEvents: .TouchUpInside)
        //
        nameLbl = UILabel()
        nameLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        nameLbl?.textColor = UIColor.blackColor()
        headerContainer?.addSubview(nameLbl!)
        nameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarBtn!.snp_right).offset(10)
            make.bottom.equalTo(avatarBtn!.snp_centerY)
            make.top.equalTo(avatarBtn!)
        })
        //
        avatarClubBtn = UIButton()
        avatarClubBtn?.layer.cornerRadius = 10
        avatarClubBtn?.clipsToBounds = true
        avatarClubBtn?.imageView?.layer.cornerRadius = 10
        avatarClubBtn?.imageView?.contentMode = .ScaleAspectFill
        headerContainer?.addSubview(avatarClubBtn!)
        avatarClubBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(20)
            make.centerY.equalTo(nameLbl!)
            make.left.equalTo(nameLbl!.snp_right).offset(7)
        })
        //
        releaseDateLbl = UILabel()
        releaseDateLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        releaseDateLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        headerContainer?.addSubview(releaseDateLbl!)
        releaseDateLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nameLbl!)
            make.bottom.equalTo(avatarBtn!)
            make.top.equalTo(nameLbl!.snp_bottom)
        })
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        avatarCarNameLbl?.textAlignment = .Right
        avatarCarNameLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        headerContainer?.addSubview(avatarCarNameLbl!)
        avatarCarNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(headerContainer!).offset(-15)
            make.centerY.equalTo(headerContainer!)
//            make.width.equalTo(superview).multipliedBy(0.3)
        })
        //
        avatarCarLogoIcon = UIImageView()
        avatarCarLogoIcon?.contentMode = .ScaleAspectFill
        avatarCarLogoIcon?.layer.cornerRadius = 10.5
        avatarCarLogoIcon?.clipsToBounds = true
        superview.addSubview(avatarCarLogoIcon!)
        avatarCarLogoIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(avatarCarNameLbl!.snp_left)
            make.centerY.equalTo(headerContainer!)
            make.size.equalTo(21)
        })
        /*
         中间内容区域
        */
        mainCover = UIImageView()
        superview.addSubview(mainCover!)
        mainCover?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(headerContainer!.snp_bottom)
            make.height.equalTo(mainCover!.snp_width)
        })
        mainCover?.contentMode = .ScaleAspectFill
        mainCover?.clipsToBounds = true
        //
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.itemSize = CGSizeMake(100, 100)
        flowLayout.minimumInteritemSpacing = 10
        otherImgList = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        otherImgList?.dataSource = self
        superview.addSubview(otherImgList!)
        otherImgList?.backgroundColor = UIColor.whiteColor()
        otherImgList?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(mainCover!.snp_bottom).offset(6)
            make.height.equalTo(0)
        })
        otherImgList?.registerClass(StatusCellImageDisplayCell.self, forCellWithReuseIdentifier: StatusCellImageDisplayCell.reuseIdentifier)
        //
        contentLbl = UILabel()
        contentLbl?.textColor = UIColor.blackColor()
        contentLbl?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)
        contentLbl?.numberOfLines = 0
        superview.addSubview(contentLbl!)
        contentLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(otherImgList!.snp_bottom).offset(15)
        })
        /*
         下方其他信息部分
        */
        let locationIcon = UIImageView(image: UIImage(named: "status_location_icon"))
        superview.addSubview(locationIcon)
        locationIcon.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(contentLbl!)
            make.top.equalTo(contentLbl!.snp_bottom).offset(15)
            make.size.equalTo(CGSizeMake(13.5, 18))
        }
        //
        locationLbL = UILabel()
        locationLbL?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        locationLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        locationLbL?.numberOfLines = 2
        locationLbL?.lineBreakMode = .ByWordWrapping
        superview.addSubview(locationLbL!)
        locationLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(locationIcon.snp_right).offset(10)
            make.top.equalTo(locationIcon)
            make.width.equalTo(superview).multipliedBy(0.5)
        })
        // 
        commentNumLbL = UILabel()
        commentNumLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbL?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        commentNumLbL?.textAlignment = .Right
        superview.addSubview(commentNumLbL!)
        commentNumLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
//            make.top.equalTo(locationLbL!.snp_bottom).offset(10)
            make.top.equalTo(locationLbL!)
            make.height.equalTo(17)
        })
        //
        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        superview.addSubview(commentIcon!)
        commentIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(commentNumLbL!.snp_left).offset(-2)
            make.top.equalTo(commentNumLbL!)
            make.size.equalTo(15)
        })
        //
        likeNumLbl = UILabel()
        likeNumLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        likeNumLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        likeNumLbl?.textAlignment = .Right
        superview.addSubview(likeNumLbl!)
        likeNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(commentIcon!.snp_left).offset(-30)
            make.top.equalTo(commentIcon!)
            make.height.equalTo(17)
        })
        //
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        superview.addSubview(likeIcon!)
        likeIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(likeNumLbl!.snp_left).offset(-2)
            make.top.equalTo(likeNumLbl!)
            make.size.equalTo(15)
        })
    }
    
    func getHeightOfCell() -> CGFloat{
        var tmp = CGRectZero
        for view in self.contentView.subviews {
            tmp = CGRectUnion(tmp, view.frame)
        }
        return tmp.height + 27
    }
    
    class func heightForStatus(data: Status) -> CGFloat{
        let content = data.content!
        let screenWidth = UIScreen.mainScreen().bounds.width
        let textHeight: CGFloat
        if content == "" {
            textHeight = 0
        } else {
//            textHeight = content.boundingRectWithSize(CGSizeMake(screenWidth - 50, 1000), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight)], context: nil).height
            textHeight = heightForStatusContent(content)
        }
        // 1080 + 40 - 200 - 114
        let imageInfo = data.image!
        let otherImageHeight: CGFloat = imageInfo.split(";").count > 1 ? 100 : 0
        return 520.0 / 375 * screenWidth + textHeight + otherImageHeight
    }
    
    func loadDataAndUpdateUI() {
        assert(NSThread.isMainThread())
        if status == nil {
            return
        }
        /*
         header区域的数据
        */
        let user: User = status!.user!
        avatarBtn?.kf_setImageWithURL(user.avatarURL!, forState: .Normal)
        nameLbl?.text = user.nickName
        releaseDateLbl?.text = dateDisplay(status!.createdAt!)
        if let club = user.avatarClubModel {
            avatarClubBtn?.hidden = false
            avatarClubBtn?.kf_setImageWithURL(club.logoURL!, forState: .Normal)
        }else{
            avatarClubBtn?.hidden = true
        }
        if let car = user.avatarCarModel {
            setAvatarCar(car)
//            avatarCarNameLbl?.hidden = false
//            avatarCarLogoIcon?.hidden = false
//            avatarCarNameLbl?.text = car.name
//            avatarCarLogoIcon?.kf_setImageWithURL(car.logoURL!)
        }else{
            avatarCarLogoIcon?.hidden = true
            avatarCarNameLbl?.hidden = true
        }
        /*
         中间内容区域
        */
        let imageInfo = status!.image!
        statusImages = imageInfo.split(";")
        mainCover?.kf_setImageWithURL(SFURL(statusImages[0])!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            if error == nil {
                self.mainCover?.setupForImageViewer(SFURL(self.statusImages[0])!, backgroundColor: UIColor.blackColor())
            }
        })
        if statusImages.count <= 1 {
            otherImgList?.reloadData()
            otherImgList?.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(0)
            })
        }else{
            otherImgList?.reloadData()
            otherImgList?.snp_updateConstraints(closure: { (make) -> Void in
                make.height.equalTo(100)
            })
        }
//        contentLbl?.text = status?.content
        contentLbl?.attributedText = self.dynamicType.makeFormatedStatusContent(status!.content!)
        /*
         底部区域数据
        */
        if let loc_des = status?.location?.descr {
            locationLbL?.text = loc_des
        }else{
            locationLbL?.text = LS("未知地点")
        }
        likeNumLbl?.text = "\(status!.likeNum)"
        commentNumLbL?.text = "\(status!.commentNum)"
        if status!.liked {
            likeIcon?.image = UIImage(named: "news_like_liked")
        } else {
            likeIcon?.image = UIImage(named: "news_like_unliked")
        }
        self.contentView.layoutIfNeeded()
    }
    
    class func heightForStatusContent(content: String) -> CGFloat {
        let attributedContent = makeFormatedStatusContent(content)
        let maxWidth = UIScreen.mainScreen().bounds.width - 30
        return attributedContent.boundingRectWithSize(CGSizeMake(maxWidth, CGFloat.max), options: .UsesLineFragmentOrigin, context: nil).height
    }
    
    class func makeFormatedStatusContent(content: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.lineBreakMode = .ByCharWrapping
        let result = NSAttributedString(string: content, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.58), NSParagraphStyleAttributeName: style])
        return result
    }
    
    func setAvatarCar(car: SportCar) {
        let carName = car.name!
        let carLogo = car.logoURL!
        
        avatarCarNameLbl?.text = carName
        avatarCarLogoIcon?.kf_setImageWithURL(carLogo, placeholderImage: nil)
        
        let carNameSingleLineLen: CGFloat = UIScreen.mainScreen().bounds.width * 0.4
        let carNameWidth = carName.sizeWithFont(avatarCarNameLbl!.font, boundingSize: CGSizeMake(CGFloat.max, CGFloat.max)).width
        
        if carNameWidth > carNameSingleLineLen {
            avatarCarNameLbl?.numberOfLines = 2
            avatarCarNameLbl?.lineBreakMode = .ByWordWrapping
            let carNameWidthLimited = carName.sizeWithFont(avatarCarNameLbl!.font, boundingSize: CGSizeMake(carNameSingleLineLen, CGFloat.max)).width
            avatarCarNameLbl?.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(headerContainer!).offset(-15)
                make.top.equalTo(avatarCarLogoIcon!)
                make.width.equalTo(carNameWidthLimited)
            })
        } else {
            avatarCarNameLbl?.numberOfLines = 1
            avatarCarNameLbl?.snp_remakeConstraints(closure: { (make) in
                make.right.equalTo(headerContainer!).offset(-15)
                make.top.equalTo(avatarCarLogoIcon!)
            })
        }
        
        avatarCarNameLbl?.superview?.layoutIfNeeded()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusImages.count - 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusCellImageDisplayCell.reuseIdentifier, forIndexPath: indexPath) as! StatusCellImageDisplayCell
        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[indexPath.row + 1])!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            if error == nil {
                cell.imageView?.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
            }
        })
        return cell
    }
    
    func avatarBtnPressed() {
        if status!.user!.isHost {
            let detail = PersonBasicController(user: status!.user!)
            parent?.navigationController?.pushViewController(detail, animated: true)
        } else {
            let detail = PersonOtherController(user: status!.user!)
            parent?.navigationController?.pushViewController(detail, animated: true)
        }
    }
}


class StatusCellImageDisplayCell: UICollectionViewCell {
    static let reuseIdentifier = "status_cell_image_display_cell"
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView?.contentMode = .ScaleAspectFill
        imageView?.clipsToBounds = true
        self.contentView.addSubview(imageView!)
        imageView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(self.contentView)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}