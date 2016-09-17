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
        super.init(nibName: nil, bundle: nil)
        self.act = act
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        mapCell.map.viewWillAppear()
//        infoView.loadDataAndUpdateUI()
        tableView.setContentOffset(CGPointMake(0, -infoView.preferedHeight), animated: false)
        
        if needReloadActInfo {
            loadActInfo()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeLayoutWhenKeyboardAppears(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(changeLayoutWhenKeyboardDisappears(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onActivityInfoChanged(_:)), name: kActivityInfoChanged, object: nil)
        
    }
    
    func onActivityInfoChanged(notification: NSNotification) {
        if let act = notification.userInfo?[kActivityKey] as? Activity where act == self.act{
            dispatch_async(dispatch_get_main_queue(), { 
                self.loadActInfo()
            })
        }
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view.config(UIColor.whiteColor())
        
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        tableView.layout { (make) in
            make.edges.equalTo(superview)
        }
        tableView.registerClass(ActivityCommentCell.self, forCellReuseIdentifier: ActivityCommentCell.reuseIdentifier)
        tableView.registerClass(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty_cell")
        
        infoView = ActivityDetailHeaderView(act: act)
        infoView.likeBtn.addTarget(self, action: #selector(likeBtnPressed), forControlEvents: .TouchUpInside)
        infoView.parentController = self
        tableView.addSubview(infoView)
        infoView.snp_makeConstraints { (make) in
            make.bottom.equalTo(tableView.snp_top)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(infoView.preferedHeight)
        }
        
        commentPanel = ActivityCommentPanel()
        inputFields.append(commentPanel.contentInput)
        commentPanel.contentInput?.delegate = self
        superview.addSubview(commentPanel)
        commentPanel.likeBtn?.addTarget(self, action: #selector(likeBtnPressed), forControlEvents: .TouchUpInside)
        commentPanel.setLikedAnimated(act.liked, flag: false)
        commentPanel.snp_makeConstraints { (make) in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
            make.height.equalTo(commentPanel.barheight)
        }
        
        tableView.contentInset = UIEdgeInsetsMake(infoView.preferedHeight, 0, commentPanel.barheight, 0)
        tableView.setContentOffset(CGPointMake(0, -infoView.preferedHeight), animated: false)
        
        mapCell = MapCell(trailingHeight: 100)
        mapCell.locBtn.addTarget(self, action: #selector(ActivityDetailController.needNavigation), forControlEvents: .TouchUpInside)
        mapCell.locLbl.text = LS("导航至 ") + (act.location?.descr ?? LS("未知地点"))
        mapCell.locDesIcon.image = UIImage(named: "location_mark_black")
        mapCell.locDesIcon.transform = CGAffineTransformMakeScale(0.8, 0.8)
    }
    
    private func navSettings() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.title = LS("活动详情")
        
        let navLeftBtn = UIButton()
            .config(self, selector: #selector(navLeftBtnPressed), image: UIImage(named: "account_header_back_btn"), contentMode: .ScaleAspectFit)
            .setFrame(CGRectMake(0, 0, 15, 15))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
    }
    
    private func setNavRightBtn() {
        if act.user!.isHost {
            if act.finished {
                let rightImage = UIImageView().config(UIImage(named: "activity_done"), contentMode: .ScaleAspectFit)
                    .setFrame(CGRectMake(0, 0, 44, 18.5))
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightImage)
            } else {
                let rightItem = UIBarButtonItem(title: LS("关闭活动"), style: .Done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
                rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
                navigationItem.rightBarButtonItem = rightItem
            }
        } else {
            let rightItem = UIBarButtonItem(title: act.applied ? LS("已报名") : LS("报名"), style: .Done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
            rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func navLeftBtnPressed() {
        navigationController?.popViewControllerAnimated(true)
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
        
        ActivityRequester.sharedInstance.postToApplyActivty(act.ssidString, onSuccess: { (json) in
            self.showToast(LS("报名成功"))
            self.act.hostApply()
            self.infoView.loadDataAndUpdateUI()
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
            act.endAt = NSDate()
            setNavRightBtn()
            lp_start()
            ActivityRequester.sharedInstance.closeActivty(act.ssidString, onSuccess: { (json) in
                self.lp_stop()
                self.parentCollectionView?.reloadData()
                NSNotificationCenter.defaultCenter().postNotificationName(kActivityManualEndedNotification, object: nil, userInfo: [kActivityKey: self.act])
                self.showToast(LS("活动已关闭报名"))
                }, onError: { (code) in
                    self.showToast(LS("Access Error: \(code)"))
                    self.lp_stop()
            })
        }
    }
    
    func likeBtnPressed() {
        lp_start()
        ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: "", opType: "like", onSuccess: { (json) in
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if comments.count == 0 {
                return 1
            }
            return comments.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if comments.count == 0 {
                // empty info cell
                return 100
            }
            return ActivityCommentCell.heightForComment(comments[indexPath.row].content!)
        } else {
            return 250
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if comments.count == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("empty_cell", forIndexPath: indexPath) as! SSEmptyListHintCell
                cell.titleLbl.text = LS("还没有评论")
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier(ActivityCommentCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityCommentCell
            cell.comment = comments[indexPath.row]
            cell.replyBtn?.tag = indexPath.row
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        infoView.adjustCoverScaleAccordingToTableOffset(scrollView.contentOffset.y + infoView.preferedHeight)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 1 {
            loadMoreComments()
        }
    }
    
    // MARK: data fetching
    
    /**
     Fetch the latest information about the act
     */
    func loadActInfo(showLoading: Bool = true) {
        if showLoading {
            lp_start()
        }
        ActivityRequester.sharedInstance.getActivityDetail(act.ssidString, onSuccess: { (json) in
            if let data = json {
                try! self.act.loadDataFromJSON(data, detailLevel: 1)
                self.infoView.act = self.act
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.setNavRightBtn()
                    self.infoView.loadDataAndUpdateUI() // the preferedHeight udpated
                    self.commentPanel.setLikedAnimated(self.act.liked, flag: false)
                    self.tableView.contentOffset = CGPointMake(0, -self.infoView.preferedHeight)
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
        let dateThreshold = comments.last()?.createdAt ?? NSDate()
        ActivityRequester.sharedInstance.getActivityComments(act.ssidString, dateThreshold: dateThreshold, limit: 20, onSuccess: { (json) in
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
    func commentConfirmed(content: String) {
        var responseToComment: ActivityComment? = nil
        if responseToRow >= 0 {
            responseToComment = comments[responseToRow]
        }
        let newComment = ActivityComment(act: act).initForPost(content, responseTo: responseToComment)
        act.commentNum += 1
        infoView.commentNumLbl.text = "\(act.commentNum)"
        
        tableView.beginUpdates()
        comments.insert(newComment, atIndex: 0)
        if comments.count > 1 {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        }
        tableView.endUpdates()
        commentPanel.contentInput?.text = ""
        commentPanel.snp_updateConstraints { (make) in
            make.height.equalTo(commentPanel.barheight)
        }
        
        lp_start()
        ActivityRequester.sharedInstance.sendActivityComment(act.ssidString, content: content, responseTo: responseToComment?.ssidString, informOf: nil, onSuccess: { (json) in
            if let data = json {
                let newCommentID = data["id"].int32Value
                newComment.confirmSent(newCommentID)
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
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.bounds.width
        let newSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        commentPanel.snp_updateConstraints { (make) in
            make.height.equalTo(max(newSize.height, commentPanel.barheight))
        }
        self.view.layoutIfNeeded()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if let commentText = textView.text where commentText.length > 0 {
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     邀请其他用户参加活动
     
     - parameter users: 被邀请的用户的list
     */
    func userSelected(users: [User]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let userIDs = users.map { $0.ssidString }
        let userIDData = try! JSON(userIDs).rawData()
        let userJSONString = String(data: userIDData, encoding: NSUTF8StringEncoding)
        self.lp_start()
        ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: userJSONString!, opType: "invite", onSuccess: { (json) in
            self.showToast(LS("邀请已发送"))
            self.lp_stop()
            }) { (code) in
                self.showToast(LS("邀请发送失败"))
                self.lp_stop()
        }
    }
    
    func avatarPressed(cell: DetailCommentCell) {
        // 评论列表的代理
        if let commentCell = cell as? ActivityCommentCell {
            let comment = commentCell.comment
            navigationController?.pushViewController(comment.user.showDetailController(), animated: true)
        }
    }
    
    func replyPressed(cell: DetailCommentCell) {
        commentPressed(cell.replyBtn!)
    }
    
    func commentPressed(sender: UIButton) {
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
            let options: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                                MKLaunchOptionsMapTypeKey: NSNumber(unsignedInteger: MKMapType.Standard.rawValue)]
            MKMapItem.openMapsWithItems([target], launchOptions: options)
        }
    }
    
    // MARK: adjust layout when keyboard appears
    
    func changeLayoutWhenKeyboardAppears(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
                var inset = tableView.contentInset
                inset.bottom += keyboardFrame.height
                tableView.contentInset = inset
                tableView.setContentOffset(CGPointMake(0, -50), animated: true)
                commentPanel.snp_remakeConstraints(closure: { (make) in
                    make.left.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
                    make.height.equalTo(commentPanel.barheight)
                })
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func changeLayoutWhenKeyboardDisappears(notification: NSNotification) {
        var inset = tableView.contentInset
        inset.bottom = commentPanel.barheight
        tableView.contentInset = inset
        commentPanel.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(commentPanel.barheight)
        })
        self.view.layoutIfNeeded()
    }
    
    // MARK: loading
    @available(*, deprecated=1)
    func checkImageDetail(cell: DetailCommentCell) {
        
    }
}


