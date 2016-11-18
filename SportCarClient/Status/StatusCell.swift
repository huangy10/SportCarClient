//
//  StatusCell.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/20.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import Dollar

protocol StatusCellProtocol: class {
    func statusCellLikePressed(cell: StatusCell)
}

class StatusCell: UITableViewCell {
    
    static let reuseIdentifier = "statuc_cell"
//    weak var parent: UIViewController?
    weak var delegate: StatusCellProtocol?
    
    var detail: StatusDetailHeaderView!
    var status: Status! {
        didSet {
            detail.status = status
        }
    }
    
    let detailInset = UIEdgeInsetsMake(5, 10, 5, 10)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = kGeneralTableViewBGColor
        configureDetail()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureDetail() {
        detail = StatusDetailHeaderView()
        detail.delegate = self
        contentView.addSubview(detail)
        detail.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(detailInset)
        }
    }
    
    class func heightForStatus(_ status: Status) -> CGFloat {
        return StatusDetailHeaderView.requiredHeight(forStatus: status) + 10
    }
}


extension StatusCell: StatusDetailHeaderDelegate {
    func statusHeaderLikePressed() {
        delegate?.statusCellLikePressed(cell: self)
    }
    
    func statusHeaderAvatarPressed() {
        //
    }
}

class StatusCellImageDisplayCell: UICollectionViewCell {
    static let reuseIdentifier = "status_cell_image_display_cell"
    
    var imageView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = UIImageView()
        imageView?.contentMode = .scaleAspectFill
        imageView?.clipsToBounds = true
        self.contentView.addSubview(imageView!)
        imageView?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(self.contentView)
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//
}
