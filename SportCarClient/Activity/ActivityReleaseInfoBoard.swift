//
//  ActivityReleaseInfoBoard.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class ActivityReleaseInfoBoard: UIView {
    weak var releaser: ActivityReleaseController!
    
    var posterBtn: UIButton!
    var posterLbl: UILabel!
    var actNameInput: UITextField!
    var actDesInput: UITextView!
    var actDesInputWordCount: UILabel!
    //
    var informOfList: InformOtherUserController!
    var informOfListCountLbl: UILabel!
    var informOfUsers: [User] = []
    // 状态变量
    var actDesEditStart: Bool = false
    //
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        let superview = self
        self.backgroundColor = UIColor.whiteColor()
        //
        posterBtn = UIButton()
        superview.addSubview(posterBtn)
        posterBtn.setImage(UIImage(named: "activity_release_default_cover"), forState: .Normal)
        posterBtn.imageView?.contentMode = .ScaleAspectFill
        posterBtn.clipsToBounds = true
        posterBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(posterBtn.snp_width).multipliedBy(0.573)
        }
        
        posterLbl = UILabel()
        posterLbl.textAlignment = .Center
        posterLbl.textColor = UIColor(white: 0.72, alpha: 1)
        posterLbl.text = LS("上传一个活动海报")
        posterBtn.addSubview(posterLbl)
        posterLbl.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(posterBtn)
        }
        //
        let staticTitleLbl = UILabel()
        staticTitleLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        staticTitleLbl.textColor = UIColor.blackColor()
        staticTitleLbl.text = LS("取一个名字")
        superview.addSubview(staticTitleLbl)
        staticTitleLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(posterBtn.snp_bottom).offset(20)
        }
        // 为了防止外层的tableView的contentOffset被TextField自动更改，这里用一个wrapper来拦截
        let wrapper = UIScrollView()
        super.addSubview(wrapper)
        wrapper.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(staticTitleLbl.snp_bottom).offset(13)
            make.height.equalTo(17)
            make.width.equalTo(superview).multipliedBy(0.8)
        }
        wrapper.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 0.8, 17)
        //
        actNameInput = UITextField()
        actNameInput.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        actNameInput.textColor = UIColor(white: 0.72, alpha: 1)
        actNameInput.placeholder = LS("为活动取一个名字")
        actNameInput.textAlignment = .Center
        wrapper.addSubview(actNameInput)
        actNameInput.frame = CGRectMake(0, 0, wrapper.contentSize.width, 17)
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 11)
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(actNameInput.snp_bottom).offset(6)
            make.height.equalTo(0.5)
        }
        //
        actDesInput = UITextView()
        actDesInput.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        actDesInput.textColor = UIColor(white: 0.72, alpha: 1)
        actDesInput.text = LS("活动描述...")
        superview.addSubview(actDesInput)
        actDesInput.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(sepLine).offset(20)
            make.height.equalTo(90)
        }
        //
        actDesInputWordCount = UILabel()
        actDesInputWordCount.text = "0/40"
        actDesInputWordCount.textColor = UIColor(white: 0.72, alpha: 1)
        actDesInputWordCount.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(actDesInputWordCount)
        actDesInputWordCount.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.bottom.equalTo(actDesInput)
        }
        //
        informOfList = InformOtherUserController()
        informOfList.onInvokeUserSelectController = { (sender: InformOtherUserController) in
            let userSelect = FFSelectController()
            userSelect.delegate = self.releaser
            let nav = BlackBarNavigationController(rootViewController: userSelect)
            self.releaser.presentViewController(nav, animated: true, completion: nil)
        }
        let informOfListView = informOfList.view
        superview.addSubview(informOfListView)
        informOfListView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(actDesInput.snp_bottom).offset(10)
            make.height.equalTo(35)
        }
        //
        informOfListCountLbl = UILabel()
        informOfListCountLbl.textColor = UIColor(white: 0.72, alpha: 1)
        informOfListCountLbl.text = "0/9"
        informOfListCountLbl.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(informOfListCountLbl)
        informOfListCountLbl.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(informOfListView)
        }
        //
    }
    
    /**
     获取需要的高度，在调用这个函数时应当给view设置一个初始的足够大的frame
     
     - returns: 高度值
     */
    func getRequiredHeight() -> CGFloat{
        self.layoutIfNeeded()
        var contentRect = CGRectZero
        for view in self.subviews {
            contentRect = CGRectUnion(contentRect, view.frame)
        }
        return contentRect.height + 10
    }
}
