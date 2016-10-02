//
//  ActivityDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Cent
import MapKit
import Dollar

class ActivityDetailController: InputableViewController, UITableViewDataSource, UITableViewDelegate, FFSelectDelegate, DetailCommentCellDelegate, LoadingProtocol {
    
    var act: Activity!
    var comments: [ActivityComment] = []
    weak var parentCollectionView: UICollectionView?
    
    var infoView: ActivityDetailHeaderView!
    var tableView: UITableView!
    var commentPanel: ActivityCommentPanel!
    
    var responseToRow: Int = -1
    var atUser: [String] = []
    var responseToPrefixStr = ""
    
    var mapCell: MapCell!
    
    var needReloadActInfo: Bool = false
    
    init(act: Activity) {
        super.init()
        self.act = act
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        mapCell.map.viewWillAppear()
//        infoView.loadDataAndUpdateUI()
        tableView.setContentOffset(CGPoint(x: 0, y: -infoView.preferedHeight), animated: false)
        
        if needReloadActInfo {
            loadActInfo()
            needReloadActInfo = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mapCell.map.viewWillDisappear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        
        loadActInfo()
        // Send request to get the comments
        loadMoreComments()
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardAppears(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardDisappears(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onActivityInfoChanged(_:)), name: NSNotification.Name(rawValue: kActivityInfoChanged), object: nil)
        
    }
    
    func onActivityInfoChanged(_ notification: Foundation.Notification) {
        if let act = (notification as NSNotification).userInfo?[kActivityKey] as? Activity , act == self.act{
            DispatchQueue.main.async(execute: { 
                self.loadActInfo()
            })
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view.config(UIColor.white)
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        tableView.layout { (make) in
            make.edges.equalTo(superview)
        }
        tableView.register(ActivityCommentCell.self, forCellReuseIdentifier: ActivityCommentCell.reuseIdentifier)
        tableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
        
        infoView = ActivityDetailHeaderView(act: act)
        infoView.likeBtn.addTarget(self, action: #selector(likeBtnPressed), for: .touchUpInside)
        infoView.parentController = self
        tableView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.bottom.equalTo(tableView.snp.top)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(infoView.preferedHeight)
        }
        
        commentPanel = ActivityCommentPanel()
        inputFields.append(commentPanel.contentInput)
        commentPanel.contentInput?.delegate = self
        superview.addSubview(commentPanel)
        commentPanel.likeBtn?.addTarget(self, action: #selector(likeBtnPressed), for: .touchUpInside)
        commentPanel.setLikedAnimated(act.liked, flag: false)
        commentPanel.snp.makeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
            make.height.equalTo(commentPanel.barheight)
        }
        
        tableView.contentInset = UIEdgeInsetsMake(infoView.preferedHeight, 0, commentPanel.barheight, 0)
        tableView.setContentOffset(CGPoint(x: 0, y: -infoView.preferedHeight), animated: false)
        
        mapCell = MapCell(trailingHeight: 100)
        mapCell.locBtn.addTarget(self, action: #selector(ActivityDetailController.needNavigation), for: .touchUpInside)
        mapCell.locLbl.text = LS("导航至 ") + (act.location?.descr ?? LS("未知地点"))
        mapCell.locDesIcon.image = UIImage(named: "location_mark_black")
        mapCell.locDesIcon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    fileprivate func navSettings() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("活动详情")
        
        let navLeftBtn = UIButton()
            .config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .scaleAspectFit)
            .setFrame(CGRect(x: 0, y: 0, width: 15, height: 15))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    fileprivate func setNavRightBtn() {
        if act.user!.isHost {
            if act.finished {
                let rightImage = UIImageView().config(UIImage(named: "activity_done"), contentMode: .scaleAspectFit)
                    .setFrame(CGRect(x: 0, y: 0, width: 44, height: 18.5))
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightImage)
            } else {
                let rightItem = UIBarButtonItem(title: LS("关闭活动"), style: .done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
                rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
                navigationItem.rightBarButtonItem = rightItem
            }
        } else {
            let rightItem = UIBarButtonItem(title: act.applied ? LS("已报名") : LS("报名"), style: .done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
            rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: UIControlState())
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        if act.mine {
            closeActivity()
//            if !act.finished {
//                act.endAt = NSDate()
//                setNavRightBtn()
//                lp_start()
//                ActivityRequester.sharedInstance.closeActivty(act.ssidString, onSuccess: { (json) in
//                    self.lp_stop()
//                    self.parentCollectionView?.reloadData()
//                    // push a notification to tell other related component to update the status
//                    NSNotificationCenter.defaultCenter().postNotificationName(kActivityManualEndedNotification, object: nil, userInfo: [kActivityKey: self.act])
//                    self.showToast(LS("活动已关闭报名"))
//                    }, onError: { (code) in
//                        self.showToast(LS("Access Error: \(code)"))
//                        self.lp_stop()
//                })
//            }
        } else {
            applyForActivity()
//            if act.applied {
//                return
//            }
//            if act.finished {
//                showToast(LS("活动已结束，无法报名"))
//            }
//            act.hostApply()
//            infoView.loadDataAndUpdateUI()
//            setNavRightBtn()
//            self.lp_start()
//            ActivityRequester.sharedInstance.postToApplyActivty(act.ssidString, onSuccess: { (json) in
//                self.showToast(LS("报名成功"))
//                self.lp_stop()
//                }, onError: { (code) in
//                    self.showToast(LS("报名失败"))
//                    self.lp_stop()
//            })
        }
    }
    
    func applyForActivity() {
        if act.applied {
            showToast(LS("已经报名了这个活动"))
            return
        }
        if act.finished {
            showToast(LS("活动已结束"))
            return
        }
        
        lp_start()
        
        _ = ActivityRequester.sharedInstance.postToApplyActivty(act.ssidString, onSuccess: { (json) in
            self.showToast(LS("报名成功"))
            _ = self.act.hostApply()
            _ = self.infoView.loadDataAndUpdateUI()
            self.setNavRightBtn()
            self.lp_stop()
            }) { (code) in
                
                if code == "full" {
                    self.showToast(LS("活动已报满"))
                    self.updateActivityMembersList()
                } else {
                    self.lp_stop()
                    self.showToast(LS("报名失败"))
                }
        }
    }
    
    func updateActivityMembersList() {
        loadActInfo(false)
    }
    
    func closeActivity() {
        if !act.finished {
            act.endAt = Foundation.Date()
            setNavRightBtn()
            lp_start()
            _ = ActivityRequester.sharedInstance.closeActivty(act.ssidString, onSuccess: { (json) in
                self.lp_stop()
                self.parentCollectionView?.reloadData()
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: kActivityManualEndedNotification), object: nil, userInfo: [kActivityKey: self.act])
                self.showToast(LS("活动已关闭报名"))
                }, onError: { (code) in
                    self.showToast(LS("Access Error: \(code)"))
                    self.lp_stop()
            })
        }
    }
    
    func likeBtnPressed() {
        lp_start()
        _ = ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: "", opType: "like", onSuccess: { (json) in
            self.lp_stop()
            if let data = json {
                let liked = data["liked"].boolValue
                let likeNum = data["like_num"].int32Value
                self.infoView.setLikeIconState(liked)
                self.infoView.likeNumLbl.text = "\(likeNum)"
                self.commentPanel.setLikedAnimated(liked)
            } else {
                assertionFailure()
            }
            }) { (code) in
                self.lp_stop()
                self.showToast("Access Error: \(code)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if comments.count == 0 {
                return 1
            }
            return comments.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if comments.count == 0 {
                // empty info cell
                return 100
            }
            return ActivityCommentCell.heightForComment(comments[(indexPath as NSIndexPath).row].content!)
        } else {
            return 250
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            if comments.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "empty_cell", for: indexPath) as! SSEmptyListHintCell
                cell.titleLbl.text = LS("还没有评论")
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCommentCell.reuseIdentifier, for: indexPath) as! ActivityCommentCell
            cell.comment = comments[(indexPath as NSIndexPath).row]
            cell.replyBtn?.tag = (indexPath as NSIndexPath).row
            cell.delegate = self
            cell.loadDataAndUpdateUI()
            return cell
        } else {
            if !mapCell.centerSet {
                let center = CLLocationCoordinate2D(latitude: act.location!.latitude, longitude: act.location!.longitude)
                mapCell.setMapCenter(center)
            }
            return mapCell
        }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        infoView.adjustCoverScaleAccordingToTableOffset(scrollView.contentOffset.y + infoView.preferedHeight)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 1 {
            loadMoreComments()
        }
    }
    
    // MARK: data fetching
    
    /**
     Fetch the latest information about the act
     */
    func loadActInfo(_ showLoading: Bool = true) {
        if showLoading {
            lp_start()
        }
        _ = ActivityRequester.sharedInstance.getActivityDetail(act.ssidString, onSuccess: { (json) in
            if let data = json {
                _ = try! self.act.loadDataFromJSON(data, detailLevel: 1)
                self.infoView.act = self.act
                
                DispatchQueue.main.async(execute: {
                    self.setNavRightBtn()
                    _ = self.infoView.loadDataAndUpdateUI() // the preferedHeight udpated
                    self.commentPanel.setLikedAnimated(self.act.liked, flag: false)
                    self.tableView.contentOffset = CGPoint(x: 0, y: -self.infoView.preferedHeight)
                    self.tableView.contentInset = UIEdgeInsetsMake(self.infoView.preferedHeight, 0, self.commentPanel.barheight, 0)
//                    UIView.animateWithDuration(0.3, animations: {
//                        self.tableView.contentInset = UIEdgeInsetsMake(self.infoView.preferedHeight, 0, self.commentPanel.barheight, 0)
//                        self.tableView.contentOffset = CGPointMake(0, -self.infoView.preferedHeight)
//                    })
                })
                
            } else {
                assertionFailure()
            }
            self.lp_stop()
            }) { (code) in
                self.lp_stop()
                self.showToast(LS("无法获取活动信息"))
        }
    }
    
    func loadMoreComments() {
        let dateThreshold = comments.last?.createdAt ?? Foundation.Date()
        _ = ActivityRequester.sharedInstance.getActivityComments(act.ssidString, dateThreshold: dateThreshold, limit: 20, onSuccess: { (json) in
            if let datas = json?.arrayValue {
                for data in datas {
                    let comment = try! ActivityComment(act: self.act)
                        .loadDataFromJSON(data)
                    self.comments.append(comment)
                }
                if datas.count > 0 {
                    self.comments = $.uniq(self.comments, by: { $0.ssid })
                    self.tableView.reloadData()
                }
            } else {
                assertionFailure()
            }
            }) { (code) in
                self.showToast(LS("无法获取活动评论内容"))
        }
    }
    
    /**
     send comments to the server
     */
    func commentConfirmed(_ content: String) {
        var responseToComment: ActivityComment? = nil
        if responseToRow >= 0 {
            responseToComment = comments[responseToRow]
        }
        let newComment = ActivityComment(act: act).initForPost(content, responseTo: responseToComment)
        act.commentNum += 1
        infoView.commentNumLbl.text = "\(act.commentNum)"
        
        tableView.beginUpdates()
        comments.insert(newComment, at: 0)
        if comments.count > 1 {
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        } else {
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        tableView.endUpdates()
        commentPanel.contentInput?.text = ""
        commentPanel.snp.updateConstraints { (make) in
            make.height.equalTo(commentPanel.barheight)
        }
        
        lp_start()
        ActivityRequester.sharedInstance.sendActivityComment(act.ssidString, content: content, responseTo: responseToComment?.ssidString, informOf: nil, onSuccess: { (json) in
            if let data = json {
                let newCommentID = data["id"].int32Value
                _ = newComment.confirmSent(newCommentID)
                // update the comment number
                let commentNum = data["comment_num"].int32Value
                self.act.commentNum = commentNum
                self.infoView.commentNumLbl.text = "\(commentNum)"
            } else {
                assertionFailure()
            }
            self.lp_stop()
            self.showToast(LS("评论成功"))
            }) { (code) in
                self.showToast(LS("评论失败"))
                self.lp_stop()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.bounds.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        commentPanel.snp.updateConstraints { (make) in
            make.height.equalTo(max(newSize.height, commentPanel.barheight))
        }
        self.view.layoutIfNeeded()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let commentText = textView.text , commentText.length > 0 {
                commentConfirmed(commentText)
            }
            dismissKeyboard()
        }
        if text == "" && responseToPrefixStr.length > 0 {
            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr.length {
                textView.text = ""
                responseToPrefixStr = ""
                responseToRow = -1
            }
        }
        return true
    }
    
    // MARK: delegate functions
    
    func userSelectCancelled() {
        // just dismiss the presented user selector
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     邀请其他用户参加活动
     
     - parameter users: 被邀请的用户的list
     */
    func userSelected(_ users: [User]) {
        self.dismiss(animated: true, completion: nil)
        let userIDs = users.map { $0.ssidString }
        let userIDData = try! JSON(userIDs).rawData()
        let userJSONString = String(data: userIDData, encoding: String.Encoding.utf8)
        self.lp_start()
        _ = ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: userJSONString!, opType: "invite", onSuccess: { (json) in
            self.showToast(LS("邀请已发送"))
            self.lp_stop()
            }) { (code) in
                self.showToast(LS("邀请发送失败"))
                self.lp_stop()
        }
    }
    
    func avatarPressed(_ cell: DetailCommentCell) {
        // 评论列表的代理
        if let commentCell = cell as? ActivityCommentCell {
            let comment = commentCell.comment
            navigationController?.pushViewController((comment?.user.showDetailController())!, animated: true)
        }
    }
    
    func replyPressed(_ cell: DetailCommentCell) {
        commentPressed(cell.replyBtn!)
    }
    
    func commentPressed(_ sender: UIButton) {
        responseToRow = sender.tag
        let targetComment = comments[responseToRow]
        if let responseToName = targetComment.user.nickName {
            responseToPrefixStr = LS("回复 ") + responseToName + ": "
            commentPanel.contentInput?.text = responseToPrefixStr
        }
        atUser.removeAll()
        commentPanel.contentInput?.becomeFirstResponder()
    }
    
    // MARK: navigation
    
    func needNavigation() {
        showConfirmToast(LS("导航"), message: LS("跳转到地图导航？"), target: self, onConfirm: #selector(openMapToNavigate))
//        toast = showConfirmToast(LS("跳转到地图导航?"), target: self, confirmSelector: #selector(openMapToNavigate), cancelSelector: #selector(hideToast as ()->()))
    }
    
    func openMapToNavigate() {
        let param = BMKNaviPara()
        let end = BMKPlanNode()
        
        let center = act.location!.coordinate
        end.pt = center
        let targetName = act.location?.descr ?? LS("位置地点")
        end.name = targetName
        param.endPoint = end
        param.appScheme = "baidumapsdk://mapsdk.baidu.com"
        let res = BMKNavigation.openBaiduMapNavigation(param)
        if res.rawValue != 0 {
            // 如果没有安装百度地图，则打开自带地图
            let target = MKMapItem(placemark: MKPlacemark(coordinate: center, addressDictionary: nil))
            target.name = targetName
            let options: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject,
                                                MKLaunchOptionsMapTypeKey: NSNumber(value: MKMapType.standard.rawValue as UInt)]
            MKMapItem.openMaps(with: [target], launchOptions: options)
        }
    }
    
    // MARK: adjust layout when keyboard appears
    
    func changeLayoutWhenKeyboardAppears(_ notification: Foundation.Notification) {
        if let userInfo = (notification as NSNotification).userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue {
                var inset = tableView.contentInset
                inset.bottom += keyboardFrame.height
                tableView.contentInset = inset
                tableView.setContentOffset(CGPoint(x: 0, y: -50), animated: true)
                commentPanel.snp.remakeConstraints({ (make) in
                    make.left.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
                    make.height.equalTo(commentPanel.barheight)
                })
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changeLayoutWhenKeyboardDisappears(_ notification: Foundation.Notification) {
        var inset = tableView.contentInset
        inset.bottom = commentPanel.barheight
        tableView.contentInset = inset
        commentPanel.snp.remakeConstraints({ (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(commentPanel.barheight)
        })
        self.view.layoutIfNeeded()
    }
    
    // MARK: loading
    @available(*, deprecated: 1)
    func checkImageDetail(_ cell: DetailCommentCell) {
        
    }
}


