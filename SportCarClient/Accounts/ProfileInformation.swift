//
//  ProfileInformation.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class ProfileInfoController: InputableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ProgressProtocol {
    
    var pp_progressView: UIProgressView?
    
    var avatarBtn: UIButton?
    var nickNameInput: UITextField?
    var genderInput: UIButton?          // 这两个控件虽然冠以Input之名，但实际是Button。因这里不需要用户直接输入，而是以此按钮呼出Pick view
    var birthDateInput: UIButton?
    
    var pickerContainer: UIView?
    var pickerTitle: UILabel?
    var genderPickerView: UIPickerView?
    var birthDatePickerView: UIDatePicker?
    
    /// 指向导航栏的下一步按钮，控制其状态
    var nextBtn: UIButton?
    
    func navigationBarSettings() {
        self.navigationItem.title = NSLocalizedString("补充信息", comment: "")
        self.navigationItem.leftBarButtonItem = navBarLeftBtn()
        self.navigationItem.rightBarButtonItem = navBarRigthBtn()
    }
    
    func navBarLeftBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), forState: .Normal)
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: "nextBtnPressed", forControlEvents: .TouchUpInside)
        let rightBtnItem = UIBarButtonItem(customView: nextStepBtn)
        return rightBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func nextBtnPressed() {
        // 发起请求先先禁用next按钮
        nextBtn?.enabled = false
        //
        guard let nickName = nickNameInput?.text else{
            showToast(LS("请填写昵称"))
            return
        }
        guard let gender = genderInput?.titleLabel?.text else{
            showToast(LS("请选择性别"))
            return
        }

        guard let birthDate = birthDateInput?.titleLabel?.text else{
            showToast(LS("请选择生日"))
            return
        }
        guard let avatar = avatarBtn?.backgroundImageForState(.Normal) else{
            showToast(LS("请选择头像"))
            return
        }
        let requester = AccountRequester.sharedRequester
        pp_showProgressView()
        requester.postToSetProfile(nickName, gender: gender, birthDate: birthDate, avatar: avatar, onSuccess: { (_) -> () in
            self.pp_hideProgressView()
            self.nextBtn?.enabled = true
            let ctrl = SportCarSelectController()
            self.navigationController?.pushViewController(ctrl, animated: true)
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
            }) { (code) -> () in
                self.pp_hideProgressView()
                self.nextBtn?.enabled = true
                switch code! {
                case "0000":
                    self.showToast(LS("网络连接失败"))
                    break
                default:
                    self.showToast(LS("未知错误"))
                    break
                }
        }
        
    }
    
    override func createSubviews(){
        super.createSubviews()
        navigationBarSettings()
        let superview = self.view
        superview.backgroundColor = UIColor.whiteColor()
        //
        avatarBtn = UIButton()
        avatarBtn?.setBackgroundImage(UIImage(named: "account_profile_avatar_btn"), forState: .Normal)
        avatarBtn?.layer.cornerRadius = 45
        avatarBtn?.clipsToBounds = true
        superview.addSubview(avatarBtn!)
        avatarBtn?.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 90, height: 90))
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(42)
        }
        avatarBtn?.addTarget(self, action: "avatarPressed", forControlEvents: .TouchUpInside)
        // 
        nickNameInput = UITextField()
        nickNameInput?.placeholder = NSLocalizedString("请输入您的昵称", comment: "")
        nickNameInput?.font = kTextInputFont
        nickNameInput?.textAlignment = NSTextAlignment.Center
        nickNameInput?.textColor = UIColor.blackColor()
        nickNameInput?.delegate = self
        superview.addSubview(nickNameInput!)
        nickNameInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(superview).offset(50)
            make.right.equalTo(superview).offset(-52)
            make.centerY.equalTo(avatarBtn!.snp_bottom).offset(60)
            make.height.equalTo(27.5)
        })
        self.inputFields.append(nickNameInput)
        //
        let sepLine = UIView()
        let lineColor = UIColor(white: 0.933, alpha: 1)
        sepLine.backgroundColor = lineColor
        superview.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(nickNameInput!)
            make.centerX.equalTo(nickNameInput!)
            make.height.equalTo(1)
            make.centerY.equalTo(nickNameInput!).offset(20)
        }
        //
        genderInput = UIButton()
        genderInput?.setTitle(NSLocalizedString("请选择您的性别", comment: ""), forState: .Normal)
        genderInput?.titleLabel?.font = kTextInputFont
        genderInput?.setTitleColor(kPlaceholderTextColor, forState: .Normal)
        superview.addSubview(genderInput!)
        genderInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(sepLine).offset(30)
            make.left.equalTo(nickNameInput!)
            make.right.equalTo(nickNameInput!)
            make.height.equalTo(27.5)
        })
        genderInput?.addTarget(self, action: "genderPressed", forControlEvents: .TouchUpInside)
        //
        let arrowIcon = UIImageView(image: UIImage(named: "account_profile_down_arrow"))
        genderInput?.addSubview(arrowIcon)
        arrowIcon.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(genderInput!)
            make.centerY.equalTo(genderInput!)
            make.width.equalTo(15.5)
            make.height.equalTo(9)
        }
        // 
        let sepLine2 = UIView()
        sepLine2.backgroundColor = lineColor
        superview.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(genderInput!)
            make.centerX.equalTo(genderInput!)
            make.centerY.equalTo(genderInput!).offset(20)
            make.height.equalTo(1)
        }
        //
        birthDateInput = UIButton()
        birthDateInput?.setTitle(NSLocalizedString("请选择您的生日", comment: ""), forState: .Normal)
        birthDateInput?.titleLabel?.font = kTextInputFont
        birthDateInput?.setTitleColor(kPlaceholderTextColor, forState: .Normal)
        superview.addSubview(birthDateInput!)
        birthDateInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(sepLine2).offset(30)
            make.left.equalTo(genderInput!)
            make.right.equalTo(genderInput!)
            make.height.equalTo(27.5)
        })
        birthDateInput?.addTarget(self, action: "birthDatePressed", forControlEvents: .TouchUpInside)
        //
        let arrowIcon2 = UIImageView(image: UIImage(named: "account_profile_down_arrow"))
        birthDateInput?.addSubview(arrowIcon2)
        arrowIcon2.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(birthDateInput!)
            make.centerY.equalTo(birthDateInput!)
            make.width.equalTo(15.5)
            make.height.equalTo(9)
        }
        // 
        let sepLine3 = UIView()
        sepLine3.backgroundColor = lineColor
        superview.addSubview(sepLine3)
        sepLine3.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(birthDateInput!)
            make.height.equalTo(1)
            make.centerY.equalTo(birthDateInput!).offset(20)
            make.centerX.equalTo(birthDateInput!)
        }
        // 
        pickerContainer = UIView()
        pickerContainer?.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview.addSubview(pickerContainer!)
        pickerContainer?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview.snp_bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        //
        let pickerHeader = UIView()
        pickerHeader.backgroundColor = UIColor(white: 0.92, alpha: 1)
        pickerContainer?.addSubview(pickerHeader)
        pickerHeader.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(pickerContainer!)
            make.left.equalTo(pickerContainer!)
            make.right.equalTo(pickerContainer!)
            make.height.equalTo(35)
        }
        
        pickerTitle = UILabel()
        pickerTitle?.text = ""
        pickerTitle?.font = UIFont.systemFontOfSize(14)
        pickerHeader.addSubview(pickerTitle!)
        pickerTitle?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(pickerHeader).offset(20)
            make.centerY.equalTo(pickerHeader)
            make.height.equalTo(pickerHeader)
            make.width.equalTo(60)
        })
        
        let pickerDoneBtn = UIButton()
        pickerDoneBtn.setTitle(NSLocalizedString("完成", comment: ""), forState: .Normal)
        pickerDoneBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        pickerDoneBtn.titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        pickerHeader.addSubview(pickerDoneBtn)
        pickerDoneBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(pickerHeader).offset(-20)
            make.centerY.equalTo(pickerHeader)
            make.height.equalTo(pickerHeader)
            make.width.equalTo(30)
        }
        pickerDoneBtn.addTarget(self, action: "pickerDonePressed", forControlEvents: .TouchUpInside)
        //
        genderPickerView = UIPickerView()
        genderPickerView?.delegate = self
        genderPickerView?.dataSource = self
        pickerContainer?.addSubview(genderPickerView!)
        genderPickerView?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(pickerContainer!)
            make.left.equalTo(pickerContainer!)
            make.bottom.equalTo(pickerContainer!)
            make.top.equalTo(pickerHeader.snp_bottom)
        })
        //
        birthDatePickerView = UIDatePicker()
        birthDatePickerView?.datePickerMode = .Date
        pickerContainer?.addSubview(birthDatePickerView!)
        birthDatePickerView?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(pickerContainer!)
            make.left.equalTo(pickerContainer!)
            make.bottom.equalTo(pickerContainer!)
            make.top.equalTo(pickerHeader.snp_bottom)
        })
    }
    
    func avatarPressed() {
        let alert = UIAlertController(title: NSLocalizedString("设置头像", comment: ""), message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.Camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .Default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func genderPressed() {
        self.nickNameInput?.resignFirstResponder()
        pickerTitle?.text = "您的性别"
        birthDatePickerView?.hidden = true
        genderPickerView?.hidden = false
        let superview = self.view
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            superview.layoutIfNeeded()
            }, completion: nil)
    }
    
    func birthDatePressed() {
        self.nickNameInput?.resignFirstResponder()
        pickerTitle?.text = "您的生日"
        birthDatePickerView?.hidden = false
        genderPickerView?.hidden = true
        let superview = self.view
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            superview.layoutIfNeeded()
            }, completion: nil)
    }
    
    func pickerDonePressed() {
        if !birthDatePickerView!.hidden{
            let selectedDate = birthDatePickerView?.date
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            birthDateInput?.setTitle(formatter.stringFromDate(selectedDate!), forState: .Normal)
            birthDateInput?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
        if !genderPickerView!.hidden{
            let selectedGender = genderPickerView?.selectedRowInComponent(0)
            if selectedGender == 0{
                genderInput?.setTitle("男", forState: .Normal)
            }else{
                genderInput?.setTitle("女", forState: .Normal)
            }
            genderInput?.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
        
        let superview = self.view
        superview.layoutIfNeeded()
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview.snp_bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            superview.layoutIfNeeded()
            }, completion: nil)
    }
    // MARK: Picker view的代理
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let titleLbl = UILabel()
        titleLbl.font = UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
        if row == 0 {
            titleLbl.text = "男"
        }else{
            titleLbl.text = "女"
        }
        titleLbl.textAlignment = NSTextAlignment.Center
        return titleLbl
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedTitle = pickerView.viewForRow(row, forComponent: component) as! UILabel
        selectedTitle.textColor = kHighlightedRedTextColor
        let otherTitle = pickerView.viewForRow(1 - row, forComponent: component) as! UILabel
        otherTitle.textColor = UIColor.blackColor()
    }
    
    // MARK: ImagePicker的代理
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatarBtn?.setBackgroundImage(image, forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
