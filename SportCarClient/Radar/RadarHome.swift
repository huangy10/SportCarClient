//
//  RadarHome.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class RadarHomeController: UIViewController{
    var homeDelegate: HomeDelegate?
    
    var driver: RadarDriverMapController!
    var club: ClubsController!
    
    var board: UIScrollView!
    var titleBtnIcon: UIImageView!
    var titleDriverBtn: UIButton!
    var titleClubBtn: UIButton!
    
    var curTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
        createSubviews()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func navSettings() {
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "home_back"), forState: .Normal)
        navLeftBtn.frame = CGRectMake(0, 0, 15, 13.5)
        navLeftBtn.addTarget(self, action: "navLeftBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let navRightBtn = UIButton()
        navRightBtn.setImage(UIImage(named: "status_add_btn_white"), forState: .Normal)
        navRightBtn.frame = CGRectMake(0, 0, 21, 21)
        navRightBtn.addTarget(self, action: "navRightBtnPressed", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navRightBtn)
        //
        let barHeight = self.navigationController!.navigationBar.frame.height
        let containerWidth = self.view.frame.width * 0.8
        let container = UIView()
        container.frame = CGRectMake(0, 0, containerWidth, barHeight)
        container.backgroundColor = UIColor.clearColor()
        //
        titleDriverBtn = UIButton()
        titleDriverBtn.tag = 0
        titleDriverBtn.setTitle(LS("车主"), forState: .Normal)
        titleDriverBtn.setTitleColor(kBarBgColor, forState: .Normal)
        titleDriverBtn.titleLabel?.font = kBarTextFont
        titleDriverBtn.addTarget(self, action: "navTitleBtnPressed:", forControlEvents: .TouchUpInside)
        container.addSubview(titleDriverBtn)
        titleDriverBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.right.equalTo(container.snp_centerX).offset(-8)
            make.centerY.equalTo(container)
        }
        //
        titleClubBtn = UIButton()
        titleClubBtn.tag = 1
        titleClubBtn.setTitle(LS("俱乐部"), forState: .Normal)
        titleClubBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleClubBtn.titleLabel?.font = kBarTextFont
        titleClubBtn.addTarget(self, action: "navTitleBtnPressed:", forControlEvents: .TouchUpInside)
        container.addSubview(titleClubBtn)
        titleClubBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.left.equalTo(container.snp_centerX).offset(8)
            make.centerY.equalTo(container)
        }
        //
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon)
        titleBtnIcon.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(titleDriverBtn)
        }
        container.sendSubviewToBack(titleBtnIcon)
        //
        self.navigationItem.titleView = container
    }
    
    func navLeftBtnPressed() {
        if homeDelegate != nil {
            homeDelegate?.backToHome(nil, screenShot: self.getScreenShotBlurred(false))
        }else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func navRightBtnPressed() {
        
    }
    
    func navTitleBtnPressed(sender: UIButton) {
        if sender.tag == curTag {
            return
        }
        
        if sender.tag == 0 {
            board.setContentOffset(CGPointZero, animated: true)
            titleDriverBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleClubBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleDriverBtn)
            })
        }else {
            board.setContentOffset(CGPointMake(self.view.frame.width, 0), animated: true)
            titleDriverBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            titleClubBtn.setTitleColor(kBarBgColor, forState: .Normal)
            titleBtnIcon.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleClubBtn)
            })
        }
        curTag = sender.tag
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.titleBtnIcon.superview?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func createSubviews(){
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        let width = self.view.frame.width
        board = UIScrollView()
        board.pagingEnabled = true
        board.scrollEnabled = false
        board.contentSize = CGSizeMake(width * 2, 0)
        superview.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(superview)
        }
        //
        driver = RadarDriverMapController()
        board.addSubview(driver.view)
        driver.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
        //
        club = ClubsController()
        board.addSubview(club.view)
        club.view.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(board).offset(width)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(width)
        }
    }
}

// MARK: - Popover
extension RadarHomeController {
    
}
