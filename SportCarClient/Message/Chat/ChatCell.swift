//
//  ChatCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/26.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

let kChatCellTimeMarkSpaceHeight: CGFloat = 25      // 上方的时间标签栏显示时需要占用的高度

protocol ChatCellDelegate: class {
    func avatarPressed(_ chatRecord: ChatRecord)
}


class ChatCell: UITableViewCell {
    
    class func registerCellForTableView(_ tableView: UITableView) {
        tableView.register(self, forCellReuseIdentifier: "text")
        tableView.register(self, forCellReuseIdentifier: "image")
        tableView.register(self, forCellReuseIdentifier: "audio")
    }
    
    weak var delegate: ChatCellDelegate? {
        didSet {
            if let audioBubble = self.bubbleAudio {
                audioBubble.delegate = delegate
            }
        }
    }
    /// 数据
    var chat: ChatRecord?
    var bubbleType: String? {
        get {
            return self.reuseIdentifier
        }
    }
    var isMineBubble: Bool {
        return chat?.senderUser?.isHost ?? false
    }
    var loading: Bool = true {
        didSet {
            
        }
    }
    
    var avatarBtn: UIButton?
    var timeMarkerLbL: UILabel?
    var timeMarkerLine: UIView?
    var displayTimeMarker: Bool = false
    
    var triangle: UIImageView?
    var loadingIndicator: UIActivityIndicatorView?
    
    var bubbleView: UIView?
    var bubbleContentView: UIView?
    let bubbleContentInset = UIEdgeInsetsMake(15, 11, 15, 11)
    
    var bubbleLbL: UILabel? {
        return bubbleContentView as? UILabel
    }
    
    var bubbleImg: UIImageView? {
        return bubbleContentView as? UIImageView
    }
    
    var bubbleAudio: ChatWaveView? {
        return bubbleContentView as? ChatWaveView
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubViews() {
        let superview = self.contentView
        self.backgroundColor = UIColor.clear
        //
        timeMarkerLbL = UILabel()
        timeMarkerLbL?.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightLight)
        timeMarkerLbL?.textColor = UIColor(white: 0.72, alpha: 1)
        timeMarkerLbL?.textAlignment = .center
        timeMarkerLbL?.backgroundColor = UIColor.white
        timeMarkerLbL?.isHidden = true
        superview.addSubview(timeMarkerLbL!)
        timeMarkerLbL?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(superview)
            make.height.equalTo(11)
            make.top.equalTo(superview).offset(10)
        })
        //
        timeMarkerLine = UIView()
        timeMarkerLine?.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(timeMarkerLine!)
        timeMarkerLine?.isHidden = true
        timeMarkerLine?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview).offset(15)
            make.centerX.equalTo(superview)
            make.width.equalTo(145)
            make.height.equalTo(0.5)
        })
        superview.sendSubview(toBack: timeMarkerLine!)
        //
        avatarBtn = UIButton()
        avatarBtn?.layer.cornerRadius = 17.5
        avatarBtn?.clipsToBounds = true
        avatarBtn?.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(avatarBtn!)
        avatarBtn?.addTarget(self, action: #selector(ChatCell.avatarBtnPressed), for: .touchUpInside)
        //
        triangle = UIImageView()
        superview.addSubview(triangle!)
        //
        bubbleView = UIView()
        bubbleView?.layer.cornerRadius = 8
        bubbleView?.clipsToBounds = true
        superview.addSubview(bubbleView!)
        bubbleView?.backgroundColor = UIColor(white: 0.945, alpha: 1)
        //
        if self.reuseIdentifier == "text" {
            let templbl = UILabel()
            templbl.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)
            templbl.textColor = UIColor.black
            templbl.textAlignment = .left
            templbl.numberOfLines = 0
            templbl.lineBreakMode = .byWordWrapping
            bubbleContentView = templbl
            bubbleView?.addSubview(templbl)
        }else if self.reuseIdentifier == "image" {
            let tempImage = UIImageView()
            bubbleContentView = tempImage
            bubbleView?.addSubview(tempImage)
        }else {
            let tempWave = ChatWaveView()
            bubbleContentView = tempWave
            bubbleView?.addSubview(tempWave)
        }
        bubbleContentView?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(bubbleView!).inset(bubbleContentInset)
        })
        //
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        bubbleView?.addSubview(loadingIndicator!)
        loadingIndicator?.snp_makeConstraints(closure: { (make) -> Void in
            make.center.equalTo(bubbleView!)
            make.size.equalTo(30)
        })
        loadingIndicator?.hidesWhenStopped = true
    }
    
    
    func loadDataAndUpdateUI() {
        adjustLayoutAccordingToData()
    }
    
    /**
     根究数据的内容调整布局
     */
    func adjustLayoutAccordingToData() {
        if chat == nil {
            assertionFailure()
        }
        let superview = self.contentView
        // Maximum width of every bubble (not including the tiny triangle)
        let maxBubbleWidth = UIScreen.main.bounds.width - 100
        let isMine = self.isMineBubble
        var timeMarkHeight: CGFloat = 10
        if displayTimeMarker {
            timeMarkHeight = kChatCellTimeMarkSpaceHeight + 10
            // display the timemark
            timeMarkerLine?.isHidden = false
            timeMarkerLbL?.isHidden = false
            timeMarkerLbL?.text = dateDisplay(self.chat!.createdAt!)
        }else{
            timeMarkerLbL?.isHidden = true
            timeMarkerLine?.isHidden = true
        }
        
        if isMine {
            avatarBtn?.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(superview).offset(7.5 + timeMarkHeight)
                make.size.equalTo(35)
                make.right.equalTo(-15)
            })
            triangle?.snp_remakeConstraints(closure: { (make) -> Void in
                make.right.equalTo(avatarBtn!.snp_left).offset(-6)
                make.size.equalTo(10)
                make.centerY.equalTo(superview.snp_top).offset(25 + timeMarkHeight)
            })
            bubbleView?.backgroundColor = UIColor(red: 0.329, green: 0.361, blue: 0.384, alpha: 1)
            triangle?.image = UIImage(named: "chat_triangle_gray")
            bubbleLbL?.textColor = UIColor.white
        }else {
            avatarBtn?.snp_remakeConstraints(closure: { (make) -> Void in
                make.top.equalTo(superview).offset(7.5 + timeMarkHeight)
                make.size.equalTo(35)
                make.left.equalTo(15)
            })
            triangle?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(avatarBtn!.snp_right).offset(6)
                make.size.equalTo(10)
                make.centerY.equalTo(superview.snp_top).offset(25 + timeMarkHeight)
            })
            bubbleView?.backgroundColor = UIColor(white: 0.945, alpha: 1)
            triangle?.image = UIImage(named: "chat_triangle_light_gray")
            bubbleLbL?.textColor = UIColor(red: 0.157, green: 0.173, blue: 0.184, alpha: 1)
        }
        avatarBtn?.kf_setImageWithURL(chat!.senderUser!.avatarURL!, forState: UIControlState())
        var bubbleContentSize = CGSize.zero
        if reuseIdentifier == "text"{
            bubbleLbL?.text = chat?.textContent
            let textSize = bubbleLbL!.sizeThatFits(CGSize(width: maxBubbleWidth - 30, height: CGFloat.greatestFiniteMagnitude))
            bubbleContentSize = textSize
        }else if reuseIdentifier == "image" {
            if chat?.image == nil {
                bubbleImg?.image = chat?.contentImage
                bubbleImg?.setupForImageViewer(nil, backgroundColor: UIColor.black)
            } else {
                guard let imageURL = SFURL(chat!.image!) else {
                    assertionFailure()
                    return
                }
                bubbleImg?.kf_setImageWithURL(imageURL, placeholderImage: nil, optionsInfo: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    if error == nil {
                    self.bubbleImg?.setupForImageViewer(imageURL, backgroundColor: UIColor.black)
                    }
                })
            }
            let imageSize = chat?.imageSize
            var contentSize = CGSize(width: 88 / imageSize!.height * imageSize!.width, height: 88)
            if contentSize.width > maxBubbleWidth - 30 {
                contentSize = CGSize(width: maxBubbleWidth - 30, height: (maxBubbleWidth - 30) / imageSize!.width * imageSize!.height)
            }
            bubbleContentSize = contentSize
        }else{
            bubbleAudio?.chatRecord = chat
            bubbleAudio?.remainingTimeLbl?.textColor = isMine ? UIColor.white : UIColor.black
            bubbleContentSize = CGSize(width: maxBubbleWidth - 30, height: 30)
        }
        if isMine {
            bubbleView?.snp_remakeConstraints(closure: { (make) -> Void in
                make.right.equalTo(triangle!.snp_left).offset(1)
                make.top.equalTo(superview).offset(timeMarkHeight)
                make.size.equalTo(CGSize(width: bubbleContentSize.width + bubbleContentInset.left + bubbleContentInset.right, height: bubbleContentSize.height + bubbleContentInset.top + bubbleContentInset.bottom))
            })
        }else{
            bubbleView?.snp_remakeConstraints(closure: { (make) -> Void in
                make.left.equalTo(triangle!.snp_right).offset(-1)
                make.top.equalTo(superview).offset(timeMarkHeight)
                make.size.equalTo(CGSize(width: bubbleContentSize.width + bubbleContentInset.left + bubbleContentInset.right, height: bubbleContentSize.height + bubbleContentInset.top + bubbleContentInset.bottom))
            })
        }
        // 这一句要放在bubbleView的布局确定之后，否则autolayout会报warning
        bubbleAudio?.processView?.process = chat!.read ? 1 : 0
    }
    
    func avatarBtnPressed() {
        delegate?.avatarPressed(chat!)
    }
    
    class func getContentHeightForChatRecord(_ chat: ChatRecord) -> CGFloat {
        let messageType = chat.messageType
        let maxBubbleContentWidth = UIScreen.main.bounds.width - 100 - 30
        let timeMarkHeight = chat.displayTimeMark ? kChatCellTimeMarkSpaceHeight : 0
        if messageType == "text" {
            if let textSize = chat.textContent?.boundingRect(with: CGSize(width: maxBubbleContentWidth, height: CGFloat.max), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)], context: nil).size {
                return textSize.height + 32 + 10 + timeMarkHeight
            }else {
                assertionFailure()
                return 0
            }
        }else if messageType == "image" {
            if chat.imageWidth == 0 || chat.imageHeight == 0 {
                assertionFailure()
            }
            let imageSize = chat.imageSize
            var contentSize = CGSize(width: 88 / (imageSize?.height)! * (imageSize?.width)!, height: 88)
            if contentSize.width > maxBubbleContentWidth{
                contentSize = CGSize(width: maxBubbleContentWidth , height: maxBubbleContentWidth / (imageSize?.width)! * (imageSize?.height)!)
            }
            return contentSize.height + 32 + 10 + timeMarkHeight
        }else {
            return 72 + timeMarkHeight
        }
    }
}
