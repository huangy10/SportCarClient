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


class StatusDetailController: UIViewController {
    
    var preCellDetailRect: CGRect?
    
    var status: Status!
    var comments: [StatusComment] = []
    
    var tableView: UITableView!
    var bottomBar: BasicBottomBar!
    
    var header: UIView!
    var detail: StatusDetailHeaderView!
    let detailInset = UIEdgeInsetsMake(5, 10, 5, 10)
    
    var animatedEntry: Bool = false
    var responseToRow: Int?                 // 被回应的评论所在的行
    // TOOD: remove ?
    var responseToPrefixStr: String?        // 回应内容前缀：当回复某人时会预填充『回复：XXX』字样
    var atUser: [String] = []
    
    var tapper: UITapGestureRecognizer!
    
    init(status: Status) {
        super.init(nibName: nil, bundle: nil)
        self.status = status
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        animatedEntry = navigationController?.delegate?.isKind(of: StatusBasicController.self) ?? false
        configureNavigationBar()
        configureTableView()
        configureHeader()
        configureBottomBar()
        configureTapper()
        
        loadMoreCommentData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if animatedEntry {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomBar.setFrame(withOffsetToBottom: 0)
            })
        }
    }
    
    func configureTapper() {
        tapper = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapper)
        tapper.isEnabled = false
    }
    
    func dismissKeyboard() {
        bottomBar.contentInput.resignFirstResponder()
        //        commentPanel.contentInput?.resignFirstResponder()
        tapper.isEnabled = false
    }
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("动态详情")
        
        let backBtn = UIButton()
        backBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        backBtn.addTarget(self, action: #selector(backBtnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
        //
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), for: .normal)
        shareBtn.imageView?.contentMode = .scaleAspectFit
        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
        shareBtn.addTarget(self, action: #selector(navRightBtnPressed), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
    }
    
    func backBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
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
    
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain).config(.white)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 87
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        tableView.register(CommentStaticHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        tableView.register(DetailCommentCell2.self, forCellReuseIdentifier: "cell")
        tableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty")
    }
    
    func getHeaderFrame() -> CGRect {
        return header.convert(CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: header.bounds.height), to: navigationController!.view)
    }
    
    func configureHeader() {
        detail = StatusDetailHeaderView()
        detail.isCoverZoomable = true
        detail.delegate = self
        detail.status = status
        header = UIView()
        header.addSubview(detail)
        tableView.tableHeaderView = header
        detail.snp.makeConstraints { (make) in
//            make.edges.equalTo(header)
            make.centerX.equalTo(header)
            make.width.equalTo(view)
            make.bottom.equalTo(header)
            make.top.equalTo(header)
        }
        
        header.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: StatusDetailHeaderView.requiredHeight(forStatus: status))
        
        if animatedEntry {
            detail.layer.opacity = 0
        }
    }
    
    func configureBottomBar() {
        bottomBar = BasicBottomBar(delegate: self)
        bottomBar.forwardTextViewDelegateTo(self)
        view.addSubview(bottomBar)
        var rect = view.bounds
        rect.size.height -= 64
        if animatedEntry {
            bottomBar.setFrame(withOffsetToBottom: -bottomBar.defaultBarHeight, superviewFrame: rect)
        } else {
            bottomBar.setFrame(withOffsetToBottom: 0, superviewFrame: rect)
        }
        
        var oldInset = tableView.contentInset
        oldInset.bottom += bottomBar.defaultBarHeight
        tableView.contentInset = oldInset
    }
    
    //
    
    weak var reqOnFly: Request?
    
    func loadMoreCommentData() {
        if let req = reqOnFly {
            req.cancel()
        }
        
        let dateThreshold = comments.last()?.createdAt ?? Date()
        reqOnFly = StatusRequester.sharedInstance.getMoreStatusComment(dateThreshold, statusID: status.ssidString, onSuccess: { (json) in
            var newComments: [StatusComment] = []
            for data in json!.arrayValue {
                let comment = try! StatusComment(status: self.status).loadDataFromJSON(data)
                newComments.append(comment)
            }
            self.comments.append(contentsOf: newComments)
            self.comments = $.uniq(self.comments, by: { $0.ssid })
            if newComments.count > 0 {
                self.tableView.reloadData()
            }
        }, onError: { (code) in
            self.showToast("Error: \(code ?? "nil")")
        })
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            loadMoreCommentData()
        }
    }
    
    func likeBtnPressed() {
        reqOnFly = StatusRequester.sharedInstance.likeStatus(status.ssidString, onSuccess: { (json) in
            self.status.likeNum = json!["like_num"].int32Value
            self.status.liked = json!["like_state"].boolValue
            self.bottomBar.reloadIcon(at: 0, withPulse: true)
            self.detail.opsView.reloadAll()
        }, onError: { (code) in
            
        })
    }
    
    func commentConfirmed(_ content: String) {
        var responseToComment: StatusComment? = nil
        if let row = responseToRow {
            responseToComment = comments[row]
        }
        let newComment = StatusComment(status: status).initForPost(content, responseTo: responseToComment)
        comments.insert(newComment, at: 0)
        StatusRequester.sharedInstance.postCommentToStatus(status.ssidString, content: content, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) in
            guard let data = data else {
                fatalError()
            }
            let newCommentID = data.int32Value
            _ = newComment.confirmSent(newCommentID)
            self.status.commentNum += 1
            self.detail.opsView.reloadAll()
        }, onError: { (_) in
            self.showToast(LS("评论失败"))
        })
        
        tableView.beginUpdates()
        if comments.count > 1 {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        } else {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        tableView.endUpdates()
        resetCommentInput()
    }
    
    func resetCommentInput() {
        bottomBar.clearInputContent()
        atUser.removeAll()
        responseToRow = nil
    }
}

extension StatusDetailController: StatusDetailHeaderDelegate {
    func statusHeaderLikePressed() {
        likeBtnPressed()
    }
    
    func statusHeaderAvatarPressed() {
        navigationController?.pushViewController(status!.user!.showDetailController(), animated: true)
    }
}

extension StatusDetailController: StatusDeleteDelegate {
    func statusDidDeleted() {
        _ = navigationController?.popViewController(animated: true)
    }
}

extension StatusDetailController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count == 0 ? 1 : comments.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as! CommentStaticHeader
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if comments.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! SSEmptyListHintCell
            cell.titleLbl.text = LS("还没有评论")
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailCommentCell2
            let comment = comments[indexPath.row]
            cell.setData(comment.user.avatarURL!, name: comment.user.nickName!, content: comment.content, commentAt: comment.createdAt, responseTo: comment.responseTo?.user.nickName, showReplyBtn: !comment.user.isHost)
            cell.delegate = self
            cell.setNeedsUpdateConstraints()
            cell.updateConstraintsIfNeeded()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if comments.count == 0 {
            return
        }
        startReplyToComment(atIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

extension StatusDetailController: DetailCommentCellDelegate2 {
    
    func startReplyToComment(atIndexPath indexPath: IndexPath) {
        responseToRow = indexPath.row
        let comment = comments[indexPath.row]
        if comment.user.isHost {
            return
        }
        let responseToName = comment.user.nickName!
        responseToPrefixStr = LS("回复 ") + responseToName + ": "
        atUser.removeAll()
        bottomBar.contentInput.text = responseToPrefixStr
        bottomBar.contentInput.becomeFirstResponder()
    }
    
    func detailCommentCellReplyPressed(_ cell: DetailCommentCell2) {
        if let indexPath = tableView.indexPath(for: cell) {
            startReplyToComment(atIndexPath: indexPath)
        }
    }
    
    func detailCommentCellAvatarPressed(_ cell: DetailCommentCell2) {
        if let indexPath = tableView.indexPath(for: cell) {
            let comment = comments[indexPath.row]
            navigationController?.pushViewController(comment.user.showDetailController(), animated: true)
        }
    }
}

extension StatusDetailController: BottomBarDelegate {
    func bottomBarMessageConfirmSent() {
        commentConfirmed(bottomBar.contentInput.text)
    }
    
    func bottomBarBtnPressed(at index: Int) {
        likeBtnPressed()
    }
    
    func bottomBarHeightShouldChange(into newHeight: CGFloat) -> Bool {
        return true
    }
    
    func bottomBarDidBeginEditing() {
        tapper?.isEnabled = true
    }
    
    func getIconForBtn(at idx: Int) -> UIImage {
        if idx == 0 && status.liked {
            return UIImage(named: "news_like_liked")!
        } else if idx == 0 {
            return UIImage(named: "news_like_unliked")!
        } else {
            fatalError()
        }
    }
    
    func numberOfLeftBtns() -> Int {
        return 0
    }
    
    func numberOfRightBtns() -> Int {
        return 1
    }
}

extension StatusDetailController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let prefix = responseToPrefixStr else {
            return true
        }
        if text == "" && prefix.length > 0 {
            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= prefix.length {
                textView.text = ""
                responseToPrefixStr = ""
                responseToRow = -1
            }
        }
        return true
    }
}
//
//class StatusDetailController: InputableViewController, DetailCommentCellDelegate, StatusDeleteDelegate, WaitableProtocol, LoadingProtocol {
//    
//    var list: UITableView?
//    var indexPath: IndexPath?
//    
//    var status: Status?
//    var statusImages: [String] = []
//    var comments: [StatusComment] = []
//    
//    var loadAnimated: Bool = true
//    
//    var board: UIScrollView?
//    
//    /// 上方显示
//    var statusContainer: UIView?
//    var tmpBackgroundImg: UIImageView?
//    /// 初始时上面的container所处的位置
//    var initialPos: CGFloat = 0
//    var initialHight: CGFloat = 0
//    var initBackground: UIImage?
//    /*
//    封面顶部的这一栏
//    */
//    var headerContainer: UIView?
//    var avatarBtn: UIButton?
//    var nameLbl: UILabel?
//    var avatarClubBtn: UIButton?
//    var releaseDateLbl: UILabel?
//    var avatarCarLogoIcon: UIImageView?
//    var avatarCarNameLbl: UILabel?
//    /*
//    中间图片和正文显示区
//    */
//    var mainCover: UIImageView?
//    var otherImgList: UICollectionView?
//    var contentLbl: UILabel?
//    /*
//    下方其他信息区域
//    */
//    var locationLbL: UILabel?
//    var likeIcon: UIImageView?
//    var likeBtn: UIButton!
//    var likeNumLbl: UILabel?
//    var commentIcon: UIImageView?
//    var commentNumLbL: UILabel?
//    
//    var commentList: UITableView?   // 评论列表，其中的cell使用News评论的cell
//    var requestingCommentData: Bool = false     // 状态标识，当前是否正在更新数据
//    
//    /// 评论栏
//    @available(*, deprecated: 1)
//    var commentPanel: CommentBarView?
//    var bottomBar: BasicBottomBar!
//    var responseToRow: Int?                 // 被回应的评论所在的行
//    var responseToPrefixStr: String?        // 回应内容前缀：当回复某人时会预填充『回复：XXX』字样
//    var atUser: [String] = []
//    
//    // MARK: variable for waitable protocol
//    var wp_waitingContainer: UIView?
//    weak var requestOnFly: Request?
//    
//    // MARK: init
//    
//    override init() {
//        super.init()
//    }
// 
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    convenience init(status: Status, background: UIImage, initPos: CGFloat, initHeight: CGFloat) {
//        self.init()
//        self.status = status
//        self.initBackground = background
//        self.initialPos = initPos
//        self.initialHight = initHeight
//    }
//    
//    convenience init(status: Status) {
//        self.init()
//        self.status = status
//    }
//    
//    deinit {
//        NotificationCenter.default.removeObserver(self)
//    }
//    
//    // MARK: view load
//    
//    override func viewDidLoad() {
//        navSetting()
//        // 顶层容器
//        board = UIScrollView()
//        board?.delegate = self
//        board?.contentSize = self.view.bounds.size
//        board?.backgroundColor = UIColor.white
//        self.view.addSubview(board!)
//        let superview = self.view!
//        board?.snp.makeConstraints({ (make) -> Void in
//            make.height.equalTo(superview.bounds.height - self.navigationController!.navigationBar.frame.height - UIApplication.shared.statusBarFrame.height)
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.bottom.equalTo(superview).offset(0)
//        })
//        if loadAnimated {
//            tmpBackgroundImg = UIImageView()
//            tmpBackgroundImg?.image = initBackground
//            board?.addSubview(tmpBackgroundImg!)
//            tmpBackgroundImg?.snp.makeConstraints({ (make) -> Void in
//                make.right.equalTo(self.view)
//                make.left.equalTo(self.view)
//                make.top.equalTo(board!)
//                make.height.equalTo(self.view)
//            })
//        }
//        
//        statusContainer = UIView()
//        statusContainer?.backgroundColor = UIColor.white
//        board?.addSubview(statusContainer!)
//        if loadAnimated {
//            statusContainer?.snp.makeConstraints({ (make) -> Void in
//                make.height.equalTo(initialHight)
//                make.right.equalTo(self.view).offset(-10)
//                make.left.equalTo(self.view).offset(10)
//                make.top.equalTo(board!).offset(initialPos)
//            })
//        }else {
//            statusContainer?.snp.remakeConstraints({ (make) -> Void in
//                make.left.equalTo(self.view)
//                make.right.equalTo(self.view)
//                make.top.equalTo(board!)
//                make.height.equalTo(StatusCell.heightForStatus(status!) + 20)
//            })
//        }
//        createStatusBoard()
//        createOtherSubivews()
//        loadDataAndUpdateUI()
//        NotificationCenter.default.addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(StatusDetailController.changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//        
//        // load the detail data
//        _ = StatusRequester.sharedInstance.getStatusDetail(status!.ssidString, onSuccess: { (json) in
//            if let data = json {
//                _ = try! self.status?.loadDataFromJSON(data, detailLevel: 0, forceMainThread: false)
//                self.loadDataAndUpdateUI()
//            }
//            }) { (code) in
//                if code == "status not found" {
//                    self.showToast(LS("动态不存在或者已经被删除"))
//                    _ = self.navigationController?.popViewController(animated: true)
//                } else {
//                    self.showToast(LS("网络访问错误:\(code)"))
//                }
//        }
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if loadAnimated {
//            self.view.updateConstraints()
//            self.view.layoutIfNeeded()
//            statusContainer?.snp.remakeConstraints({ (make) -> Void in
//                make.left.equalTo(self.view)
//                make.right.equalTo(self.view)
//                make.top.equalTo(board!)
//                make.height.equalTo(board!)
//            })
//            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { () -> Void in
//                self.view.layoutIfNeeded()
//                }) { (_) -> Void in
//                    self.tmpBackgroundImg?.isHidden = true
//                    self.animateOtherSubViews()
//                    self.autoSetBoardContentSize(true)
//                    self.loadMoreCommentData()
//            }
//        }
//    }
//    
//    // MARK: Navigator
//    
//    func navSetting() {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        navigationItem.title = LS("动态详情")
//        //
//        let backBtn = UIButton()
//        backBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
//        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
//        backBtn.addTarget(self, action: #selector(StatusDetailController.backBtnPressed), for: .touchUpInside)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBtn)
//        //
//        let shareBtn = UIButton()
//        shareBtn.setImage(UIImage(named: "status_detail_other_operation"), for: .normal)
//        shareBtn.imageView?.contentMode = .scaleAspectFit
//        shareBtn.frame = CGRect(x: 0, y: 0, width: 24, height: 214)
//        shareBtn.addTarget(self, action: #selector(StatusDetailController.navRightBtnPressed), for: .touchUpInside)
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareBtn)
//        //
//    }
//    
//    func backBtnPressed() {
//        _ = self.navigationController?.popViewController(animated: true)
//        wp_abortWaiting()
//    }
//    
//    func navRightBtnPressed() {
//        // 根据的状态的发布者来确定弹出的窗口
//        if status!.user!.isHost {
//            // 是当前用户发布的状态，则弹出删除
//            let delete = StatusDeleteController(parent: self)
//            delete.delegate = self
//            delete.status = status!
//            self.present(delete, animated: false, completion: nil)
//        }else {
//            // 否则弹出举报
//            let report = ReportBlacklistViewController(userID: status!.ssid, reportType: "status", parent: self)
//            self.present(report, animated: false, completion: nil)
//        }
//    }
//    
//    /**
//     弹出的删除窗口删除了状态以后调用这个回调
//     */
//    func statusDidDeleted() {
//        // pop当前这个窗口
//        self.backBtnPressed()
//    }
//    
//    func createOtherSubivews() {
//        let superview = self.view!
//        //
//        let sepLine = UIView()
//        sepLine.backgroundColor = UIColor(white: 0.8, alpha: 1)
//        board?.addSubview(sepLine)
//        if loadAnimated {
//            sepLine.snp.makeConstraints { (make) -> Void in
//                make.right.equalTo(superview).offset(-15)
//                make.left.equalTo(superview).offset(15)
//                make.top.equalTo(board!).offset(initialHight + 20)
//                make.height.equalTo(0.5)
//            }
//        }else {
//            sepLine.snp.makeConstraints({ (make) -> Void in
//                make.right.equalTo(superview).offset(-15)
//                make.left.equalTo(superview).offset(15)
//                make.top.equalTo(statusContainer!.snp.bottom)
//                make.height.equalTo(0.5)
//            })
//        }
//        //
//        let commentStaticLbl = UILabel()
//        commentStaticLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
//        commentStaticLbl.textColor = kTextGray28
//        commentStaticLbl.backgroundColor = UIColor.white
//        commentStaticLbl.textAlignment = .center
//        commentStaticLbl.text = LS("评论")
//        board?.addSubview(commentStaticLbl)
//        commentStaticLbl.snp.makeConstraints { (make) -> Void in
//            make.center.equalTo(sepLine)
//            make.width.equalTo(70)
//        }
//        //
//        commentList = UITableView(frame: CGRect.zero, style: .plain)
//        commentList?.dataSource = self
//        commentList?.delegate = self
//        commentList?.separatorStyle = .none
//        commentList?.isScrollEnabled = false
//        commentList?.backgroundColor = UIColor.white
//        board?.addSubview(commentList!)
//        commentList?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.top.equalTo(commentStaticLbl.snp.bottom).offset(20)
//            make.height.equalTo(64)
//        })
//        commentList?.register(StatusDetailCommentCell.self, forCellReuseIdentifier: StatusDetailCommentCell.reuseIdentifier)
//        commentList?.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
//        //
//        
//        commentPanel = CommentBarView()
//        commentPanel?.shareBtnHidden = true
//        commentPanel?.likeBtn?.addTarget(self, action: #selector(StatusDetailController.likeBtnPressed), for: .touchUpInside)
//        self.view?.addSubview(commentPanel!)
//        if loadAnimated {
//            commentPanel?.snp.makeConstraints({ (make) -> Void in
//                make.right.equalTo(superview)
//                make.left.equalTo(superview)
//                make.height.equalTo(commentPanel!.barheight)
//                make.bottom.equalTo(superview).offset(commentPanel!.barheight)      // 先将这个panel放置在底部，后续动画调出
//            })
//        }else {
//            commentPanel?.snp.makeConstraints({ (make) -> Void in
//                make.right.equalTo(superview)
//                make.left.equalTo(superview)
//                make.height.equalTo(commentPanel!.barheight)
//                make.bottom.equalTo(superview).offset(0)
//            })
//        }
//        self.inputFields.append(commentPanel?.contentInput)
//        commentPanel?.contentInput?.delegate = self
//    }
//    
//    func animateOtherSubViews() {
//        self.view.layoutIfNeeded()
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }, completion: nil)
//    }
//    
//    /**
//     自动调整board的size大小
//     
//      - parameter   animated: 是否动态调整
//     */
//    func autoSetBoardContentSize(_ animated: Bool) {
//        commentList?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(max(commentList!.contentSize.height, 88))
//        })
//        self.view.updateConstraints()
//        self.view.layoutIfNeeded()
//        var contentRect = CGRect.zero
//        for view in board!.subviews[0..<(board!.subviews.count - 2)] {
//            contentRect = contentRect.union(view.frame)
//        }
//        if animated {
//            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
//                self.board?.contentSize = CGSize(width: self.board!.frame.width, height: contentRect.height + self.commentPanel!.frame.height)
//                }, completion: nil)
//        }else{
//            self.view.layoutIfNeeded()
//        }
//    }
//}
//
//// MARK: - 上方status部分
//extension StatusDetailController: UICollectionViewDataSource {
//    func createStatusBoard() {
//        
//        let superview = statusContainer!
//        /*
//        header 区域的子空间创建
//        */
//        headerContainer = UIView()
//        superview.addSubview(headerContainer!)
//        headerContainer?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.top.equalTo(superview)
//            make.height.equalTo(70)
//        })
//        //
//        avatarBtn = UIButton()
//        headerContainer?.addSubview(avatarBtn!)
//        avatarBtn?.layer.cornerRadius = 35 / 2.0
//        avatarBtn?.clipsToBounds = true
//        avatarBtn?.addTarget(self, action: #selector(StatusDetailController.statusHostAvatarPressed), for: .touchUpInside)
//        avatarBtn?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(headerContainer!).offset(15)
//            make.centerY.equalTo(headerContainer!)
//            make.size.equalTo(35)
//        })
//        //
//        nameLbl = UILabel()
//        nameLbl?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
//        nameLbl?.textColor = UIColor.black
//        headerContainer?.addSubview(nameLbl!)
//        nameLbl?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(avatarBtn!.snp.right).offset(10)
//            make.bottom.equalTo(avatarBtn!.snp.centerY)
//            make.top.equalTo(avatarBtn!)
//        })
//        //
//        avatarClubBtn = UIButton()
//        avatarClubBtn?.layer.cornerRadius = 10
//        avatarClubBtn?.clipsToBounds = true
//        headerContainer?.addSubview(avatarClubBtn!)
//        avatarClubBtn?.snp.makeConstraints({ (make) -> Void in
//            make.size.equalTo(20)
//            make.centerY.equalTo(nameLbl!)
//            make.left.equalTo(nameLbl!.snp.right).offset(7)
//        })
//        //
//        releaseDateLbl = UILabel()
//        releaseDateLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
//        releaseDateLbl?.textColor = kTextGray28
//        headerContainer?.addSubview(releaseDateLbl!)
//        releaseDateLbl?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(nameLbl!)
//            make.bottom.equalTo(avatarBtn!)
//            make.top.equalTo(nameLbl!.snp.bottom)
//        })
//        //
//        avatarCarNameLbl = UILabel()
//        avatarCarNameLbl?.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
//        avatarCarNameLbl?.textAlignment = .right
//        avatarCarNameLbl?.textColor = kTextGray28
//        headerContainer?.addSubview(avatarCarNameLbl!)
//        avatarCarNameLbl?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(headerContainer!).offset(-15)
//            make.centerY.equalTo(headerContainer!)
//        })
//        //
//        avatarCarLogoIcon = UIImageView()
//        avatarCarLogoIcon?.contentMode = .scaleAspectFit
//        avatarCarLogoIcon?.layer.cornerRadius = 10.5
//        avatarCarLogoIcon?.clipsToBounds = true
//        superview.addSubview(avatarCarLogoIcon!)
//        avatarCarLogoIcon?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(avatarCarNameLbl!.snp.left).offset(-4)
//            make.centerY.equalTo(avatarCarNameLbl!)
//            make.size.equalTo(21)
//        })
//        /*
//        中间内容区域
//        */
//        mainCover = UIImageView()
//        mainCover?.contentMode = .scaleAspectFill
//        mainCover?.clipsToBounds = true
//        superview.addSubview(mainCover!)
//        mainCover?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.top.equalTo(headerContainer!.snp.bottom)
//            make.height.equalTo(mainCover!.snp.width)
//        })
//        //
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = .horizontal
//        flowLayout.itemSize = CGSize(width: 100, height: 100)
//        flowLayout.minimumInteritemSpacing = 10
//        otherImgList = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
//        otherImgList?.dataSource = self
//        superview.addSubview(otherImgList!)
//        otherImgList?.backgroundColor = UIColor.white
//        otherImgList?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview)
//            make.left.equalTo(superview)
//            make.top.equalTo(mainCover!.snp.bottom).offset(6)
//            make.height.equalTo(0)
//        })
//        otherImgList?.register(StatusCellImageDisplayCell.self, forCellWithReuseIdentifier: StatusCellImageDisplayCell.reuseIdentifier)
//        //
//        contentLbl = UILabel()
//        contentLbl?.textColor = UIColor.black
//        contentLbl?.numberOfLines = 0
//        superview.addSubview(contentLbl!)
//        contentLbl?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview).offset(-15)
//            make.left.equalTo(superview).offset(15)
//            make.top.equalTo(otherImgList!.snp.bottom).offset(15)
//        })
//        /*
//        下方其他信息部分
//        */
//        let locationIcon = UIImageView(image: UIImage(named: "status_location_icon"))
//        superview.addSubview(locationIcon)
//        locationIcon.snp.makeConstraints { (make) -> Void in
//            make.left.equalTo(contentLbl!)
//            make.top.equalTo(contentLbl!.snp.bottom).offset(15)
//            make.size.equalTo(CGSize(width: 13.5, height: 18))
//        }
//        //
//        locationLbL = UILabel()
//        locationLbL?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
//        locationLbL?.textColor = kTextGray28
//        locationLbL?.numberOfLines = 0
//        locationLbL?.lineBreakMode = .byWordWrapping
//        superview.addSubview(locationLbL!)
//        locationLbL?.snp.makeConstraints({ (make) -> Void in
//            make.left.equalTo(locationIcon.snp.right).offset(10)
//            make.top.equalTo(locationIcon)
//            make.width.equalTo(superview).multipliedBy(0.6)
//        })
//        //
//        commentNumLbL = UILabel()
//        commentNumLbL?.textColor = kTextGray28
//        commentNumLbL?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
//        commentNumLbL?.textAlignment = .right
//        superview.addSubview(commentNumLbL!)
//        commentNumLbL?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(superview).offset(-15)
//            make.top.equalTo(locationLbL!)
//            make.height.equalTo(17)
//        })
//        //
//        commentIcon = UIImageView(image: UIImage(named: "news_comment"))
//        superview.addSubview(commentIcon!)
//        commentIcon?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(commentNumLbL!.snp.left).offset(-2)
//            make.top.equalTo(commentNumLbL!)
//            make.size.equalTo(15)
//        })
//        //
//        likeNumLbl = UILabel()
//        likeNumLbl?.textColor = kTextGray28
//        likeNumLbl?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
//        likeNumLbl?.textAlignment = .right
//        superview.addSubview(likeNumLbl!)
//        likeNumLbl?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(commentIcon!.snp.left).offset(-30)
//            make.top.equalTo(commentIcon!)
//            make.height.equalTo(17)
//        })
//        //
//        likeIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
//        superview.addSubview(likeIcon!)
//        likeIcon?.snp.makeConstraints({ (make) -> Void in
//            make.right.equalTo(likeNumLbl!.snp.left).offset(-2)
//            make.top.equalTo(likeNumLbl!)
//            make.size.equalTo(15)
//        })
//        
//        likeBtn = superview.addSubview(UIButton.self)
//            .config(self, selector: #selector(likeBtnPressed))
//            .layout({ (make) in
//                make.center.equalTo(likeIcon!)
//                make.size.equalTo(20)
//            })
//    }
//    
//    func statusHostAvatarPressed() {
////        let detail = PersonOtherController(user: status!.user!)
////        self.navigationController?.pushViewController(detail, animated: true)
//        navigationController?.pushViewController(status!.user!.showDetailController(), animated: true)
//    }
//    
//    func loadDataAndUpdateUI() {
//        if status == nil {
//            return
//        }
//        /*
//        header区域的数据
//        */
//        let user: User = status!.user!
//        avatarBtn?.kf.setImage(with: user.avatarURL!, for: .normal)
//        nameLbl?.text = user.nickName
//        releaseDateLbl?.text = dateDisplay(status!.createdAt!)
//        if let club = user.avatarClubModel {
//            avatarClubBtn?.isHidden = false
//            avatarClubBtn?.kf.setImage(with: club.logoURL!, for: .normal)
//        }else{
//            avatarClubBtn?.isHidden = true
//            avatarClubBtn?.setImage(nil, for: .normal)
//        }
//        if let car = user.avatarCarModel {
//            avatarCarNameLbl?.isHidden = false
//            avatarCarNameLbl?.text = car.name
//            avatarCarLogoIcon?.isHidden = false
//            avatarCarLogoIcon?.kf.setImage(with: car.logoURL!)
//        }else{
//            avatarCarLogoIcon?.isHidden = true
//            avatarCarNameLbl?.isHidden = true
//            avatarCarLogoIcon?.image = nil
//        }
//        /*
//        中间内容区域
//        */
//        let imageInfo = status!.image!
//        statusImages = imageInfo.split(delimiter: ";")
////        mainCover?.kf_setImageWithURL(SFURL(statusImages[0])!)
////        mainCover?.kf_setImageWithURL(status!.coverURL!, placeholderImage: mainCover?.image, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) in
////            if error == nil {
////                self.mainCover?.setupForImageViewer(nil, backgroundColor: UIColor.black)
////            }
////        })
//        mainCover?.kf.setImage(with: status!.coverURL!, placeholder: mainCover?.image, options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
//            if error == nil {
//                self.mainCover?.setupForImageViewer(nil, backgroundColor: UIColor.black)
//            }
//        })
//        if statusImages.count <= 1 {
//            otherImgList?.reloadData()
//            otherImgList?.snp.updateConstraints({ (make) -> Void in
//                make.height.equalTo(0)
//            })
//        }else{
//            otherImgList?.reloadData()
//            otherImgList?.snp.updateConstraints({ (make) -> Void in
//                make.height.equalTo(100)
//            })
//        }
//        contentLbl?.attributedText = type(of: self).makeAttributedContentText(status!.content!)
//        /*
//        底部区域数据
//        */
//        if let loc_des = status?.location?.descr {
//            locationLbL?.text = loc_des
//        }else{
//            locationLbL?.text = LS("未知地点")
//        }
//        likeNumLbl?.text = "\(status!.likeNum)"
//        commentNumLbL?.text = "\(status!.commentNum)"
//        likeIcon?.image = status!.liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
//        commentPanel?.likeBtnIcon.image = status!.liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
//        self.view.layoutIfNeeded()
//    }
//    
//    class func makeAttributedContentText(_ content: String) -> NSAttributedString {
//        let style = NSMutableParagraphStyle()
//        style.lineSpacing = 3
//        style.lineBreakMode = .byCharWrapping
//        return NSAttributedString(string: content, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: style])
//    }
//    
//    class func heightForStatusContent(_ content: String) -> CGFloat {
//        let attributedContent = makeAttributedContentText(content)
//        let maxWidth = UIScreen.main.bounds.width - 30
//        return attributedContent.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return statusImages.count - 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatusCellImageDisplayCell.reuseIdentifier, for: indexPath) as! StatusCellImageDisplayCell
////        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[(indexPath as NSIndexPath).row + 1])!)
////        cell.imageView?.kf_setImageWithURL(SFURL(statusImages[(indexPath as NSIndexPath).row + 1])!, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
////            if error == nil {
////                cell.imageView?.setupForImageViewer(nil, backgroundColor: UIColor.black)
////            }
////        })
//        cell.imageView?.kf.setImage(with: SFURL(statusImages[(indexPath as NSIndexPath).row + 1])!, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, _, _) in
//            if error == nil {
//                cell.imageView?.setupForImageViewer(nil, backgroundColor: UIColor.black)
//            }
//        })
//        return cell
//    }
//}
//
//// MARK: - about comments
//extension StatusDetailController: UITableViewDataSource, UITableViewDelegate {
//    
//    func loadMoreCommentData() {
//        if requestingCommentData{
//            return
//        }
//        requestingCommentData = true
//        let requester = StatusRequester.sharedInstance
//        let dateThreshold = comments.last?.createdAt ?? Date()
//        _ = requester.getMoreStatusComment(dateThreshold, statusID: status!.ssidString, onSuccess: { (json) -> () in
//            for data in json!.arrayValue {
//                let newComment = try! StatusComment(status: self.status!).loadDataFromJSON(data)
//                self.comments.append(newComment)
//            }
//            self.comments = $.uniq(self.comments, by: { $0.ssid })
//            self.reorgnizeComments()
//            self.commentList?.reloadData()
//            self.autoSetBoardContentSize(true)
//            self.requestingCommentData = false
//            }) { (code) -> () in
//                self.requestingCommentData = false
//        }
//    }
//    
//    func reorgnizeComments() {
//        comments.sort { (comment1, comment2) -> Bool in
//            switch comment1.createdAt!.compare(comment2.createdAt! as Date) {
//            case .orderedDescending:
//                return true
//            default:
//                return false
//            }
//        }
//    }
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
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
//        let cell = tableView.dequeueReusableCell(withIdentifier: DetailCommentCell.reuseIdentifier, for: indexPath) as! StatusDetailCommentCell
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
//    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 88
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if comments.count == 0 {
//            return 100
//        }
//        return StatusDetailCommentCell.heightForComment(comments[(indexPath as NSIndexPath).row].content!)
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView == board && board?.contentOffset.y >= board!.contentSize.height - board!.frame.height - 1 {
//            loadMoreCommentData()
//        }
//    }
//    
//    func avatarPressed(_ cell: DetailCommentCell) {
//        if let cell = cell as? StatusDetailCommentCell {
//            if let user = cell.comment?.user {
//                navigationController?.pushViewController(user.showDetailController(), animated: true)
//            }
//        }
//    }
//    
//    /**
//     试图回应已有的一条评论
//     
//     - parameter cell: 被评论的cell
//     */
//    func replyPressed(_ cell: DetailCommentCell) {
//        responseToRow = cell.replyBtn?.tag
//        let responseToName = cell.nameLbl!.text!
//        responseToPrefixStr = LS("回复 ") + responseToName + ": "
//        commentPanel?.contentInput?.text = responseToPrefixStr
//        atUser.removeAll()
//        commentPanel?.contentInput?.becomeFirstResponder()
//    }
//    
//    func checkImageDetail(_ cell: DetailCommentCell) {
//        
//    }
//}
//
//
//// MARK: - 下方评论条相关
//extension StatusDetailController {
//    
//    func likeBtnPressed() {
//        let requester = StatusRequester.sharedInstance
//        wp_startWaiting()
//        lp_start()
//        requestOnFly = requester.likeStatus(status!.ssidString, onSuccess: { (json) -> () in
//            self.status?.likeNum = json!["like_num"].int32Value
//            let liked = json!["like_state"].boolValue
//            self.status?.liked = liked
//            self.commentPanel?.setLikedAnimated(liked)
//            self.likeNumLbl?.text = "\(self.status!.likeNum)"
//            self.likeIcon?.image = liked ? UIImage(named: "news_like_liked") : UIImage(named: "news_like_unliked")
//            self.wp_stopWaiting()
//            self.lp_stop()
//            }) { (code) -> () in
//                self.lp_stop()
//                self.wp_stopWaiting()
//                self.showToast(LS("无法访问服务器"))
//        }
//    }
//    
//    /**
//     评论编辑完成，确认发送
//     
//     - parameter commentString: 评论文字内容
//     - parameter image:         图片内容，现在图片已经取消
//     */
//    func commentConfirmed(_ commentString: String, image: UIImage?) {
//        var responseToComment: StatusComment? = nil
//        if responseToRow != nil {
//            responseToComment = comments[responseToRow!]
//        }
//        let newComment = StatusComment(status: status!).initForPost(commentString, responseTo: responseToComment)
//        comments.insert(newComment, at: 0)
//        let requester = StatusRequester.sharedInstance
//        self.lp_start()
//        requester.postCommentToStatus(self.status!.ssidString, content: commentString, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (data) -> () in
//            // data里面的只有一个id
//            if data == nil {
//                assertionFailure()
//            }
//            let newCommentID = data!.int32Value
//            _ = newComment.confirmSent(newCommentID)
//            self.status?.commentNum += 1
//            self.loadDataAndUpdateUI()
//            self.lp_stop()
//            self.showToast(LS("评论成功"))
//            }) { (code) -> () in
//                self.lp_stop()
//                self.showToast(LS("评论失败"))
//        }
//
//        commentList?.beginUpdates()
//        if comments.count > 1 {
//            commentList?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
//        } else {
//            commentList?.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
//        }
//        commentList?.endUpdates()
//    
//        commentPanel?.contentInput?.text = ""
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.height.equalTo(commentPanel!.barheight)
//        })
//        
//        autoSetBoardContentSize(true)
//    }
//    
//    func commentCanceled(_ commentString: String, image: UIImage?) {
//        
//    }
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
//            make.bottom.equalTo(self.view).offset(-(keyboardFrame.height) )
//        })
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//    func changeLayoutWhenKeyboardDisappears(_ notif: Foundation.Notification) {
//        board?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        commentPanel?.snp.updateConstraints({ (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//}

