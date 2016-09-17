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


//class NotificationBaseCell2: UITableViewCell {
//    
//    weak var delegate: NotificationCellDelegate!
//    
//    var avatarBtn: UIButton!
//    var titleLbl: UILabel!
//    var dateLbl: UILabel!
//    var readDot: UIView!
//    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        createSubviews()
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func createSubviews() {
//        contentView.backgroundColor = UIColor.whiteColor()
//        
//        configureAvatarBtn()
//        configureTitleLbl()
//        configureDateLbl()
//        configureReadDotView()
//    }
//    
//    func configureAvatarBtn() {
//        let avatarSize: CGFloat = 45
//        avatarBtn = contentView.addSubview(UIButton)
//            .config(self, selector: #selector(avatarBtnPressed))
//            .toRoundButton(avatarSize / 2)
//            .layout({ (make) in
//                make.top.equalTo(contentView).offset(15)
//                make.left.equalTo(contentView).offset(15)
//                make.size.equalTo(avatarSize)
//            })
//    }
//    
//    func configureTitleLbl() {
//        titleLbl = contentView.addSubview(UILabel)
//            .layout({ (make) in
//                make.left.equalTo(avatarBtn.snp_right).offset(15)
//                make.top.equalTo(avatarBtn).offset(5)
//                make.width.equalTo(self.dynamicType.titleMaxWidthForCurrentScreen())
//            })
//        titleLbl.numberOfLines = 0
//        titleLbl.lineBreakMode = .ByCharWrapping
//    }
//    
//    func configureDateLbl() {
//        dateLbl = contentView.addSubview(UILabel)
//            .config(10, fontWeight: UIFontWeightUltraLight, textColor: kNotificationHintColor)
//            .layout({ (make) in
//                make.left.equalTo(titleLbl)
//                make.top.equalTo(titleLbl.snp_bottom).offset(5)
//            })
//    }
//    
//    func configureReadDotView() {
//        readDot = contentView.addSubview(UIView).config(kHighlightedRedTextColor)
//            .toRound(5).layout({ (make) in
//                make.centerX.equalTo(contentView.snp_right).offset(-15)
//                make.centerY.equalTo(avatarBtn.snp_top)
//                make.size.equalTo(10)
//            })
//    }
//    
//    func avatarBtnPressed() {
//        delegate.notificationCellAvatarBtnPressed(atCell: self)
//    }
//    
//    func setData(avatarURL: NSURL, date: NSDate, read: Bool, titleContents: [String]) {
//        avatarBtn.kf_setImageWithURL(avatarURL, forState: .Normal)
//        dateLbl.text = dateDisplay(date)
//        titleLbl.attributedText = self.dynamicType.makeTitleLblContent(titleContents)
//        readDot.hidden = read
//    }
//    
//    class func cellHeightForTitle(phrases: [String]) -> CGFloat {
//        // 75 是设计图纸中的单行标题时cell的高度，14是单行标题本身的高度
//        let staticPartHeight: CGFloat = 75 - 14
//        let title = self.makeTitleLblContent(phrases)
//        let titleHeight = title.boundingRectWithSize(CGSizeMake(titleMaxWidthForCurrentScreen(), CGFloat.max), options: .UsesLineFragmentOrigin, context: nil).height
//        return staticPartHeight + titleHeight
//    }
//    
//    class func titleMaxWidthForCurrentScreen() -> CGFloat {
//        // 减去的四个个常数分别为：头像距离画面左侧的距离，头像的宽度, 标题离头像的距离，标题离画面右侧的距离
//        return UIScreen.mainScreen().bounds.width - 15 - 45 - 15 - 15
//    }
//    
//    class func makeTitleLblContent(args: [String]) -> NSAttributedString {
//        // 利用一组数量可变的参数来构造一定格式的标题，格式的规则是  粗体-细体-粗体-细体... 等粗细交替
//        // 返回一个AttributedString
//        let wholeSentence = args.joinWithSeparator(" ")
//        let result = NSMutableAttributedString(string: wholeSentence)
//        var scanLoc: Int = 0
//        var index: Int = 0
//        for phrase in args {
//            // +1 是为了跳过各个短语之间的空格，最后一个元素不加
//            let length = (index == args.count - 1) ? phrase.length : (phrase.length + 1)
//            result.addAttributes(
//                [NSFontAttributeName: getFontForArgsAt(index), NSForegroundColorAttributeName: getTextColorForArgsAt(index)],
//                range: NSRange(location: scanLoc, length: length)
//            )
//            index += 1
//            scanLoc += length
//        }
//        return result
//    }
//    
//    class func getFontForArgsAt(index: Int) -> UIFont {
//        if index % 2 == 0 {
//            return UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
//        } else {
//            return UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
//        }
//    }
//    
//    class func getTextColorForArgsAt(index: Int) -> UIColor {
//        if index % 2 == 0 {
//            return UIColor.blackColor()
//        } else {
//            return kNotificationHintColor
//        }
//    }
//}
//
//class NotificationDetailedCell: NotificationBaseCell2 {
//    var cover: UIImageView!
//    var detailLbl: UILabel!
//    
//    override func createSubviews() {
//        super.createSubviews()
//        configureCover()
//        configureDetailLbl()
//    }
//    
//    func setData(
//        avatarURL: NSURL,
//        date: NSDate,
//        read: Bool,
//        titleContents: [String],
//        coverURL: NSURL,
//        detailDescription: String
//        ) {
//        setData(avatarURL, date: date, read: read, titleContents: titleContents)
//        cover.kf_setImageWithURL(coverURL)
//        detailLbl.text = detailDescription
//    }
//    
//    func configureCover() {
//        cover = contentView.addSubview(UIImageView)
//            .layout({ (make) in
//                make.right.equalTo(contentView).offset(-15)
//                make.centerY.equalTo(avatarBtn)
//                make.size.equalTo(avatarBtn)
//            })
//        contentView.bringSubviewToFront(readDot)
//    }
//    
//    func configureDetailLbl() {
//        detailLbl = contentView.addSubview(UILabel)
//            .config(14, fontWeight: UIFontWeightUltraLight)
//            .layout({ (make) in
//                make.left.equalTo(avatarBtn)
//                make.right.equalTo(cover)
//                make.top.equalTo(dateLbl.snp_bottom).offset(15)
//            })
//    }
//    
//    override class func titleMaxWidthForCurrentScreen() -> CGFloat {
//        // 这里减去的45是右侧封面的宽度，15则是右侧封面和标题之间的距离
//        return super.titleMaxWidthForCurrentScreen() - 45 - 15
//    }
//    
//    class func detailMaxWidthForCurrentScreen() -> CGFloat {
//        // 这里减去的两个15是详情栏距离屏幕两端的距离
//        return UIScreen.mainScreen().bounds.width - 15 - 15
//    }
//    
//    class func cellHeightForTitle(phrases: [String], detailDescription: String) -> CGFloat {
//        // 这里加的15是详情和日期之间的纵向距离
//        let height: CGFloat
//            
//        if detailDescription == "" {
//            height = cellHeightForTitle(phrases)
//        } else {
//            let detailLblHeight = (detailDescription as NSString).boundingRectWithSize(CGSizeMake(titleMaxWidthForCurrentScreen(), CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)], context: nil).height
//            height = cellHeightForTitle(phrases) + detailLblHeight + 15
//        }
//        
//        return height
//    }
//}
//
//class NotificationInteractCell: NotificationDetailedCell {
//    var agreeBtn: UIButton!
//    var denyBtn: UIButton!
//    var resultLbl: UILabel!
//    
//    enum OperationType {
//        case AGREE, DENY
//    }
//    
//    override func createSubviews() {
//        super.createSubviews()
//        configureAgreeBtn()
//        configureDenyBtn()
//        configureResultLbl()
//    }
//    
//    func configureAgreeBtn() {
//        agreeBtn = contentView.addSubview(UIButton)
//            .config(self, selector: #selector(agreeBtnPressed), title: LS("同意"), titleColor: kHighlightedRedTextColor, titleSize: 14, titleWeight: UIFontWeightRegular)
//            .layout({ (make) in
//                make.centerX.equalTo(contentView.snp_right).offset(-45)
//                make.bottom.equalTo(contentView).offset(-15)
//                make.size.equalTo(CGSizeMake(44, 20))
//            })
//    }
//    
//    func configureDenyBtn() {
//        denyBtn = contentView.addSubview(UIButton)
//            .config(self, selector: #selector(denyBtnPressed), title: LS("谢绝"), titleColor: kTextGray, titleSize: 14, titleWeight: UIFontWeightRegular)
//            .layout({ (make) in
//                make.centerX.equalTo(agreeBtn).offset(-50)
//                make.centerY.equalTo(agreeBtn)
//                make.size.equalTo(agreeBtn)
//            })
//    }
//    
//    func configureResultLbl() {
//        resultLbl = contentView.addSubview(UILabel)
//            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor.blackColor(), textAlignment: .Right)
//            .layout({ (make) in
//                make.edges.equalTo(agreeBtn)
//            })
//        resultLbl.hidden = true
//    }
//    
//    /**
//     设置cell 的数据
//     
//     - parameter checked:           这个cell对应的操作是否已经处理
//     - parameter flag:              处理的结果（选择的是同意(true)还是谢绝(false),当checked为false时，这个值会被忽略
//     */
//    func setData(
//        avatarURL: NSURL,
//        date: NSDate,
//        read: Bool,
//        titleContents: [String],
//        coverURL: NSURL,
//        detailDescription: String,
//        checked: Bool,
//        flag: Bool
//        ) {
//        setData(avatarURL, date: date, read: read, titleContents: titleContents, coverURL: coverURL, detailDescription: detailDescription)
//        resultLbl.hidden = !checked
//        agreeBtn.hidden = checked
//        denyBtn.hidden = checked
//        if checked {
//            resultLbl.text = flag ? LS("已同意") : LS("已拒绝")
//        }
//    }
//    
//    override func setData(avatarURL: NSURL, date: NSDate, read: Bool, titleContents: [String]) {
//        super.setData(avatarURL, date: date, read: read, titleContents: titleContents)
//    }
//    
//    func agreeBtnPressed() {
//        delegate.notificationCellOperationInvoked(atCell: self, operationType: .AGREE)
//    }
//    
//    func denyBtnPressed() {
//        delegate.notificationCellOperationInvoked(atCell: self, operationType: .DENY)
//    }
//    
//    override class func cellHeightForTitle(phrases: [String], detailDescription: String) -> CGFloat {
//        // 这里加的20是下面按钮的高度，15是按钮和详情之间的距离
//        return super.cellHeightForTitle(phrases, detailDescription: detailDescription) + 20 + 15
//    }
//}

class NotificationCell: UITableViewCell {
    weak var delegate: NotificationCellDelegate!
    var displayMode: DisplayMode = .Minimal {
        didSet {
            let raw = displayMode.rawValue
            cover.hidden = raw < 1
            detailLbl.hidden = raw < 1
            agreeBtn.hidden = raw < 2
            denyBtn.hidden = raw < 2
            resultLbl.hidden = raw < 2
            
            titleLbl.snp_remakeConstraints { (make) in
                make.left.equalTo(avatarBtn.snp_right).offset(15)
                make.top.equalTo(avatarBtn).offset(5)
                make.width.equalTo(self.dynamicType.titleMaxWidthForCurrentScreen(displayMode))
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
        case Minimal = 0, WithCover, Interact
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        contentView.backgroundColor = UIColor.whiteColor()
        selectionStyle = .None
        
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
        avatarBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(avatarBtnPressed))
            .toRoundButton(avatarSize / 2)
            .layout({ (make) in
                make.top.equalTo(contentView).offset(15)
                make.left.equalTo(contentView).offset(15)
                make.size.equalTo(avatarSize)
            })
    }
    
    func configureTitleLbl() {
        titleLbl = contentView.addSubview(UILabel)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp_right).offset(15)
                make.top.equalTo(avatarBtn).offset(5)
                make.width.equalTo(self.dynamicType.titleMaxWidthForCurrentScreen(displayMode))
            })
        titleLbl.numberOfLines = 0
        titleLbl.lineBreakMode = .ByCharWrapping
    }
    
    func configureDateLbl() {
        dateLbl = contentView.addSubview(UILabel)
            .config(10, fontWeight: UIFontWeightUltraLight, textColor: kNotificationHintColor)
            .layout({ (make) in
                make.left.equalTo(titleLbl)
                make.top.equalTo(titleLbl.snp_bottom).offset(5)
            })
    }
    
    func configureReadDotView() {
        readDot = contentView.addSubview(UIView).config(kHighlightedRedTextColor)
            .toRound(5).layout({ (make) in
                make.centerX.equalTo(contentView.snp_right).offset(-15)
                make.centerY.equalTo(avatarBtn.snp_top)
                make.size.equalTo(10)
            })
    }
    
    func configureCover() {
        cover = contentView.addSubview(UIImageView)
            .layout({ (make) in
                make.right.equalTo(contentView).offset(-15)
                make.centerY.equalTo(avatarBtn)
                make.size.equalTo(avatarBtn)
            })
        contentView.bringSubviewToFront(readDot)
    }
    
    func configureDetailLbl() {
        detailLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightUltraLight)
            .layout({ (make) in
                make.left.equalTo(avatarBtn)
                make.right.equalTo(cover)
                make.top.equalTo(dateLbl.snp_bottom).offset(15)
            })
    }
    
    func configureAgreeBtn() {
        agreeBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(agreeBtnPressed), title: LS("同意"), titleColor: kHighlightedRedTextColor, titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout({ (make) in
                make.centerX.equalTo(contentView.snp_right).offset(-45)
                make.bottom.equalTo(contentView).offset(-15)
                make.size.equalTo(CGSizeMake(44, 20))
            })
    }
    
    func configureDenyBtn() {
        denyBtn = contentView.addSubview(UIButton)
            .config(self, selector: #selector(denyBtnPressed), title: LS("谢绝"), titleColor: kTextGray, titleSize: 14, titleWeight: UIFontWeightRegular)
            .layout({ (make) in
                make.centerX.equalTo(agreeBtn).offset(-50)
                make.centerY.equalTo(agreeBtn)
                make.size.equalTo(agreeBtn)
            })
    }
    
    func configureResultLbl() {
        resultLbl = contentView.addSubview(UILabel)
            .config(14, fontWeight: UIFontWeightRegular, textColor: UIColor.blackColor(), textAlignment: .Right)
            .layout({ (make) in
                make.centerY.equalTo(agreeBtn)
                make.right.equalTo(cover)
            })
        resultLbl.hidden = true
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
    
    class func cellHeightForTitle(phrases: [String], detailDescription: String, displayMode: DisplayMode) -> CGFloat {
        // 75 是设计图纸中的单行标题时cell的高度，14是单行标题本身的高度
        let staticPartHeight: CGFloat = 75 - 14
        let title = self.makeTitleLblContent(phrases)
        let titleHeight = title.boundingRectWithSize(CGSizeMake(titleMaxWidthForCurrentScreen(displayMode), CGFloat.max), options: .UsesLineFragmentOrigin, context: nil).height
        
        let minimalHeight = staticPartHeight + titleHeight
        if displayMode == .Minimal {
            return minimalHeight
        }
        
        let withCoverHeight: CGFloat
        if detailDescription == "" {
            withCoverHeight = minimalHeight
        } else {
            let detailLblHeight = (detailDescription as NSString).boundingRectWithSize(CGSizeMake(titleMaxWidthForCurrentScreen(displayMode), CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)], context: nil).height
            withCoverHeight = minimalHeight + detailLblHeight + 15
        }
        
        if displayMode == .WithCover {
            return withCoverHeight
        }
        
        let interactHeight = withCoverHeight + 20 + 15
        return interactHeight
    }
    
    class func titleMaxWidthForCurrentScreen(displayMode: DisplayMode) -> CGFloat {
        // 减去的四个个常数分别为：头像距离画面左侧的距离，头像的宽度, 标题离头像的距离，标题离画面右侧的距离
        let widthForMinmal = UIScreen.mainScreen().bounds.width - 15 - 45 - 15 - 15
        switch displayMode {
        case .Minimal:
            return widthForMinmal
        default:
            // 这里减去的45是右侧封面的宽度，15则是右侧封面和标题之间的距离
            return widthForMinmal - 45 - 15
        }
    }
    
    class func detailMaxWidthForCurrentScreen() -> CGFloat {
        // 这里减去的两个15是详情栏距离屏幕两端的距离
        return UIScreen.mainScreen().bounds.width - 15 - 15
    }
    
    
    class func makeTitleLblContent(args: [String]) -> NSAttributedString {
        // 利用一组数量可变的参数来构造一定格式的标题，格式的规则是  粗体-细体-粗体-细体... 等粗细交替
        // 返回一个AttributedString
        let wholeSentence = args.joinWithSeparator(" ")
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
    
    class func getFontForArgsAt(index: Int) -> UIFont {
        if index % 2 == 0 {
            return UIFont.systemFontOfSize(14, weight: UIFontWeightBlack)
        } else {
            return UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        }
    }
    
    class func getTextColorForArgsAt(index: Int) -> UIColor {
        if index % 2 == 0 {
            return UIColor.blackColor()
        } else {
            return kNotificationHintColor
        }
    }
    
    func setData(
        avatarURL: NSURL,
        date: NSDate,
        read: Bool,
        titleContents: [String],
        displayMode: DisplayMode = .Minimal
        ) {
        self.displayMode = displayMode
        avatarBtn.kf_setImageWithURL(avatarURL, forState: .Normal)
        dateLbl.text = dateDisplay(date)
        titleLbl.attributedText = self.dynamicType.makeTitleLblContent(titleContents)
        readDot.hidden = read
    }
    
    func setData(
        avatarURL: NSURL,
        date: NSDate,
        read: Bool,
        titleContents: [String],
        coverURL: NSURL?,
        detailDescription: String,
        displayMode: DisplayMode = .WithCover
        ) {
        setData(avatarURL, date: date, read: read, titleContents: titleContents, displayMode: displayMode)
        if displayMode.rawValue < DisplayMode.WithCover.rawValue {
            return
        }
        if let url = coverURL {
            cover.kf_setImageWithURL(url)
        }
        detailLbl.text = detailDescription
    }
    
    func setData(
        avatarURL: NSURL,
        date: NSDate,
        read: Bool,
        titleContents: [String],
        coverURL: NSURL?,
        detailDescription: String,
        checked: Bool,
        flag: Bool,
        displayMode: DisplayMode = .Interact
        ) {
        setData(avatarURL, date: date, read: read, titleContents: titleContents, coverURL: coverURL, detailDescription: detailDescription, displayMode: displayMode)
        if displayMode.rawValue < DisplayMode.Interact.rawValue {
            return
        }
        resultLbl.hidden = !checked
        agreeBtn.hidden = checked
        denyBtn.hidden = checked
        if checked {
            resultLbl.text = flag ? LS("已同意") : LS("已拒绝")
        }
    }
}

