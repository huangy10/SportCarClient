//
//  ChatBubble.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

enum ChatBubbleType {
    case Text
    case Image
    case Audio
}

class ChatBubbleView: UIView {
    
    var bubbleType: String = "text"
    // 是否本人发送的bubble
    var isMineBubble: Bool = false {
        didSet {
            if isMineBubble {
                triangle?.image = UIImage(named: "chat_triangle_gray")
                triangle?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.right.equalTo(self)
                    make.size.equalTo(10)
                    make.centerY.equalTo(self.snp_top).offset(25)
                })
                container?.backgroundColor = UIColor(red: 0.329, green: 0.361, blue: 0.384, alpha: 1)
                container?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 10))
                })
            }else{
                triangle?.image = UIImage(named: "chat_triangle_light_gray")
                triangle?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.left.equalTo(self)
                    make.size.equalTo(10)
                    make.centerY.equalTo(self.snp_top).offset(25)
                })
                container?.backgroundColor = UIColor(white: 0.945, alpha: 1)
                container?.snp_remakeConstraints(closure: { (make) -> Void in
                    make.edges.equalTo(UIEdgeInsetsMake(0, 10, 0, 0))
                })
            }
        }
    }
    
    var loading: Bool = true {
        didSet {
            if loading {
                loadingIndicator?.startAnimating()
            }else {
                loadingIndicator?.stopAnimating()
            }
        }
    }
    
    var triangle: UIImageView?
    var container: UIView?
    var loadingIndicator: UIActivityIndicatorView?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        triangle = UIImageView(image: UIImage(named: "chat_triangle_light_gray"))
        self.addSubview(triangle!)
        triangle?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(self)
            make.size.equalTo(10)
            make.centerY.equalTo(self.snp_top).offset(25)
        })
        container = UIView()
        container?.backgroundColor = UIColor(white: 0.945, alpha: 1)
        container?.layer.cornerRadius = 20
        self.addSubview(container!)
        container?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(self).inset(UIEdgeInsetsMake(0, 10, 0, 0))
        })
        
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        loadingIndicator?.hidesWhenStopped = true
        self.addSubview(loadingIndicator!)
        loadingIndicator?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(self)
            make.size.equalTo(44)
        })
        loadingIndicator?.startAnimating()
    }
    
    func addContainedContentView(contentView: UIView) {
        self.addSubview(contentView)
        self.bringSubviewToFront(loadingIndicator!)
    }
}


class ChatBubbleCell: UITableViewCell {
    
    ///
    var timeMarkLine: UIView?
    var timeMarkLbl: UILabel?
    /// 头像按钮
    var avatarBtn: UIButton?
    /// 消息显示内容
    var bubble: ChatBubbleView?
    var bubbleWidth: CGFloat = 70       // 这个由外部代理设置
    /// 数据
    var chatRecord: ChatRecord? {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    var bubbleContentView: UIView?
    
    var bubbleImageView: UIImageView? {
        get {
            return bubbleContentView as? UIImageView
        }
    }
    
    var bubbleContentLbl: UILabel? {
        get {
            return bubbleContentView as? UILabel
        }
    }
    /// cell所在的行
    var row: Int = -1 {
        didSet {
            if avatarBtn != nil {
                avatarBtn?.tag = row
            }
        }
    }
    //
    var displayTimeMark: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal func createSubview() {
        
        let superview = self.contentView
        timeMarkLbl = UILabel()
        timeMarkLbl?.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
        timeMarkLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        timeMarkLbl?.textAlignment = .Center
        timeMarkLbl?.backgroundColor = superview.backgroundColor
        superview.addSubview(timeMarkLbl!)
        timeMarkLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(superview)
            make.width.equalTo(44)
            make.top.equalTo(superview)
            make.height.equalTo(11)
        })
        //
        timeMarkLine = UIView()
        timeMarkLine?.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(timeMarkLine!)
        timeMarkLine?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview).offset(5)
            make.width.equalTo(145)
            make.centerX.equalTo(superview)
            make.height.equalTo(0.5)
        })
        superview.sendSubviewToBack(timeMarkLine!)
        //
        avatarBtn = UIButton()
        avatarBtn?.layer.cornerRadius = 17.5
        avatarBtn?.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(avatarBtn!)
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(35)
            make.top.equalTo(superview).offset(33.5)
            make.left.equalTo(superview).offset(15)
        })
        // 
        bubble = ChatBubbleView()
        superview.addSubview(bubble!)
        bubble?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarBtn!.snp_right).offset(7.5)
            make.top.equalTo(avatarBtn!).offset(-7.5)
            make.bottom.equalTo(superview)
            make.width.equalTo(70)
        })
        
        if reuseIdentifier == "text" {
            let contentTextLbl = UILabel()
            bubbleContentView = contentTextLbl as UIView
            bubble?.addContainedContentView(contentTextLbl)
            contentTextLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
            contentTextLbl.textColor = UIColor.blackColor()
            contentTextLbl.textAlignment = .Right
        } else if reuseIdentifier == "image" {
            let contentImage = UIImageView()
            bubbleContentView = contentImage
            bubble?.addContainedContentView(contentImage)
        }
        
        bubbleContentView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(bubbleContentView!.superview!).inset(UIEdgeInsetsMake(15, 11, 15, 11))
        })
    }
    
    internal func loadDataAndUpdateUI() {
        timeMarkLbl?.hidden = !displayTimeMark
        timeMarkLine?.hidden = !displayTimeMark
        
        let superview = self.contentView
        let user = chatRecord?.sender
        
        let isMineBubble = user == User.objects.hostUser
        bubble?.isMineBubble = isMineBubble
        if isMineBubble {
            // 将头像和bubble移到右边
            avatarBtn?.snp_remakeConstraints(closure: { (make) -> Void in
                make.size.equalTo(35)
                make.top.equalTo(superview).offset(displayTimeMark ? 33.5 : 7.5)
                make.left.equalTo(superview).offset(-15)
            })
            bubble?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(avatarBtn!.snp_right).offset(7.5)
                make.top.equalTo(avatarBtn!).offset(-7.5)
                make.bottom.equalTo(superview)
                make.width.equalTo(bubbleWidth)
            })
        }else{
            // 将头像和bubble移到左边
            avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
                make.size.equalTo(35)
                make.top.equalTo(superview).offset(33.5)
                make.left.equalTo(superview).offset(15)
            })
            bubble?.snp_makeConstraints(closure: { (make) -> Void in
                make.left.equalTo(avatarBtn!.snp_right).offset(7.5)
                make.top.equalTo(avatarBtn!).offset(-7.5)
                make.bottom.equalTo(superview)
                make.width.equalTo(70)
            })
        }
        
        avatarBtn?.kf_setImageWithURL(SFURL(user!.avatarUrl!)!, forState: .Normal)
        if chatRecord?.messageType == "text" {
            self.bubbleContentLbl?.text = chatRecord?.textContent
            self.bubble?.loading = false
        }else if chatRecord?.messageType == "image" {
            self.bubbleImageView?.kf_setImageWithURL(SFURL(self.chatRecord!.image!)!, placeholderImage: nil, optionsInfo: [], completionHandler: { (image, error, cacheType, imageURL) -> () in
                self.bubble?.loading = false
            })
        }
    }
    
    class func getBubbleSizeForChatRecord(chatRecord: ChatRecord) -> CGSize {
        return CGSizeZero
    }
}