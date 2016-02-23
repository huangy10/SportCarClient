//
//  ActivityDetail.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/16.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SwiftyJSON
import Mapbox

class ActivityDetailController: InputableViewController, UITableViewDelegate, UITableViewDataSource{
    weak var parentTableView: UITableView?
    
    var act: Activity!
    var comments: [ActivityComment] = []
    var isMineAct: Bool{
        print(act.user)
        return act.user?.userID == User.objects.hostUser?.userID
    }
    
    var actInfoBoard: ActivityDetailBoardView!
    var tableView: UITableView!
    var boardHeight: CGFloat = 0
    var commentPanel: ActivityCommentPanel!
    
    var responseToRow: Int = -1
    var atUser: [String] = []
    var responseToPrefixStr = ""
    
    init(act: Activity) {
        super.init(nibName: nil, bundle: nil)
        self.act = act
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        navSettings()
        //
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardAppears:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "changeLayoutWhenKeyboardDisappears:", name: UIKeyboardWillHideNotification, object: nil)
        //
        let requester = ActivityRequester.requester
        // 尽管已经传入了一个较为完整的活动对象，但是为了保证数据最新，仍然向服务器发起请求
        requester.getActivityDetail(act.activityID!, onSuccess: { (json) -> () in
            self.act.loadValueFromJSON(json!)
            self.actInfoBoard.act = self.act
            self.boardHeight = self.actInfoBoard.loadDataAndUpdateUI()
            self.actInfoBoard.frame = CGRectMake(0, -self.boardHeight, self.tableView.frame.width, self.boardHeight)
            self.tableView.contentInset = UIEdgeInsetsMake(self.boardHeight, 0, self.commentPanel.barheight, 0)
            self.actInfoBoard.backMaskView.setNeedsDisplay()
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPointMake(0, -self.boardHeight), animated: false)
            }) { (code) -> () in
                print(code)
        }
        loadMoreComments()
    }
    
    override func createSubviews() {
        super.createSubviews()
        let superview = self.view
        //
        tableView = UITableView(frame: CGRectZero, style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.bottom.equalTo(superview).offset(0)
            make.right.equalTo(superview)
            make.height.equalTo(superview)
        }
        tableView.registerClass(MapCell.self, forCellReuseIdentifier: MapCell.reuseIdentifier)
        tableView.registerClass(ActivityCommentCell.self, forCellReuseIdentifier: ActivityCommentCell.reuseIdentifier)
        //
        actInfoBoard = ActivityDetailBoardView()
        actInfoBoard.frame = self.view.bounds
        actInfoBoard.hostAvatar.addTarget(self, action: "hostAvatarPressed", forControlEvents: .TouchUpInside)
        //
        tableView.addSubview(actInfoBoard)
        tableView.separatorStyle = .None
        //
        commentPanel = ActivityCommentPanel()
        self.inputFields.append(commentPanel.contentInput)
        commentPanel.contentInput?.delegate = self
        self.view.addSubview(commentPanel)
        commentPanel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.bottom.equalTo(superview)
            make.height.equalTo(commentPanel.barheight)
        }
    }
    
    
    func navSettings() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.title = LS("活动详情")
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 9, 15)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: isMineAct ? LS("关闭") : LS("报名"), style: .Done, target: self, action: "navRightBtnPressed")
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight), NSForegroundColorAttributeName: kHighlightedRedTextColor], forState: .Normal)
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    func navLeftBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    /**
     报名或者是关闭
     */
    func navRightBtnPressed() {
        let requester = ActivityRequester()
        if isMineAct {
            let endAt = act.endAt!
            if endAt.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                self.displayAlertController(LS("活动已结束，无法关闭报名"), message: nil)
                return
            }
            // 关闭报名
            requester.closeActivty(act.activityID!, onSuccess: { (json) -> () in
                // 成功以后修改活动的状态
                self.act.endAt = NSDate()
                Activity.objects.save()
                self.parentTableView?.reloadData()
                // 更新UI
                self.actInfoBoard.loadDataAndUpdateUI()
                }, onError: { (code) -> () in
                    print(code)
            })
        }else{
            // 报名
            let endAt = act.endAt!
            if endAt.compare(NSDate()) == NSComparisonResult.OrderedAscending {
                self.displayAlertController(LS("活动已结束，无法报名"), message: nil)
                return
            }
            requester.postToApplyActivty(act.activityID!, onSuccess: { (json) -> () in
                // 当前用户加入
                self.act.hostApply()
                self.actInfoBoard.loadDataAndUpdateUI()
                }, onError: { (code) -> () in
                    print(code)
            })
            
        }
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return comments.count
        }else{
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCellWithIdentifier(ActivityCommentCell.reuseIdentifier, forIndexPath: indexPath) as! ActivityCommentCell
            cell.comment = comments[indexPath.row]
            cell.loadDataAndUpdateUI()
            return cell
        }else{
            let cell = tableView.dequeueReusableCellWithIdentifier(MapCell.reuseIdentifier, forIndexPath: indexPath) as! MapCell
            let center = CLLocationCoordinate2D(latitude: act.location_y, longitude: act.location_x)
            cell.setMapCenter(center)
            cell.locLbl.text = LS("导航至 ") + (act.location_des ?? LS("未知地点"))
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return ActivityCommentCell.heightForComment(comments[indexPath.row].content!)
        }else{
            return 250
        }
    }
}

// MARK: - 评论Panel相关
extension ActivityDetailController {
    
    func loadMoreComments() {
        // 获取时间阈值
        let dateThreshold = comments.last()?.createdAt ?? NSDate()
        let requester = ActivityRequester.requester
        requester.getActivityComments(act.activityID!, dateThreshold: dateThreshold, limit: 10, onSuccess: { (json) -> () in
            for data in json!.arrayValue {
                let comment = ActivityComment.objects.create(data, act: self.act)
                self.comments.append(comment)
            }
            self.tableView.reloadData()
            }) { (code) -> () in
                print(code)
        }
    }
    
    /**
     确认发送评论
     
     - parameter content: 评论的内容
     - parameter image:   deprecated
     */
    func commentConfirmed(content: String, image: UIImage?) {
        var responseToComment: ActivityComment? = nil
        if responseToRow >= 0 {
            responseToComment = comments[responseToRow]
        }
        let newComment = ActivityComment.objects.postToNewCommentToActivity(act, commentString: content, atString: JSON(atUser).string, responseToComment: responseToComment)
        comments.insert(newComment, atIndex: 0)
        tableView.reloadData()
        commentPanel.contentInput?.text = ""
        commentPanel.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(commentPanel.barheight)
        }
        let requester = ActivityRequester.requester
        requester.sendActivityComment(act.activityID!, content: content, image: image, responseTo: responseToComment?.commentID, informOf: atUser, onSuccess: { (json) -> () in
            let newCommentID = json!.stringValue
            ActivityComment.objects.confirmSent(newComment, commentID: newCommentID)
            }) { (code) -> () in
                print(code)
        }
    }
    
    func commentCanceled(content: String, image: UIImage?) {
        
    }
    
    func textViewDidChange(textView: UITextView) {
        let fixedWidth = textView.bounds.width
        let newSize = textView.sizeThatFits(CGSizeMake(fixedWidth, CGFloat.max))
        commentPanel.snp_updateConstraints { (make) -> Void in
            make.height.equalTo(max(newSize.height, commentPanel.barheight))
        }
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
        
        if text == "" && responseToPrefixStr.length > 0 {
            // 删除
            if (textView.textInputMode?.primaryLanguage != "zh-Hans" || textView.markedTextRange == nil) && textView.text.length <= responseToPrefixStr.length{
                textView.text = ""
                responseToPrefixStr = ""
                responseToRow = -1
            }
        }
        return true
    }
    
    
    
    func changeLayoutWhenKeyboardAppears(notif: NSNotification) {
        let userInfo = notif.userInfo!
        let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
        tableView?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-(keyboardFrame.height) )
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-keyboardFrame.height)
        })
        self.view.layoutIfNeeded()
    }
    
    func changeLayoutWhenKeyboardDisappears(notif: NSNotification) {
        tableView?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        commentPanel?.snp_updateConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(self.view).offset(0)
        })
        self.view.layoutIfNeeded()
    }
}

extension ActivityDetailController {
    func hostAvatarPressed() {
        let detail = PersonOtherController(user: act.user!)
        self.navigationController?.pushViewController(detail, animated: true)
    }
}

