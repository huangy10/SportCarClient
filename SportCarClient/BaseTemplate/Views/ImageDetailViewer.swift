//
//  ImageDetailViewer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/3/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol ImageDetailViewDataSource {
    /**
     所有需要展示的图片的数量
     */
    func imageDetailViewNumberOfImages() -> Int
    
    /**
     在第index张图片位置的imageView
     */
    func imageDetailViewForIndex(index: Int) -> UIImageView
    
    /**
     打开页面时第一章展示的图片
    */
    func imageDetailViewInitIndex() -> Int
    
    /**
     打开页面时第一章图片的初始位置
     */
    func imageDetailViewInitFrame() -> CGRect
    
    /**
     初始背景显示
     */
    func imageDetailViewInitBackgroundImage() -> UIImage
}


class ImageDetailView: UIViewController {
    // Should never be nil
    var dataSource: ImageDetailViewDataSource!
    // 实现
    var panGesture: UIPanGestureRecognizer!
    // 实现单机推出
    var tapGesture: UITapGestureRecognizer!
    //
    var curIndexLbl: UILabel!
    var initBg: UIImageView!
    var currentImage: UIImageView?
    var leftImage: UIImageView?
    var rightImage: UIImageView?
    var currentIndex: Int = 0
    var totalNum: Int = 0
    var mulitPage: Bool {
        get {
            return totalNum != 1
        }
    }
    
    func createInitStatus() {
        self.view.backgroundColor = UIColor(red: 0.157, green: 0.172, blue: 0.184, alpha: 1)
        //
        initBg = UIImageView(image: dataSource.imageDetailViewInitBackgroundImage())
        self.view.addSubview(initBg)
        initBg.frame = self.view.bounds
        //
        totalNum = dataSource.imageDetailViewNumberOfImages()
        if totalNum < 1 {
            assertionFailure()
        }
        currentIndex = dataSource.imageDetailViewInitIndex()
        // 当前显示的页面
        currentImage = dataSource.imageDetailViewForIndex(currentIndex)
        currentImage?.contentMode = .ScaleAspectFit
        self.view.addSubview(currentImage!)
        currentImage?.frame = dataSource.imageDetailViewInitFrame()
        // 显示当前位置的
        if totalNum == 0 {
            // 如果总页数只有1页，则不再创建下面的页码
            return
        }
        curIndexLbl = UILabel()
        curIndexLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        curIndexLbl.textColor = UIColor.whiteColor()
        curIndexLbl.textAlignment = .Center
        curIndexLbl.text = "\(curIndexLbl)/\(totalNum)"
        self.view.addSubview(curIndexLbl)
        curIndexLbl.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-10)
        }
    }
    
    func showAnimated() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.initBg.layer.opacity = 0
            self.currentImage!.frame = self.view.bounds
            }) { (_) -> Void in
                self.createAdjacentImages()
        }
    }
    
    func createAdjacentImages() {
        if !mulitPage {
            return
        }
        let width = self.view.frame.width
        let height = self.view.frame.height
        if currentIndex + 1 < totalNum {
            // 右侧还有图片，获取之
            rightImage = dataSource.imageDetailViewForIndex(currentIndex + 1)
            self.view.addSubview(rightImage!)
            rightImage?.frame = CGRectMake(width, 0, width, height)
        }
    }
    
    func goLeft() {
        
    }
    
    func goRight() {
        
    }
}
