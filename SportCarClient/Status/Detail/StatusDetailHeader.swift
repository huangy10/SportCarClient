//
//  StatusDetailHeader.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol StatusDetailHeaderDelegate: class {
    func statusHeaderAvatarPressed()
    func statusHeaderLikePressed()
}

class StatusDetailHeaderView: UIView {
    var status: Status? {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    weak var delegate: StatusDetailHeaderDelegate!
    
    let headerHeight: CGFloat = 70
    
    var headerContainer: UIView!
    var cover: UIImageView!
    
    // 头部
    var avatarBtn: UIButton!
    var nameLbl: UILabel!
    var avatarClubIcon: UIImageView!
    var releaseDateLbl: UILabel!
    var avatarCarLogoIcon: UIImageView!
    var avatarCarNameLbl: UILabel!
    
    // 底部
    var contentLbl: UILabel!
    var locIcon: UIImageView!
    var locLbl: UILabel!
    var opsView: SmallOperationBoard!
    
    var isCoverZoomable: Bool = false
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0))
        backgroundColor = .white
        configureHeader()
        configureCover()
        configureFooter()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHeader() {
        headerContainer = addSubview(UIView.self).config(.white)
            .layout({ (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.top.equalTo(self)
                make.height.equalTo(headerHeight)
            })
        configureAvatarBtn()
        configureNameLbl()
        configureAvatarClubIcon()
        configureReleaseDateLbl()
        configureAvatarCars()
    }
    
    func configureAvatarBtn() {
        avatarBtn = headerContainer.addSubview(UIButton.self).config(self, selector: #selector(avatarBtnPressed))
            .layout({ (make) in
                make.left.equalTo(headerContainer).offset(15)
                make.centerY.equalTo(headerContainer)
                make.size.equalTo(35)
            })
        avatarBtn.imageView?.layer.cornerRadius = 35.0 / 2
    }
    
    func configureNameLbl() {
        nameLbl = headerContainer.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightSemibold)
            .layout({ (make) in
                make.left.equalTo(avatarBtn.snp.right).offset(10)
                make.bottom.equalTo(avatarBtn.snp.centerY)
                make.top.equalTo(avatarBtn)
            })
    }
    
    func configureAvatarClubIcon() {
        avatarClubIcon = headerContainer.addSubview(UIImageView.self)
            .layout({ (make) in
                make.left.equalTo(nameLbl.snp.right).offset(5)
                make.centerY.equalTo(nameLbl)
                make.size.equalTo(20)
            })
        avatarClubIcon.layer.cornerRadius = 10
    }
    
    func configureReleaseDateLbl() {
        releaseDateLbl = headerContainer.addSubview(UILabel.self)
            .config(12, fontWeight: UIFontWeightRegular, textColor: kTextGray28)
            .layout({ (make) in
                make.left.equalTo(nameLbl)
                make.bottom.equalTo(avatarBtn)
                make.top.equalTo(nameLbl.snp.bottom)
            })
    }
    
    var fontForAvatarCarName = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)

    func configureAvatarCars() {
        avatarCarNameLbl = headerContainer.addSubview(UILabel.self)
            .layout({ (make) in
                make.right.equalTo(headerContainer).offset(-15)
                make.centerY.equalTo(headerContainer)
            })
        avatarCarNameLbl.font = fontForAvatarCarName
        avatarCarNameLbl.textColor = kTextGray54
        avatarCarNameLbl.textAlignment = .right
        avatarCarLogoIcon = headerContainer.addSubview(UIImageView.self)
            .layout({ (make) in
                make.centerY.equalTo(avatarCarNameLbl)
                make.right.equalTo(avatarCarNameLbl.snp.left)
                make.size.equalTo(21)
            })
    }
    
    func configureCover() {
        cover = addSubview(UIImageView.self)
        cover.layout({ (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.top.equalTo(headerContainer.snp.bottom)
                make.height.equalTo(cover.snp.width)
            })
    }
    
    func configureFooter() {
        configureContentLbl()
        configureLocationDisplay()
        configureOpsView()
    }
    
    func configureContentLbl() {
        contentLbl = addSubview(UILabel.self)
            .layout({ (make) in
                make.right.equalTo(self).offset(-15)
                make.left.equalTo(self).offset(15)
                make.top.equalTo(cover.snp.bottom).offset(15)
            })
        contentLbl.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 30
        contentLbl.numberOfLines = 0
    }
    
    func configureLocationDisplay() {
        locIcon = addSubview(UIImageView.self).config(UIImage(named: "status_location_icon"), contentMode: .scaleAspectFit)
            .layout({ (make) in
                make.left.equalTo(contentLbl)
                make.top.equalTo(contentLbl.snp.bottom).offset(15)
                make.size.equalTo(18)
            })
        locLbl = addSubview(UILabel.self).config(14, fontWeight: UIFontWeightRegular, textColor: kTextGray28)
            .layout({ (make) in
                make.left.equalTo(locIcon.snp.right).offset(10)
                make.top.equalTo(locIcon)
                make.width.equalTo(self).dividedBy(2)
            })
        locLbl.numberOfLines = 2
        locLbl.lineBreakMode = .byWordWrapping
    }
    
    func configureOpsView() {
        opsView = SmallOperationBoard(delegate: self)
        opsView.delegate = self
        addSubview(opsView)
        opsView.snp.makeConstraints { (make) in
            make.right.equalTo(self)
            make.top.equalTo(locIcon)
            make.height.equalTo(17)
            make.width.equalTo(opsView.requiredWidth())
        }
    }
    
    func avatarBtnPressed() {
        delegate.statusHeaderAvatarPressed()
    }
    
    func loadDataAndUpdateUI() {
        guard let status = status else {
            return
        }
        let user = status.user!
        avatarBtn.kf.setImage(with: user.avatarURL!, for: .normal)
        nameLbl.text = user.nickName
        releaseDateLbl.text = dateDisplay(status.createdAt!)
        if let club = user.avatarClubModel {
            avatarClubIcon.isHidden = false
            avatarClubIcon.kf.setImage(with: club.logoURL!)
        } else {
            avatarClubIcon.isHidden = true
        }
        if let car = user.avatarCarModel {
            avatarCarLogoIcon.isHidden = false
            avatarCarNameLbl.isHidden = false
            avatarCarLogoIcon.kf.setImage(with: car.logoURL!)
            setAvatarCarName(car.name!)
        } else {
            avatarCarLogoIcon.isHidden = true
            avatarCarNameLbl.isHidden = true
        }
        
        cover.kf.setImage(with: status.coverURL!)
        if isCoverZoomable {
            cover.setupForImageViewer(status.coverURL!, backgroundColor: .black, fadeToHide: false)
        }
        contentLbl.attributedText = type(of: self).makeFormatedStatusContent(status.content!)
        if let des = status.location?.descr {
            locLbl.text = des
        } else {
            locLbl.text = LS("未知地点")
        }
        opsView.reloadAll()
    }
    
    class func heightForStatusContent(_ content: String) -> CGFloat {
        let attributedContent = makeFormatedStatusContent(content)
        let maxWidth = UIScreen.main.bounds.width - 30
        return attributedContent.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil).height
    }
    
    class func makeFormatedStatusContent(_ content: String) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 3
        style.lineBreakMode = .byCharWrapping
        let result = NSAttributedString(string: content, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular), NSForegroundColorAttributeName: UIColor.black, NSParagraphStyleAttributeName: style])
        return result
    }
    
    func setAvatarCarName(_ name: String) {
        avatarCarNameLbl.text = name
        let carNameMaxNameInScreen = UIScreen.main.bounds.width * 0.4
        let actualWitdh = name.sizeWithFont(fontForAvatarCarName, boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        if actualWitdh > carNameMaxNameInScreen {
            avatarCarNameLbl.numberOfLines = 2
            avatarCarNameLbl.lineBreakMode = .byWordWrapping
            let limitedWidth = name.sizeWithFont(fontForAvatarCarName, boundingSize: CGSize(width: carNameMaxNameInScreen, height: CGFloat.greatestFiniteMagnitude)).width
            avatarCarNameLbl.snp.remakeConstraints({ (make) in
                make.right.equalTo(headerContainer!).offset(-15)
//                make.top.equalTo(avatarCarLogoIcon!)
                make.centerY.equalTo(headerContainer)
                make.width.equalTo(limitedWidth)
            })
        } else {
            avatarCarNameLbl.numberOfLines = 1
            avatarCarNameLbl.snp.remakeConstraints({ (make) in
                make.right.equalTo(headerContainer!).offset(-15)
//                make.top.equalTo(avatarCarLogoIcon!)
                make.centerY.equalTo(headerContainer)
            })
        }
    }
    
    class func requiredHeight(forStatus status: Status) -> CGFloat {
        let content = status.content!
        let screenWidth = UIScreen.main.bounds.width
        let textHeight: CGFloat
        if content == "" {
            textHeight = 0
        } else {
            textHeight = heightForStatusContent(content)
        }
        
        return 505.0 / 375 * screenWidth + textHeight
    }
}

extension StatusDetailHeaderView: SmallOpertaionDelegate {
    func smallOperationBtnPressed(atIdx idx: Int) {
        if idx == 0 {
            delegate.statusHeaderLikePressed()
        }
    }
    
    func numberOfBtnsInSmallOperationBoard() -> Int {
        return 2
    }
    
    func smallOperationLblVal(foridx idx: Int) -> Int {
        guard let status = status else {
            return 0
        }
        if idx == 0 {
            return Int(status.likeNum)
        } else if idx == 1 {
            return Int(status.commentNum)
        } else {
            fatalError()
        }
    }
    
    func smallOperationIconImage(forIdx idx: Int) -> UIImage? {
        if idx == 0 && (status?.liked ?? false) {
            return UIImage(named: "news_like_liked")
        } else if idx == 0 {
            return UIImage(named: "news_like_unliked")
        } else if idx == 1 {
            return UIImage(named: "news_comment")
        } else {
            fatalError()
        }
    }
}
