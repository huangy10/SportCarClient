//
//  TaggedContainer
//  SportCarClient
//
//  Created by 黄延 on 2016/10/29.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


class TaggedContainer: UIViewController {
    weak var homeDelegate: HomeDelegate?
    
    var ctrlCount: Int {
        return numberOfCountrollers()
    }
    var arrangedControllers: [UIViewController] = []
    var titleLbls: [UILabel] = []
    var board: UIScrollView!
    var homeBtn: BackToHomeBtn!
    var barTitleIcon: UIImageView!
    
    var curTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        configureBoard()
        configureControllers()
    }
    
    func numberOfCountrollers() -> Int {
        fatalError("Not implemented")
    }
    
    func createArrangedController() -> [UIViewController] {
        fatalError("Not implemented")
    }
    
    func titleForController(at index: Int)  -> String {
        fatalError("Not implemented")
    }
    
    func firstSelectedTag() -> Int {
        return 0
    }
    
    func titleLblColor(forSelected selected: Bool) -> UIColor {
        return selected ? kTextGray87 : kTextGray54
    }
    
    func configureNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        configureHomeBtn()
        configureNavRightBtn()
        configureTitleBtns()
    }
    
    func configureHomeBtn() {
        homeBtn = BackToHomeBtn()
        homeBtn.addTarget(self, action: #selector(homeBtnPressed), for: .touchUpInside)
        navigationItem.leftBarButtonItem = homeBtn.wrapToBarBtn()
    }
    
    func configureNavRightBtn() {
        // implement this in subclasses
    }
    
    func configureTitleBtns() {
        let barHeight = navigationController!.navigationBar.frame.height
        let count = ctrlCount
        let container = UIStackView()
        let titleBtnWidth: CGFloat = 70
        let containerWidth = titleBtnWidth * CGFloat(count)
        container.spacing = 0
        container.alignment = .center
        container.axis = .horizontal
        container.distribution = .fillEqually
        container.frame = CGRect(x: 0, y: 0, width: containerWidth, height: barHeight)
        
        (0..<count).forEach { (idx) in
            let btn = UIButton()
            btn.tag = idx
            btn.addTarget(self, action: #selector(titleBtnPressed(sender:)), for: .touchUpInside)
            container.addArrangedSubview(btn)
            btn.autoresizingMask = .flexibleHeight
//            btn.snp.makeConstraints({ (make) in
//                make.top.equalTo(container)
//                make.height.equalTo(container)
//            })
            self.titleLbls.append(btn.addSubview(UILabel.self).config(15, fontWeight: UIFontWeightSemibold, textColor: titleLblColor(forSelected: idx == firstSelectedTag()), textAlignment: .center, text: titleForController(at: idx))
                .layout({ (make) in
                    make.center.equalTo(btn)
                    make.size.equalTo(titleLblSize(forContent: titleForController(at: idx)))
                }))
        }
        
        let alignedTo = titleLbls[firstSelectedTag()]
        
        barTitleIcon = UIImageView(image: UIImage(named: "nav_title_btn_icon"))
        container.addSubview(barTitleIcon)
        container.sendSubview(toBack: barTitleIcon)
        barTitleIcon.snp.makeConstraints { (make) in
            make.left.equalTo(alignedTo)
            make.right.equalTo(alignedTo)
            make.bottom.equalTo(container)
            make.height.equalTo(2.5)
        }
        self.navigationItem.titleView = container
        curTag = firstSelectedTag()
    }
    
    func titleLblSize(forContent text: String) -> CGSize {
        return " \(text) ".sizeWithFont(UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold), boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
    }
    
    func configureBoard() {
        board = UIScrollView()
        view.addSubview(board)
        board.isPagingEnabled = true
        board.isScrollEnabled = false
        
        let width = view.bounds.width
        board.contentSize = CGSize(width: CGFloat(ctrlCount) * width, height: 0)
        board.setContentOffset(CGPoint(x: CGFloat(firstSelectedTag()) * width, y: 0), animated: false)
        
//        board.snp.makeConstraints { (make) in
//            make.edges.equalTo(view)
//        }
        var rect = view.bounds
        rect.size.height -= 44 + 22
        board.frame = view.bounds
    }
    
    func configureControllers() {
        arrangedControllers = createArrangedController()
        let width = UIScreen.main.bounds.width
        // minus the height of the navigationBar and the status bar
        let height = view.bounds.height - 44 - 20
        for (idx, ctl) in arrangedControllers.enumerated() {
            addChildViewController(ctl)
            ctl.view.frame = CGRect(x: width * CGFloat(idx), y: 0, width: width , height: height)
            board.addSubview(ctl.view)
            ctl.didMove(toParentViewController: self)
        }
        
        let firstSelected = firstSelectedTag()
        if firstSelected != 0 {
            board.setContentOffset(CGPoint(x: width * CGFloat(firstSelected), y: 0), animated: false)
        }
    }
    
    func titleBtnPressed(sender: UIButton) {
        if sender.tag == curTag {
            return
        }
        
        arrangedControllers[curTag].viewWillDisappear(true)
        arrangedControllers[sender.tag].viewWillAppear(true)
        
        titleLbls[curTag].textColor = titleLblColor(forSelected: false)
        titleLbls[sender.tag].textColor = titleLblColor(forSelected: true)
        
        barTitleIcon.snp.remakeConstraints { (make) in
            make.bottom.equalTo(barTitleIcon.superview!)
            make.left.equalTo(titleLbls[sender.tag])
            make.right.equalTo(titleLbls[sender.tag])
            make.height.equalTo(2.5)
        }
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.barTitleIcon.superview?.layoutIfNeeded()
        })
        
        board.setContentOffset(CGPoint(x: view.frame.width * CGFloat(sender.tag), y: 0), animated: true)
        curTag = sender.tag
    }
    
    func homeBtnPressed() {
        homeDelegate?.backToHome(nil)
    }
}

