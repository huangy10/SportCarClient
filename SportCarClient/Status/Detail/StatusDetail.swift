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
import Dollar
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


//
//class StatusDetailController2: InputableViewController, UITableViewDataSource, UITableViewDelegate, DetailCommentCellDelegate, StatusDeleteDelegate, WaitableProtocol {
//    var status: Status!
//    var comments: [Status]!
//    var loadAnimated: Bool = true
//    
//    var tableView: UITableView!
//    
//    var statusContainer: UIView!
//    
//}


class StatusDetailController: InputableViewController, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, DetailCommentCellDelegate, StatusDeleteDelegate, WaitableProtocol, LoadingProtocol {
    
    var list: UITableView?
    var indexPath: IndexPath?
    
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
    var likeBtn: UIButton!
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: view load
    
    override func viewDidLoad() {
        navSetting()
        // 顶层容器
        board = UIScrollView()
        board?.delegate = self
        board?.contentSize = self.view.bounds.size
        board?.backgroundColor = UIColor.white
        self.view.addSubview(board!)
        let superview = self.view
        board?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(superview.bounds.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
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
        statusContainer?.backgroundColor = UIColor.white
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
        NotificationCenter.default.addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // load the detail data
        StatusRequester.sharedInstance.getStatusDetail(status!.ssidString, onSuccess: { (json) in
            if let data = json {
                try! self.status?.loadDataFromJSON(data, detailLevel: 0, forceMainThread: false)
                self.loadDataAndUpdateUI()
            }
            }) { (code) in
                if code == "status not found" {
                    self.showToast(LS("动态不存在或者已经被删除"))
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showToast(LS("网络访问错误:\(code)"))
                }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }) { (_) -> Void in
                    self.tmpBackgroundImg?.isHidden = true
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
        backBtn.setImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: #selector(StatusDetailController.backBtnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), for: UIControlState())
        shareBtn.imageView?.contentMode = .scaleAspectFit
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
        shareBtn.addTarget(self, action: #selector(StatusDetailController.navRightBtnPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
        wp_abortWaiting()
    }
    
    func navRightBtnPressed() {
        // 根据的状态的发布者来确定弹出的窗口
        if status!.user!.isHost {
            // 是当前用户发布的状态，则弹出删除
            let delete = StatusDeleteController(parent: self)
            delete.delegate = self
            delete.status = status!
            self.present(delete, animated: false, completion: nil)
        }else {
            // 否则弹出举报
            let report = ReportBlacklistViewController(userID: status!.ssid, reportType: "status", parent: self)
            self.present(report, animated: false, completion: nil)
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
        sepLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
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
        commentStaticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentStaticLbl.backgroundColor = UIColor.white
        commentStaticLbl.textAlignment = .center
        commentStaticLbl.text = LS("评论")
        board?.addSubview(commentStaticLbl)
        commentStaticLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(sepLine)
            make.width.equalTo(70)
        }
        //
        commentList = UITableView(frame: CGRect.zero, style: .plain)
        commentList?.dataSource = self
        commentList?.delegate = self
        commentList?.separatorStyle = .none
        commentList?.isScrollEnabled = false
        commentList?.backgroundColor = UIColor.white
        board?.addSubview(commentList!)
        commentList?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(commentStaticLbl.snp_bottom).offset(20)
            make.height.equalTo(64)
        })
        commentList?.register(StatusDetailCommentCell.self, forCellReuseIdentifier: StatusDetailCommentCell.reuseIdentifier)
        commentList?.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
        //
        
        commentPanel = CommentBarView()
        commentPanel?.shareBtnHidden = true
        commentPanel?.likeBtn?.addTarget(self, action: #selector(StatusDetailController.likeBtnPressed), for: .touchUpInside)
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
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    /**
     自动调整board的size大小
     
      - parameter   animated: 是否动态调整
     */
    func autoSetBoardContentSize(_ animated: Bool) {
        commentList?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(max(commentList!.contentSize.height, 88))
        })
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        var contentRect = CGRect.zero
        for view in board!.subviews[0..<(board!.subviews.count - 2)] {
            contentRect = contentRect.union(view.frame)
        }
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.board?.contentSize = CGSize(width: self.board!.frame.width, height: contentRect.height + self.commentPanel!.frame.height)
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
        avatarBtn?.addTarget(self, action: #selector(StatusDetailController.statusHostAvatarPressed), for: .touchUpInside)
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(headerContainer!).offset(15)
            make.centerY.equalTo(headerContainer!)
            make.size.equalTo(35)
        })
        //
        nameLbl = UILabel()
        nameLbl?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightBlack)
        nameLbl?.textColor = UIColor.black
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
        releaseDateLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        releaseDateLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        headerContainer?.addSubview(releaseDateLbl!)
        releaseDateLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nameLbl!)
            make.bottom.equalTo(avatarBtn!)
            make.top.equalTo(nameLbl!.snp_bottom)
        })
        //
        avatarCarNameLbl = UILabel()
        avatarCarNameLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        avatarCarNameLbl?.textAlignment = .right
        avatarCarNameLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        headerContainer?.addSubview(avatarCarNameLbl!)
        avatarCarNameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(headerContainer!).offset(-15)
            make.centerY.equalTo(headerContainer!)
        })
        //
        avatarCarLogoIcon = UIImageView()
        avatarCarLogoIcon?.contentMode = .scaleAspectFit
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
        mainCover?.contentMode = .scaleAspectFill
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
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        flowLayout.minimumInteritemSpacing = 10
        otherImgList = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        otherImgList?.dataSource = self
        superview.addSubview(otherImgList!)
        otherImgList?.backgroundColor = UIColor.white
        otherImgList?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(mainCover!.snp_bottom).offset(6)
            make.height.equalTo(0)
        })
        otherImgList?.register(StatusCellImageDisplayCell.self, forCellWithReuseIdentifier: StatusCellImageDisplayCell.reuseIdentifier)
        //
        contentLbl = UILabel()
        contentLbl?.textColor = UIColor.black
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
            make.size.equalTo(CGSize(width: 13.5, height: 18))
        }
        //
        locationLbL = UILabel()
        locationLbL?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        locationLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        locationLbL?.numberOfLines = 0
        locationLbL?.lineBreakMode = .byWordWrapping
        superview.addSubview(locationLbL!)
        locationLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(locationIcon.snp_right).offset(10)
            make.top.equalTo(locationIcon)
            make.width.equalTo(superview).multipliedBy(0.6)
        })
        //
        commentNumLbL = UILabel()
        commentNumLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbL?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        commentNumLbL?.textAlignment = .right
        superview.addSubview(commentNumLbL!)
        commentNumLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
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
        likeNumLbl?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        likeNumLbl?.textAlignment = .right
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
        
        likeBtn = superview.addSubview(UIButton)
            .config(self, selector: #selector(likeBtnPressed))
            .layout({ (make) in
                make.center.equalTo(likeIcon!)
                make.size.equalTo(20)
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
        avatarBtn?.kf_setImageWithURL(user.avatarURL!, forState: UIControlState())
        nameLbl?.text = user.nickName
        releaseDateLbl?.text = dateDisplay(status!.createdAt!)
        if let club = user.avatarClubModel {
            avatarClubBtn?.isHidden = false
            avatarClubBtn?.kf_setImageWithURL(club.logoURL!, forState: UIControlState())
        }else{
            avatarClubBtn?.isHidden = true
            avatarClubBtn?.setImage(nil, for: UIControlState())
        }
        if let car = user.avatarCarModel {
            avatarCarNameLbl?.isHidden = false
            avatarCarNameLbl?.text = car.name
            avatarCarLogoIcon?.isHidden = false
            avatarCarLogoIcon?.kf_setImageWithURL(car.logoURL!)
        }else{
            avatarCarLogoIcon?.isHidden = true
            avatarCarNameLbl?.isHidden = true
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
                self.mainCover?.setupForImageViewer(nil, backgroundColor: UIColor.black)
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
        contentLbl?.attributedText = type(of: self).makeAttributedContentText(status!.content!)
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
    
    class func makeAttributedContentText(_ content: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.lineBreakMode = .byCharWrapping
        return NSAttributedString(string: content, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: UIColor(white: 0, alpha: 0.58), NSParagraphStyleAttributeName: style])
    }
    
    class func heightForStatusContent(_ content: String) -> CGFloat {
        let attributedContent = makeAttributedContentText(content)
        let maxWidth = UIScreen.main.bounds.width - 30
        return attributedContent.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return statusImages.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusCellImageDisplayCell.reuseIdentifier, for: indexPath) as! StatusCellImageDisplayCell
        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[(indexPath as NSIndexPath).row + 1])!)
        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[(indexPath as NSIndexPath).row + 1])!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
            if error == nil {
                cell.imageView?.setupForImageViewer(nil, backgroundColor: UIColor.black)
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
        let requester = StatusRequester.sharedInstance
        let dateThreshold = comments.last?.createdAt ?? Date()
        requester.getMoreStatusComment(dateThreshold, statusID: status!.ssidString, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let newComment = try! StatusComment(status: self.status!).loadDataFromJSON(data)
                self.comments.append(newComment)
            }
            self.comments = $.uniq(self.comments, by: { $0.ssid })
            self.reorgnizeComments()
            self.commentList?.reloadData()
            self.autoSetBoardContentSize(true)
            self.requestingCommentData = false
            }) { (code) -> () in
                self.requestingCommentData = false
        }
    }
    
    func reorgnizeComments() {
        comments.sort { (comment1, comment2) -> Bool in
            switch comment1.createdAt!.compare(comment2.createdAt! as Date) {
            case .orderedDescending:
                return true
            default:
                return false
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.count == 0 {
            return 1
        }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有评论")
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommentCell.reuseIdentifier, for: indexPath) as! StatusDetailCommentCell
        cell.comment = comments[(indexPath as NSIndexPath).row]
        cell.replyBtn?.tag = (indexPath as NSIndexPath).row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if comments.count == 0 {
            return
        }
        let comment = comments[(indexPath as NSIndexPath).row]
        if comment.user.isHost {
            return
        } else {
            responseToRow = (indexPath as NSIndexPath).row
            let responseToName = comment.user.nickName!
            responseToPrefixStr = LS("回复 ") + responseToName + ": "
            commentPanel?.contentInput?.text = responseToPrefixStr
            atUser.removeAll()
            commentPanel?.contentInput?.becomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if comments.count == 0 {
            return 100
        }
        return StatusDetailCommentCell.heightForComment(comments[(indexPath as NSIndexPath).row].content!)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == board && board?.contentOffset.y >= board!.contentSize.height - board!.frame.height - 1 {
            loadMoreCommentData()
        }
    }
    
    func avatarPressed(_ cell: DetailCommentCell) {
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
    func replyPressed(_ cell: DetailCommentCell) {
        responseToRow = cell.replyBtn?.tag
        let responseToName = cell.nameLbl!.text!
        responseToPrefixStr = LS("回复 ") + responseToName + ": "
        commentPanel?.contentInput?.text = responseToPrefixStr
        atUser.removeAll()
        commentPanel?.contentInput?.becomeFirstResponder()
    }
    
    func checkImageDetail(_ cell: DetailCommentCell) {
        
    }
}


// MARK: - 下方评论条相关
extension StatusDetailController {
    
    func likeBtnPressed() {
        let requester = StatusRequester.sharedInstance
        wp_startWaiting()
        lp_start()
        requestOnFly = requester.likeStatus(status!.ssidString, onSuccess: { (json) -> () in
            self.status?.likeNum = json!["like_num"].int32Value
            let liked = json!["like_state"].boolValue
            self.status?.liked = liked
            self.commentPanel?.setLikedAnimated(liked)
            self.likeNumLbl?.text = "\(self.status!.likeNum)"
            self.likeIcon?.image = liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
            self.wp_stopWaiting()
            self.lp_stop()
            }) { (code) -> () in
                self.lp_stop()
                self.wp_stopWaiting()
                self.showToast(LS("无法访问服务器"))
        }
    }
    
    /**
     评论编辑完成，确认发送
     
     - parameter commentString: 评论文字内容
     - parameter image:         图片内容，现在图片已经取消
     */
    func commentConfirmed(_ commentString: String, image: UIImage?) {
        var responseToComment: StatusComment? = nil
        if responseToRow != nil {
            responseToComment = comments[responseToRow!]
        }
        let newComment = StatusComment(status: status!).initForPost(commentString, responseTo: responseToComment)
        comments.insert(newComment, at: 0)
        let requester = StatusRequester.sharedInstance
        self.lp_start()
        requester.postCommentToStatus(self.status!.ssidString, content: commentString, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) -> () in
            // data里面的只有一个id
            if data == nil {
                assertionFailure()
            }
            let newCommentID = data!.int32Value
            newComment.confirmSent(newCommentID)
            self.status?.commentNum += 1
            self.loadDataAndUpdateUI()
            self.lp_stop()
            self.showToast(LS("评论成功"))
            }) { (code) -> () in
                self.lp_stop()
                self.showToast(LS("评论失败"))
        }

        commentList?.beginUpdates()
        if comments.count > 1 {
            commentList?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        } else {
            commentList?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        commentList?.endUpdates()
    
        commentPanel?.contentInput?.text = ""
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(commentPanel!.barheight)
        })
        
        autoSetBoardContentSize(true)
    }
    
    func commentCanceled(_ commentString: String, image: UIImage?) {
        
    }
    
    /**
     在这个代理函数中，检测输入框行数的变化，并且及时调整输入框的高度
     
     - parameter textView: 目标textview
     */
    func textViewDidChange(_ textView: UITextView) {
        let textView = commentPanel?.contentInput
        let fixedWidth = textView?.bounds.width
        let newSize = textView?.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.greatestFiniteMagnitude))
        // 注：参见 CommentPanel 内部的布局设置，输入框的边缘总是距离下面的Bar的上下边界5个Point
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(max(newSize!.height  + 10 , commentPanel!.barheight))
        })
        self.view.layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
    
    func changeLayoutWhenKeyboardAppears(_ notif: Foundation.Notification) {
        let userInfo = (notif as NSNotification).userInfo!
        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-(keyboardFrame.height) )
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutWhenKeyboardDisappears(_ notif: Foundation.Notification) {
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
    
}

