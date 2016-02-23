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

class NewsDetailController: InputableViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, MakeCommentControllerDelegate, DetailCommentCellDelegate {
    /// 这个详情页面需要展示的相关资讯
    var news: News?
    /// 评论列表
    var comments: [NewsComment] = []
    
    /*
      下面是subviews
    */
    /// 显示面板
    var board: UIScrollView?
    var bg: UIView?
    /// 评论列表
    var commentTableView: UITableView?
    var commentTableLoading: UIActivityIndicatorView?
    /// 资讯内容的详情
    var newsDetailPanelView: UIWebView?
    var newsDetailLoading: UIActivityIndicatorView?
    /// 资讯封面
    var newsCover: UIImageView?
    /// 资讯标题
    var newsTitle: UILabel?
    //
    var likeIcon: UIImageView?
    var likeDescriptionLbl: UILabel?
    //
    var commentPanel: CommentBarView?
    
    
    var hideBarGestureRecognizer: UIPanGestureRecognizer?
    
    var coverTopConstraintOffset: SnapKit.Constraint?
    
    // 数据相关的状态变量
    var allCommentsLoaded: Bool = false
    var requestingCommentData: Bool = false
    var disableWebLink: Bool = false
    var responseToRow: Int?         // 回应的评论对象所在的行
    var responseToPrefixStr: String?
    var atUser: [String] = []
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSetting()
        createSubviews()
        loadDataAndUpdateUI()
    }
    
    internal override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        //
        board = UIScrollView(frame: superview.bounds)
        superview.addSubview(board!)
        board?.delegate = self
        board?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(superview.bounds.height - 45)
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(superview).offset(-45)
//            make.edges.equalTo(superview).inset(UIEdgeInsets(top: 0, left: 0, bottom: 45, right: 0))
        })
        board?.backgroundColor = UIColor.blackColor()
        //
        bg = UIView()
        bg?.backgroundColor = UIColor.whiteColor()
        board?.addSubview(bg!)
        //
        newsCover = UIImageView()
        board?.addSubview(newsCover!)
        newsCover?.snp_makeConstraints(closure: { (make) -> Void in
            coverTopConstraintOffset = make.top.equalTo(board!).offset(0).constraint
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(newsCover!.snp_width).multipliedBy(0.573)
        })
        newsCover?.backgroundColor = UIColor.grayColor()
        //
        newsTitle = UILabel()
        newsTitle?.font = UIFont.systemFontOfSize(21, weight: UIFontWeightBlack)
        newsTitle?.text = LS("资讯标题")
        newsTitle?.textColor = UIColor.blackColor()
        board?.addSubview(newsTitle!)
        newsTitle?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(board!).offset(-20)
            make.left.equalTo(board!).offset(20)
            make.top.equalTo(board!).offset(superview.frame.width * 0.573 + 16)
        })
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.92, alpha: 1)
        board?.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(newsTitle!)
            make.height.equalTo(1)
            make.width.equalTo(board!).multipliedBy(0.64)
            make.top.equalTo(newsTitle!.snp_bottom).offset(15)
        }
        //
        newsDetailPanelView = UIWebView()
        newsDetailPanelView?.userInteractionEnabled = false
        newsDetailPanelView?.delegate = self
        newsDetailPanelView?.paginationMode = .Unpaginated
        board?.addSubview(newsDetailPanelView!)
        newsDetailPanelView?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(sepLine.snp_bottom).offset(15)
            make.right.equalTo(superview).offset(-20)
            make.left.equalTo(superview).offset(20)
            make.height.equalTo(200)
        })
        newsDetailPanelView?.backgroundColor = UIColor.redColor()
        newsDetailPanelView?.scrollView.scrollEnabled = false
        //
        newsDetailLoading = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        newsDetailPanelView?.addSubview(newsDetailLoading!)
        newsDetailLoading?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(newsDetailPanelView!)
        })
        newsDetailLoading?.hidesWhenStopped = true
        newsDetailLoading?.startAnimating()
        //
        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        board?.addSubview(likeIcon!)
        likeIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(15)
            make.left.equalTo(newsDetailPanelView!)
            make.top.equalTo(newsDetailPanelView!.snp_bottom).offset(35)
        })
        //
        likeDescriptionLbl = UILabel()
        board?.addSubview(likeDescriptionLbl!)
        likeDescriptionLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(likeIcon!.snp_right).offset(10)
            make.centerY.equalTo(likeIcon!)
            make.height.equalTo(17)
        })
        // 
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.72, alpha: 1)
        board?.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(board!)
            make.top.equalTo(likeIcon!.snp_bottom).offset(16)
            make.height.equalTo(1)
        }
        
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
        //
        commentTableLoading = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        commentTableView?.addSubview(commentTableLoading!)
        commentTableLoading?.hidesWhenStopped = true
        commentTableLoading?.startAnimating()
        commentTableLoading?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(commentTableView!)
        })
        //
        bg?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(newsTitle!).offset(-17)
            make.bottom.equalTo(commentTableView!)
        })
        //
        initializeCommentBar()
    }
    
    func initializeCommentBar() {
        commentPanel = CommentBarView()
        let superview = self.view
        commentPanel?.contentInput?.delegate = self
        self.inputFields.append(commentPanel?.contentInput)
        superview.addSubview(commentPanel!)
        commentPanel?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview)
            make.bottom.equalTo(superview).offset(0)
            make.left.equalTo(superview)
            make.height.equalTo(commentPanel!.barheight)
        })
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
        navigationController?.popViewControllerAnimated(true)
    }
    
    func shareBtnPressed() {
        
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
        
    }
    
    func likePressed() {
        
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
        board?.contentSize = CGSize(width: self.view.bounds.width, height: contentRect.height)
        self.view.layoutIfNeeded()
    }
    
    /**
     载入数据并刷新UI
     */
    private func loadDataAndUpdateUI() {
        likeDescriptionLbl?.attributedText = news?.getLikeDescription()
        let imageURL = SFURL(news!.cover!)!
        newsCover?.kf_setImageWithURL(imageURL)
        let url = NSURL(string: news!.contentURL!)!
        let request = NSURLRequest(URL: url)
        newsDetailPanelView?.loadRequest(request)
        loadMoreCommentData()
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
            guard let data = json?.array else{
                assertionFailure()
                return
            }
            let newComments = NewsComment.objects.createOrUpdate(data, news: self.news!)
            self.comments.appendContentsOf(newComments)
            //
            self.allCommentsLoaded  = newComments.count == 0
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
        if indexPath.row == comments.count - 1 && !allCommentsLoaded{
            loadMoreCommentData()
        }
        return cell
    }
}

// MARK: - Web 相关
extension NewsDetailController {
    /**
     开始载入news.content制定的URL中的网页内容
     */
    func startLoadWebContent() {
        guard let url = NSURL(string: news!.contentURL!) else{
            return
        }
        let request = NSURLRequest(URL: url)
        newsDetailPanelView?.loadRequest(request)
    }

    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        newsDetailLoading?.startAnimating()
        switch navigationType{
        case .Other:
            return true
        default:
            return false
        }
        
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        newsDetailLoading?.stopAnimating()
        reArrageWebViewFrames()
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

