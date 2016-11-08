//
//  PersonCarGallery.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/11/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation


protocol PersonCarProfileDelegate: class {
    func carProfileEditBtnPressed()
}


class PersonCarProfileView: UIView {
    var car: SportCar {
        didSet {
            loadDataAndUpdateUI()
        }
    }
    weak var delegate: PersonCarProfileDelegate!
    
    var gallary: SportCarGallary!
    var audioWave: CarWaveView!
    var nameLbl: UILabel!
    var logoIcon: UIImageView!
    var editBtn: UIButton!
    var signatureLbl: UILabel!
    
    var paramBoardStack: UIStackView!
    var priceLbl: UILabel!
    var engineLbl: UILabel!
    var subNameLbl: UILabel!
    var bodyLbl: UILabel!
    var speedLbl: UILabel!
    var acceLbl: UILabel!
    
    var statusListHeader: UILabel!
    
    init (car: SportCar) {
        self.car = car
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = .clear
        
        configureCarGallary()
        configureCarName()
        configureCarLogo()
        configureEditBtn()
        configureSignatureLbl()
        configureAudioWav()
        configureParamBoard()
        configureStatusListHeader()
        
        loadDataAndUpdateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    func configureCarGallary() {
        gallary = SportCarGallary(dataSource: self)
        addSubview(gallary)
        gallary.snp.makeConstraints { (mk) in
            mk.left.equalTo(self)
            mk.right.equalTo(self)
            mk.top.equalTo(self)
            mk.height.equalTo(self.snp.width).multipliedBy(0.588)
        }
    }
    
    func configureCarName() {
        nameLbl = addSubview(UILabel.self).config(19, fontWeight: UIFontWeightSemibold)
            .layout({ (mk) in
                mk.left.equalTo(self).offset(20)
                mk.top.equalTo(gallary.snp.bottom).offset(15)
            })
        nameLbl.preferredMaxLayoutWidth = UIScreen.main.bounds.width * 0.55
        nameLbl.numberOfLines = 0
    }
    
    func configureCarLogo() {
        logoIcon = addSubview(UIImageView.self)
            .layout({ (mk) in
                mk.size.equalTo(30)
                mk.top.equalTo(nameLbl)
                mk.left.equalTo(nameLbl.snp.right).offset(13)
            })
        logoIcon.layer.cornerRadius = 15
        logoIcon.contentMode = .scaleAspectFit
        logoIcon.clipsToBounds = true
    }
    
    func configureEditBtn() {
        editBtn = addSubview(UIButton.self).config(self, selector: #selector(editBtnPressed))
            .layout({ (mk) in
                mk.right.equalTo(self).offset(-15)
                mk.top.equalTo(nameLbl)
                mk.width.equalTo(70)
                mk.height.equalTo(32)
            })
        editBtn.setTitle(LS("设置/认证"), for: .normal)
        editBtn.setTitleColor(kHighlightRed, for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
    }
    
    func configureSignatureLbl() {
        signatureLbl = addSubview(UILabel.self).config(14, textColor: kTextGray54, multiLine: true)
            .layout({ (mk) in
                mk.left.equalTo(self).offset(20)
                mk.top.equalTo(nameLbl.snp.bottom).offset(20)
                mk.width.equalTo(nameLbl)
            })
    }
    
    func configureAudioWav() {
        audioWave = CarWaveView()
        addSubview(audioWave)
        audioWave.snp.makeConstraints { (mk) in
            mk.top.equalTo(signatureLbl.snp.bottom).offset(22.5)
            mk.left.equalTo(signatureLbl)
            mk.width.equalTo(270)
            mk.height.equalTo(50)
        }
    }
    
    func configureParamBoard() {
        paramBoardStack = UIStackView()
        paramBoardStack.axis = .vertical
        paramBoardStack.spacing = 0.5
        paramBoardStack.distribution = .fillEqually
        paramBoardStack.alignment = .center
        addSubview(paramBoardStack)
        paramBoardStack.snp.makeConstraints { (mk) in
            mk.top.equalTo(signatureLbl.snp.bottom).offset(22.5)
            mk.left.equalTo(self)
            mk.right.equalTo(self)
        }
        
        paramBoardStack.addSubview(UIView.self).config(UIColor(white: 0.1, alpha: 1))
            .layout { (mk) in
                mk.edges.equalToSuperview()
        }
        
        func createSubStack() -> UIStackView {
            let stack = UIStackView()
            stack.axis = .horizontal
            stack.spacing = 0
            stack.distribution = .fillEqually
            stack.alignment = .center
            paramBoardStack.addArrangedSubview(stack)
//            stack.autoresizingMask = .flexibleWidth
            stack.snp.makeConstraints { (mk) in
                mk.width.equalTo(self)
            }
            return stack
        }
        
        var lbls: [UILabel] = []
        
        let subStacks = (0..<3).map{ _ in createSubStack() }
        
        ["型号", "发动机", "最高车速", "价格", "车身结构", "百公里加速"].enumerated().forEach { (idx, text) in
            let stack = subStacks[idx / 2]
            let container = UIView()
            container.backgroundColor = UIColor(red: 0.145, green: 0.161, blue: 0.173, alpha: 1)
//            container.autoresizingMask = .flexibleHeight
            container.heightAnchor.constraint(equalToConstant: 84).isActive = true
            stack.addArrangedSubview(container)
            
            let sLbl = container.addSubview(UILabel.self).config(12, textColor: kTextGray28, text: LS(text))
                .layout({ (mk) in
                    mk.left.equalTo(container).offset(20)
                    mk.top.equalTo(container).offset(20)
                })
            
            let lbl = container.addSubview(UILabel.self).config(17, fontWeight: UIFontWeightSemibold, textColor: .white)
                .layout({ (mk) in
                    mk.left.equalTo(sLbl)
                    mk.top.equalTo(sLbl.snp.bottom)
                })
            
            lbls.append(lbl)
        }
        
        subNameLbl = lbls[0]
        priceLbl = lbls[1]
        engineLbl = lbls[2]
        bodyLbl = lbls[3]
        speedLbl = lbls[4]
        acceLbl = lbls[5]
    }
    
    func configureStatusListHeader() {
        statusListHeader = addSubview(UILabel.self).config(14, fontWeight: UIFontWeightSemibold, textAlignment: .center, text: "动态")
            .config(.white)
            .layout({ (mk) in
                mk.left.equalTo(self)
                mk.right.equalTo(self)
                mk.top.equalTo(paramBoardStack.snp.bottom)
                mk.height.equalTo(44)
            })
    }
    
    func editBtnPressed() {
        delegate.carProfileEditBtnPressed()
    }
    
    func loadDataAndUpdateUI () {
        nameLbl.text = car.name
        logoIcon.kf.setImage(with: car.logoURL!)
        gallary.reloadData()
        
        audioWave.audioURL = car.audioURL
        setAudioWaveHidden(car.audioURL == nil)
        
        signatureLbl.text = car.signature
        //
        priceLbl.text = car.price
        engineLbl.text = car.engine
        subNameLbl.text = car.subname
        bodyLbl.text = car.body
        speedLbl.text = car.maxSpeed
        acceLbl.text = car.zeroTo60
        
        editBtn.isHidden = car.mine
    }
    
    func setAudioWaveHidden(_ flag: Bool) {
        if audioWave.isHidden == flag {
            return
        }
        audioWave.isHidden = flag
        audioWave.snp.remakeConstraints { (mk) in
            if flag {
                mk.top.equalTo(signatureLbl.snp.bottom).offset(22.5)
            } else {
                mk.top.equalTo(audioWave.snp.bottom).offset(22.5)
            }
            mk.left.equalTo(self)
            mk.right.equalTo(self)
            mk.height.equalTo(252)
        }
    }
    
    func requiredHeight() -> CGFloat {
        if frame == .zero {
            // 在autolayout系统没有对本view进行布局之前先将这个view的frame设置成最大
            frame = UIScreen.main.bounds
        }
        layoutIfNeeded()
        var rect: CGRect = .zero
        for view in subviews {
            rect = rect.union(view.frame)
        }
        
        return rect.height + 5
    }
}

extension PersonCarProfileView: SportCarGallaryDataSource {
    func numberOfItems() -> Int {
        let imageNum = car.imageArray.count
        let videoNum = car.video == nil ? 0 : 1
        return imageNum + videoNum
    }
    
    func itemSize() -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        return CGSize(width: screenWidth, height: screenWidth * 0.588)
    }
    
    func itemForPage(_ pageNum: Int) -> SportCargallaryItem {
        let imageNum = car.imageArray.count
        if pageNum < imageNum {
            let image = car.imageArray[pageNum]
            return SportCargallaryItem(itemType: "image", resource: image.absoluteString)
        } else {
            return SportCargallaryItem(itemType: "video", resource: car.video!)
        }
    }
}
