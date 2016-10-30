//
//  NewsDetail2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/9/15.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Alamofire
import Dollar

private var newsContext = 0

class NewsDetailEntranceAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var slowDownFactor: Double = 1
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! NewsController2
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! NewsDetailController2
        let containerView = transitionContext.containerView
        
        let fromView = fromViewController.view
        let toView = toViewController.view
        
        toView?.layer.opacity = 0
        toView?.frame = transitionContext.finalFrame(for: toViewController)
        containerView.addSubview(toView!)
        
        let tempCover = fromViewController.selectedCell!.snapshotView(afterScreenUpdates: false)
        let originFrame = fromViewController.getSelectedNewsCellFrame()
        toViewController.initCoverFrame = originFrame
        tempCover?.frame = originFrame
        containerView.addSubview(tempCover!)
        let targetFrame = CGRect(x: 0, y: 64, width: originFrame.width, height: originFrame.height)
        
        UIView.animate(withDuration: 0.4 * slowDownFactor, animations: {
            tempCover?.frame = targetFrame
            fromView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            fromView?.layer.opacity = 0.1
            toView?.layer.opacity = 1
            }, completion: { (_) in
                tempCover?.removeFromSuperview()
                toViewController.animateTitleEntry(0.3 * self.slowDownFactor, onFinished: {
                    if transitionContext.transitionWasCancelled {
                        toView?.removeFromSuperview()
                    } else {
                        fromView?.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                })
        }) 
    }
}

class NewsDetailDismissAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var slowDownFactor: Double = 1
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7 * slowDownFactor
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! NewsDetailController2
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! NewsController2
        let containerView = transitionContext.containerView
        
        fromViewController.animateTitleOut(0.3 * slowDownFactor) {
            let fromView = fromViewController.view
            let toView = toViewController.view
            toView?.layer.opacity = 0.1
            toView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            containerView.addSubview(toView!)
            containerView.addSubview(fromView!)
            containerView.sendSubview(toBack: toView!)
            
            let tempCover = fromViewController.cover.snapshotView(afterScreenUpdates: false)
            tempCover?.backgroundColor = UIColor.red
            let targetFrame = fromViewController.initCoverFrame
            var originFrame = fromViewController.cover.convert(fromViewController.cover.bounds, to: containerView)
            if originFrame.origin.y + originFrame.height < 0 {
                originFrame.origin.y = -originFrame.height
            }
            tempCover?.frame = originFrame
            containerView.addSubview(tempCover!)
            
            UIView.animate(withDuration: 0.4 * self.slowDownFactor, animations: {
                tempCover?.frame = targetFrame
                toView?.transform = CGAffineTransform.identity
                toView?.layer.opacity = 1
                fromView?.layer.opacity = 0
                }, completion: { (_) in
                    tempCover?.removeFromSuperview()
                    if transitionContext.transitionWasCancelled {
                        toView?.removeFromSuperview()
                    } else {
                        fromView?.removeFromSuperview()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
}


class NewsDetailController2: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, LoadingProtocol, UIWebViewDelegate, RequestManageProtocol, ShareControllorDelegate, DetailCommentCellDelegate2 {
    internal var delayWorkItem: DispatchWorkItem?

    var news: News!
    var comments: [NewsComment] = []
    
    weak var newsController: NewsController2?
    
    var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    var header: UIView!
    var cover: UIImageView!
    var titleLbl: UILabel!
    var titleLblWhite: UILabel!
    var commentNumLbl: UILabel!
    var commentIcon: UIImageView!
    var shareNumLbl: UILabel!
    var shareIcon: UIImageView!
    var likeNumLbl: UILabel!
    var likeIcon: UIImageView!
    
    var newsDetail: UIWebView!
    var commentPanel: CommentBarView!
    
    var likeInfoIcon: UIImageView!
    var likeDescriptionLbl: UILabel!
    
    // animation related
    var initCoverFrame: CGRect = CGRect.zero
    
    // data related
    var onGoingRequest: [String: Request] = [:]
    let likeRequestKey = "like"
    let commentRequestKey = "comment"
    var responseToRow: Int?         // 回应的评论对象所在的行
    var responseToPrefixStr: String?
    var atUser: [String] = []
    
    // 
    var tapper: UITapGestureRecognizer!
    
    //
    var initialTaskUndone: Int = 2 {
        didSet {
            if initialTaskUndone == 0 {
                lp_stop()
            }
        }
    }
    
    var webViewReqPermitted: Int = 2
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        newsDetail.removeObserver(self, forKeyPath: "scrollView.contentSize", context: &newsContext)
        clearAllRequest()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureTapperGesture()
        configureHeader()
        configureCover()
        configureShareNumDisplay()
        configureCommentNumDisplay()
        configureLikeNumDisplay()
        configureTitleLbl()
        configureNewsContentBoard()
        configureRecentLikeInfo()
        configureCommentSepLine()
        configureCommentBar()
        
        configureNavigationBar()
        
        lp_start()
        
        loadDataAndUpdateUI()
        loadMoreCommentData(true)
        
        if news.isVideo {
            webViewReqPermitted = 2
        } else {
            webViewReqPermitted = 1
        }
    }
    
    func configureNavigationBar() {
        navigationItem.title = LS("资讯详情")
        let backBtn = UIButton().config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"))
            .setFrame(CGRect(x: 0, y: 0, width: 18, height: 18))
        backBtn.imageView?.contentMode = .scaleAspectFit
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        
        let shareBtn = UIButton().config(self, selector: #selector(navRightBtnPressed), image: UIImage(named: "news_share"))
            .setFrame(CGRect(x: 0, y: 0, width: 24, height: 24))
        shareBtn.imageView?.contentMode = .scaleAspectFit
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
    }
    
    func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        shareBtnPressed()
    }
    
    func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 87.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(NewsCommentCell2.self, forCellReuseIdentifier: "cell")
        tableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty")
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadNewsContent), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func configureTapperGesture() {
        tapper = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapper)
        tapper.isEnabled = false
    }
    
    func configureCover() {
        cover = header.addSubview(UIImageView.self)
            .layout({ (make) in
                make.left.equalTo(header)
                make.right.equalTo(header)
                make.top.equalTo(header)
                make.height.equalTo(UIScreen.main.bounds.width * 0.573)
            })
        cover.isHidden = true
        
        cover.addSubview(UIImageView.self).config(UIImage(named: "news_cover_mask"))
            .layout { (make) in
                make.left.equalTo(cover)
                make.right.equalTo(cover)
                make.bottom.equalTo(cover)
                make.height.equalTo(cover.snp.width).multipliedBy(0.285)
        }
    }
    
    func configureShareNumDisplay() {
        shareNumLbl = cover.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28, text: "0")
            .layout({ (make) in
                make.bottom.equalTo(cover).offset(-10)
                make.right.equalTo(cover)
                make.width.equalTo(25)
            })
        shareIcon = cover.addSubview(UIImageView.self)
            .config(UIImage(named: "news_share_white"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.right.equalTo(shareNumLbl.snp.left).offset(-3)
                make.bottom.equalTo(shareNumLbl)
                make.size.equalTo(15)
            })
    }
    
    func configureCommentNumDisplay() {
        commentNumLbl = cover.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28, text: "0")
            .layout({ (make) in
                make.right.equalTo(shareIcon.snp.left)
                make.bottom.equalTo(shareIcon)
                make.width.equalTo(30)
            })
        commentIcon = cover.addSubview(UIImageView.self)
            .config(UIImage(named: "news_comment"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.right.equalTo(commentNumLbl.snp.left).offset(-3)
                make.bottom.equalTo(commentNumLbl)
                make.size.equalTo(15)
            })
    }
    
    func configureLikeNumDisplay() {
        likeNumLbl = cover.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28, text: "0")
            .layout({ (make) in
                make.bottom.equalTo(commentNumLbl)
                make.right.equalTo(commentIcon.snp.left)
                make.width.equalTo(30)
            })
        likeIcon = cover.addSubview(UIImageView.self)
            .config(UIImage(named: "news_like_unliked"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.bottom.equalTo(likeNumLbl)
                make.right.equalTo(likeNumLbl.snp.left).offset(-3)
                make.size.equalTo(15)
            })
    }
    
    func configureTitleLbl() {
        titleLbl = header.addSubview(UILabel.self)
            .config(17, fontWeight: UIFontWeightSemibold, textColor: UIColor.black, multiLine: true)
            .layout({ (make) in
                make.left.equalTo(cover).offset(15)
                make.bottom.equalTo(cover).offset(-10)
                make.right.equalTo(likeIcon.snp.left).offset(-5)
            })
        titleLbl.layer.opacity = 0
        
        titleLblWhite = cover.addSubview(UILabel.self)
            .config(17, fontWeight: UIFontWeightSemibold, textColor: UIColor.white, multiLine: true)
            .layout({ (make) in
                make.edges.equalTo(titleLbl)
            })
        titleLbl.layer.opacity = 0
    }
    
    func configureNewsContentBoard() {
        newsDetail = UIWebView()
        newsDetail.delegate = self
        
        newsDetail.addObserver(self, forKeyPath: "scrollView.contentSize", options: .new, context: &newsContext)
        header.addSubview(newsDetail)
        
        newsDetail.snp.makeConstraints { (make) in
            make.top.equalTo(cover.snp.bottom).offset(15)
            make.left.equalTo(cover)
            make.right.equalTo(cover)
            make.height.equalTo(100)
        }
        newsDetail.scrollView.isScrollEnabled = false
    }
    
    func configureRecentLikeInfo() {
        likeInfoIcon = header.addSubview(UIImageView.self)
            .config(UIImage(named: "news_like_unliked"))
            .layout({ (make) in
                make.left.equalTo(header).offset(15)
                make.size.equalTo(15)
                make.top.equalTo(newsDetail.snp.bottom).offset(30)
            })
        likeInfoIcon.contentMode = .scaleAspectFit
        likeDescriptionLbl = header.addSubview(UILabel.self)
            .layout({ (make) in
                make.left.equalTo(likeInfoIcon.snp.right).offset(10)
                make.centerY.equalTo(likeInfoIcon)
            })
    }
    
    func configureCommentSepLine() {
        let sepLine = header.addSubview(UIView.self).config(kTextGray28)
            .layout { (make) in
                make.left.equalTo(view)
                make.right.equalTo(view)
                make.height.equalTo(0.5)
                make.top.equalTo(likeInfoIcon.snp.bottom).offset(24)
        }
        header.addSubview(UILabel.self).config(UIColor.white).config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28, textAlignment: .center, text: LS("评论"))
            .layout { (make) in
                make.centerY.equalTo(sepLine.snp.top)
                make.centerX.equalTo(header)
                make.width.equalTo(75)
        }
    }
    
    func configureCommentBar() {
        commentPanel = CommentBarView()
        view.addSubview(commentPanel)
        commentPanel.contentInput?.delegate = self
        commentPanel.setOriginY(view.bounds.height)
        
        commentPanel.likeBtn?.addTarget(self, action: #selector(likeBtnPressed), for: .touchUpInside)
        commentPanel.shareBtn?.addTarget(self, action: #selector(shareBtnPressed), for: .touchUpInside)
        
        tableView.contentInset = UIEdgeInsetsMake(0, 0, commentPanel.barheight, 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func configureHeader() {
        header = UIView()
        header.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)

        tableView.tableHeaderView = header
    }
    
    func loadDataAndUpdateUI() {
        cover.kf.setImage(with: news.coverURL!)
        titleLbl.text = news.title
        titleLblWhite.text = news.title
        if news.likeNum > 99 {
            likeNumLbl.text = "99+"
        } else {
            likeNumLbl.text = "\(news.likeNum)"
        }
        
        if news.commentNum > 99 {
            commentNumLbl.text = "99+"
        } else {
            commentNumLbl.text = "\(news.commentNum)"
        }
        
        if news.shareNum > 99 {
            shareNumLbl.text = "99+"
        } else {
            shareNumLbl.text = "\(news.shareNum)"
        }
        reloadLikeStatusAndUpdateUI()
        
        setNewsDetail()
    }
    
    func reloadLikeStatusAndUpdateUI(){
        if news.liked {
            likeIcon.image = UIImage(named: "news_like_liked")
            likeInfoIcon.image = likeIcon.image
        } else {
            likeIcon.image = UIImage(named: "news_like_unliked")
            likeInfoIcon.image = likeIcon.image
        }
        commentPanel.setLikedAnimated(news.liked)
        likeDescriptionLbl.attributedText = news.getLikeDescription()
    }
    
    
    func reloadNewsContent() {
        newsDetail.stopLoading()
        
        if news.isVideo {
            webViewReqPermitted = 2
        } else {
            webViewReqPermitted = 1
        }
        
        setNewsDetail()
    }
    
    func setNewsDetail() {
        if news.isVideo {
            newsDetail.loadHTMLString(String(format: VIDEO_HTML_TEMPLATE, news.content), baseURL: nil)
        } else {
            let req = URLRequest(url: news.contentURL! as URL)
            newsDetail.loadRequest(req)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "scrollView.contentSize" {
            view.updateConstraints()
            view.layoutIfNeeded()
            newsDetail.snp.updateConstraints({ (make) in
                make.height.equalTo(newsDetail.scrollView.contentSize.height)
            })
            view.layoutIfNeeded()
            updateHeaderHeight()
        }
    }
    
    func updateHeaderHeight() {
        header.layoutIfNeeded()
        var headerRect: CGRect = CGRect.zero
        for view in header.subviews {
            headerRect = headerRect.union(view.frame)
        }
        var currentFrame = header.frame
        currentFrame.size.height = headerRect.height + 18
        
        header.frame = currentFrame
        tableView.tableHeaderView = header
    }
    
    //
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(comments.count, 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments.count > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsCommentCell2
            let comment = comments[(indexPath as NSIndexPath).row]
            cell.setData(comment.user.avatarURL!, name: comment.user.nickName!, content: comment.content, commentAt: comment.createdAt, responseTo: comment.responseTo?.user.nickName, showReplyBtn: !comment.user.isHost)
            cell.delegate = self
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有评论")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // Animation utilities
    
    func animateTitleEntry(_ duration: Double, onFinished: @escaping ()->()) {
        titleLblWhite.layer.opacity = 1
        cover.isHidden = false
        let titleWidth = titleLbl.frame.width
        view.layoutIfNeeded()
        titleLbl.snp.remakeConstraints { (make) in
            make.left.equalTo(header).offset(40)
            make.top.equalTo(cover.snp.bottom).offset(15)
            make.width.equalTo(titleWidth)
        }
        newsDetail.snp.remakeConstraints { (make) in
            make.top.equalTo(titleLbl.snp.bottom).offset(10)
            make.left.equalTo(cover)
            make.right.equalTo(cover)
            make.height.equalTo(newsDetail.scrollView.contentSize.height)
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.titleLbl.layer.opacity = 1
            self.titleLblWhite.layer.opacity = 0
            let titleTransform = CGAffineTransform(scaleX: 1.23, y: 1.23)
            self.titleLbl.transform = titleTransform
            self.titleLblWhite.transform = titleTransform
            
            self.commentPanel.setOriginY(self.view.bounds.height - self.commentPanel.barheight)
            self.view.layoutIfNeeded()
            self.updateHeaderHeight()
            }, completion: { (_) in
                onFinished()
        }) 
    }
    
    func animateTitleOut(_ duration: Double, onFinished: @escaping ()->()) {
        titleLbl.snp.remakeConstraints { (make) in
            make.left.equalTo(cover).offset(15)
            make.bottom.equalTo(cover).offset(-10)
            make.right.equalTo(likeIcon.snp.left).offset(-5)
        }
        newsDetail.snp.remakeConstraints { (make) in
            make.top.equalTo(cover.snp.bottom).offset(15)
            make.left.equalTo(cover)
            make.right.equalTo(cover)
            make.height.equalTo(newsDetail.scrollView.contentSize.height)
        }
        
        UIView.animate(withDuration: duration, animations: { 
            self.titleLbl.layer.opacity = 0
            self.titleLblWhite.layer.opacity = 1
            self.titleLbl.transform = CGAffineTransform.identity
            self.titleLblWhite.transform = CGAffineTransform.identity
            
            self.view.layoutIfNeeded()
            self.commentPanel.setOriginY(self.view.frame.height)
            self.updateHeaderHeight()
            }, completion: { (_) in
                onFinished()
        }) 
    }
    
    // data
    
    func loadMoreCommentData(_ initialCall: Bool = false) {
        clearRequestForKey(#function)
        
        let dateThreshold = comments.last?.createdAt ?? Date()
        
        NewsRequester.sharedInstance.getMoreNewsComment(dateThreshold, newsID: news.ssidString, onSuccess: { (json) in
            let array = json!.arrayValue
            for data in array {
                let comment = try! NewsComment(news: self.news).loadDataFromJSON(data)
                self.comments.append(comment)
            }
            if array.count > 0 {
                self.comments = $.uniq(self.comments, by: { $0.ssid })
                self.tableView.reloadData()
            }
            if initialCall {
                self.initialTaskUndone -= 1
            }
            }, onError: { (code) in
                self.showToast(LS("网络访问错误：\(code)"))
        }).registerForRequestManage(self, forKey: #function)
    }
    
    // 
    
    func likeBtnPressed() {
        clearRequestForKey(#function)
        lp_start()
        NewsRequester.sharedInstance.likeNews(news!.ssidString, onSuccess: { (json) -> () in
            self.lp_stop()
            let liked = json!["like_state"].boolValue
            
            self.news.liked = liked
            self.news.likeNum = json!["like_num"].int32Value
            self.likeNumLbl.text = "\(self.news.likeNum)"
            self.reloadLikeStatusAndUpdateUI()
        }) { (code) -> () in
            self.lp_stop()
            self.showToast(LS("Access Error: \(code)"))
            }.registerForRequestManage(self, forKey: #function)
    }
    
    func shareBtnPressed() {
        let share = ShareController()
        share.delegate = self
        share.bgImg = self.getScreenShotBlurred(false)
        self.present(share, animated: false, completion: nil)
    }
    
    func shareControllerFinished() {
        dismiss(animated: false, completion: nil)
    }
    
    func changeLayoutWhenKeyboardStatusChanges(_ notification: Foundation.Notification) {
        switch notification.name {
        case NSNotification.Name.UIKeyboardWillShow:
            let userInfo = (notification as NSNotification).userInfo!
            let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue!
            commentPanel.setOriginY(view.frame.height - keyboardFrame.height - commentPanel.frame.height)
            tableView.contentInset = UIEdgeInsetsMake(0, 0, view.bounds.height - commentPanel.frame.origin.y, 0)
            break
        case NSNotification.Name.UIKeyboardWillHide:
            commentPanel.setOriginY(view.frame.height - commentPanel.frame.height)
            tableView.contentInset = UIEdgeInsetsMake(0, 0, view.bounds.height - commentPanel.frame.origin.y, 0)
            break
        case NSNotification.Name.UIKeyboardDidChangeFrame:
            break
        default:
            break
        }
    }
    
    // text editor
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        tapper.isEnabled = true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let textView = commentPanel.contentInput!
        let fixedWidth = textView.bounds.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        commentPanel.setBarHeight(newSize.height)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let commentText = textView.text ?? ""
            if commentText.length > 0 {
                commentConfirmed(commentText)
            }else{
                commentCanceled()
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
    
    func dismissKeyboard() {
        commentPanel.contentInput?.resignFirstResponder()
        tapper.isEnabled = false
    }
    
    func commentCanceled() {
        // do nothing
    }
    
    func commentConfirmed(_ commentString: String?) {
        var responseToComment: NewsComment? = nil
        if responseToRow != nil {
            responseToComment = comments[responseToRow!]
        }
        
        //        let newComment = NewsComment.objects.postNewCommentToNews(news!, commentString: commentString!, responseToComment: responseToComment, atString: JSON(atUser).string)
        let newComment = NewsComment(news: news!)
        newComment.content = commentString
        newComment.responseTo = responseToComment
        newComment.sent = false
        newComment.user = MainManager.sharedManager.hostUser
        newComment.createdAt = Date()
        //
        let requester = NewsRequester.sharedInstance
        requester.postCommentToNews(news.ssidString, content: commentString, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) -> () in
            // data里面的只有一个id
            if data == nil {
                assertionFailure()
            }
            let newCommentID = data!.int32Value
            newComment.ssid = newCommentID
            newComment.sent = true
            self.news.commentNum += 1
            self.commentNumLbl.text = "\(self.news.commentNum)"
            self.showToast(LS("评论成功！"))
        }) { (code) -> () in
            
        }
        // 重载数据
        
        tableView.beginUpdates()
        // 将这个新建的commnet添加在列表的头部
        comments.insert(newComment, at: 0)
        if comments.count == 1 {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        } else {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        tableView.endUpdates()
        commentPanel?.contentInput?.text = ""
        
        commentPanel.restBarHeight()
    }
    
    // 
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.initialTaskUndone -= 1
        self.webViewReqPermitted -= 1
        
        if webViewReqPermitted == 0 {
            refreshControl.endRefreshing()
        }
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return webViewReqPermitted > 0
    }
    
    func titleForShare() -> String {
        return news.title
    }
    
    func descriptionForShare() -> String {
        return news.content
    }
    
    func thumbnailForShare() -> UIImage {
        let image = cover.image!
        let thumbnail = RBSquareImageTo(image, size: CGSize(width: 100, height: 100))
        return thumbnail
    }
    
    func linkForShare() -> String {
        return news.contentURL!.absoluteString
    }
    
    func detailCommentCellReplyPressed(_ cell: DetailCommentCell2) {
        responseToRow = (tableView.indexPath(for: cell) as NSIndexPath?)?.row
        let targetComment = comments[responseToRow!]
        let responseToName = targetComment.user!.nickName!
        responseToPrefixStr = LS("回复") + responseToName + ": "
        commentPanel.contentInput!.text = responseToPrefixStr
        atUser.removeAll()
        commentPanel.contentInput?.becomeFirstResponder()
    }
    
    func detailCommentCellAvatarPressed(_ cell: DetailCommentCell2) {
        if let row = (tableView.indexPath(for: cell) as NSIndexPath?)?.row {
            let comment = comments[row]
            navigationController?.pushViewController(comment.user.showDetailController(), animated: true)
        }
    }
}
