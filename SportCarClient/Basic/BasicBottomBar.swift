//
//  BasicBottomBar.swift
//  SportCarClient
//
//  Created by 黄延 on 2016/10/29.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit

protocol BottomBarDelegate: class {
    // 功能相关
    func bottomBarHeightShouldChange(into newHeight: CGFloat) -> Bool
    func bottomBarBtnPressed(at index: Int)
    func bottomBarMessageConfirmSent()
    func bottomBarDidBeginEditing()
    
    // 外观相关
    func getIconForBtn(at idx: Int) -> UIImage
    func numberOfLeftBtns() -> Int
    func numberOfRightBtns() -> Int
}

class BasicBottomBar: UIView {
    
    weak var delegate: BottomBarDelegate!
    
    var leftStack: UIStackView?
    var rightStack: UIStackView?
    var btns: [SSButton] = []
    var contentInput: UITextView!
    var contentInputFormatter: ContentInputFormatter!
    
    var autoAdjustLayoutWhenKeyboardChanges: Bool = true
    
    var btnNum: Int {
        return delegate.numberOfLeftBtns() + delegate.numberOfRightBtns()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(delegate: BottomBarDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        backgroundColor = UIColor(white: 0.92, alpha: 1)
        configureLeftBtns()
        configureRightBtns()
        configureContentInput()
        configureNotificationObserver()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    var defaultBarHeight: CGFloat {
        return 45
    }
    
    var textCountLimit: Int = 140
    
    func getIconToTheLeftOfContentInput() -> UIImage {
        return UIImage(named: "news_comment_icon")!
    }
    
    func getIconSize() -> (CGFloat, CGFloat) {
        return (35, 17)
    }
    
    func getIntervalOfBtns() -> CGFloat {
        return 9
    }
    
    func reloadIcon(at idx: Int, withPulse: Bool = false) {
        assert(idx < btns.count)
        if withPulse {
            btns[idx].resetIconImageWithPulse(delegate.getIconForBtn(at: idx))
        } else {
            btns[idx].icon.image = delegate.getIconForBtn(at: idx)
        }
    }
    
    func configureLeftBtns() {
        
        if delegate.numberOfLeftBtns() == 0 {
            return
        }
        
        let num = CGFloat(delegate.numberOfLeftBtns())
        let stack = createEmptyStack()
        let (bSize, _) = getIconSize()
        addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(15)
            make.bottom.equalTo(self).offset(-5)
            make.width.equalTo(num * bSize + (num - 1) * getIntervalOfBtns())
            make.height.equalTo(bSize)
        }
        
        for idx in 0..<delegate.numberOfLeftBtns() {
            let btn = SSButton()
            addSubview(btn)
            configure(btn: btn, at: idx)
            btn.icon.image = delegate.getIconForBtn(at: idx)
            stack.addArrangedSubview(btn)
            
            btns.append(btn)
        }
        leftStack = stack
    }
    
    func configureRightBtns() {
        if delegate.numberOfRightBtns() == 0 {
            return
        }
        let num = CGFloat(delegate.numberOfRightBtns())
        let stack = createEmptyStack()
        let (bSize, _) = getIconSize()
        addSubview(stack)
        stack.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-15)
            make.bottom.equalTo(self).offset(-5)
            make.width.equalTo(num * bSize + (num - 1) * getIntervalOfBtns())
            make.height.equalTo(bSize)
        }
        stack.backgroundColor = UIColor.red
        let baseNum = delegate.numberOfLeftBtns()
        for idx in baseNum..<(baseNum + delegate.numberOfRightBtns()) {
            let btn = SSButton()
            addSubview(btn)
            configure(btn: btn, at: idx)
            btn.icon.image = delegate.getIconForBtn(at: idx)
            stack.addArrangedSubview(btn)
            
            btns.append(btn)
        }
        rightStack = stack
    }
   
    func configure(btn: SSButton, at idx: Int) {
        btn.autoresizingMask = .flexibleHeight
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(btnPressed), for: .touchUpInside)
        let (bSize, iSize) = getIconSize()
        btn.layer.cornerRadius = bSize / 2
        btn.iconSize = iSize
        btn.tag = idx
    }
    
    func createEmptyStack() -> UIStackView {
        let stack = UIStackView()
        stack.spacing = getIntervalOfBtns()
        stack.alignment = .center
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        return stack
    }
   
    
    func btnPressed(sender: UIButton) {
        delegate.bottomBarBtnPressed(at: sender.tag)
    }
    
    func configureContentInput() {
        let (bSize, iSize) = getIconSize()
        let container = UIView()
        container.backgroundColor = .white
        addSubview(container)
        container.snp.makeConstraints { (make) in
            if let stack = leftStack {
                make.left.equalTo(stack.snp.right).offset(15)
            } else {
                make.left.equalTo(self).offset(15)
            }
            
            if let stack = rightStack {
                make.right.equalTo(stack.snp.left).offset(-15)
            } else {
                make.right.equalTo(self).offset(-15)
            }
            
            make.bottom.equalTo(self).offset(-5)
            make.top.equalTo(self).offset(5)
        }
        container.layer.cornerRadius = bSize / 2
        
        let icon = UIImageView()
        icon.image = getIconToTheLeftOfContentInput()
        container.addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.left.equalTo(container).offset(18)
            make.bottom.equalTo(container).offset(-9)
            make.size.equalTo(iSize)
        }
        
        contentInput = UITextView()
        configureContentInputFormatter()
        contentInput.delegate = contentInputFormatter
        
        container.addSubview(contentInput)
        contentInput.snp.makeConstraints { (make) in
            make.left.equalTo(icon.snp.right).offset(10)
            make.right.equalTo(container).offset(-18)
            make.top.equalTo(container)
            make.bottom.equalTo(container)
        }
    }
    
    func configureContentInputFormatter() {
        contentInputFormatter = ContentInputFormatter()
        contentInputFormatter.delegate = self
        contentInputFormatter.textInput = contentInput
        contentInputFormatter.textCountLimit = 140
    }
    
    func configureNotificationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeLayoutWhenKeyboardStatusChanges(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(contentInputDidStartEditing(notification:)), name: NSNotification.Name.UITextViewTextDidBeginEditing, object: contentInput)
    }
    
    func changeLayoutWhenKeyboardStatusChanges(_ notification: NSNotification) {
        if !autoAdjustLayoutWhenKeyboardChanges {
            return
        }
        switch notification.name {
        case NSNotification.Name.UIKeyboardWillShow:
            let userInfo = notification.userInfo!
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue!
            setFrame(withOffsetToBottom: keyboardFrame.height)
        case NSNotification.Name.UIKeyboardWillHide:
            setFrame(withOffsetToBottom: 0)
        default:
            break
        }
    }
    
    func setFrame(withOffsetToBottom offset: CGFloat, superviewFrame: CGRect? = nil) {
        let sFrame = superviewFrame ?? superview!.frame
        let width = sFrame.width
        let height = frame.height != 0 ? frame.height : defaultBarHeight
        let y = sFrame.height - height - offset
        frame = CGRect(x: 0, y: y, width: width, height: height)
    }
    
    func updateBarHeight(_ newHeight: CGFloat) {
        var oldFrame = frame
        oldFrame.origin.y -= newHeight - oldFrame.height
        oldFrame.size.height = newHeight
        frame = oldFrame
    }
    
    func resetBarBarHeight() {
        updateBarHeight(defaultBarHeight)
    }
    
    func clearInputContent() {
        contentInput.text = ""
//        resetBarBarHeight()
    }
    
    func contentInputDidStartEditing(notification: NSNotification) {
        delegate.bottomBarDidBeginEditing()
    }
    
    func forwardTextViewDelegateTo(_ upStream: UITextViewDelegate) {
        contentInputFormatter.forwardToDelegate = upStream
    }
}

extension BasicBottomBar: ContentInputFormatterDelegate {
    func contentInputShouldChangeHeight(into height: CGFloat) {
        if delegate.bottomBarHeightShouldChange(into: height) {
            updateBarHeight(max(height, defaultBarHeight))
        }
    }
    
    func contentInputConfirmed(contentInputFormatter: ContentInputFormatter) {
        delegate.bottomBarMessageConfirmSent()
    }
    
    func smallOperationIconImage(forIdx idx: Int) -> UIImage? {
//        if idx == 0 && status. {
//            
//        }
        return nil
    }
}


