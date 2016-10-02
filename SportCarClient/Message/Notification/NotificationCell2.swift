//
//  NotificationCell2.swift
//  SportCarClient
//
//  Created by 黄延 on 16/8/17.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit


protocol NotificationCellDelegate: class {
    func notificationCellAvatarBtnPressed(atCell cell: NotificationCell)
    
    func notificationCellOperationInvoked(atCell cell: NotificationCell, operationType: NotificationCell.OperationType)
}


class NotificationCell: UITableViewCell {
    weak var delegate: NotificationCellDelegate!
    var displayMode: DisplayMode = .minimal {
        didSet {
            let raw = displayMode.rawValue
            cover.isHidden = raw < 1
            detailLbl.isHidden = raw < 1
            agreeBtn.isHidden = raw < 2
            denyBtn.isHidden = raw < 2
            resultLbl.isHidden = raw < 2
            
            titleLbl.snp.remakeConstraints { (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(15)
                make.top.equalTo(avatarBtn).offset(5)
                make.width.equalTo(type(of: self).titleMaxWidthForCurrentScreen(displayMode))
            }
            contentView.layoutIfNeeded()
        }
    }
    
    var avatarBtn: UIButton!
    var titleLbl: UILabel!
    var dateLbl: UILabel!
    var readDot: UIView!
    var cover: UIImageView!
    var detailLbl: UILabel!
    var agreeBtn: UIButton!
    var denyBtn: UIButton!
    var resultLbl: UILabel!
    
    enum OperationType: String{
        case Agree = "agree"
        case Deny = "deny"
    }
    
    enum DisplayMode: Int {
        case minimal = 0, withCover, interact
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        contentView.backgroundColor = UIColor.white
        selectionStyle = .none
        
        configureAvatarBtn()
        configureTitleLbl()
        configureDateLbl()
        configureReadDotView()
        
        configureCover()
        configureDetailLbl()
        
        configureAgreeBtn()
        configureDenyBtn()
        configureResultLbl()
    }
    
    func configureAvatarBtn() {
        let avatarSize: CGFloat = 45
        avatarBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(avatarBtnPressed))
            .toRoundButton(avatarSize / 2)
            .layout({ (make) in
                make.top.equalTo(contentView).offset(15)
                make.left.equalTo(contentView).offset(15)
                make.size.equalTo(avatarSize)
            })
    }
    
    func configureTitleLbl() {
        titleLbl = contentView.addSubview(UILabel.self)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(15)
                make.top.equalTo(avatarBtn).offset(5)
                make.width.equalTo(type(of: self).titleMaxWidthForCurrentScreen(displayMode))
            })
        titleLbl.numberOfLines = 0
        titleLbl.lineBreakMode = .byCharWrapping
    }
    
    func configureDateLbl() {
        dateLbl = contentView.addSubview(UILabel.self)
            .config(10, fontWeight: UIFontWeightUltraLight, textColor: kNotificationHintColor)
            .layout({ (make) in
                make.left.equalTo(titleLbl)
                make.top.equalTo(titleLbl.snp.bottom).offset(5)
            })
    }
    
    func configureReadDotView() {
        readDot = contentView.addSubview(UIView.self).config(kHighlightedRedTextColor)
            .toRound(5).layout({ (make) in
                make.centerX.equalTo(contentView.snp.right).offset(-15)
                make.centerY.equalTo(avatarBtn.snp.top)
                make.size.equalTo(10)
            })
    }
    
    func configureCover() {
        cover = contentView.addSubview(UIImageView.self)
            .layout({ (make) in
                make.right.equalTo(contentView).offset(-15)
                make.centerY.equalTo(avatarBtn)
                make.size.equalTo(avatarBtn)
            })
        contentView.bringSubview(toFront: readDot)
    }
    
    func configureDetailLbl() {
        detailLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightUltraLight)
            .layout({ (make) in
                make.left.equalTo(avatarBtn)
                make.right.equalTo(cover)
                make.top.equalTo(dateLbl.snp.bottom).offset(15)
            })
    }
    
    func configureAgreeBtn() {
        agreeBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(agreeBtnPressed), title: LS("同意"), titleColor: kHighlightedRedTextColor, titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout({ (make) in
                make.centerX.equalTo(contentView.snp.right).offset(-45)
                make.bottom.equalTo(contentView).offset(-15)
                make.size.equalTo(CGSize(width: 44, height: 20))
            })
    }
    
    func configureDenyBtn() {
        denyBtn = contentView.addSubview(UIButton.self)
            .config(self, selector: #selector(denyBtnPressed), title: LS("谢绝"), titleColor: kTextGray, titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout({ (make) in
                make.centerX.equalTo(agreeBtn).offset(-50)
                make.centerY.equalTo(agreeBtn)
                make.size.equalTo(agreeBtn)
            })
    }
    
    func configureResultLbl() {
        resultLbl = contentView.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor.black, textAlignment: .right)
            .layout({ (make) in
                make.centerY.equalTo(agreeBtn)
                make.right.equalTo(cover)
            })
        resultLbl.isHidden = true
    }
    
    func avatarBtnPressed() {
        delegate.notificationCellAvatarBtnPressed(atCell: self)
    }
    
    func agreeBtnPressed() {
        delegate.notificationCellOperationInvoked(atCell: self, operationType: .Agree)
    }
    
    func denyBtnPressed() {
        delegate.notificationCellOperationInvoked(atCell: self, operationType: .Deny)
    }
    
    class func cellHeightForTitle(_ phrases: [String], detailDescription: String, displayMode: DisplayMode) -> CGFloat {
        // 75 是设计图纸中的单行标题时cell的高度，14是单行标题本身的高度
        let staticPartHeight: CGFloat = 75 - 14
        let title = self.makeTitleLblContent(phrases)
        let titleHeight = title.boundingRect(with: CGSize(width: titleMaxWidthForCurrentScreen(displayMode), height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
        
        let minimalHeight = staticPartHeight + titleHeight
        if displayMode == .minimal {
            return minimalHeight
        }
        
        let withCoverHeight: CGFloat
        if detailDescription == "" {
            withCoverHeight = minimalHeight
        } else {
            let detailLblHeight = (detailDescription as NSString).boundingRect(with: CGSize(width: titleMaxWidthForCurrentScreen(displayMode), height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14, weight: UIFontWeightUltraLight)], context: nil).height
            withCoverHeight = minimalHeight + detailLblHeight + 15
        }
        
        if displayMode == .withCover {
            return withCoverHeight
        }
        
        let interactHeight = withCoverHeight + 20 + 15
        return interactHeight
    }
    
    class func titleMaxWidthForCurrentScreen(_ displayMode: DisplayMode) -> CGFloat {
        // 减去的四个个常数分别为：头像距离画面左侧的距离，头像的宽度, 标题离头像的距离，标题离画面右侧的距离
        let widthForMinmal = UIScreen.main.bounds.width - 15 - 45 - 15 - 15
        switch displayMode {
        case .minimal:
            return widthForMinmal
        default:
            // 这里减去的45是右侧封面的宽度，15则是右侧封面和标题之间的距离
            return widthForMinmal - 45 - 15
        }
    }
    
    class func detailMaxWidthForCurrentScreen() -> CGFloat {
        // 这里减去的两个15是详情栏距离屏幕两端的距离
        return UIScreen.main.bounds.width - 15 - 15
    }
    
    
    class func makeTitleLblContent(_ args: [String]) -> NSAttributedString {
        // 利用一组数量可变的参数来构造一定格式的标题，格式的规则是  粗体-细体-粗体-细体... 等粗细交替
        // 返回一个AttributedString
        let wholeSentence = args.joined(separator: " ")
        let result = NSMutableAttributedString(string: wholeSentence)
        var scanLoc: Int = 0
        var index: Int = 0
        for phrase in args {
            // +1 是为了跳过各个短语之间的空格，最后一个元素不加
            let length = (index == args.count - 1) ? phrase.length : (phrase.length + 1)
            result.addAttributes(
                [NSFontAttributeName: getFontForArgsAt(index), NSForegroundColorAttributeName: getTextColorForArgsAt(index)],
                range: NSRange(location: scanLoc, length: length)
            )
            index += 1
            scanLoc += length
        }
        return result
    }
    
    class func getFontForArgsAt(_ index: Int) -> UIFont {
        if index % 2 == 0 {
            return UIFont.systemFont(ofSize: 14, weight: UIFontWeightBlack)
        } else {
            return UIFont.systemFont(ofSize: 12, weight: UIFontWeightUltraLight)
        }
    }
    
    class func getTextColorForArgsAt(_ index: Int) -> UIColor {
        if index % 2 == 0 {
            return UIColor.black
        } else {
            return kNotificationHintColor
        }
    }
    
    func setData(
        _ avatarURL: URL,
        date: Date,
        read: Bool,
        titleContents: [String],
        displayMode: DisplayMode = .minimal
        ) {
        self.displayMode = displayMode
        avatarBtn.kf.setImage(with: avatarURL, for: .normal)
        dateLbl.text = dateDisplay(date)
        titleLbl.attributedText = type(of: self).makeTitleLblContent(titleContents)
        readDot.isHidden = read
    }
    
    func setData(
        _ avatarURL: URL,
        date: Date,
        read: Bool,
        titleContents: [String],
        coverURL: URL?,
        detailDescription: String,
        displayMode: DisplayMode = .withCover
        ) {
        setData(avatarURL, date: date, read: read, titleContents: titleContents, displayMode: displayMode)
        if displayMode.rawValue < DisplayMode.withCover.rawValue {
            return
        }
        if let url = coverURL {
            cover.kf.setImage(with: url)
        }
        detailLbl.text = detailDescription
    }
    
    func setData(
        _ avatarURL: URL,
        date: Date,
        read: Bool,
        titleContents: [String],
        coverURL: URL?,
        detailDescription: String,
        checked: Bool,
        flag: Bool,
        displayMode: DisplayMode = .interact
        ) {
        setData(avatarURL, date: date, read: read, titleContents: titleContents, coverURL: coverURL, detailDescription: detailDescription, displayMode: displayMode)
        if displayMode.rawValue < DisplayMode.interact.rawValue {
            return
        }
        resultLbl.isHidden = !checked
        agreeBtn.isHidden = checked
        denyBtn.isHidden = checked
        if checked {
            resultLbl.text = flag ? LS("已同意") : LS("已拒绝")
        }
    }
}

