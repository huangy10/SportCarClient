//
//  MakeCommentPanel.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/3.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit

let maxWordLimit = 200

protocol MakeCommentControllerDelegate {
    /**
     评论取消了会调用这个函数
     
     - parameter commentString: 评论的内容。当用户没有输入时返回[图片]
     - parameter image:         评论的图片
     */
    func commentCanceled(commentString: String, image: UIImage?)
    
    /**
     评论完成，可以发布了
     虽然两个参数可以为空，但是不能同时为空
     
     - parameter commentString: 评论的内容，可以为空
     - parameter image:         评论的图片，可以为空
     */
    func commentConfirmed(commentString: String?, image: UIImage?)
}

/// 评论器
class MakeCommentController: InputableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /*
    ======================================================================================================================== All Subviews
    */
    /// 模糊化的背景
    var blurBG: UIImageView?
    /// 取消按钮
    var cancelBtn: UIButton?
    /// 中间的分割线
    var sepLine: UIView?
    /// 发布按钮
    var confirmBtn: UIButton?
    /// 下面的输入等操作的容纳筐
    var opPanel: UIView?
    ///
    var inputContainerView: UIView?
    /// 输入框
    var input: UITextView?
    /// 字数统计
    var wordCount: UILabel?
    /// 添加图片按钮
    var attachImageBtn: UIButton?
    /*
    ======================================================================================================================== 外界输入的参数
    */
    var bgImage: UIImage?
    var responseToName: String? // 回复对象的名称
    var row: Int =  -1          // 回复对象所处的行
    var commentPrefix: String?
    var delegate: MakeCommentControllerDelegate?
    /*
    ======================================================================================================================== 数据
    */
    var commentImage: UIImage?
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
        self.createSubviews()
    }
    
    override func createSubviews() {
        super.createSubviews()
        //
        let superview = self.view
        superview.backgroundColor = UIColor.blackColor()
        //
        blurBG = UIImageView()
        superview.addSubview(blurBG!)
        blurBG?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(superview);
        })
        //
        cancelBtn = UIButton()
        cancelBtn?.setImage(UIImage(named: "news_comment_cancel_btn"), forState: .Normal)
        cancelBtn?.addTarget(self, action: "commentCancelled", forControlEvents: .TouchUpInside)
        superview.addSubview(cancelBtn!)
        cancelBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(21)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(35)
        })
        //
        sepLine = UIView()
        sepLine?.backgroundColor = UIColor.whiteColor()
        superview.addSubview(sepLine!)
        sepLine?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(0.5)
            make.width.equalTo(superview).multipliedBy(0.6)
            make.centerX.equalTo(superview)
            make.top.equalTo(cancelBtn!.snp_bottom).offset(48)
        })
        //
        confirmBtn = UIButton()
        confirmBtn?.setTitle(LS("发布"), forState: .Normal)
        confirmBtn?.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightBold)
        confirmBtn?.setTitleColor(UIColor(red: 1, green: 0.29, blue: 0.30, alpha: 1), forState: .Normal)
        confirmBtn?.titleLabel?.textAlignment = .Center
        confirmBtn?.layer.borderColor = UIColor(red: 1, green: 0.29, blue: 0.30, alpha: 1).CGColor
        confirmBtn?.layer.borderWidth = 1.5
        superview.addSubview(confirmBtn!)
        confirmBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(CGSize(width: 105, height: 50))
            make.centerX.equalTo(superview)
            make.top.equalTo(sepLine!.snp_bottom).offset(33)
        })
        confirmBtn?.addTarget(self, action: "commentConfirmed", forControlEvents: .TouchUpInside)
        //
        opPanel = UIView()
        opPanel?.backgroundColor = UIColor(white: 0.92, alpha: 1)
        superview.addSubview(opPanel!)
        opPanel?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.top.equalTo(confirmBtn!.snp_bottom).offset(40)
            make.bottom.equalTo(superview)
        })
        //
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.whiteColor()
        opPanel?.addSubview(inputContainer)
        inputContainer.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(superview).offset(-15)
            make.left.equalTo(superview).offset(15)
            make.top.equalTo(opPanel!).offset(10)
            make.height.equalTo(150)
        }
        inputContainerView = inputContainer
        //
        wordCount = UILabel()
        wordCount?.font = UIFont.systemFontOfSize(12, weight: UIFontWeightUltraLight)
        wordCount?.textColor = UIColor(white: 0.72, alpha: 1)
        wordCount?.textAlignment = .Right
        wordCount?.text = "0/\(maxWordLimit)"
        inputContainer.addSubview(wordCount!)
        wordCount?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(inputContainer).inset(8)
            make.bottom.equalTo(inputContainer).inset(5)
        })
        //
        input = UITextView()
        self.inputFields.append(input)
        input?.delegate = self
        inputContainer.addSubview(input!)
        input?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(inputContainer).inset(25)
            make.left.equalTo(inputContainer).inset(25)
            make.top.equalTo(inputContainer).inset(11)
            make.bottom.equalTo(wordCount!.snp_top)
        })
        //
        attachImageBtn = UIButton()
        attachImageBtn?.setImage(UIImage(named: "news_comment_attach_image"), forState: .Normal)
        opPanel?.addSubview(attachImageBtn!)
        attachImageBtn?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(inputContainer)
            make.top.equalTo(inputContainer.snp_bottom).offset(9)
            make.size.equalTo(CGSize(width: 75, height: 43))
        })
        attachImageBtn?.addTarget(self, action: "attachImageBtnPressed", forControlEvents: .TouchUpInside)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if row > 0 && responseToName != nil {
            commentPrefix = LS("回复") + " " + responseToName! + ": "
            input?.text = commentPrefix
        }
        input?.becomeFirstResponder()
    }
    /**
     通过这个函数设置模糊化的背景，只需要传入原图即可，
     
     - parameter image: 截取的前一个画面的截图
     */
    func setBluredBackground(image: UIImage) {
        bgImage = image
        // blurBG?.image = image
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        //
    }
}


// MARK: - 按钮响应
extension MakeCommentController {
    func commentCancelled() {
        var commentText = input?.text ?? ""
        if commentText.length == 0 && commentImage != nil {
            commentText = "[\(LS("图片"))]"
        }
        delegate?.commentCanceled(commentText, image: commentImage)
    }
    
    func commentConfirmed() {
        delegate?.commentConfirmed(input?.text, image: commentImage)
    }
    
    func attachImageBtnPressed() {
        let alert = UIAlertController(title: LS("设置评论图片"), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: LS("拍照"), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.Camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: LS("错误"), message: LS("无法打开相机"), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: LS("从相册选择"), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: LS("错误"), message: LS("无法打开相册"), preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: LS("取消"), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        attachImageBtn?.setImage(image, forState: .Normal)
        commentImage = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - TextField输入框的代理
extension MakeCommentController {
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return true
            }
        }
        let curText = input!.text! as NSString
        let newText = curText.stringByReplacingCharactersInRange(range, withString: text) as String
        if newText.length > maxWordLimit {
            return false
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.textInputMode?.primaryLanguage == "zh-Hans" {
            let selectedRange = textView.markedTextRange
            if selectedRange != nil {
                return
            }
        }
        let text = input?.text ?? ""
        if text.length > maxWordLimit{
            input?.text = text[0..<maxWordLimit]
        }
        
        wordCount?.text = "\(min(text.length, maxWordLimit))/\(maxWordLimit)"
        
    }
    
    func textView(textView: UITextView, shouldInteractWithURL URL: NSURL, inRange characterRange: NSRange) -> Bool {
        return false
    }
    
    func textView(textView: UITextView, shouldInteractWithTextAttachment textAttachment: NSTextAttachment, inRange characterRange: NSRange) -> Bool {
        return false
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        print("haha")
    }
    
}
