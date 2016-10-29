//
//  CommentPanel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/9.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

class CommentBarView: UIView {
    
    /*
    ==============================================================================================================================
    */
    var commentIcon: UIImageView?
    var contentInput: UITextView?
    var shareBtn: UIButton?
    var shareBtnHidden: Bool = false{
        didSet {
            if shareBtnHidden {
                shareBtn?.isHidden = true
                likeBtn?.snp.remakeConstraints({ (make) -> Void in
                    make.size.equalTo(barheight * 0.76)
                    make.bottom.equalTo(self).offset(-5)
                    make.right.equalTo(self).offset(-15)
                })
            }else {
                assertionFailure()
            }
        }
    }
    var likeBtn: UIButton?
    var likeBtnIcon: UIImageView!
    
    let barheight: CGFloat = 45
    
    fileprivate var frameFirstSet: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubivews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    func setOriginY(_ y: CGFloat) {
        if frameFirstSet {
            frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: barheight)
        } else {
            let oldFrame = frame
            frame = CGRect(x: 0, y: y, width: UIScreen.main.bounds.width, height: oldFrame.height)
            frameFirstSet = false
        }
    }
    
    func setBarHeight(_ height: CGFloat) {
        var oldFrame = frame
        let validHeight = max(height, barheight)
        oldFrame.origin.y = oldFrame.origin.y + oldFrame.height - validHeight
        oldFrame.size.height = validHeight
        frame = oldFrame
    }
    
    func restBarHeight() {
        var oldFrame = frame
        oldFrame.size.height = barheight
        frame = oldFrame
    }
    
    func createSubivews() {
        self.backgroundColor = UIColor(white: 0.92, alpha: 1)
        //
        let contentHeight = barheight * 0.76
        shareBtn = UIButton()
        shareBtn?.backgroundColor = UIColor.white
        shareBtn?.layer.cornerRadius = contentHeight * 0.5
        self.addSubview(shareBtn!)
        shareBtn?.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(self).offset(-15)
        })
        //
        let shareBtnIcon = UIImageView(image: UIImage(named: "news_share"))
        shareBtnIcon.contentMode = .scaleAspectFit
        shareBtn?.addSubview(shareBtnIcon)
        shareBtnIcon.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(15)
            make.center.equalTo(shareBtn!)
        }
        //
        likeBtn = UIButton()
        likeBtn?.layer.cornerRadius = contentHeight * 0.5
        likeBtn?.backgroundColor = UIColor.white
        self.addSubview(likeBtn!)
        likeBtn?.snp.makeConstraints({ (make) -> Void in
            make.size.equalTo(contentHeight)
            make.bottom.equalTo(self).offset(-5)
            make.right.equalTo(shareBtn!.snp.left).offset(-9)
        })
        //
        likeBtnIcon = UIImageView(image: UIImage(named: "news_like_unliked"))
        likeBtn?.addSubview(likeBtnIcon)
        likeBtnIcon.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(17)
            make.center.equalTo(likeBtn!)
        }
        //
        let roundCornerContainer = UIView()
        roundCornerContainer.backgroundColor = UIColor.white
        roundCornerContainer.layer.cornerRadius = contentHeight / 2
        self.addSubview(roundCornerContainer)
        roundCornerContainer.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(likeBtn!.snp.left).offset(-9)
            make.top.equalTo(self).offset(5)
            make.left.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-5)
        }
        //
        commentIcon = UIImageView(image: UIImage(named: "news_comment_icon"))
        roundCornerContainer.addSubview(commentIcon!)
        commentIcon?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(18)
            make.top.equalTo(roundCornerContainer).offset(9)
            make.size.equalTo(20)
        })
        //
        contentInput = UITextView()
        contentInput?.returnKeyType = .done
        contentInput?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        contentInput?.textColor = UIColor.black
        roundCornerContainer.addSubview(contentInput!)
        contentInput?.snp.makeConstraints({ (make) -> Void in
            make.left.equalTo(commentIcon!.snp.right).offset(10)
            make.right.equalTo(roundCornerContainer).offset(-18)
            make.top.equalTo(roundCornerContainer)
            make.bottom.equalTo(roundCornerContainer)
        })
    }
    
    func setLikedAnimated(_ liked: Bool, flag: Bool = true) {
        if liked {
            likeBtnIcon.image = UIImage(named: "news_like_liked")
            if flag {
                likeBtnIcon.transform = CGAffineTransform.identity
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 140, options: UIViewAnimationOptions(), animations: { () -> Void in
                    self.likeBtnIcon.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }, completion: nil)
            }
        }else {
            likeBtnIcon.image = UIImage(named: "news_like_unliked")
        }
    }
}
