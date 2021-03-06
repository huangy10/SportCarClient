//
//  AuthBasic.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/12.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class AuthBasicController: InputableViewController {
    var board: UIScrollView!
    var privilegeBoard: UIView!
    var descriptionLabel: UIView!
    var imagesInputPanel: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navSettings()
    }
    
    func navSettings() {
        self.navigationItem.title = navTitle()
        //
        let navLeftBtn = UIButton()
        navLeftBtn.setImage(UIImage(named: "account_header_back_btn"), for: .normal)
        navLeftBtn.frame = CGRect(x: 0, y: 0, width: 9, height: 15)
        navLeftBtn.addTarget(self, action: #selector(AuthBasicController.navLeftBtnPressed), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navLeftBtn)
        //
        let rightItem = UIBarButtonItem(title: titleForRightNavBtn(), style: .done, target: self, action: #selector(AuthBasicController.navRightBtnPressed))
        rightItem.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular), NSForegroundColorAttributeName: kHighlightedRedTextColor], for: .normal)
        self.navigationItem.rightBarButtonItem = rightItem

    }
    
    func navTitle() -> String {
        assertionFailure()
        return ""
    }
    
    func navRightBtnPressed() {
        assertionFailure()
    }
    
    func navLeftBtnPressed(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func titleForRightNavBtn() -> String{
        assertionFailure()
        return ""
    }
    
    override func createSubviews() {
        super.createSubviews()
        self.view.backgroundColor = UIColor.white
        board = UIScrollView()
        board.showsVerticalScrollIndicator = false
        self.view.addSubview(board)
        board.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
        let superview = board!
        //
        privilegeBoard = createPrivilegeBoard()
        board.addSubview(privilegeBoard)
        privilegeBoard.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.left.equalTo(self.view)
            make.top.equalTo(superview)
            make.height.equalTo(getHeightForPrivilegeBoard())
        }
        //
        descriptionLabel = createDescriptionLabel()
        superview.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.top.equalTo(privilegeBoard.snp.bottom)
            make.height.equalTo(getHeightForDescriptionLable())
        }
        //
        imagesInputPanel = createImagesImputPanel()
        superview.addSubview(imagesInputPanel)
        imagesInputPanel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(15)
            make.right.equalTo(self.view).offset(-15)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(35)
            make.height.equalTo(getHeightForImageInputPanel())
        }
        board.contentSize = CGSize(width: UIScreen.main.bounds.width, height: getHeightForDescriptionLable() + getHeightForImageInputPanel() + getHeightForPrivilegeBoard() + 35)
    }
    
    func createPrivilegeBoard() -> UIView{
        assertionFailure()
        return UIView()
    }
    
    func createDescriptionLabel() -> UIView{
        assertionFailure()
        return UIView()
    }
    
    func createImagesImputPanel() -> UIView {
        assertionFailure()
        return UIView()
    }
    
    func getHeightForDescriptionLable() -> CGFloat {
        assertionFailure()
        return 0
    }
    
    func getHeightForPrivilegeBoard() -> CGFloat {
        assertionFailure()
        return 0
    }
    
    func getHeightForImageInputPanel() -> CGFloat {
        assertionFailure()
        return 0
    }
}
