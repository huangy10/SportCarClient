//
//  NewsDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/29.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import Spring
import Dollar
import SwiftyJSON

class NewsDetailController: InputableViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, MakeCommentControllerDelegate, DetailCommentCellDelegate, ShareControllorDelegate {
    /// 这个详情页面需要展示的相关资讯
    var news: News?
    /// 评论列表
    var comments: [NewsComment] = []
    /// 动画需要：cover的初始位置
    var initPos: CGFloat = 0
    /// 动画需要：初始启动的背景截图
    var initBg: UIImageView!
    var initBgImg: UIImage!
    /*
      下面是subviews
    */
    /// 显示面板
    var board: UIScrollView!
    var bg: UIView!
    /// 评论列表
    var commentTableView: UITableView!
    var commentTableLoading: UIActivityIndicatorView!
    /// 资讯内容的详情
    var newsDetailPanelView: UIWebView!
    var newsDetailLoading: UIActivityIndicatorView!
    /// 资讯封面
    var newsCover: UIImageView!
    /// 资讯标题
    var newsTitleFake: UILabel!
    var newsTitle: UILabel!
    /// 封面下方的三组信息
    var commentNumLbl: UILabel!
    var shareNumLbl: UILabel!
    var likeNumLbl: UILabel!
    var likeIcon: UIImageView!
    var shareIcon: UIImageView!
    var commentIcon: UIImageView!
    //
    var likeInfoIcon: UIImageView!
    var likeDescriptionLbl: UILabel!
    //
    var commentPanel: CommentBarView!
    
    
    var hideBarGestureRecognizer: UIPanGestureRecognizer?
    
    var coverTopConstraintOffset: SnapKit.Constraint?
    
    // 数据相关的状态变量
    var requestingCommentData: Bool = false
    var disableWebLink: Bool = false
    var responseToRow: Int?         // 回应的评论对象所在的行
    var responseToPrefixStr: String?
    var atUser: [String] = []
    
    var likeRequesting: Bool = false
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetting()
        createSubviews()
        createNewsContentViews()
        initializeCommentBar()
        loadDataAndUpdateUI()
        loadNewsCoverAnimated()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadNewsCoverAnimated() {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        let titleWidth = self.newsTitle.frame.width
        newsCover.snp_updateConstraints { (make) -> Void in
            make.top.equalTo(board).offset(0)
        }
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.initBg.layer.opacity = 0.1
            self.initBg.transform = CGAffineTransformMakeScale(0.9, 0.9)
            }, completion: { _ in
                self.newsTitle.snp_remakeConstraints(closure: { (make) -> Void in
                    make.left.equalTo(self.view).offset(40)
                    make.top.equalTo(self.newsCover.snp_bottom).offset(15)
                    make.width.equalTo(titleWidth)
                })
                self.newsTitleFake.snp_remakeConstraints(closure: { (make) -> Void in
                    make.edges.equalTo(self.newsTitle)
                })
                UIView.animateWithDuration(0.4, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.newsTitle.layer.opacity = 1
                    self.newsTitleFake.layer.opacity = 0
                    self.newsTitle.transform = CGAffineTransformMakeScale(1.23, 1.23)
                    self.newsTitleFake.transform = CGAffineTransformMakeScale(1.23, 1.23)
                    self.view.layoutIfNeeded()
                    self.showNewsContentViews()
                    }, completion: { _ in
                        
                })
        })
        bg.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        bg.hidden = false
        UIView.animateWithDuration(0.4, delay: 0.3, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        // 弹出评论栏
        
        commentPanel.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        }
        UIView.animateWithDuration(0.2, delay: 0.7, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func hideNewsCoverAnimated() {
        let superview = self.view
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        commentPanel.snp_updateConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(45)
            self.hideNewsContentViews()
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        bg.snp_remakeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview).offset(UIScreen.mainScreen().bounds.width * 0.573)
            make.height.equalTo(0)
        }
        UIView.animateWithDuration(0.4, delay: 0.4, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        //
        self.newsTitle.snp_remakeConstraints { (make) -> Void in
            make.right.equalTo(likeIcon.snp_left)
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(newsCover).offset(-10)
        }
        self.newsTitleFake.snp_remakeConstraints { (make) -> Void in
            make.edges.equalTo(newsTitle)
        }
        UIView.animateWithDuration(0.4, delay: 0.3, options: .CurveEaseInOut, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.newsTitle.layer.opacity = 0
            self.newsTitleFake.layer.opacity = 1
            self.newsTitle.transform = CGAffineTransformIdentity
            self.newsTitleFake.transform = CGAffineTransformIdentity
            }) { (_) -> Void in
                self.newsCover.snp_updateConstraints(closure: { (make) -> Void in
                    make.top.equalTo(self.board).offset(self.initPos)
                })
                UIView.animateWithDuration(0.9, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    self.initBg.layer.opacity = 1
                    self.initBg.transform = CGAffineTransformIdentity
                    }, completion: { _ in
                        self.navigationController?.popViewControllerAnimated(false)
                })
        }
    }
    
    /**
     进场动画后期开始创建载入资讯的内容，此处将其均设置为hidden
     */
    func createNewsContentViews() {
        let superview = self.view
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        board?.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(newsTitle!)
            make.height.equalTo(1)
            make.width.equalTo(board!).multipliedBy(0.64)
            make.top.equalTo(newsTitle!.snp_bottom).offset(15)
        }
        sepLine.layer.opacity = 0
        newsDetailPanelView = UIWebView()
        newsDetailPanelView?.delegate = self
        newsDetailPanelView?.paginationMode = .Unpaginated
        board?.addSubview(newsDetailPanelView!)
        newsDetailPanelView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(sepLine.snp_bottom).offset(15)
            make.right.equalTo(superview).offset(-20)
            make.left.equalTo(superview).offset(20)
            make.height.equalTo(200)
        })
        newsDetailPanelView?.scrollView.scrollEnabled = false
        newsDetailPanelView.layer.opacity = 0
        //
        newsDetailLoading = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        newsDetailPanelView?.addSubview(newsDetailLoading!)
        newsDetailLoading?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(newsDetailPanelView)
            make.size.equalTo(44)
        })
        newsDetailLoading?.hidesWhenStopped = true
        newsDetailLoading?.startAnimating()
        newsDetailLoading.layer.opacity = 0
        //
        likeInfoIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        board?.addSubview(likeInfoIcon!)
        likeInfoIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(15)
            make.left.equalTo(newsDetailPanelView!)
            make.top.equalTo(newsDetailPanelView!.snp_bottom).offset(35)
        })
        likeInfoIcon.hidden = true
        //
        likeDescriptionLbl = UILabel()
        board?.addSubview(likeDescriptionLbl!)
        likeDescriptionLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(likeInfoIcon!.snp_right).offset(10)
            make.centerY.equalTo(likeInfoIcon!)
            make.height.equalTo(17)
        })
        likeDescriptionLbl.layer.opacity = 0
        //
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(board!)
            make.top.equalTo(likeInfoIcon!.snp_bottom).offset(16)
            make.height.equalTo(1)
        }
        sepLine2.layer.opacity = 0
        
        let commentStaticLbl = UILabel()
        commentStaticLbl.backgroundColor = UIColor.whiteColor()
        commentStaticLbl.text = LS("评论")
        commentStaticLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        commentStaticLbl.textAlignment = .Center
        commentStaticLbl.textColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(commentStaticLbl)
        commentStaticLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(board!)
            make.centerY.equalTo(sepLine2)
            make.size.equalTo(CGSize(width: 75, height: 17))
        }
        commentStaticLbl.layer.opacity = 0
        //
        commentTableView = UITableView(frame: CGRect.zero, style: .Plain)
        commentTableView?.delegate = self
        commentTableView?.dataSource = self
        commentTableView?.separatorStyle = .None
        commentTableView?.registerClass(NewsDetailCommentCell.self, forCellReuseIdentifier: NewsDetailCommentCell.reuseIdentifier)
        board?.addSubview(commentTableView!)
        commentTableView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(sepLine2.snp_bottom).offset(27)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(100)
        })
        commentTableView?.scrollEnabled = false
        commentTableView.layer.opacity = 0
        //
        commentTableLoading = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        commentTableView?.addSubview(commentTableLoading!)
        commentTableLoading?.hidesWhenStopped = true
        commentTableLoading?.startAnimating()
        commentTableLoading?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(commentTableView!)
            make.size.equalTo(44)
        })
        commentTableLoading.layer.opacity = 0
    }
    
    func showNewsContentViews(){
        newsDetailPanelView.layer.opacity = 1
        commentTableView.layer.opacity = 1
    }
    
    func hideNewsContentViews() {
        newsDetailPanelView.layer.opacity = 0
        commentTableView.layer.opacity = 0
    }
    
    internal override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        board = UIScrollView()
        superview.addSubview(board)
        board.delegate = self
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        board.backgroundColor = UIColor.blackColor()
        //
        initBg = UIImageView(image: initBgImg)
        board.addSubview(initBg)
        initBg.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
            make.height.equalTo(UIScreen.mainScreen().bounds.height)
        }//
        bg = UIView()
        board.addSubview(bg)
        bg.backgroundColor = UIColor.whiteColor()
        bg.hidden = true
        bg.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(superview).offset(UIScreen.mainScreen().bounds.width * 0.573)
            make.height.equalTo(0)
        }
        //
        newsCover = UIImageView()
        board.addSubview(newsCover)
        newsCover.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(board).offset(initPos)
            make.height.equalTo(newsCover.snp_width).multipliedBy(0.573)
        }
        let coverMask = UIImageView(image: UIImage(named: "news_cover_mask"))
        newsCover.addSubview(coverMask)
        coverMask.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(newsCover)
            make.right.equalTo(newsCover)
            make.bottom.equalTo(newsCover)
            make.height.equalTo(107)
        }
        // 创建like， comment和share标签
        shareNumLbl = UILabel()
        shareNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        shareNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        shareNumLbl.text = "0"
        superview.addSubview(shareNumLbl)
        shareNumLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(newsCover).offset(-10)
            make.right.equalTo(superview).offset(-15)
            make.height.equalTo(15)
            make.width.lessThanOrEqualTo(30)
        })
        shareIcon = UIImageView(image: UIImage(named: "news_share"))
        superview.addSubview(shareIcon)
        shareIcon.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(shareNumLbl.snp_left).offset(-3)
            make.bottom.equalTo(shareNumLbl)
            make.size.equalTo(15)
        })
        //
        commentNumLbl = UILabel()
        commentNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        commentNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        commentNumLbl.text = "0"
        superview.addSubview(commentNumLbl)
        commentNumLbl.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(shareIcon.snp_left)
            make.bottom.equalTo(shareIcon)
            make.size.equalTo(CGSize(width: 30, height: 15))
        })
        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
        superview.addSubview(commentIcon)
        commentIcon.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(commentNumLbl.snp_left).offset(-3)
            make.bottom.equalTo(commentNumLbl)
            make.size.equalTo(15)
        })
        //
        likeNumLbl = UILabel()
        likeNumLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        likeNumLbl.textColor = UIColor(white: 0.72, alpha: 1)
        superview.addSubview(likeNumLbl)
        likeNumLbl.text = "0"
        likeNumLbl.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(commentIcon)
            make.right.equalTo(commentIcon.snp_left)
            make.size.equalTo(CGSizeMake(30, 15))
        })
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        superview.addSubview(likeIcon)
        likeIcon.snp_makeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(commentIcon)
            make.right.equalTo(likeNumLbl.snp_left).offset(-3)
            make.size.equalTo(15)
        })
        //
        newsTitleFake = UILabel()
        newsTitleFake.font = UIFont.systemFontOfSize(17, weight: UIFontWeightBlack)
        newsTitleFake.textColor = UIColor.whiteColor()
        newsTitleFake.numberOfLines = 0
        board.addSubview(newsTitleFake)
        newsTitleFake.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(likeIcon.snp_left)
            make.left.equalTo(superview).offset(15)
            make.bottom.equalTo(newsCover).offset(-10)
        }
        newsTitle = UILabel()
        newsTitle.font = UIFont.systemFontOfSize(17, weight: UIFontWeightBlack)
        newsTitle.textColor = UIColor.blackColor()
        newsTitle.numberOfLines = 0
        board.addSubview(newsTitle)
        newsTitle.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(newsTitleFake)
        }
        newsTitle.layer.opacity = 0
        //
        
    }
    
    func initializeCommentBar() {
        commentPanel = CommentBarView()
        let superview = self.view
        commentPanel?.contentInput?.delegate = self
        self.inputFields.append(commentPanel?.contentInput)
        superview.addSubview(commentPanel!)
        commentPanel?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.bottom.equalTo(superview).offset(45)
            make.left.equalTo(superview)
            make.height.equalTo(commentPanel!.barheight)
        })
        
        commentPanel.likeBtn?.addTarget(self, action: "likePressed", forControlEvents: .TouchUpInside)
        commentPanel.shareBtn?.addTarget(self, action: "sharePressed", forControlEvents: .TouchUpInside)
        
        // 添加键盘出现时时间的监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardAppears:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardDisappears:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func navSetting() {
        navigationItem.title = LS("资讯详情")
        //
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "news_share_white"), forState: .Normal)
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 21)
        shareBtn.addTarget(self, action: "shareBtnPressed", forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
        //
        hideBarGestureRecognizer = UIPanGestureRecognizer(target: self, action: "hideNavBar:")
    }
    
    func hideNavBar(gestureRecognizer: UIPanGestureRecognizer) {
        let panMove = gestureRecognizer.translationInView(board)
        if panMove.y > 20 {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }else if panMove.y < -20 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func backBtnPressed() {
//        navigationController?.popViewControllerAnimated(true)
        hideNewsCoverAnimated()
    }
    
    func shareBtnPressed() {
        sharePressed()
    }
    
}

// MARK: - 下方评论操作栏目涉及的功能
extension NewsDetailController{
    
    func avatarPressed(cell: DetailCommentCell) {
        
    }
    
    func replyPressed(cell: DetailCommentCell) {
        // 调用原来的commentPresse函数
        commentPressed(cell.replyBtn!)
    }
    
    func checkImageDetail(cell: DetailCommentCell) {
        
    }
    
    /**
     评论按钮被按下。上面评论列表的每个Cell。这里用被按下按钮的tag来区分。此时tag的值对应的是被回复的cell所在的row
     
     - parameter sender: 被按下的按钮
     */
    func commentPressed(sender: UIButton) {
        responseToRow = sender.tag
        // 取出改行的用户信息并在评论内容输入框里面填入『回复 某人：』字样
        let targetComment = comments[responseToRow!]
        if let responseToName = targetComment.user?.nickName {
            responseToPrefixStr = LS("回复 ") + responseToName + ": "
            commentPanel?.contentInput?.text = responseToPrefixStr
        }
        
        atUser.removeAll()
        commentPanel?.contentInput?.becomeFirstResponder()
    }
    
    func sharePressed() {
        let share = ShareController()
        share.delegate = self
        share.bgImg = self.getScreenShotBlurred(false)
        self.presentViewController(share, animated: false, completion: nil)
    }
    
    func shareControllerFinished() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func likePressed() {
        if likeRequesting {
            return
        }
        likeRequesting = true
        let requester = NewsRequester.newsRequester
        requester.likeNews(news!.newsID!, onSuccess: { (json) -> () in
            
            let liked = json!["like_state"].boolValue
            
            self.news?.liked = liked
            self.news?.likeNum = json!["like_num"].int32Value
            self.commentPanel.setLikedAnimated(liked)
            self.likeIcon.image = liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
            self.likeRequesting = false
            }) { (code) -> () in
                self.likeRequesting = false
        }
    }
    
    func commentCanceled(commentString: String, image: UIImage?) {
        // 目前来看取消评论以后不做任何事情
    }
    
    /**
     评论确认，将评论发送给服务器
     
     - parameter commentString: 评论的内容
     - parameter image:         评论的图片，目前取消了的这个功能，故这里image总是nil
     */
    func commentConfirmed(commentString: String?, image: UIImage?) {
        var responseToComment: NewsComment? = nil
        if responseToRow != nil {
            responseToComment = comments[responseToRow!]
        }
        
        let newComment = NewsComment.objects.postNewCommentToNews(news!, commentString: commentString!, responseToComment: responseToComment, atString: JSON(atUser).string)
        // 将这个新建的commnet添加在列表的头部
        comments.insert(newComment, atIndex: 0)
        //
        let requester = NewsRequester.newsRequester
        requester.postCommentToNews(self.news!.newsID!, content: commentString, image: nil, responseTo: responseToComment?.commentID, informOf: atUser, onSuccess: { (data) -> () in
            // data里面的只有一个id
            if data == nil {
                assertionFailure()
            }
            let newCommentID = data!.stringValue
            NewsComment.objects.confirmSent(newComment, commentID: newCommentID)
            }) { (code) -> () in
                print(code)
        }
        // 重载数据
        commentTableView?.reloadData()
        commentPanel?.contentInput?.text = ""
        reArrangeCommentTableFrame()
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(commentPanel!.barheight)
        })
    }
    
    
    /**
     截取当前画面作为UIImage输出
     
     - returns: 截图
     */
    func getScreenShot() -> UIImage {
        UIGraphicsBeginImageContext(self.view.frame.size)
        if let ctx = UIGraphicsGetCurrentContext(){
            self.view.layer.renderInContext(ctx)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    
}

// MARK: - 数据相关
extension NewsDetailController {
    
    /**
      这个部分负责处理数据内容，在detail界面需要下载news的web内容和评论的内容，web的一些其他数据并不会保证保持同步
     */
    
    
    /**
     重新整理页面的结构，主要完成如下的几个工作：
     1- 重新调整web页面的高度
     
     这个函数在web载入完成以后自动调用
     */
    private func reArrageWebViewFrames() {

        newsDetailPanelView?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(newsDetailPanelView!.scrollView.contentSize.height)
        })
        reArrageBoardContentSize()
    }
    
    /**
     重整评论列表的长度，在reload之后调用
     */
    private func reArrangeCommentTableFrame() {
        let tableContentSize = commentTableView?.contentSize
        commentTableView?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(tableContentSize!.height)
        })
        reArrageBoardContentSize()
    }
    
    private func reArrageBoardContentSize() {
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        var contentRect = CGRect.zero
        for view in board!.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        board?.contentSize = CGSize(width: self.view.bounds.width, height: contentRect.height + 45)
        self.view.layoutIfNeeded()
    }
    
    /**
     载入数据并刷新UI
     */
    private func loadDataAndUpdateUI() {
        likeDescriptionLbl?.attributedText = news?.getLikeDescription()
        let imageURL = SFURL(news!.cover!)!
        newsCover?.kf_setImageWithURL(imageURL)
        newsTitleFake.text = news?.title
        newsTitle.text = news?.title
        likeNumLbl.text = "\(news?.likeNum ?? 0)"
        commentNumLbl.text = "\(news?.commentNum ?? 0)"
        let url = NSURL(string: news!.contentURL!)!
        let request = NSURLRequest(URL: url)
        newsDetailPanelView?.loadRequest(request)
        loadMoreCommentData()
        if news!.liked {
            likeIcon.image = UIImage(named: "news_like_liked")
            commentPanel.likeBtnIcon.image = UIImage(named: "news_like_liked")
        }else {
            likeIcon.image = UIImage(named: "news_like_unliked")
            commentPanel.likeBtnIcon.image = UIImage(named: "news_like_unliked")
        }
    }
    
    /**

     */
    func loadMoreCommentData() {
        if requestingCommentData {
            print("重复的网络请求---资讯详情页面")
            return
        }
        let requester = NewsRequester.newsRequester
        var dateThreshold = NSDate()
        if let lastComment = comments.last {
            dateThreshold  = lastComment.createdAt ?? dateThreshold
        }
        requestingCommentData = true
        requester.getMoreNewsComment(dateThreshold, newsID: news!.newsID!, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let newComment = NewsComment.objects.getOrCreate(data, news: self.news!)
                self.comments.append(newComment)
            }
            //
            self.reorganizComments()
            self.commentTableView?.reloadData()
            self.commentTableLoading?.stopAnimating()
        
            self.requestingCommentData = false
            self.reArrangeCommentTableFrame()
            }) { (code) -> () in
                print(code)
                self.requestingCommentData = false
                assertionFailure()
        }
    }
    
    /**
     重新整理这里的comments，保证排序正确和去除冗余的comment
     */
    func reorganizComments() {
        // 去冗余
        comments = $.uniq(comments, by: { (comment: NewsComment) -> String in
            return comment.commentID!
        })
        // 排序
        comments.sortInPlace { (comment1, comment2) -> Bool in
            switch comment1.createdAt!.compare(comment2.createdAt!) {
            case .OrderedDescending:
                return true
            default:
                return false
            }
        }
    }
}


// MARK: - Table 相关
extension NewsDetailController {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return NewsDetailCommentCell.heightForComment(comments[indexPath.row].content!)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(NewsDetailCommentCell.reuseIdentifier, forIndexPath: indexPath) as! NewsDetailCommentCell
        cell.comment = comments[indexPath.row]
        cell.replyBtn?.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

// MARK: - Web 相关
extension NewsDetailController {
    /**
     开始载入news.content制定的URL中的网页内容
     */
    func tapTest() {
        print("tapped")
    }
    func startLoadWebContent() {
        guard let url = NSURL(string: news!.contentURL!) else{
            return
        }
        let request = NSURLRequest(URL: url)
        newsDetailPanelView?.loadRequest(request)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        newsDetailLoading?.startAnimating()
        return true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        newsDetailLoading?.stopAnimating()
        reArrageWebViewFrames()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if error == nil {
            showToast(LS("无法获取资讯详情"))
        }
    }
}

extension NewsDetailController {
    func scrollViewDidScroll(scrollView: UIScrollView){
        if scrollView != self.board {
            return
        }
        let curOffsetY = scrollView.contentOffset.y
        if curOffsetY <= 0 {
            newsCover?.snp_updateConstraints(closure: { (make) -> Void in
                make.top.equalTo(board!).offset(curOffsetY / 2)
            })
        }else{
            
        }
        self.view.layoutIfNeeded()
    }
}


// MARK: - 与下方评论bar相关的功能
extension NewsDetailController {
    
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
            make.bottom.equalTo(self.view).offset(-(commentPanel!.barheight + keyboardFrame.height) )
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
//        print(notif)
//        print("hahahahahahha")
    }
    
    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
        board?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-(commentPanel!.barheight) )
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
}

