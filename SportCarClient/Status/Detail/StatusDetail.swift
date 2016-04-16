//
//  StatusDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/21.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Spring
import Alamofire
import SwiftyJSON


class StatusDetailController2: InputableViewController, UITableViewDataSource, UITableViewDelegate, DetailCommentCellDelegate, StatusDeleteDelegate, WaitableProtocol {
    var status: Status!
    var comments: [Status]!
    var loadAnimated: Bool = true
    
    var tableView: UITableView!
    
    var statusContainer: UIView!
    
}


class StatusDetailController: InputableViewController, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, DetailCommentCellDelegate, StatusDeleteDelegate, WaitableProtocol {
    
    var list: UITableView?
    var indexPath: NSIndexPath?
    
    var status: Status?
    var statusImages: [String] = []
    var comments: [StatusComment] = []
    
    var loadAnimated: Bool = true
    
    var board: UIScrollView?
    
    /// 上方显示
    var statusContainer: UIView?
    var tmpBackgroundImg: UIImageView?
    /// 初始时上面的container所处的位置
    var initialPos: CGFloat = 0
    var initialHight: CGFloat = 0
    var initBackground: UIImage?
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
    
    var commentList: UITableView?   // 评论列表，其中的cell使用News评论的cell
    var requestingCommentData: Bool = false     // 状态标识，当前是否正在更新数据
    
    /// 评论栏
    var commentPanel: CommentBarView?
    var responseToRow: Int?                 // 被回应的评论所在的行
    var responseToPrefixStr: String?        // 回应内容前缀：当回复某人时会预填充『回复：XXX』字样
    var atUser: [String] = []
    
    // MARK: variable for waitable protocol
    var wp_waitingContainer: UIView?
    weak var requestOnFly: Request?
    
    // MARK: init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(status: Status, background: UIImage, initPos: CGFloat, initHeight: CGFloat) {
        self.init(nibName: nil, bundle: nil)
        self.status = status
        self.initBackground = background
        self.initialPos = initPos
        self.initialHight = initHeight
    }
    
    convenience init(status: Status) {
        self.init(nibName: nil, bundle: nil)
        self.status = status
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: view load
    
    override func viewDidLoad() {
        navSetting()
        // 顶层容器
        board = UIScrollView()
        board?.delegate = self
        board?.contentSize = self.view.bounds.size
        board?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(board!)
        let superview = self.view
        board?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(superview.bounds.height - self.navigationController!.navigationBar.frame.height - UIApplication.sharedApplication().statusBarFrame.height)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview).offset(0)
        })
        if loadAnimated {
            tmpBackgroundImg = UIImageView()
            tmpBackgroundImg?.image = initBackground
            board?.addSubview(tmpBackgroundImg!)
            tmpBackgroundImg?.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(self.view)
                make.left.equalTo(self.view)
                make.top.equalTo(board!)
                make.height.equalTo(self.view)
            })
        }
        
        statusContainer = UIView()
        statusContainer?.backgroundColor = UIColor.whiteColor()
        board?.addSubview(statusContainer!)
        if loadAnimated {
            statusContainer?.snp_makeConstraints(closure: { (make) -> Void in
                make.height.equalTo(initialHight)
                make.right.equalTo(self.view).offset(-10)
                make.left.equalTo(self.view).offset(10)
                make.top.equalTo(board!).offset(initialPos)
            })
        }else {
            statusContainer?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.top.equalTo(board!)
                make.height.equalTo(StatusCell.heightForStatus(status!) + 20)
            })
        }
        createStatusBoard()
        createOtherSubivews()
        loadDataAndUpdateUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardAppears(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardDisappears(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if loadAnimated {
            self.view.updateConstraints()
            self.view.layoutIfNeeded()
            statusContainer?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.top.equalTo(board!)
                make.height.equalTo(board!)
            })
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }) { (_) -> Void in
                    self.tmpBackgroundImg?.hidden = true
                    self.animateOtherSubViews()
                    self.autoSetBoardContentSize(true)
                    self.loadMoreCommentData()
            }
        }
    }
    
    // MARK: Navigator
    
    func navSetting() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("动态详情")
        //
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: #selector(StatusDetailController.backBtnPressed), forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), forState: .Normal)
        shareBtn.imageView?.contentMode = .ScaleAspectFit
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
        shareBtn.addTarget(self, action: #selector(StatusDetailController.navRightBtnPressed), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
        wp_abortWaiting()
    }
    
    func navRightBtnPressed() {
        // 根据的状态的发布者来确定弹出的窗口
        if status!.user!.isHost {
            // 是当前用户发布的状态，则弹出删除
            let delete = StatusDeleteController(parent: self)
            delete.delegate = self
            delete.status = status!
            self.presentViewController(delete, animated: false, completion: nil)
        }else {
            // 否则弹出举报
            let report = ReportBlacklistViewController(user: status?.user, parent: self)
            self.presentViewController(report, animated: false, completion: nil)
        }
    }
    
    /**
     弹出的删除窗口删除了状态以后调用这个回调
     */
    func statusDidDeleted() {
        // pop当前这个窗口
        self.backBtnPressed()
    }
    
    func createOtherSubivews() {
        let superview = self.view
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        board?.addSubview(sepLine)
        if loadAnimated {
            sepLine.snp_makeConstraints { (make) -> Void in
                make.right.equalTo(superview).offset(-15)
                make.left.equalTo(superview).offset(15)
                make.top.equalTo(board!).offset(initialHight + 20)
                make.height.equalTo(0.5)
            }
        }else {
            sepLine.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(superview).offset(-15)
                make.left.equalTo(superview).offset(15)
                make.top.equalTo(statusContainer!.snp_bottom)
                make.height.equalTo(0.5)
            })
        }
        //
        let commentStaticLbl = UILabel()
        commentStaticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentStaticLbl.backgroundColor = UIColor.whiteColor()
        commentStaticLbl.textAlignment = .Center
        commentStaticLbl.text = LS("评论")
        board?.addSubview(commentStaticLbl)
        commentStaticLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(sepLine)
            make.width.equalTo(70)
        }
        //
        commentList = UITableView(frame: CGRectZero, style: .Plain)
        commentList?.dataSource = self
        commentList?.delegate = self
        commentList?.separatorStyle = .None
        commentList?.scrollEnabled = false
        commentList?.backgroundColor = UIColor.whiteColor()
        board?.addSubview(commentList!)
        commentList?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(commentStaticLbl.snp_bottom).offset(20)
            make.height.equalTo(64)
        })
        commentList?.registerClass(StatusDetailCommentCell.self, forCellReuseIdentifier: StatusDetailCommentCell.reuseIdentifier)
        commentList?.registerClass(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
        //
        
        commentPanel = CommentBarView()
        commentPanel?.shareBtnHidden = true
        commentPanel?.likeBtn?.addTarget(self, action: #selector(StatusDetailController.likeBtnPressed), forControlEvents: .TouchUpInside)
        self.view?.addSubview(commentPanel!)
        if loadAnimated {
            commentPanel?.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(superview)
                make.left.equalTo(superview)
                make.height.equalTo(commentPanel!.barheight)
                make.bottom.equalTo(superview).offset(commentPanel!.barheight)      // 先将这个panel放置在底部，后续动画调出
            })
        }else {
            commentPanel?.snp_makeConstraints(closure: { (make) -> Void in
                make.right.equalTo(superview)
                make.left.equalTo(superview)
                make.height.equalTo(commentPanel!.barheight)
                make.bottom.equalTo(superview).offset(0)
            })
        }
        self.inputFields.append(commentPanel?.contentInput)
        commentPanel?.contentInput?.delegate = self
    }
    
    func animateOtherSubViews() {
        self.view.layoutIfNeeded()
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    /**
     自动调整board的size大小
     
      - parameter   animated: 是否动态调整
     */
    func autoSetBoardContentSize(animated: Bool) {
        commentList?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(max(commentList!.contentSize.height, 88))
        })
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in board!.subviews[0..<(board!.subviews.count - 2)] {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        if animated {
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.board?.contentSize = CGSizeMake(self.board!.frame.width, contentRect.height + self.commentPanel!.frame.height)
                }, completion: nil)
        }else{
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - 上方status部分
extension StatusDetailController {
    func createStatusBoard() {
        
        let superview = statusContainer!
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
        avatarBtn?.addTarget(self, action: #selector(StatusDetailController.statusHostAvatarPressed), forControlEvents: .TouchUpInside)
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(headerContainer!).offset(15)
            make.centerY.equalTo(headerContainer!)
            make.size.equalTo(35)
        })
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
            make.height.equalTo(17)
        })
        //
        avatarCarLogoIcon = UIImageView()
        avatarCarLogoIcon?.contentMode = .ScaleAspectFit
        avatarCarLogoIcon?.layer.cornerRadius = 10.5
        avatarCarLogoIcon?.clipsToBounds = true
        superview.addSubview(avatarCarLogoIcon!)
        avatarCarLogoIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(avatarCarNameLbl!.snp_left).offset(-4)
            make.centerY.equalTo(avatarCarNameLbl!)
            make.size.equalTo(21)
        })
        /*
        中间内容区域
        */
        mainCover = UIImageView()
        mainCover?.contentMode = .ScaleAspectFill
        mainCover?.clipsToBounds = true
        superview.addSubview(mainCover!)
        mainCover?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(headerContainer!.snp_bottom)
            make.height.equalTo(mainCover!.snp_width)
        })
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
        locationLbL?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        locationLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(locationLbL!)
        locationLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(locationIcon.snp_right).offset(10)
            make.top.equalTo(locationIcon)
            make.height.equalTo(17)
        })
        //
        commentNumLbL = UILabel()
        commentNumLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbL?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        commentNumLbL?.textAlignment = .Right
        superview.addSubview(commentNumLbL!)
        commentNumLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(locationLbL!.snp_bottom).offset(10)
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
    
    func statusHostAvatarPressed() {
//        let detail = PersonOtherController(user: status!.user!)
//        self.navigationController?.pushViewController(detail, animated: true)
        navigationController?.pushViewController(status!.user!.showDetailController(), animated: true)
    }
    
    func loadDataAndUpdateUI() {
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
            avatarClubBtn?.setImage(nil, forState: .Normal)
        }
        if let car = user.avatarCarModel {
            avatarCarNameLbl?.hidden = false
            avatarCarNameLbl?.text = car.name
            avatarCarLogoIcon?.hidden = false
            avatarCarLogoIcon?.kf_setImageWithURL(car.logoURL!)
        }else{
            avatarCarLogoIcon?.hidden = true
            avatarCarNameLbl?.hidden = true
            avatarCarLogoIcon?.image = nil
        }
        /*
        中间内容区域
        */
        let imageInfo = status!.image!
        statusImages = imageInfo.split(";")
        mainCover?.kf_setImageWithURL(SFURL(statusImages[0])!)
        mainCover?.kf_setImageWithURL(status!.coverURL!, placeholderImage: mainCover?.image, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) in
            if error == nil {
                self.mainCover?.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
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
        contentLbl?.text = status?.content
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
        likeIcon?.image = status!.liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
        commentPanel?.likeBtnIcon.image = status!.liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
        self.view.layoutIfNeeded()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusImages.count - 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(StatusCellImageDisplayCell.reuseIdentifier, forIndexPath: indexPath) as! StatusCellImageDisplayCell
        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[indexPath.row + 1])!)
        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[indexPath.row + 1])!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            if error == nil {
                cell.imageView?.setupForImageViewer(nil, backgroundColor: UIColor.blackColor())
            }
        })
        return cell
    }
}

// MARK: - about comments
extension StatusDetailController {
    
    func loadMoreCommentData() {
        if requestingCommentData{
            return
        }
        requestingCommentData = true
        let requester = StatusRequester.SRRequester
        let dateThreshold = comments.last()?.createdAt ?? NSDate()
        requester.getMoreStatusComment(dateThreshold, statusID: status!.ssidString, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let newComment = try! StatusComment(status: self.status!).loadDataFromJSON(data)
                self.comments.append(newComment)
            }
            self.reorgnizeComments()
            self.commentList?.reloadData()
            self.autoSetBoardContentSize(true)
            self.requestingCommentData = false
            }) { (code) -> () in
                self.requestingCommentData = false
        }
    }
    
    func reorgnizeComments() {
        comments.sortInPlace { (comment1, comment2) -> Bool in
            switch comment1.createdAt!.compare(comment2.createdAt!) {
            case .OrderedDescending:
                return true
            default:
                return false
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.count == 0 {
            return 1
        }
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if comments.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("empty_cell", forIndexPath: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有评论")
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(DetailCommentCell.reuseIdentifier, forIndexPath: indexPath) as! StatusDetailCommentCell
        cell.comment = comments[indexPath.row]
        cell.replyBtn?.tag = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if comments.count == 0 {
            return
        }
        let comment = comments[indexPath.row]
        if comment.user.isHost {
            return
        } else {
            responseToRow = indexPath.row
            let responseToName = comment.user.nickName!
            responseToPrefixStr = LS("回复 ") + responseToName + ": "
            commentPanel?.contentInput?.text = responseToPrefixStr
            atUser.removeAll()
            commentPanel?.contentInput?.becomeFirstResponder()
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if comments.count == 0 {
            return 100
        }
        return StatusDetailCommentCell.heightForComment(comments[indexPath.row].content!)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == board && board?.contentOffset.y >= board!.contentSize.height - board!.frame.height - 1 {
            loadMoreCommentData()
        }
    }
    
    func avatarPressed(cell: DetailCommentCell) {
        if let cell = cell as? StatusDetailCommentCell {
            if let user = cell.comment?.user {
                navigationController?.pushViewController(user.showDetailController(), animated: true)
            }
        }
    }
    
    /**
     试图回应已有的一条评论
     
     - parameter cell: 被评论的cell
     */
    func replyPressed(cell: DetailCommentCell) {
        responseToRow = cell.replyBtn?.tag
        let responseToName = cell.nameLbl!.text!
        responseToPrefixStr = LS("回复 ") + responseToName + ": "
        commentPanel?.contentInput?.text = responseToPrefixStr
        atUser.removeAll()
        commentPanel?.contentInput?.becomeFirstResponder()
    }
    
    func checkImageDetail(cell: DetailCommentCell) {
        
    }
}


// MARK: - 下方评论条相关
extension StatusDetailController {
    
    func likeBtnPressed() {
        let requester = StatusRequester.SRRequester
//        if status!.liked {
//            status!.likeNum -= 1
//        } else {
//            status!.likeNum += 1
//        }
//        status?.liked = !status!.liked
//        self.commentPanel?.setLikedAnimated(status!.liked)
//        self.likeNumLbl?.text = "\(self.status!.likeNum)"
//        self.likeIcon?.image = status!.liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
        wp_startWaiting()
        requestOnFly = requester.likeStatus(status!.ssidString, onSuccess: { (json) -> () in
            self.status?.likeNum = json!["like_num"].int32Value
            let liked = json!["like_state"].boolValue
            self.status?.liked = liked
            self.commentPanel?.setLikedAnimated(liked)
            self.likeNumLbl?.text = "\(self.status!.likeNum)"
            self.likeIcon?.image = liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
            
            self.wp_stopWaiting()
            }) { (code) -> () in
                print(code)
                self.wp_stopWaiting()
                self.showToast(LS("无法访问服务器"))
        }
    }
    
    /**
     评论编辑完成，确认发送
     
     - parameter commentString: 评论文字内容
     - parameter image:         图片内容，现在图片已经取消
     */
    func commentConfirmed(commentString: String, image: UIImage?) {
        var responseToComment: StatusComment? = nil
        if responseToRow != nil {
            responseToComment = comments[responseToRow!]
        }
        let newComment = StatusComment(status: status!).initForPost(commentString, responseTo: responseToComment)
        comments.insert(newComment, atIndex: 0)
        let requester = StatusRequester.SRRequester
        requester.postCommentToStatus(self.status!.ssidString, content: commentString, image: nil, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) -> () in
            // data里面的只有一个id
            if data == nil {
                assertionFailure()
            }
            let newCommentID = data!.int32Value
            newComment.confirmSent(newCommentID)
            self.status?.commentNum += 1
            self.loadDataAndUpdateUI()
            }) { (code) -> () in
                print(code)
        }

        commentList?.beginUpdates()
        if comments.count > 1 {
            commentList?.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        } else {
            commentList?.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        }
        commentList?.endUpdates()
    
        commentPanel?.contentInput?.text = ""
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(commentPanel!.barheight)
        })
        
        autoSetBoardContentSize(true)
    }
    
    func commentCanceled(commentString: String, image: UIImage?) {
        
    }
    
    /**
     在这个代理函数中，检测输入框行数的变化，并且及时调整输入框的高度
     
     - parameter textView: 目标textview
     */
    func textViewDidChange(textView: UITextView) {
        let textView = commentPanel?.contentInput
        let fixedWidth = textView?.bounds.width
        let newSize = textView?.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.max))
        // 注：参见 CommentPanel 内部的布局设置，输入框的边缘总是距离下面的Bar的上下边界5个Point
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(max(newSize!.height  + 10 , commentPanel!.barheight))
        })
        self.view.layoutIfNeeded()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let commentText = textView.text ?? ""
            if commentText.length > 0 {
                commentConfirmed(commentText, image: nil)
            }else{
                commentCanceled("", image: nil)
            }
            // 调用父类InputableViewControlle的这个函数来隐藏键盘
            dismissKeyboard()
        }
        
        if text == "" && responseToPrefixStr != nil {
            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr!.length{
                textView.text = ""
                responseToPrefixStr = nil
                responseToRow = nil
            }
        }
        return true
    }
    
    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
        let userInfo = notif.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-(keyboardFrame.height) )
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
    
}