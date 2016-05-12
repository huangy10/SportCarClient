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

class ActivityDetailController: InputableViewController, UITableViewDataSource, UITableViewDelegate, FFSelectDelegate, DetailCommentCellDelegate {
    
    var act: Activity!
    var comments: [ActivityComment] = []
    weak var parentCollectionView: UICollectionView?
    
    var infoView: ActivityDetailHeaderView!
    var tableView: UITableView!
    var commentPanel: ActivityCommentPanel!
    
    var responseToRow: Int = -1
    var atUser: [String] = []
    var responseToPrefixStr = ""
    var toast: UIView?
    
    var mapCell: MapCell!
    
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
        
        infoView.loadDataAndUpdateUI()
        print(infoView.frame)
        tableView.setContentOffset(CGPointMake(0, -infoView.preferedHeight), animated: false)
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
            if !act.finished {
                act.endAt = NSDate()
                setNavRightBtn()
                ActivityRequester.sharedInstance.closeActivty(act.ssidString, onSuccess: { (json) in
                    self.parentCollectionView?.reloadData()
                    // push a notification to tell other related component to update the status
                    NSNotificationCenter.defaultCenter().postNotificationName(kActivityManualEndedNotification, object: nil, userInfo: [kActivityKey: self.act])
                    }, onError: { (code) in
                })
            }
        } else {
            if act.applied {
                return
            }
            if act.finished {
                showToast(LS("活动已结束，无法报名"))
            }
            act.hostApply()
            infoView.loadDataAndUpdateUI()
            setNavRightBtn()
            ActivityRequester.sharedInstance.postToApplyActivty(act.ssidString, onSuccess: { (json) in
                }, onError: { (code) in
                    self.showToast(LS("报名失败"))
            })
        }
    }
    
    func likeBtnPressed() {
        ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: "", opType: "like", onSuccess: { (json) in
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
    func loadActInfo() {
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
            }) { (code) in
                
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
            }) { (code) in
                
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
    
    func userSelected(users: [User]) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let userIDs = users.map { $0.ssidString }
        let userIDData = try! JSON(userIDs).rawData()
        let userJSONString = String(data: userIDData, encoding: NSUTF8StringEncoding)
        ActivityRequester.sharedInstance.activityOperation(act.ssidString, targetUserID: userJSONString!, opType: "invite", onSuccess: { (json) in
            self.showToast(LS("邀请已发送"))
            }) { (code) in
                self.showToast(LS("邀请发送失败"))
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
    
    @available(*, deprecated=1.0)
    func checkImageDetail(cell: DetailCommentCell) {
    }
    
    // MARK: navigation
    
    func needNavigation() {
        toast = showConfirmToast(LS("导航"), message: LS("跳转到地图导航?"), target: self, confirmSelector: #selector(openMapToNavigate), cancelSelector: #selector(hideToast as ()->()))
//        toast = showConfirmToast(LS("跳转到地图导航?"), target: self, confirmSelector: #selector(openMapToNavigate), cancelSelector: #selector(hideToast as ()->()))
    }
    
    func hideToast() {
        if let t = toast {
            hideToast(t)
        }
    }
    
    func openMapToNavigate() {
        hideToast()
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
}
//
//class ActivityDetailController: InputableViewController, UITableViewDelegate, UITableViewDataSource, InlineUserSelectDelegate, FFSelectDelegate, DetailCommentCellDelegate {
//    weak var parentCollectionView: UICollectionView?
//    
//    var act: Activity!
//    var comments: [ActivityComment] = []
//    
//    var actInfoBoard: ActivityDetailBoardView!
//    var tableView: UITableView!
//    var boardHeight: CGFloat = 0
//    var commentPanel: ActivityCommentPanel!
//    
//    var responseToRow: Int = -1
//    var atUser: [String] = []
//    var responseToPrefixStr = ""
//    var toast: UIView?
//    weak var navRightItem: UIBarButtonItem?
//    init(act: Activity) {
//        super.init(nibName: nil, bundle: nil)
//        self.act = act
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    deinit {
//        print("deinit activity detail")
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        //
//        navSettings()
//        //
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivityDetailController.changeLayoutWhenKeyboardAppears(_:)), name: UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ActivityDetailController.changeLayoutWhenKeyboardDisappears(_:)), name: UIKeyboardWillHideNotification, object: nil)
//        //
//        let requester = ActivityRequester.requester
//        // 尽管已经传入了一个较为完整的活动对象，但是为了保证数据最新，仍然向服务器发起请求
//        requester.getActivityDetail(act.ssidString, onSuccess: { (json) -> () in
//            try! self.act.loadDataFromJSON(json!, detailLevel: 1)
//            self.navRightItem?.title = self.act.mine ? LS("关闭活动") : (self.act.applied ? LS("已报名") : LS("报名"))
//            self.actInfoBoard.act = self.act
//            self.commentPanel.setLikedAnimated(self.act.liked, flag: false)
//            self.boardHeight = self.actInfoBoard.loadDataAndUpdateUI()
//            self.actInfoBoard.frame = CGRectMake(0, -self.boardHeight, self.tableView.frame.width, self.boardHeight)
//            self.tableView.contentInset = UIEdgeInsetsMake(self.boardHeight, 0, self.commentPanel.barheight, 0)
//            self.actInfoBoard.backMaskView.setNeedsDisplay()
//            self.tableView.reloadData()
//            self.tableView.setContentOffset(CGPointMake(0, -self.boardHeight), animated: false)
//            }) { (code) -> () in
//                print(code)
//        }
//        self.actInfoBoard.act = act
//        self.commentPanel.setLikedAnimated(self.act.liked, flag: false)
//        self.actInfoBoard.loadDataAndUpdateUI()
//        loadMoreComments()
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//    }
//    
//    override func createSubviews() {
//        super.createSubviews()
//        let superview = self.view
//        //
//        tableView = UITableView(frame: CGRectZero, style: .Plain)
//        tableView.delegate = self
//        tableView.dataSource = self
//        self.view.addSubview(tableView)
//        tableView.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.bottom.equalTo(superview).offset(0)
//            make.right.equalTo(superview)
//            make.height.equalTo(superview)
//        }
//        tableView.registerClass(MapCell.self, forCellReuseIdentifier: MapCell.reuseIdentifier)
//        tableView.registerClass(ActivityCommentCell.self, forCellReuseIdentifier: ActivityCommentCell.reuseIdentifier)
//        //
//        actInfoBoard = ActivityDetailBoardView()
//        actInfoBoard.frame = self.view.bounds
//        actInfoBoard.hostAvatar.addTarget(self, action: #selector(ActivityDetailController.hostAvatarPressed), forControlEvents: .TouchUpInside)
//        actInfoBoard.editBtn.addTarget(self, action: #selector(ActivityDetailController.editBtnPressed), forControlEvents: .TouchUpInside)
//        actInfoBoard.parentController = self
//        actInfoBoard.memberDisplay.delegate = self
//        //
//        tableView.addSubview(actInfoBoard)
//        tableView.separatorStyle = .None
//        //
//        commentPanel = ActivityCommentPanel()
//        self.inputFields.append(commentPanel.contentInput)
//        commentPanel.contentInput?.delegate = self
//        self.view.addSubview(commentPanel)
//        commentPanel.likeBtn?.addTarget(self, action: #selector(ActivityDetailController.likeBtnPressed), forControlEvents: .TouchUpInside)
//        commentPanel.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(superview)
//            make.right.equalTo(superview)
//            make.bottom.equalTo(superview)
//            make.height.equalTo(commentPanel.barheight)
//        }
//    }
//    
//    
//    func navSettings() {
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
//        self.navigationItem.title = LS("活动详情")
//        //
//        let navLeftBtn = UIButton()
//        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
//        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
//        navLeftBtn.addTarget(self, action: #selector(ActivityDetailController.navLeftBtnPressed), forControlEvents: .TouchUpInside)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
//        //
//        let rightItem = UIBarButtonItem(title: act.mine ? LS("关闭活动") : (act.applied ? LS("已报名") : LS("报名")), style: .Done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
//        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
//        self.navRightItem = rightItem
//        self.navigationItem.rightBarButtonItem = rightItem
//    }
//    
//    func navLeftBtnPressed() {
//        self.navigationController?.popViewControllerAnimated(true)
//
//    }
//    
//    /**
//     报名或者是关闭
//     */
//    func navRightBtnPressed() {
//        let requester = ActivityRequester()
//        if act.mine {
//            let endAt = act.endAt!
//            if endAt.compare(NSDate()) == NSComparisonResult.OrderedAscending {
//                self.displayAlertController(LS("活动已结束，无法关闭报名"), message: nil)
//                return
//            }
//            // 关闭报名
//            requester.closeActivty(act.ssidString, onSuccess: { (json) -> () in
//                // 成功以后修改活动的状态
//                self.act.endAt = NSDate()
//                self.parentCollectionView?.reloadData()
//                // 更新UI
//                self.actInfoBoard.loadDataAndUpdateUI()
//                }, onError: { (code) -> () in
//                    print(code)
//            })
//        }else{
//            if act.applied {
//                return
//            }
//            // 报名
//            let endAt = act.endAt!
//            if endAt.compare(NSDate()) == NSComparisonResult.OrderedAscending {
//                self.showToast(LS("活动已结束，无法报名"))
//                return
//            }
//            requester.postToApplyActivty(act.ssidString, onSuccess: { (json) -> () in
//                // 当前用户加入
//                self.act.hostApply()
//                self.actInfoBoard.loadDataAndUpdateUI()
//                self.navRightItem?.title = LS("已报名")
//                self.showToast(LS("报名成功"))
//                }, onError: { (code) -> () in
//                    print(code)
//                    self.showToast(LS("报名失败"))
//            })
//            
//        }
////        self.navigationController?.popViewControllerAnimated(true)
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return comments.count
//        }else{
//            return 1
//        }
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if indexPath.section == 0{
//            let cell = tableView.dequeueReusableCellWithIdentifier(ActivityCommentCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityCommentCell
//            cell.comment = comments[indexPath.row]
//            cell.replyBtn?.tag = indexPath.row
//            cell.delegate = self
//            cell.loadDataAndUpdateUI()
//            return cell
//        }else{
//            let cell = tableView.dequeueReusableCellWithIdentifier(MapCell.reuseIdentifier, forIndexPath: indexPath) as! MapCell
//            let center = CLLocationCoordinate2D(latitude: act.location!.latitude, longitude: act.location!.longitude)
//            cell.setMapCenter(center)
//            cell.locBtn.addTarget(self, action: #selector(ActivityDetailController.needNavigation), forControlEvents: .TouchUpInside)
//            cell.locLbl.text = LS("导航至 ") + (act.location?.descr ?? LS("未知地点"))
//            cell.locDesIcon.image = UIImage(named: "person_guide_to")
//            return cell
//        }
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return ActivityCommentCell.heightForComment(comments[indexPath.row].content!)
//        }else{
//            return 250
//        }
//    }
//    
//    func inlineUserSelectShouldDeleteUser(user: User) {
//        let requester = ActivityRequester.requester
//        requester.activityOperation(act.ssidString, targetUserID: user.ssidString, opType: "apply_deny", onSuccess: { (json) -> () in
//            self.act.removeApplicant(user)
//            self.boardHeight = self.actInfoBoard.loadDataAndUpdateUI()
//            self.actInfoBoard.frame = CGRectMake(0, -self.boardHeight, self.tableView.frame.width, self.boardHeight)
//            self.tableView.contentInset = UIEdgeInsetsMake(self.boardHeight, 0, self.commentPanel.barheight, 0)
//            self.actInfoBoard.backMaskView.setNeedsDisplay()
//            }) { (code) -> () in
//                print(code)
//        }
//    }
//    
//    func inlineUserSelectNeedAddMembers() {
//        var forceUsers = act.applicants
//        forceUsers.append(act.user!)
//        let select = FFSelectController(maxSelectNum: kMaxSelectUserNum, preSelectedUsers: act.applicants, preSelect: false)
//        select.delegate = self
//        let wrapper = BlackBarNavigationController(rootViewController: select)
//        self.presentViewController(wrapper, animated: true, completion: nil)
//    }
//    
//    func userSelectCancelled() {
//        self.dismissViewControllerAnimated(true, completion: nil)
//    }
//    
//    func userSelected(users: [User]) {
//        // send invitation to those guys
//        self.dismissViewControllerAnimated(true, completion: nil)
//        let requester = ActivityRequester.requester
//        let userIDs = users.map { return $0.ssidString }
//        let userIDData = try! JSON(userIDs).rawData()
//        let userJSONString = String(data: userIDData, encoding: NSUTF8StringEncoding)
//        requester.activityOperation(act.ssidString, targetUserID: userJSONString!, opType: "invite", onSuccess: { (json) -> () in
//            self.showToast(LS("邀请已发送"))
//            }) { (code) -> () in
//                self.showToast(LS("邀请发送失败，请坚持您的网络状况"))
//        }
//    }
//}
//
//// MARK: - 评论Panel相关
//extension ActivityDetailController {
//    
//    func loadMoreComments() {
//        // 获取时间阈值
//        let dateThreshold = comments.last()?.createdAt ?? NSDate()
//        let requester = ActivityRequester.requester
//        requester.getActivityComments(act.ssidString, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
//            for data in json!.arrayValue {
//                let comment = try! ActivityComment(act: self.act).loadDataFromJSON(data)
//                self.comments.append(comment)
//            }
//            self.comments = $.uniq(self.comments, by: { return $0.ssid })
//            self.tableView.reloadData()
//            }) { (code) -> () in
//                print(code)
//        }
//    }
//    
//    /**
//     确认发送评论
//     
//     - parameter content: 评论的内容
//     - parameter image:   deprecated
//     */
//    func commentConfirmed(content: String, image: UIImage?) {
//        var responseToComment: ActivityComment? = nil
//        if responseToRow >= 0 {
//            responseToComment = comments[responseToRow]
//        }
//        let newComment = ActivityComment(act: act).initForPost(content, responseTo: responseToComment)
//        comments.insert(newComment, atIndex: 0)
//        tableView.reloadData()
//        commentPanel.contentInput?.text = ""
//        commentPanel.snp_updateConstraints { (make) -> Void in
//            make.height.equalTo(commentPanel.barheight)
//        }
//        let requester = ActivityRequester.requester
//        requester.sendActivityComment(act.ssidString, content: content, image: image, responseTo: responseToComment?.ssidString, informOf: atUser, onSuccess: { (json) -> () in
//            let newCommentID = json!["id"].int32Value
//            newComment.confirmSent(newCommentID)
//            // update the comment number
//            let commentNum = json!["comment_num"].int32Value
//            self.act.commentNum = commentNum
//            self.actInfoBoard.commentNumLbl.text = "\(commentNum)"
//            }) { (code) -> () in
//                print(code)
//        }
//    }
//    
//    func commentCanceled(content: String, image: UIImage?) {
//        
//    }
//    
//    func textViewDidChange(textView: UITextView) {
//        let fixedWidth = textView.bounds.width
//        let newSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
//        commentPanel.snp_updateConstraints { (make) -> Void in
//            make.height.equalTo(max(newSize.height, commentPanel.barheight))
//        }
//        self.view.layoutIfNeeded()
//    }
//    
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
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
//        if text == "" && responseToPrefixStr.length > 0 {
//            // 删除
//            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr.length{
//                textView.text = ""
//                responseToPrefixStr = ""
//                responseToRow = -1
//            }
//        }
//        return true
//    }
//    
//    
//    
//    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
//        let userInfo = notif.userInfo!
//        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
//        tableView?.snp_updateConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-(keyboardFrame.height) )
//        })
//        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
//        })
//        self.view.layoutIfNeeded()
//    }
//    
//    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
//        tableView?.snp_updateConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
//            make.bottom.equalTo(self.view).offset(0)
//        })
//        self.view.layoutIfNeeded()
//    }
//}
//
//extension ActivityDetailController {
//    func hostAvatarPressed() {
//        let detail = PersonOtherController(user: act.user!)
//        self.navigationController?.pushViewController(detail, animated: true)
//    }
//    
//    func likeBtnPressed() {
//        ActivityRequester.requester.activityOperation(act.ssidString, targetUserID: "", opType: "like", onSuccess: { (json) -> () in
//            let liked = json!["liked"].boolValue
//            let likeNum = json!["like_num"].int32Value
//            self.actInfoBoard.setLikeIconState(liked)
//            self.actInfoBoard.likeNumLbl.text = "\(likeNum)"
//            self.commentPanel.setLikedAnimated(liked)
//            }) { (code) -> () in
//                print(code)
//        }
//    }
//    
//    func needNavigation() {
//        toast = self.showConfirmToast(LS("跳转到地图导航?"), target: self, confirmSelector: #selector(ActivityDetailController.openMapToNavigate), cancelSelector: #selector(ActivityDetailController.hideToast as (ActivityDetailController) -> () -> ()))
//    }
//    
//    func hideToast() {
//        if toast != nil {
//            self.hideToast(toast!)
//        }
//    }
//    
//    func openMapToNavigate() {
//        self.hideToast(toast!)
//        let param = BMKNaviPara()
//        let end = BMKPlanNode()
//
//        let center = act.location!.coordinate
//        end.pt = center
//        let targetName = act.location?.descr ?? LS("位置地点")
//        end.name = targetName
//        param.endPoint = end
//        param.appScheme = "baidumapsdk://mapsdk.baidu.com"
//        let res = BMKNavigation.openBaiduMapNavigation(param)
//        if res.rawValue != 0 {
//            // 如果没有安装百度地图，则打开自带地图
//            let target = MKMapItem(placemark: MKPlacemark(coordinate: center, addressDictionary: nil))
//            target.name = targetName
//            let options: [String: AnyObject] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
//                MKLaunchOptionsMapTypeKey: NSNumber(unsignedInteger: MKMapType.Standard.rawValue)]
//            MKMapItem.openMapsWithItems([target], launchOptions: options)
//        }
//    }
//    
//    func editBtnPressed() {
//        let detail = ActivityEditController()
//        detail.act = act
//        self.navigationController?.pushViewController(detail, animated: true)
//    }
//    
//    
//    // 评论列表的代理
//    func avatarPressed(cell: DetailCommentCell) {
//        if let commentCell = cell as? ActivityCommentCell {
//            let comment = commentCell.comment
//            navigationController?.pushViewController(comment.user.showDetailController(), animated: true)
//        }
//    }
//    
//    func replyPressed(cell: DetailCommentCell) {
//        commentPressed(cell.replyBtn!)
//    }
//    
//    func checkImageDetail(cell: DetailCommentCell) {
//        
//    }
//    
//    func commentPressed(sender: UIButton) {
//        responseToRow = sender.tag
//        // 取出改行的用户信息并在评论内容输入框里面填入『回复 某人：』字样
//        let targetComment = comments[responseToRow]
//        if let responseToName = targetComment.user?.nickName {
//            responseToPrefixStr = LS("回复 ") + responseToName + ": "
//            commentPanel?.contentInput?.text = responseToPrefixStr
//        }
//        
//        atUser.removeAll()
//        commentPanel?.contentInput?.becomeFirstResponder()
//    }
//
//}

