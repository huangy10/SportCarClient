//
//  SmallOperationBoard.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/30.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol SmallOpertaionDelegate: class {
    func smallOperationIconImage(forIdx idx: Int) -> UIImage?
    func smallOperationLblVal(foridx idx: Int) -> Int
    func smallOperationBtnPressed(atIdx idx: Int)
    func numberOfBtnsInSmallOperationBoard() -> Int
}


class SmallOperationBoard: UIView {
    var btns: [SSButton] = []
    var lbls: [UILabel] = []
    
    weak var delegate: SmallOpertaionDelegate!
    
    init(delegate: SmallOpertaionDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        configureBtns()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadAll() {
        for idx in 0..<delegate.numberOfBtnsInSmallOperationBoard() {
            reloadBtn(at: idx)
        }
    }
    
    func reloadBtn(at idx: Int, withPulse: Bool = false) {
        let btn = btns[idx]
        if withPulse {
            btn.resetIconImageWithPulse(delegate.smallOperationIconImage(forIdx: idx)!)
        } else {
            btn.icon.image = delegate.smallOperationIconImage(forIdx: idx)
        }
        
        let lbl = lbls[idx]
        lbl.text = "\(delegate.smallOperationLblVal(foridx: idx))"
    }
    
    func configureBtns() {
        let stack = createEmptyStack()
        addSubview(stack)
        stack.snp.makeConstraints{ $0.edges.equalTo(self) }
        for idx in 0..<delegate.numberOfBtnsInSmallOperationBoard() {
            let btn = SSButton()
            stack.addArrangedSubview(btn)
            btns.append(btn)
            configure(btn: btn, atIdx: idx)
            btn.icon.image = delegate.smallOperationIconImage(forIdx: idx)
            
            let lbl = UILabel()
            btn.addSubview(lbl)
            configure(lbl: lbl, atIdx: idx)
            lbls.append(lbl)
            lbl.snp.makeConstraints({ (make) in
                make.centerY.equalTo(btn)
                make.left.equalTo(btn.icon.snp.right).offset(2)
            })
            lbl.text = "\(delegate.smallOperationLblVal(foridx: idx))"
        }
    }
    
    func btnPressed(sender: SSButton) {
        delegate.smallOperationBtnPressed(atIdx: sender.tag)
    }
    
    func requiredWidth() -> CGFloat {
        let num = CGFloat(delegate.numberOfBtnsInSmallOperationBoard())
        let lblWidth = "99+".sizeWithFont(fontForLbl(), boundingSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        let btnWidth = lblWidth + 17
        return btnWidth * num + intervalForBtns * (num - 1)
    }
    
    var intervalForBtns: CGFloat = 5
    
    func fontForLbl() -> UIFont {
        return UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
    }
    
    func configure(lbl: UILabel, atIdx idx: Int) {
        lbl.font = fontForLbl()
        lbl.textColor = kTextGray28
    }
    
    func configure(btn: SSButton, atIdx idx: Int) {
        btn.autoresizingMask = .flexibleHeight
        btn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        btn.tag = idx
        btn.icon.snp.remakeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(15)
        }
    }
    
    func createEmptyStack() -> UIStackView {
        let stack = UIStackView()
        stack.spacing = 0
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }
}
