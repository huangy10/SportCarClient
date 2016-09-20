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
    var selectedAvatarImage: UIImage?
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
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), for: UIControlState())
        backBtn.addTarget(self, action: #selector(ProfileInfoController.backBtnPressed), for: .touchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.2, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func navBarRigthBtn() -> UIBarButtonItem! {
        let nextStepBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 42, height: 16))
        nextStepBtn.setTitle(NSLocalizedString("下一步", comment: ""), for: UIControlState())
        nextStepBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        nextStepBtn.titleLabel?.font = kBarTextFont
        nextStepBtn.addTarget(self, action: #selector(ProfileInfoController.nextBtnPressed), for: .touchUpInside)
        let rightBtnItem = UIBarButtonItem(customView: nextStepBtn)
        return rightBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func nextBtnPressed() {
        // 发起请求先先禁用next按钮
        nextBtn?.isEnabled = false
        //
        guard let nickName = nickNameInput?.text else{
            showToast(LS("请填写昵称"))
            return
        }
        guard let gender = genderInput?.titleLabel?.text , gender != "" else{
            showToast(LS("请选择性别"))
            return
        }

        guard let birthDate = birthDateInput?.titleLabel?.text , birthDate != "" else{
            showToast(LS("请选择生日"))
            return
        }
        guard let avatar = selectedAvatarImage else{
            showToast(LS("请选择头像"))
            return
        }
        let requester = AccountRequester2.sharedInstance
        pp_showProgressView()
        requester.postToSetProfile(nickName, gender: gender, birthDate: birthDate, avatar: avatar, onSuccess: { (_) -> () in
            self.pp_hideProgressView()
            self.nextBtn?.isEnabled = true
            let ctrl = SportCarSelectController()
            self.navigationController?.pushViewController(ctrl, animated: true)
            }, onProgress: { (progress) in
                self.pp_updateProgress(progress)
            }) { (code) -> () in
                self.pp_hideProgressView()
                self.nextBtn?.isEnabled = true
                switch code! {
                case "0000":
                    self.showToast(LS("网络连接失败"), onSelf: true)
                    break
                default:
                    self.showToast(LS("未知错误"), onSelf: true)
                    break
                }
        }
        
    }
    
    override func createSubviews(){
        super.createSubviews()
        navigationBarSettings()
        let superview = self.view
        superview?.backgroundColor = UIColor.white
        //
        avatarBtn = UIButton()
        avatarBtn?.setImage(UIImage(named: "account_profile_avatar_btn"), for: UIControlState())
        avatarBtn?.layer.cornerRadius = 45
        avatarBtn?.clipsToBounds = true
        superview?.addSubview(avatarBtn!)
        avatarBtn?.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 90, height: 90))
            make.centerX.equalTo(superview)
            make.top.equalTo(superview).offset(42)
        }
        avatarBtn?.addTarget(self, action: #selector(ProfileInfoController.avatarPressed), for: .touchUpInside)
        // 
        nickNameInput = UITextField()
        nickNameInput?.placeholder = NSLocalizedString("请输入您的昵称", comment: "")
        nickNameInput?.font = kTextInputFont
        nickNameInput?.textAlignment = NSTextAlignment.center
        nickNameInput?.textColor = UIColor.black
        nickNameInput?.delegate = self
        superview?.addSubview(nickNameInput!)
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
        superview?.addSubview(sepLine)
        sepLine.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(nickNameInput!)
            make.centerX.equalTo(nickNameInput!)
            make.height.equalTo(1)
            make.centerY.equalTo(nickNameInput!).offset(20)
        }
        //
        genderInput = UIButton()
        genderInput?.setTitle(NSLocalizedString("请选择您的性别", comment: ""), for: UIControlState())
        genderInput?.titleLabel?.font = kTextInputFont
        genderInput?.setTitleColor(kPlaceholderTextColor, for: UIControlState())
        superview?.addSubview(genderInput!)
        genderInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(sepLine).offset(30)
            make.left.equalTo(nickNameInput!)
            make.right.equalTo(nickNameInput!)
            make.height.equalTo(27.5)
        })
        genderInput?.addTarget(self, action: #selector(ProfileInfoController.genderPressed), for: .touchUpInside)
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
        superview?.addSubview(sepLine2)
        sepLine2.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(genderInput!)
            make.centerX.equalTo(genderInput!)
            make.centerY.equalTo(genderInput!).offset(20)
            make.height.equalTo(1)
        }
        //
        birthDateInput = UIButton()
        birthDateInput?.setTitle(NSLocalizedString("请选择您的生日", comment: ""), for: UIControlState())
        birthDateInput?.titleLabel?.font = kTextInputFont
        birthDateInput?.setTitleColor(kPlaceholderTextColor, for: UIControlState())
        superview?.addSubview(birthDateInput!)
        birthDateInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerY.equalTo(sepLine2).offset(30)
            make.left.equalTo(genderInput!)
            make.right.equalTo(genderInput!)
            make.height.equalTo(27.5)
        })
        birthDateInput?.addTarget(self, action: #selector(ProfileInfoController.birthDatePressed), for: .touchUpInside)
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
        superview?.addSubview(sepLine3)
        sepLine3.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(birthDateInput!)
            make.height.equalTo(1)
            make.centerY.equalTo(birthDateInput!).offset(20)
            make.centerX.equalTo(birthDateInput!)
        }
        // 
        pickerContainer = UIView()
        pickerContainer?.backgroundColor = UIColor(white: 0.945, alpha: 1)
        superview?.addSubview(pickerContainer!)
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
        pickerTitle?.font = UIFont.systemFont(ofSize: 14)
        pickerHeader.addSubview(pickerTitle!)
        pickerTitle?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(pickerHeader).offset(20)
            make.centerY.equalTo(pickerHeader)
            make.height.equalTo(pickerHeader)
            make.width.equalTo(60)
        })
        
        let pickerDoneBtn = UIButton()
        pickerDoneBtn.setTitle(NSLocalizedString("完成", comment: ""), for: UIControlState())
        pickerDoneBtn.setTitleColor(kHighlightedRedTextColor, for: UIControlState())
        pickerDoneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightLight)
        pickerHeader.addSubview(pickerDoneBtn)
        pickerDoneBtn.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(pickerHeader).offset(-20)
            make.centerY.equalTo(pickerHeader)
            make.height.equalTo(pickerHeader)
            make.width.equalTo(30)
        }
        pickerDoneBtn.addTarget(self, action: #selector(ProfileInfoController.pickerDonePressed), for: .touchUpInside)
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
        birthDatePickerView?.datePickerMode = .date
        pickerContainer?.addSubview(birthDatePickerView!)
        birthDatePickerView?.snp_makeConstraints(closure: { (make) -> Void in
            make.right.equalTo(pickerContainer!)
            make.left.equalTo(pickerContainer!)
            make.bottom.equalTo(pickerContainer!)
            make.top.equalTo(pickerHeader.snp_bottom)
        })
    }
    
    func avatarPressed() {
        let alert = UIAlertController(title: NSLocalizedString("设置头像", comment: ""), message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: NSLocalizedString("拍照", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.camera
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相机", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("从相册中选择", comment: ""), style: .default, handler: { (action) -> Void in
            let sourceType = UIImagePickerControllerSourceType.photoLibrary
            guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
                let alert = UIAlertController(title: "错误", message: "无法打开相册", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("取消", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    func genderPressed() {
        self.nickNameInput?.resignFirstResponder()
        pickerTitle?.text = "您的性别"
        birthDatePickerView?.isHidden = true
        genderPickerView?.isHidden = false
        let superview = self.view
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            superview?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func birthDatePressed() {
        self.nickNameInput?.resignFirstResponder()
        pickerTitle?.text = "您的生日"
        birthDatePickerView?.isHidden = false
        genderPickerView?.isHidden = true
        let superview = self.view
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            superview?.layoutIfNeeded()
            }, completion: nil)
    }
    
    func pickerDonePressed() {
        if !birthDatePickerView!.isHidden{
            let selectedDate = birthDatePickerView?.date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            birthDateInput?.setTitle(formatter.string(from: selectedDate!), for: UIControlState())
            birthDateInput?.setTitleColor(UIColor.black, for: UIControlState())
        }
        if !genderPickerView!.isHidden{
            let selectedGender = genderPickerView?.selectedRow(inComponent: 0)
            if selectedGender == 0{
                genderInput?.setTitle("男", for: UIControlState())
            }else{
                genderInput?.setTitle("女", for: UIControlState())
            }
            genderInput?.setTitleColor(UIColor.black, for: UIControlState())
        }
        
        let superview = self.view
        superview?.layoutIfNeeded()
        pickerContainer?.snp_remakeConstraints(closure: { (make) -> Void in
            make.top.equalTo(superview.snp_bottom)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
            make.height.equalTo(234)
        })
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            superview?.layoutIfNeeded()
            }, completion: nil)
    }
    // MARK: Picker view的代理
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let titleLbl = UILabel()
        titleLbl.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightLight)
        if row == 0 {
            titleLbl.text = "男"
        }else{
            titleLbl.text = "女"
        }
        titleLbl.textAlignment = NSTextAlignment.center
        return titleLbl
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedTitle = pickerView.view(forRow: row, forComponent: component) as! UILabel
        selectedTitle.textColor = kHighlightedRedTextColor
        let otherTitle = pickerView.view(forRow: 1 - row, forComponent: component) as! UILabel
        otherTitle.textColor = UIColor.black
    }
    
    // MARK: ImagePicker的代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        avatarBtn?.setImage(image, for: UIControlState())
        selectedAvatarImage = image
        self.dismiss(animated: true, completion: nil)
    }
}
