////
////  NewsDetail.swift
////  SportCarClient
////
////  Created by 黄延 on 15/12/29.
////  Copyright © 2015年 WoodyHuang. All rights reserved.
////
//
//import UIKit
//import Kingfisher
//import SnapKit
//import Spring
//import Dollar
//import SwiftyJSON
//
//private var newsContext = 0
//
//@available(*, deprecated: 1)
//class NewsDetailController: InputableViewController, UIWebViewDelegate, MakeCommentControllerDelegate, DetailCommentCellDelegate, ShareControllorDelegate, LoadingProtocol {
//    /// 这个详情页面需要展示的相关资讯
//    var news: News!
//    /// 评论列表
//    var comments: [NewsComment] = []
//    /// 动画需要：cover的初始位置
//    var initPos: CGFloat = 0
//    /// 动画需要：初始启动的背景截图
//    var initBg: UIImageView!
//    var initBgImg: UIImage!
//    /*
//      下面是subviews
//    */
//    /// 显示面板
//    var board: UIScrollView!
//    var bg: UIView!
//    /// 评论列表
//    var commentTableView: UITableView!
//    var commentTableLoading: UIActivityIndicatorView!
//    /// 资讯内容的详情
//    var newsDetailPanelView: UIWebView!
//    var newsDetailLoading: UIActivityIndicatorView!
//    /// 资讯封面
//    var newsCover: UIImageView!
//    /// 资讯标题
//    var newsTitleFake: UILabel!
//    var newsTitle: UILabel!
//    /// 封面下方的三组信息
//    var commentNumLbl: UILabel!
//    var shareNumLbl: UILabel!
//    var likeNumLbl: UILabel!
//    var likeIcon: UIImageView!
//    var shareIcon: UIImageView!
//    var commentIcon: UIImageView!
//    //
//    var likeInfoIcon: UIImageView!
//    var likeDescriptionLbl: UILabel!
//    //
//    
//    //
//    var commentPanel: CommentBarView!
//    
//    
//    var hideBarGestureRecognizer: UIPanGestureRecognizer?
//    
//    var coverTopConstraintOffset: SnapKit.Constraint?
//    
//    // 数据相关的状态变量
//    var requestingCommentData: Bool = false
//    var disableWebLink: Bool = false
//    var responseToRow: Int?         // 回应的评论对象所在的行
//    var responseToPrefixStr: String?
//    var atUser: [String] = []
//    
//    var likeRequesting: Bool = false
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//        newsDetailPanelView.removeObserver(self, forKeyPath: "scrollView.contentSize", context: &newsContext)
//    }
//    
//    override func viewDidLoad() {
//        navSetting()
//        createSubviews()
//        createNewsContentViews()
//        initializeCommentBar()
//        loadDataAndUpdateUI()
//        loadNewsCoverAnimated()
//        
//        print(navigationController?.delegate)
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    func loadNewsCoverAnimated() {
//        self.view.updateConstraints()
//        self.view.layoutIfNeeded()
//        let titleWidth = self.newsTitle.frame.width
//        newsCover.snp.updateConstraints { (make) -> Void in
//            make.top.equalTo(board).offset(0)
//        }
//        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            self.initBg.layer.opacity = 0.1
//            self.initBg.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
//            }, completion: { _ in
//                self.newsTitle.snp.remakeConstraints({ (make) -> Void in
//                    make.left.equalTo(self.view).offset(40)
//                    make.top.equalTo(self.newsCover.snp.bottom).offset(15)
//                    make.width.equalTo(titleWidth)
//                })
//                self.newsTitleFake.snp.remakeConstraints({ (make) -> Void in
//                    make.edges.equalTo(self.newsTitle)
//                })
//                UIView.animate(withDuration: 0.4, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//                    self.newsTitle.layer.opacity = 1
//                    self.newsTitleFake.layer.opacity = 0
//                    self.newsTitle.transform = CGAffineTransform(scaleX: 1.23, y: 1.23)
//                    self.newsTitleFake.transform = CGAffineTransform(scaleX: 1.23, y: 1.23)
//                    self.view.layoutIfNeeded()
//                    self.showNewsContentViews()
//                    }, completion: { _ in
//                        
//                })
//        })
//        bg.snp.remakeConstraints { (make) -> Void in
//            make.edges.equalTo(self.view)
//        }
//        bg.isHidden = false
//        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//        // 弹出评论栏
//        
//        commentPanel.snp.updateConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        }
//        UIView.animate(withDuration: 0.2, delay: 0.7, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }
//    
//    func hideNewsCoverAnimated() {
//        let superview = self.view!
//        self.view.updateConstraints()
//        self.view.layoutIfNeeded()
//        commentPanel.snp.updateConstraints { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(45)
//            self.hideNewsContentViews()
//        }
//        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//        bg.snp.remakeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(superview).offset(UIScreen.main.bounds.width * 0.573)
//            make.height.equalTo(0)
//        }
//        UIView.animate(withDuration: 0.4, delay: 0.4, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//        //
//        self.newsTitle.snp.remakeConstraints { (make) -> Void in
//            make.right.equalTo(likeIcon.snp.left)
//            make.left.equalTo(superview).offset(15)
//            make.bottom.equalTo(newsCover).offset(-10)
//        }
//        self.newsTitleFake.snp.remakeConstraints { (make) -> Void in
//            make.edges.equalTo(newsTitle)
//        }
//        UIView.animate(withDuration: 0.4, delay: 0.3, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            self.newsTitle.layer.opacity = 0
//            self.newsTitleFake.layer.opacity = 1
//            self.newsTitle.transform = CGAffineTransform.identity
//            self.newsTitleFake.transform = CGAffineTransform.identity
//            }) { (_) -> Void in
//                self.newsCover.snp.updateConstraints({ (make) -> Void in
//                    make.top.equalTo(self.board).offset(self.initPos)
//                })
//                UIView.animate(withDuration: 0.9, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//                    self.view.layoutIfNeeded()
//                    self.initBg.layer.opacity = 1
//                    self.initBg.transform = CGAffineTransform.identity
//                    }, completion: { _ in
//                        _ = self.navigationController?.popViewController(animated: false)
//                })
//        }
//    }
//    
//    /**
//     进场动画后期开始创建载入资讯的内容，此处将其均设置为hidden
//     */
//    func createNewsContentViews() {
//        let superview = self.view!
//        let sepLine = UIView()
//        sepLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
//        board?.addSubview(sepLine)
//        sepLine.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(newsTitle!)
//            make.height.equalTo(1)
//            make.width.equalTo(board!).multipliedBy(0.64)
//            make.top.equalTo(newsTitle!.snp.bottom).offset(15)
//        }
//        sepLine.layer.opacity = 0
//        newsDetailPanelView = UIWebView()
//        newsDetailPanelView.addObserver(self, forKeyPath: "scrollView.contentSize", options: .new, context: &newsContext)
//        newsDetailPanelView?.delegate = self
//        newsDetailPanelView?.paginationMode = .unpaginated
//        board?.addSubview(newsDetailPanelView!)
//        newsDetailPanelView?.snp.makeConstraints({ (make) -> Void in
//            make.top.equalTo(sepLine.snp.bottom).offset(15)
//            make.right.equalTo(superview).offset(-20)
//            make.left.equalTo(superview).offset(20)
//            make.height.equalTo(200)
//        })
//        newsDetailPanelView?.scrollView.isScrollEnabled = false
//        newsDetailPanelView.layer.opacity = 0
//        //
//        newsDetailLoading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        newsDetailPanelView?.addSubview(newsDetailLoading!)
//        newsDetailLoading?.snp.makeConstraints({ (make) -> Void in
//            make.center.equalTo(newsDetailPanelView)
//            make.size.equalTo(44)
//        })
//        newsDetailLoading?.hidesWhenStopped = true
//        newsDetailLoading?.startAnimating()
//        newsDetailLoading.layer.opacity = 0
//        //
//        likeInfoIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
//        board?.addSubview(likeInfoIcon!)
//        likeInfoIcon?.snp.makeConstraints({ (make) -> Void in
//            make.size.equalTo(15)
//            make.left.equalTo(newsDetailPanelView!)
//            make.top.equalTo(newsDetailPanelView!.snp.bottom).offset(35)
//        })
//        likeInfoIcon.isHidden = true
//        //
//        likeDescriptionLbl = UILabel()
//        board?.addSubview(likeDescriptionLbl!)
//        likeDescriptionLbl?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(likeInfoIcon!.snp.right).offset(10)
//            make.centerY.equalTo(likeInfoIcon!)
//            make.height.equalTo(17)
//        })
//        likeDescriptionLbl.layer.opacity = 0
//        //
//        let sepLine2 = UIView()
//        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
//        board?.addSubview(sepLine2)
//        sepLine2.snp.makeConstraints { (make) -> Void in
//            make.right.equalTo(superview)
//            make.left.equalTo(board!)
//            make.top.equalTo(likeInfoIcon!.snp.bottom).offset(16)
//            make.height.equalTo(1)
//        }
//        sepLine2.layer.opacity = 0
//        
//        let commentStaticLbl = UILabel()
//        commentStaticLbl.backgroundColor = UIColor.white
//        commentStaticLbl.text = LS("评论")
//        commentStaticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
//        commentStaticLbl.textAlignment = .center
//        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
//        board?.addSubview(commentStaticLbl)
//        commentStaticLbl.snp.makeConstraints { (make) -> Void in
//            make.centerX.equalTo(board!)
//            make.centerY.equalTo(sepLine2)
//            make.size.equalTo(CGSize(width: 75, height: 17))
//        }
//        commentStaticLbl.layer.opacity = 0
//        //
//        commentTableView = UITableView(frame: CGRect.zero, style: .plain)
//        commentTableView?.delegate = self
//        commentTableView?.dataSource = self
//        commentTableView?.separatorStyle = .none
//        commentTableView?.register(NewsDetailCommentCell.self, forCellReuseIdentifier: NewsDetailCommentCell.reuseIdentifier)
//        commentTableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
//        board?.addSubview(commentTableView!)
//        commentTableView?.snp.makeConstraints({ (make) -> Void in
//            make.top.equalTo(sepLine2.snp.bottom).offset(27)
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.height.equalTo(100)
//        })
//        commentTableView?.isScrollEnabled = false
//        commentTableView.layer.opacity = 0
//        //
//        commentTableLoading = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
//        commentTableView?.addSubview(commentTableLoading!)
//        commentTableLoading?.hidesWhenStopped = true
//        commentTableLoading?.startAnimating()
//        commentTableLoading?.snp.makeConstraints({ (make) -> Void in
//            make.center.equalTo(commentTableView!)
//            make.size.equalTo(44)
//        })
//        commentTableLoading.layer.opacity = 0
//    }
//    
//    func showNewsContentViews(){
//        newsDetailPanelView.layer.opacity = 1
//        commentTableView.layer.opacity = 1
//    }
//    
//    func hideNewsContentViews() {
//        newsDetailPanelView.layer.opacity = 0
//        commentTableView.layer.opacity = 0
//    }
//    
//    internal override func createSubviews() {
//        super.createSubviews()
//        let superview = self.view!
//        superview.backgroundColor = UIColor.white
//        //
//        board = UIScrollView()
//        superview.addSubview(board)
//        board.delegate = self
//        board.snp.makeConstraints { (make) -> Void in
//            make.edges.equalTo(superview)
//        }
//        board.backgroundColor = UIColor.black
//        //
//        initBg = UIImageView(image: initBgImg)
//        board.addSubview(initBg)
//        initBg.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.bottom.equalTo(superview)
//            make.height.equalTo(UIScreen.main.bounds.height)
//        }//
//        bg = UIView()
//        board.addSubview(bg)
//        bg.backgroundColor = UIColor.white
//        bg.isHidden = true
//        bg.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(superview).offset(UIScreen.main.bounds.width * 0.573)
//            make.height.equalTo(0)
//        }
//        //
//        newsCover = UIImageView()
//        board.addSubview(newsCover)
//        newsCover.snp.makeConstraints { (make) -> Void in
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.top.equalTo(board).offset(initPos)
//            make.height.equalTo(newsCover.snp.width).multipliedBy(0.573)
//        }
//        let coverMask = UIImageView(image: UIImage(named: "news_cover_mask"))
//        newsCover.addSubview(coverMask)
//        coverMask.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(newsCover)
//            make.right.equalTo(newsCover)
//            make.bottom.equalTo(newsCover)
//            make.height.equalTo(107)
//        }
//        // 创建like， comment和share标签
//        shareNumLbl = UILabel()
//        shareNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
//        shareNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
//        shareNumLbl.text = "0"
//        superview.addSubview(shareNumLbl)
//        shareNumLbl?.snp.makeConstraints({ (make) -> Void in
//            make.bottom.equalTo(newsCover).offset(-10)
//            make.right.equalTo(superview).offset(-15)
//            make.height.equalTo(15)
//            make.width.lessThanOrEqualTo(30)
//        })
//        shareIcon = UIImageView(image: UIImage(named: "news_share_white"))
//        superview.addSubview(shareIcon)
//        shareIcon.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(shareNumLbl.snp.left).offset(-3)
//            make.bottom.equalTo(shareNumLbl)
//            make.size.equalTo(15)
//        })
//        //
//        commentNumLbl = UILabel()
//        commentNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
//        commentNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
//        commentNumLbl.text = "0"
//        superview.addSubview(commentNumLbl)
//        commentNumLbl.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(shareIcon.snp.left)
//            make.bottom.equalTo(shareIcon)
//            make.size.equalTo(CGSize(width: 30, height: 15))
//        })
//        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
//        superview.addSubview(commentIcon)
//        commentIcon.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(commentNumLbl.snp.left).offset(-3)
//            make.bottom.equalTo(commentNumLbl)
//            make.size.equalTo(15)
//        })
//        //
//        likeNumLbl = UILabel()
//        likeNumLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
//        likeNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
//        superview.addSubview(likeNumLbl)
//        likeNumLbl.text = "0"
//        likeNumLbl.snp.makeConstraints({ (make) -> Void in
//            make.bottom.equalTo(commentIcon)
//            make.right.equalTo(commentIcon.snp.left)
//            make.size.equalTo(CGSize(width: 30, height: 15))
//        })
//        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
//        superview.addSubview(likeIcon)
//        likeIcon.snp.makeConstraints({ (make) -> Void in
//            make.bottom.equalTo(commentIcon)
//            make.right.equalTo(likeNumLbl.snp.left).offset(-3)
//            make.size.equalTo(15)
//        })
//        //
//        newsTitleFake = UILabel()
//        newsTitleFake.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBlack)
//        newsTitleFake.textColor = UIColor.white
//        newsTitleFake.numberOfLines = 0
//        board.addSubview(newsTitleFake)
//        newsTitleFake.snp.makeConstraints { (make) -> Void in
//            make.right.equalTo(likeIcon.snp.left)
//            make.left.equalTo(superview).offset(15)
//            make.bottom.equalTo(newsCover).offset(-10)
//        }
//        newsTitle = UILabel()
//        newsTitle.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightBlack)
//        newsTitle.textColor = UIColor.black
//        newsTitle.numberOfLines = 0
//        board.addSubview(newsTitle)
//        newsTitle.snp.makeConstraints { (make) -> Void in
//            make.edges.equalTo(newsTitleFake)
//        }
//        newsTitle.layer.opacity = 0
//        //
//        
//    }
//    
//    func initializeCommentBar() {
//        commentPanel = CommentBarView()
//        let superview = self.view!
//        commentPanel?.contentInput?.delegate = self
//        self.inputFields.append(commentPanel?.contentInput)
//        superview.addSubview(commentPanel!)
//        commentPanel?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview)
//            make.bottom.equalTo(superview).offset(45)
//            make.left.equalTo(superview)
//            make.height.equalTo(commentPanel!.barheight)
//        })
//        
//        commentPanel.likeBtn?.addTarget(self, action: #selector(NewsDetailController.likePressed), for: .touchUpInside)
//        commentPanel.shareBtn?.addTarget(self, action: #selector(NewsDetailController.sharePressed), for: .touchUpInside)
//        
//        // 添加键盘出现时时间的监听
//        NotificationCenter.default.addObserver(self, selector: #selector(NewsDetailController.changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(NewsDetailController.changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//    }
//    
//    func navSetting() {
//        navigationItem.title = LS("资讯详情")
//        //
//        let backBtn = UIButton().config(
//            self, selector: #selector(backBtnPressed),
//            image: UIImage(named: "account_header_back_btn"))
//            .setFrame(CGRect(x: 0, y: 0, width: 10.5, height: 18))
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
//        //
//        let shareBtn = UIButton().config(
//            self, selector: #selector(shareBtnPressed),
//            image: UIImage(named: "news_share"))
//            .setFrame(CGRect(x: 0, y: 0, width: 24, height: 21))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
//        //
//        hideBarGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(hideNavBar(_:)))
//    }
//    
//    func hideNavBar(_ gestureRecognizer: UIPanGestureRecognizer) {
//        let panMove = gestureRecognizer.translation(in: board)
//        if panMove.y > 20 {
//            navigationController?.setNavigationBarHidden(true, animated: true)
//        }else if panMove.y < -20 {
//            navigationController?.setNavigationBarHidden(false, animated: true)
//        }
//    }
//    
//    func backBtnPressed() {
////        navigationController?.popViewControllerAnimated(true)
//        hideNewsCoverAnimated()
//    }
//    
//    func shareBtnPressed() {
//        sharePressed()
//    }
//    
//}
//
//// MARK: - 下方评论操作栏目涉及的功能
//extension NewsDetailController{
//    
//    func avatarPressed(_ cell: DetailCommentCell) {
//        
//    }
//    
//    func replyPressed(_ cell: DetailCommentCell) {
//        // 调用原来的commentPresse函数
//        commentPressed(cell.replyBtn!)
//    }
//    
//    func checkImageDetail(_ cell: DetailCommentCell) {
//        
//    }
//    
//    /**
//     评论按钮被按下。上面评论列表的每个Cell。这里用被按下按钮的tag来区分。此时tag的值对应的是被回复的cell所在的row
//     
//     - parameter sender: 被按下的按钮
//     */
//    func commentPressed(_ sender: UIButton) {
//        responseToRow = sender.tag
//        // 取出改行的用户信息并在评论内容输入框里面填入『回复 某人：』字样
//        let targetComment = comments[responseToRow!]
//        if let responseToName = targetComment.user?.nickName {
//            responseToPrefixStr = LS("回复 ") + responseToName + ": "
//            commentPanel?.contentInput?.text = responseToPrefixStr
//        }
//        
//        atUser.removeAll()
//        commentPanel?.contentInput?.becomeFirstResponder()
//    }
//    
//    func sharePressed() {
//        let share = ShareController()
//        share.delegate = self
//        share.bgImg = self.getScreenShotBlurred(false)
//        self.present(share, animated: false, completion: nil)
//    }
//    
//    func shareControllerFinished() {
//        self.dismiss(animated: false, completion: nil)
//    }
//    
//    func likePressed() {
//        if likeRequesting {
//            return
//        }
//        likeRequesting = true
//        let requester = NewsRequester.sharedInstance
//        lp_start()
//        _ = requester.likeNews(news!.ssidString, onSuccess: { (json) -> () in
//            self.lp_stop()
//            let liked = json!["like_state"].boolValue
//            
//            self.news.liked = liked
//            self.news.likeNum = json!["like_num"].int32Value
//            self.commentPanel.setLikedAnimated(liked)
//            self.likeIcon.image = liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
//            self.likeNumLbl.text = "\(self.news.likeNum)"
//            self.likeRequesting = false
//            }) { (code) -> () in
//                self.likeRequesting = false
//                self.lp_stop()
//                self.showToast(LS("Access Error: \(code)"))
//        }
//    }
//    
//    func commentCanceled(_ commentString: String, image: UIImage?) {
//        // 目前来看取消评论以后不做任何事情
//    }
//    
//    /**
//     评论确认，将评论发送给服务器
//     
//     - parameter commentString: 评论的内容
//     - parameter image:         评论的图片，目前取消了的这个功能，故这里image总是nil
//     */
//    func commentConfirmed(_ commentString: String?, image: UIImage?) {
//        var responseToComment: NewsComment? = nil
//        if responseToRow != nil {
//            responseToComment = comments[responseToRow!]
//        }
//        
////        let newComment = NewsComment.objects.postNewCommentToNews(news!, commentString: commentString!, responseToComment: responseToComment, atString: JSON(atUser).string)
//        let newComment = NewsComment(news: news!)
//        newComment.content = commentString
//        newComment.responseTo = responseToComment
//        newComment.sent = false
//        newComment.user = MainManager.sharedManager.hostUser
//        newComment.createdAt = Date()
//        //
//        let requester = NewsRequester.sharedInstance
//        requester.postCommentToNews(news.ssidString, content: commentString, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) -> () in
//            // data里面的只有一个id
//            if data == nil {
//                assertionFailure()
//            }
//            let newCommentID = data!.int32Value
//            newComment.ssid = newCommentID
//            newComment.sent = true
//            self.news.commentNum += 1
//            self.commentNumLbl.text = "\(self.news.commentNum)"
//            self.showToast(LS("评论成功！"))
//            }) { (code) -> () in
//                
//        }
//        // 重载数据
//        
//        commentTableView.beginUpdates()
//        // 将这个新建的commnet添加在列表的头部
//        comments.insert(newComment, at: 0)
//        if comments.count == 1 {
//            commentTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        } else {
//            commentTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        }
//        commentTableView.endUpdates()
//        commentPanel?.contentInput?.text = ""
//        reArrangeCommentTableFrame()
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(commentPanel!.barheight)
//        })
//        commentPanel.superview?.layoutIfNeeded()
//    }
//    
//    
//    /**
//     截取当前画面作为UIImage输出
//     
//     - returns: 截图
//     */
//    func getScreenShot() -> UIImage {
//        UIGraphicsBeginImageContext(self.view.frame.size)
//        if let ctx = UIGraphicsGetCurrentContext(){
//            self.view.layer.render(in: ctx)
//        }
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return image!
//    }
//    
//    
//}
//
//// MARK: - 数据相关
//extension NewsDetailController {
//    
//    /**
//      这个部分负责处理数据内容，在detail界面需要下载news的web内容和评论的内容，web的一些其他数据并不会保证保持同步
//     */
//    
//    
//    /**
//     重新整理页面的结构，主要完成如下的几个工作：
//     1- 重新调整web页面的高度
//     
//     这个函数在web载入完成以后自动调用
//     */
//    fileprivate func reArrageWebViewFrames() {
//
//        newsDetailPanelView?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(newsDetailPanelView!.scrollView.contentSize.height)
//        })
//        reArrageBoardContentSize()
//    }
//    
//    /**
//     重整评论列表的长度，在reload之后调用
//     */
//    fileprivate func reArrangeCommentTableFrame() {
//        let tableContentSize = commentTableView?.contentSize
//        commentTableView?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(tableContentSize!.height)
//        })
//        reArrageBoardContentSize()
//    }
//    
//    fileprivate func reArrageBoardContentSize() {
//        self.view.updateConstraints()
//        self.view.layoutIfNeeded()
//        var contentRect = CGRect.zero
//        for view in board!.subviews {
//            contentRect = contentRect.union(view.frame)
//        }
//        board?.contentSize = CGSize(width: self.view.bounds.width, height: contentRect.height + 45)
//        self.view.layoutIfNeeded()
//    }
//    
//    /**
//     载入数据并刷新UI
//     */
//    fileprivate func loadDataAndUpdateUI() {
//        likeDescriptionLbl?.attributedText = news.getLikeDescription()
//        let imageURL = SFURL(news.cover)!
//        newsCover.kf.setImage(with: imageURL)
//        newsTitleFake.text = news.title
//        newsTitle.text = news.title
//        likeNumLbl.text = "\(news.likeNum)"
//        commentNumLbl.text = "\(news.commentNum)"
//        if news.isVideo {
//            newsDetailPanelView.loadHTMLString(news.content, baseURL: nil)
//        } else {
//            let request = URLRequest(url: news.contentURL! as URL)
//            newsDetailPanelView?.loadRequest(request)
//        }
//        loadMoreCommentData()
//        if news!.liked {
//            likeIcon.image = UIImage(named: "news_like_liked")
//            commentPanel.likeBtnIcon.image = UIImage(named: "news_like_liked")
//        }else {
//            likeIcon.image = UIImage(named: "news_like_unliked")
//            commentPanel.likeBtnIcon.image = UIImage(named: "news_like_unliked")
//        }
//    }
//    
//    /**
//
//     */
//    func loadMoreCommentData() {
//        if requestingCommentData {
//            return
//        }
//        let requester = NewsRequester.sharedInstance
//        var dateThreshold = Date()
//        if let lastComment = comments.last {
//            dateThreshold  = lastComment.createdAt as Date? ?? dateThreshold
//        }
//        requestingCommentData = true
//        _ = requester.getMoreNewsComment(dateThreshold, newsID: news.ssidString, onSuccess: { (json) -> () in
//            for data in json!.arrayValue {
//                let newComment = try! NewsComment(news: self.news).loadDataFromJSON(data)
//                self.comments.append(newComment)
//            }
//            //
//            if json!.arrayValue.count > 0 {
//                self.reorganizComments()
//                self.commentTableView?.reloadData()
//                self.commentTableLoading?.stopAnimating()
//                self.reArrangeCommentTableFrame()
//            }
//            self.requestingCommentData = false
//            }) { (code) -> () in
//                self.showToast(LS("网络访问错误:\(code)"))
//                self.requestingCommentData = false
//        }
//    }
//    
//    /**
//     重新整理这里的comments，保证排序正确和去除冗余的comment
//     */
//    func reorganizComments() {
//        // 去冗余
//        comments = $.uniq(comments, by: {return $0.ssid})
//        // 排序
//        comments.sort { (comment1, comment2) -> Bool in
//            switch comment1.createdAt!.compare(comment2.createdAt! as Date) {
//            case .orderedDescending:
//                return true
//            default:
//                return false
//            }
//        }
//    }
//}
//
//
//// MARK: - Table 相关
//extension NewsDetailController: UITableViewDataSource, UITableViewDelegate {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 88
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if comments.count == 0 {
//            return 100
//        }
//        return NewsDetailCommentCell.heightForComment(comments[(indexPath as NSIndexPath).row].content!)
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if comments.count == 0 {
//            return 1
//        }
//        return comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if comments.count == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! SSEmptyListHintCell
//            cell.titleLbl.text = LS("还没有评论")
//            return cell
//        }
//        let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailCommentCell.reuseIdentifier, for: indexPath) as! NewsDetailCommentCell
//        cell.comment = comments[(indexPath as NSIndexPath).row]
//        cell.replyBtn?.tag = (indexPath as NSIndexPath).row
//        cell.delegate = self
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if comments.count == 0 {
//            return
//        }
//        let comment = comments[(indexPath as NSIndexPath).row]
//        if comment.user.isHost {
//            return
//        } else {
//            responseToRow = (indexPath as NSIndexPath).row
//            let responseToName = comment.user.nickName!
//            responseToPrefixStr = LS("回复 ") + responseToName + ": "
//            commentPanel?.contentInput?.text = responseToPrefixStr
//            atUser.removeAll()
//            commentPanel?.contentInput?.becomeFirstResponder()
//        }
//    }
//}
//
//// MARK: - Web 相关
//extension NewsDetailController {
//    /**
//     开始载入news.content制定的URL中的网页内容
//     */
//    func startLoadWebContent() {
//        guard let url = news.contentURL else{
//            return
//        }
//        let request = URLRequest(url: url as URL)
//        newsDetailPanelView?.loadRequest(request)
//    }
//
////    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
////        newsDetailLoading?.startAnimating()
////        print(request)
////        return true
////    }
//    
//    @objc(webView:shouldStartLoadWithRequest:navigationType:)
//    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        newsDetailLoading.startAnimating()
//        print(request)
//        return true
//    }
//    
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        newsDetailLoading?.stopAnimating()
////        reArrageWebViewFrames()
//    }
//    
//    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
////        if error != nil {
//            // TODO: 错误处理，目前遇到redirect的情况的话，运作错误，暂时取消报错
////            showToast(LS("无法获取资讯详情"))
////        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "scrollView.contentSize" {
//            reArrageWebViewFrames()
//        }
//    }
//}
//
//extension NewsDetailController {
//    func scrollViewDidScroll(_ scrollView: UIScrollView){
//        if scrollView != self.board {
//            return
//        }
//        let curOffsetY = scrollView.contentOffset.y
//        let superview = self.view!
//        if curOffsetY >= 0 {
//            newsCover?.snp.remakeConstraints({ (make) -> Void in
//                make.right.equalTo(superview)
//                make.left.equalTo(superview)
//                make.top.equalTo(board)
//                make.height.equalTo(newsCover.snp.width).multipliedBy(0.573)
//            })
//        }else if curOffsetY < 0 {
//            let basicHeight = superview.frame.width * 0.573
//            let scaleFactor = (-curOffsetY) / basicHeight + 1
//            newsCover?.snp.remakeConstraints({ (make) -> Void in
//                make.top.equalTo(superview)
//                make.centerX.equalTo(superview)
//                make.width.equalTo(superview).multipliedBy(scaleFactor)
//                make.height.equalTo(newsCover.snp.width).multipliedBy(0.573)
//            })
//        }
//        self.view.layoutIfNeeded()
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 1 {
//            loadMoreCommentData()
//        }
//    }
//}
//
//
//// MARK: - 与下方评论bar相关的功能
//extension NewsDetailController {
//    
//    /**
//     在这个代理函数中，检测输入框行数的变化，并且及时调整输入框的高度
//     
//     - parameter textView: 目标textview
//     */
//    func textViewDidChange(_ textView: UITextView) {
//        let textView = commentPanel?.contentInput
//        let fixedWidth = textView?.bounds.width
//        let newSize = textView?.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.greatestFiniteMagnitude))
//        // 注：参见 CommentPanel 内部的布局设置，输入框的边缘总是距离下面的Bar的上下边界5个Point
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(max(newSize!.height  + 10 , commentPanel!.barheight))
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n" {
//            let commentText = textView.text ?? ""
//            if commentText.length > 0 {
//                commentConfirmed(commentText, image: nil)
//            }else{
//                commentCanceled("", image: nil)
//            }
//            // 调用父类InputableViewControlle的这个函数来隐藏键盘
//            dismissKeyboard()
//        }
//        
//        if text == "" && responseToPrefixStr != nil {
//            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr!.length{
//                textView.text = ""
//                responseToPrefixStr = nil
//                responseToRow = nil
//            }
//        }
//        return true
//    }
//    
//    func changeLayoutWhenKeyboardAppears(_ notif: Foundation.Notification) {
//        let userInfo = (notif as NSNotification).userInfo!
//        let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue!
//        board?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-(commentPanel!.barheight + keyboardFrame.height) )
//        })
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//    func changeLayoutWhenKeyboardDisappears(_ notif: Foundation.Notification) {
//        board?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-(commentPanel!.barheight) )
//        })
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//    // MARK: - Share
//    func titleForShare() -> String {
//        return news.title
//    }
//    
//    func descriptionForShare() -> String {
//        return news.content
//    }
//    
//    func thumbnailForShare() -> UIImage {
//        let image = newsCover.image!
//        let thumbnail = RBSquareImageTo(image, size: CGSize(width: 100, height: 100))
//        return thumbnail
//    }
//    
//    func linkForShare() -> String {
//        return news.contentURL!.absoluteString
//    }
//
//}
//
