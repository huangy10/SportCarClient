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

class ActivityDetailController: UIViewController, LoadingProtocol {

    var delayWorkItem: DispatchWorkItem?
    
    var act: Activity!
    var comments: [ActivityComment] = []
    weak var parentCollectionView: UICollectionView?
    
    var infoView: ActivityDetailHeaderView!
    var tableView: UITableView!
    var bottomBar: BasicBottomBar!
    
    var responseToRow: Int = -1
    var atUser: [String] = []
    var responseToPrefixStr = ""
    
    var mapCell: MapCell!
    
    var needReloadActInfo: Bool = false
    
    var tapper: UITapGestureRecognizer!
    
    init(act: Activity) {
        super.init(nibName: nil, bundle: nil)
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
    
    func dismissKeyboard() {
        bottomBar.contentInput.resignFirstResponder()
        tapper.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        configureTapper()
        configureTableView()
        configureMapCell()
        configureInfoView()
        configureBottomBar()
        
        loadActInfo()
        loadMoreComments()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onActivityInfoChanged(_:)), name: NSNotification.Name(rawValue: kActivityInfoChanged), object: nil)
        
    }
    
    func onActivityInfoChanged(_ notification: Foundation.Notification) {
        if let act = (notification as NSNotification).userInfo?[kActivityKey] as? Activity , act == self.act{
            DispatchQueue.main.async(execute: { 
                self.loadActInfo()
            })
        }
    }
    
    func configureTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        tableView.snp.makeConstraints{ $0.edges.equalTo(view) }
        
        tableView.register(DetailCommentCell2.self, forCellReuseIdentifier: "cell")
        tableView.register(SSEmptyListHintCell.self, forCellReuseIdentifier: "empty")
    }
    
    func configureInfoView() {
        infoView = ActivityDetailHeaderView(act: act)
        infoView.likeBtn.addTarget(self, action: #selector(likeBtnPressed), for: .touchUpInside)
        infoView.parentController = self
        tableView.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.bottom.equalTo(tableView.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.height.equalTo(infoView.preferedHeight)
        }
    }
    
    func configureTapper() {
        tapper = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapper)
    }
    
    func configureMapCell() {
        mapCell = MapCell(trailingHeight: 100)
        mapCell.locBtn.addTarget(self, action: #selector(ActivityDetailController.needNavigation), for: .touchUpInside)
        mapCell.locLbl.text = LS("导航至 ") + (act.location?.descr ?? LS("未知地点"))
        mapCell.locDesIcon.image = UIImage(named: "location_mark_black")
        mapCell.locDesIcon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    func configureBottomBar() {
        bottomBar = BasicBottomBar(delegate: self)
        bottomBar.forwardTextViewDelegateTo(self)
        view.addSubview(bottomBar)
        var rect = view.bounds
        rect.size.height -= 64
        bottomBar.setFrame(withOffsetToBottom: 0, superviewFrame: rect)
        var oldInset = tableView.contentInset
        oldInset.bottom += bottomBar.defaultBarHeight
        tableView.contentInset = oldInset
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
                let rightItem = UIBarButtonItem(title: LS("关闭活动"), style: .done, target: self, action: #selector(navRightBtnPressed))
                rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
                navigationItem.rightBarButtonItem = rightItem
            }
        } else {
            let rightItem = UIBarButtonItem(title: act.applied ? LS("已报名") : LS("报名"), style: .done, target: self, action: #selector(ActivityDetailController.navRightBtnPressed))
            rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
            self.navigationItem.rightBarButtonItem = rightItem
        }
    }
    
    func navLeftBtnPressed() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func navRightBtnPressed() {
        if act.mine {
            closeActivity()
        } else {
            applyForActivity()
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
                self.bottomBar.reloadIcon(at: 0, withPulse: true)
            } else {
                assertionFailure()
            }
            }) { (code) in
                self.lp_stop()
                self.showToast("Access Error: \(code)")
        }
    }
    
    
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
                    self.bottomBar.reloadIcon(at: 0)
                    self.tableView.contentOffset = CGPoint(x: 0, y: -self.infoView.preferedHeight)
                    var oldInset = self.tableView.contentInset
                    oldInset.top = self.infoView.preferedHeight
                    self.tableView.contentInset = oldInset
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
        bottomBar.clearInputContent()
        
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
    
    func avatarPressed(_ cell: DetailCommentCell) {
        // 评论列表的代理
        if let commentCell = cell as? ActivityCommentCell {
            let comment = commentCell.comment
            navigationController?.pushViewController((comment?.user.showDetailController())!, animated: true)
        }
    }

    // MARK: navigation
    
    func needNavigation() {
        showConfirmToast(LS("导航"), message: LS("跳转到地图导航？"), target: self, onConfirm: #selector(openMapToNavigate))
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
}

extension ActivityDetailController: BottomBarDelegate {
    func bottomBarDidBeginEditing() {
        tapper.isEnabled = true
    }
    
    func bottomBarMessageConfirmSent() {
        commentConfirmed(bottomBar.contentInput.text)
    }
    
    func bottomBarHeightShouldChange(into newHeight: CGFloat) -> Bool {
        return true
    }
    
    func bottomBarBtnPressed(at index: Int) {
        likeBtnPressed()
    }
    
    func getIconForBtn(at idx: Int) -> UIImage {
        if act.liked {
            return UIImage(named: "news_like_liked")!
        } else {
            return UIImage(named: "news_like_unliked")!
        }
    }
    
    func numberOfLeftBtns() -> Int {
        return 0
    }
    
    func numberOfRightBtns() -> Int {
        return 1
    }
}

extension ActivityDetailController: DetailCommentCellDelegate2 {
    
    func startReplyToComment(atIndexPath indexPath: IndexPath) {
        responseToRow = indexPath.row
        let comment = comments[responseToRow]
        responseToPrefixStr = getCommentPrefix(forUserNickName: comment.user.nickName!)
        bottomBar.contentInput.text = responseToPrefixStr
        atUser.removeAll()
        bottomBar.contentInput.becomeFirstResponder()
    }
    
    func getCommentPrefix(forUserNickName name: String) -> String {
        return LS("回复 ") + name + ": "
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

extension ActivityDetailController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" && responseToPrefixStr.length > 0 {
            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr.length {
                textView.text = ""
                responseToPrefixStr = ""
                responseToRow = -1
            }
        }
        return true
    }
}


extension ActivityDetailController: UITableViewDelegate, UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if comments.count == 0 {
                return 100
            } else {
                return 87
            }
        } else {
            return 250
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).section == 0 {
            if comments.count == 0 {
                // empty info cell
                return 100
            }
//            return ActivityCommentCell.heightForComment(comments[(indexPath as NSIndexPath).row].content!)
            return UITableViewAutomaticDimension
        } else {
            return 250
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if comments.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "empty", for: indexPath) as! SSEmptyListHintCell
                cell.titleLbl.text = LS("还没有评论")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DetailCommentCell2
                cell.delegate = self
                let comment = comments[indexPath.row]
                cell.setData(comment.user.avatarURL!, name: comment.user.nickName!, content: comment.content, commentAt: comment.createdAt, responseTo: comment.responseTo?.user.nickName, showReplyBtn: !comment.user.isHost)
                cell.setNeedsUpdateConstraints()
                cell.updateConstraintsIfNeeded()
                return cell
            }
        } else {
            if !mapCell.centerSet {
                let center = CLLocationCoordinate2D(latitude: act.location!.latitude, longitude: act.location!.longitude)
                mapCell.setMapCenter(center)
            }
            return mapCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if comments.count == 0 || indexPath.section > 0 {
            return
        }
        startReplyToComment(atIndexPath: indexPath)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        infoView.adjustCoverScaleAccordingToTableOffset(scrollView.contentOffset.y + infoView.preferedHeight)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.height > scrollView.contentSize.height - 1 {
            loadMoreComments()
        }
    }
}

extension ActivityDetailController: FFSelectDelegate {
    func userSelectCancelled() {
        // just dismiss the presented user selector
        self.dismiss(animated: true, completion: nil)
    }
  
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
}

