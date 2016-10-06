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
        self.backgroundColor = UIColor.white
        //
        posterBtn = UIButton()
        superview.addSubview(posterBtn)
        posterBtn.setImage(UIImage(named: "activity_release_default_cover"), for: .normal)
        posterBtn.imageView?.contentMode = .scaleAspectFill
        posterBtn.clipsToBounds = true
        posterBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.top.equalTo(superview)
            make.left.equalTo(superview)
            make.height.equalTo(posterBtn.snp.width).multipliedBy(0.573)
        }
        
        posterLbl = UILabel()
        posterLbl.textAlignment = .center
        posterLbl.textColor = UIColor(white: 0.72, alpha: 1)
        posterLbl.font = UIFont.systemFont(ofSize: 12)
        posterLbl.text = LS("上传一个活动海报")
        posterBtn.addSubview(posterLbl)
        posterLbl.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(posterBtn)
        }
        //
        let staticTitleLbl = UILabel()
        staticTitleLbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightSemibold)
        staticTitleLbl.textColor = UIColor.black
        staticTitleLbl.text = LS("取一个名字")
        superview.addSubview(staticTitleLbl)
        staticTitleLbl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(posterBtn.snp.bottom).offset(20)
        }
        // 为了防止外层的tableView的contentOffset被TextField自动更改，这里用一个wrapper来拦截
        let wrapper = UIScrollView()
        super.addSubview(wrapper)
        wrapper.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(superview)
            make.top.equalTo(staticTitleLbl.snp.bottom).offset(13)
            make.height.equalTo(24)
            make.width.equalTo(superview).multipliedBy(0.8)
        }
        wrapper.contentSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: 17)
        //
        actNameInput = UITextField()
        actNameInput.font = UIFont.systemFont(ofSize: 19, weight: UIFontWeightUltraLight)
        actNameInput.textColor = UIColor(white: 0.72, alpha: 1)
        actNameInput.placeholder = LS("为活动取一个名字")
        actNameInput.textAlignment = .center
        wrapper.addSubview(actNameInput)
        actNameInput.frame = CGRect(x: 0, y: 0, width: wrapper.contentSize.width, height: 24)
        //
        let sepLine = UIView()
        sepLine.backgroundColor = UIColor(white: 0.933, alpha: 11)
        superview.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(actNameInput.snp.bottom).offset(6)
            make.height.equalTo(0.5)
        }
        //
        actDesInput = UITextView()
        actDesInput.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
        actDesInput.textColor = UIColor(white: 0.72, alpha: 1)
        actDesInput.text = LS("活动描述...")
        superview.addSubview(actDesInput)
        actDesInput.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(sepLine).offset(20)
            make.height.equalTo(90)
        }
        //
        actDesInputWordCount = UILabel()
        actDesInputWordCount.text = "0/40"
        actDesInputWordCount.textColor = UIColor(white: 0.72, alpha: 1)
        actDesInputWordCount.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(actDesInputWordCount)
        actDesInputWordCount.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.bottom.equalTo(actDesInput)
        }
        //
        informOfList = InformOtherUserController()
        informOfList.onInvokeUserSelectController = { (sender: InformOtherUserController) in
            let userSelect = FFSelectController()
            userSelect.delegate = self.releaser
            let nav = BlackBarNavigationController(rootViewController: userSelect)
            self.releaser.present(nav, animated: true, completion: nil)
        }
        let informOfListView = informOfList.view
        superview.addSubview(informOfListView!)
        informOfListView!.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview)
            make.left.equalTo(superview)
            make.top.equalTo(actDesInput.snp.bottom).offset(10)
            make.height.equalTo(35)
        }
        //
        informOfListCountLbl = UILabel()
        informOfListCountLbl.textColor = UIColor(white: 0.72, alpha: 1)
        informOfListCountLbl.text = "0/9"
        informOfListCountLbl.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        superview.addSubview(informOfListCountLbl)
        informOfListCountLbl.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.centerY.equalTo(informOfListView!)
        }
        //
    }
    
    /**
     获取需要的高度，在调用这个函数时应当给view设置一个初始的足够大的frame
     
     - returns: 高度值
     */
    func getRequiredHeight() -> CGFloat{
        self.layoutIfNeeded()
        var contentRect = CGRect.zero
        for view in self.subviews {
            contentRect = contentRect.union(view.frame)
        }
        return contentRect.height + 10
    }
}
