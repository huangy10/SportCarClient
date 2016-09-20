//
//  RadarHome.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class RadarHomeController: UIViewController, FFSelectDelegate, GroupChatSetupDelegate{
    weak var homeDelegate: HomeDelegate?
    
    var driver: RadarDriverMapController!
    var club: ClubDiscoverController!
    var act: ActivityNearByController!
    var controllers: [UIViewController] = []
    
    var board: UIScrollView!
    var titleBtnIcon: UIImageView!
    
    var titleDriverLbl: UILabel!
    var titleClubLbl: UILabel!
    var titleActLbl: UILabel!
    
    var releaseBoard: UIView!
    var navRightBtn: UIButton!
    var navRightIcon: UIImageView!
    var navLeftBtn: BackToHomeBtn!
    
    var curTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        controllers[curTag].viewWillAppear(animated)
        board.setContentOffset(CGPoint(x: CGFloat(self.curTag) * board.frame.width,  y: 0), animated: false)
        navLeftBtn.unreadStatusChanged()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        controllers[curTag].viewWillDisappear(animated)
    }
    
    func navSettings() {
        navLeftBtn = BackToHomeBtn()
        navLeftBtn.addTarget(self, action: #selector(navLeftBtnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = navLeftBtn.wrapToBarBtn()
        navRightBtn = UIButton()
        navRightBtn.tag = 0
        navRightIcon = UIImageView(image: UIImage(named: "status_add_btn_white"))
        navRightBtn.addSubview(navRightIcon)
        navRightIcon.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        navRightBtn.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        navRightBtn.addTarget(self, action: #selector(RadarHomeController.navRightBtnPressed), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        //
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView()
        container.frame = CGRect(x: 0, y: 0, width: containerWidth, height: barHeight)
        container.backgroundColor = UIColor.clear
        
        let titleClubBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(navTitleBtnPressed(_:)))
            .layout({ (make) in
                make.size.equalTo(CGSize(width: 70, height: 30))
                make.center.equalTo(container)
            })
        titleClubBtn.tag = 1
        let defaultFont = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        titleClubLbl = titleClubBtn.addSubview(UILabel)
            .config(15, textColor: kTextGray, textAlignment: .center, text: LS("俱乐部"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleClubBtn)
                make.size.equalTo(LS(" 俱乐部 ").sizeWithFont(defaultFont, boundingSize: CGSize(width: CGFloat.max, height: CGFloat.max)))
            })
        
        let titleDriverBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(navTitleBtnPressed(_:)))
            .layout({ (make) in
                make.centerY.equalTo(container)
                make.right.equalTo(titleClubBtn.snp_left)
                make.size.equalTo(CGSize(width: 70, height: 30))
            })
        titleDriverBtn.tag = 0
        titleDriverLbl = titleDriverBtn.addSubview(UILabel)
            .config(15, textColor: kTextBlack, textAlignment: .center, text: LS("车主"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleDriverBtn)
                make.size.equalTo(LS(" 车主 ").sizeWithFont(defaultFont, boundingSize: CGSize(width: CGFloat.max, height: CGFloat.max)))
            })
        
        let titleActBtn = container.addSubview(UIButton)
            .config(self, selector: #selector(navTitleBtnPressed(_:)))
            .layout({ (make) in
                make.centerY.equalTo(container)
                make.left.equalTo(titleClubBtn.snp_right)
                make.size.equalTo(CGSize(width: 70, height: 30))
            })
        titleActBtn.tag = 2
        titleActLbl = titleActBtn.addSubview(UILabel)
            .config(15, textColor: kTextGray, textAlignment: .center, text: LS("活动"), fontWeight: UIFontWeightBold)
            .layout({ (make) in
                make.center.equalTo(titleActBtn)
                make.size.equalTo(LS(" 活动 ").sizeWithFont(defaultFont, boundingSize: CGSize(width: CGFloat.max, height: CGFloat.max)))
            })
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(container)
            make.left.equalTo(titleDriverLbl).offset(-3)
            make.right.equalTo(titleDriverLbl).offset(3)
            make.height.equalTo(2.5)
        }
        container.sendSubview(toBack: titleBtnIcon)
        //
        self.navigationItem.titleView = container
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func navRightBtnPressed() {
        let superview = self.view
        let trans: CATransform3D
        if navRightBtn.tag == 1 {
            releaseBoard.snp_remakeConstraints { (make) -> Void in
                make.bottom.equalTo(superview.snp_top).offset(-10)
                make.right.equalTo(superview)
                make.width.equalTo(125)
                make.height.equalTo(150)
            }
            trans = CATransform3DIdentity
            navRightBtn.tag = 0
        }else {
            releaseBoard.snp_remakeConstraints { (make) -> Void in
                make.top.equalTo(superview)
                make.right.equalTo(superview)
                make.width.equalTo(125)
                make.height.equalTo(150)
            }
            trans = CATransform3DMakeRotation(CGFloat(M_PI / 4), 0, 0, 1.0)
            navRightBtn.tag = 1
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.navRightIcon.layer.transform = trans
        }) 
    }
    
    func navTitleBtnPressed(_ sender: UIButton) {
        if sender.tag == curTag {
            return
        }
        controllers[sender.tag].viewWillAppear(true)
        controllers[curTag].viewWillDisappear(true)
        
        let btns = [titleDriverLbl, titleClubLbl, titleActLbl]
        let targetLbl = btns[sender.tag]
        let sourceLbl = btns[curTag]
        targetLbl?.textColor = kTextBlack
        sourceLbl?.textColor = kTextGray
        titleBtnIcon.snp_remakeConstraints { (make) in
            make.bottom.equalTo(titleBtnIcon.superview!)
            make.left.equalTo(targetLbl).offset(-3)
            make.right.equalTo(targetLbl).offset(3)
            make.height.equalTo(2.5)
        }
        
//        if sender.tag == 0 {
//            board.setContentOffset(CGPointZero, animated: true)
//            titleDriverBtn.setTitleColor(kBarBgColor, forState: .Normal)
//            titleClubBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
//                make.edges.equalTo(titleDriverBtn)
//            })
//            driver.viewWillAppear(true)
//            club.viewWillDisappear(true)
//        }else {
//            board.setContentOffset(CGPointMake(self.view.frame.width, 0), animated: true)
//            titleDriverBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            titleClubBtn.setTitleColor(kBarBgColor, forState: .Normal)
//            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
//                make.edges.equalTo(titleClubBtn)
//            })
//            driver.viewWillDisappear(true)
//            club.viewWillAppear(true)
//        }
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.titleBtnIcon.superview?.layoutIfNeeded()
            }, completion: nil)
        board.setContentOffset(CGPoint(x: self.view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
        curTag = sender.tag
    }
    
    func createSubviews(){
        let superview = self.view
        superview?.backgroundColor = UIColor.white
        //
        let width = self.view.frame.width
        board = UIScrollView()
        board.isPagingEnabled = true
        board.isScrollEnabled = false
        board.contentSize = CGSize(width: width * 2, height: 0)
        superview?.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        driver = RadarDriverMapController()
        driver.radarHome = self
        board.addSubview(driver.view)
        driver.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
        //
        club = ClubDiscoverController()
        club.radarHome = self
        board.addSubview(club.view)
        club.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(width)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
        
        act = ActivityNearByController()
        act.home = self
        board.addSubview(act.view)
        act.view.snp_makeConstraints { (make) in
            make.size.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(board).offset(width * 2)
        }
        
        controllers = [driver, club, act]
        
        createReleaseBoard()
    }
    
    func createReleaseBoard() {
        var superview = self.view
        
        releaseBoard = superview?.addSubview(UIView).config(UIColor.white)
            .addShadow().layout({ (make) in
                make.bottom.equalTo(superview.snp_top).offset(-10)
                make.right.equalTo(superview)
                make.width.equalTo(125)
                make.height.equalTo(150)
            })
        superview = releaseBoard
        let releaseStatus = UIButton()
        releaseStatus.tag = 0
        releaseStatus.addTarget(self, action: #selector(RadarHomeController.releaseBtnPressed(_:)), for: .touchUpInside)
        releaseStatus.setTitle(LS("发布动态"), for: UIControlState())
        releaseStatus.setTitleColor(UIColor.black, for: UIControlState())
        releaseStatus.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview?.addSubview(releaseStatus)
        releaseStatus.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.height.equalTo(superview).dividedBy(3)
            make.width.equalTo(90)
        }
        let releaseStatusIcon = UIImageView(image: UIImage(named: "radar_new_status"))
        superview?.addSubview(releaseStatusIcon)
        releaseStatusIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(releaseStatus)
            make.right.equalTo(releaseStatus.snp_left)
            make.size.equalTo(17)
        }
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview?.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(releaseStatus)
            make.height.equalTo(0.5)
        }
        let addChat = UIButton()
        addChat.tag = 1
        addChat.addTarget(self, action: #selector(RadarHomeController.releaseBtnPressed(_:)), for: .touchUpInside)
        addChat.setTitleColor(UIColor.black, for: UIControlState())
        addChat.setTitle(LS("新建聊天"), for: UIControlState())
        addChat.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview?.addSubview(addChat)
        addChat.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(releaseStatus.snp_bottom)
            make.width.equalTo(releaseStatus)
            make.height.equalTo(releaseStatus)
        }
        let addChatIcon = UIImageView(image: UIImage(named: "radar_new_chat"))
        superview?.addSubview(addChatIcon)
        addChatIcon.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(addChat)
            make.right.equalTo(addChat.snp_left)
            make.size.equalTo(19)
        }
        let sepLine2 = UIView()
        sepLine2.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview?.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.bottom.equalTo(addChat)
            make.height.equalTo(0.5)
        }
        let startActivity = UIButton()
        startActivity.tag = 2
        startActivity.addTarget(self, action: #selector(RadarHomeController.releaseBtnPressed(_:)), for: .touchUpInside)
        startActivity.setTitle(LS("发起活动"), for: UIControlState())
        startActivity.setTitleColor(UIColor.black, for: UIControlState())
        startActivity.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        superview?.addSubview(startActivity)
        startActivity.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(addChat.snp_bottom)
            make.width.equalTo(addChat)
            make.bottom.equalTo(superview)
        }
        let startActivityIcon = UIImageView(image: UIImage(named: "radar_new_activity"))
        superview?.addSubview(startActivityIcon)
        startActivityIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(startActivity.snp_left)
            make.centerY.equalTo(startActivity)
            make.size.equalTo(19)
        }
    }
}

// MARK: - Popover
extension RadarHomeController {
    
    func releaseBtnPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let release = StatusReleaseController()
            release.pp_presentWithWrapperFromController(self)
        case 1:
            let selector = FFSelectController()
            selector.delegate = self
            let nav = BlackBarNavigationController(rootViewController: selector)
            self.present(nav, animated: true, completion: nil)
        case 2:
            if PermissionCheck.sharedInstance.releaseActivity {
                let release = ActivityReleaseController()
                release.presentFrom(self)
            } else {
                showToast(LS("请先认证一辆车辆"), onSelf: true)
            }
        default:
            break
        }
        self.navRightBtnPressed()
    }
    
    func userSelectCancelled() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func userSelected(_ users: [User]) {
        self.dismiss(animated: true, completion: nil)
        if users.count == 1 {
            let room = ChatRoomController()
            room.targetUser = users.first
            room.chatCreated = false
            self.navigationController?.pushViewController(room, animated: true)
        }else if users.count > 1 {
            let detail = GroupChatSetupController()
            detail.delegate = self
            detail.users = users
            self.navigationController?.pushViewController(detail, animated: true)
        }
    }
    
    func groupChatSetupControllerDidSuccessCreatingClub(_ newClub: Club) {
        // 群聊创建成功，打开聊天窗口
        self.navigationController?.popViewController(animated: true)
        // Ensure that the datasource is started
        let chatRoom = ChatRoomController()
        chatRoom.chatCreated = false
        chatRoom.targetClub = newClub
        self.navigationController?.pushViewController(chatRoom, animated: true)

    }
}
