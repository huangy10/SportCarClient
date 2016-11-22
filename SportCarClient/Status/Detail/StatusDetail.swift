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


class StatusDetailController: UIViewController, RequestManageMixin, LoadingProtocol {
    var onGoingRequest: [String : Request] = [:]
    var delayWorkItem: DispatchWorkItem?
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
    
    deinit {
        clearAllRequest()
    }
    
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
        updateStatusInfo()
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

    func updateStatusInfo() {
        StatusRequester.sharedInstance.getStatusDetail(status.ssidString, onSuccess: { (json) -> () in
            do {
                _ = try self.status.loadDataFromJSON(json!, detailLevel: 1, forceMainThread: true)
            } catch { return }
            self.detail.loadDataAndUpdateUI()
        }, onError: { (code) -> () in
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
    }
    
    func loadMoreCommentData() {
        let dateThreshold = comments.last()?.createdAt ?? Date()
        StatusRequester.sharedInstance.getMoreStatusComment(dateThreshold, statusID: status.ssidString, onSuccess: { (json) in
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
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.height {
            loadMoreCommentData()
        }
    }
    
    func likeBtnPressed() {
        lp_start()
        StatusRequester.sharedInstance.likeStatus(status.ssidString, onSuccess: { (json) in
            self.lp_stop()
            self.status.likeNum = json!["like_num"].int32Value
            self.status.liked = json!["like_state"].boolValue
            self.bottomBar.reloadIcon(at: 0, withPulse: true)
            self.detail.opsView.reloadAll()
            if self.status.liked {
                self.status.recentLikeUserName = MainManager.sharedManager.hostUser?.nickName
                self.detail.updateLikeInfoLbl()
            } else {
                self.updateStatusInfo()
            }
        }, onError: { (code) in
            self.lp_stop()
            self.showReqError(withCode: code)
        }).registerForRequestManage(self)
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
    
    func statusHeaderLikeListPressed() {
        let vc = StatusLikeUsersList()
        vc.status = status
        navigationController?.pushViewController(vc, animated: true)
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


