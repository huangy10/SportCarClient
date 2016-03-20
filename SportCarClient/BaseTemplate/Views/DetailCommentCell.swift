//
//  DetailCommentCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/22.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Kingfisher


protocol DetailCommentCellDelegate: class {
    func avatarPressed(cell: DetailCommentCell)
    
    func replyPressed(cell: DetailCommentCell)
    
    func checkImageDetail(cell: DetailCommentCell)
}



/// 通用的评论cell
class DetailCommentCell: UITableViewCell {
    static let reuseIdentifier = "DetailCommentCell"
    
    /// 代理，一般指向对应的tableViewController
    weak var delegate: DetailCommentCellDelegate?
    /// 头像
    var avatarBtn: UIButton?
    /// 姓名标签
    var nameLbl: UILabel?
    /// 回应Label
    var responseStaticLbl: UILabel?
    var responseLbl: UILabel?
    /// 评论日期
    var commentDateLbl: UILabel?
    /// 回复按钮
    var replyBtn: UIButton?
    /// 评论内容标签
    var commentContentLbl: UILabel?
    /// 评论附图
    var commentImage: UIButton?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     创建子View
     */
    private func createSubviews() {
        let superview = self.contentView
        //
        avatarBtn = UIButton()
        avatarBtn?.addTarget(self, action: "avatarPressed", forControlEvents: .TouchUpInside)
        avatarBtn?.layer.cornerRadius = 17.5
        avatarBtn?.clipsToBounds = true
        avatarBtn?.backgroundColor = UIColor.grayColor()
        superview.addSubview(avatarBtn!)
        avatarBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(superview)
            make.size.equalTo(35)
        })
        //
        nameLbl = UILabel()
        nameLbl?.text = LS("用户昵称")
        nameLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        nameLbl?.textColor = UIColor.blackColor()
        superview.addSubview(nameLbl!)
        nameLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(avatarBtn!.snp_right).offset(11)
            make.top.equalTo(avatarBtn!)
        })
        //
        responseStaticLbl = UILabel()
        responseStaticLbl?.text = LS("回复了")
        responseStaticLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        responseStaticLbl?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(responseStaticLbl!)
        responseStaticLbl!.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(nameLbl!.snp_right).offset(2)
            make.bottom.equalTo(nameLbl!)
        }
        responseStaticLbl?.hidden = true
        //
        responseLbl = UILabel()
        responseLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightSemibold)
        responseLbl?.textColor = UIColor.blackColor()
        superview.addSubview(responseLbl!)
        responseLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(responseStaticLbl!.snp_right).offset(2)
            make.bottom.equalTo(nameLbl!)
        })
        responseLbl?.hidden = true
        //
        commentDateLbl = UILabel()
        commentDateLbl?.font = UIFont.systemFontOfSize(10, weight: UIFontWeightLight)
        commentDateLbl?.textColor = UIColor(white: 0.72, alpha: 1)
        commentDateLbl?.text = LS("评论时间")
        superview.addSubview(commentDateLbl!)
        commentDateLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nameLbl!)
            make.height.equalTo(11)
            make.top.equalTo(nameLbl!.snp_bottom).offset(2)
        })
        //
        replyBtn = UIButton()
        replyBtn?.setTitle(LS("回复"), forState: .Normal)
        replyBtn?.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        replyBtn?.titleLabel?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        superview.addSubview(replyBtn!)
        replyBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.top.equalTo(commentDateLbl!)
            make.height.equalTo(17)
            make.width.equalTo(25)
        })
        replyBtn?.addTarget(self, action: "replyPressed", forControlEvents: .TouchUpInside)
        //
        commentContentLbl = UILabel()
        commentContentLbl?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)
        commentContentLbl?.lineBreakMode = .ByWordWrapping
        commentContentLbl?.numberOfLines = 0
        commentContentLbl?.text = LS("评论内容")
        superview.addSubview(commentContentLbl!)
        commentContentLbl?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(nameLbl!)
            make.top.equalTo(avatarBtn!.snp_bottom).offset(7)
            make.right.equalTo(replyBtn!.snp_left)
        })
        //
        commentImage = UIButton()
        superview.addSubview(commentImage!)
        commentImage?.addTarget(self, action: "commentImagePressed", forControlEvents: .TouchUpInside)
        commentImage?.hidden = true
    }
    
    /**
     获取这个Cell的高度
     
     - parameter data: Cell的评论数据，为空时使用当前的评论数据，否则覆盖原来的评论数据
     
     - returns: Cell的高度
     */
    func getHeightForThisCell(data: NewsComment?) -> CGFloat {
        return 0
    }
    
    class func heightForComment(commentContent: String) -> CGFloat {
        let otherContentHeight = 78 as CGFloat
        let screenWidth = UIScreen.mainScreen().bounds.width
        let content = commentContent as NSString
        let textRect = content.boundingRectWithSize(CGSizeMake(screenWidth - 101, 1000), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14, weight: UIFontWeightUltraLight)], context: nil)
        return otherContentHeight + textRect.height
    }
    
    /**
     读取comment的数据并更新UI表现。在设置comment之后自动调用，请勿在外部调用
     注意这里认为的数据已经经过了完整性验证
     */
    func loadDataAndUpdateUI() {
        assertionFailure("Not Implemented")
    }
}

// MARK: - 按钮响应
extension DetailCommentCell {
    func avatarPressed() {
        if let d = delegate {
            d.avatarPressed(self)
        }else{
            assertionFailure()
        }
    }
    
    func replyPressed() {
        if let d = delegate {
            d.replyPressed(self)
        }else{
            assertionFailure()
        }
    }
    
    func commentImagePressed() {
        if let d = delegate {
            d.checkImageDetail(self)
        }else{
            assertionFailure()
        }
    }
}
