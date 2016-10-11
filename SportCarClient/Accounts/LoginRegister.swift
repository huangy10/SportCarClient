//
//  Login.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/7.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class LoginRegisterController: InputableViewController {
    /**
    *  登陆和注册页面
    */
    var board : UIScrollView?
    
    var bgImgView: UIImageView!
    
    var loginPhoneInput: TextFieldWithLeadingIconView?
    var loginPasswordInput: TextFieldWithLeadingIconView?
    var registerPhoneInput: TextFieldWithLeadingIconView?
    var registerPasswordInput: TextFieldWithLeadingIconView?
    var registerAuthCode: TextFieldWithLeadingIconView?
    var titleLbl: UILabel?
    var titleLogo: UIImageView!
    var titleBtnIcon: UIImageView?
    var titleLoginBtn: UIButton?
    var titleRegisterBtn: UIButton?
    
    let requester = AccountRequester2.sharedInstance
    
    // 一些需要干预状态的按钮
    var authCodeBtn: AuthCodeBtnView?
    var loginBtn: UIButton?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        bgImgView.snp.remakeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.width.equalTo(bgImgView.snp.height).multipliedBy(0.807)
        }
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseIn, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
 
    override func createSubviews() {
        super.createSubviews()
        // 创建所有的子控件
        self.navigationItem.titleView = self.barTitleView()
        self.navigationItem.leftBarButtonItem = self.leftBarBtn()
        //
        let superview = self.view!
        superview.backgroundColor = UIColor.black
        //
        bgImgView = UIImageView(image: UIImage(named: "account_bg_image"))
        superview.addSubview(bgImgView)
        bgImgView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(-50)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(bgImgView.snp.height).multipliedBy(0.807)
        }
        //
        titleLbl = UILabel()
        titleLbl?.clipsToBounds = true
//        titleLbl?.text = "跑车范"
        titleLbl?.font = UIFont.systemFont(ofSize: 30, weight: UIFontWeightSemibold)
        titleLbl?.textColor = UIColor.white
        titleLbl?.textAlignment = NSTextAlignment.center
        superview.addSubview(titleLbl!)
        titleLbl!.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(superview)
            make.height.equalTo(125)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview)
        }
        //
        titleLogo = UIImageView(image: UIImage(named: "account_title_logo"))
        titleLbl?.addSubview(titleLogo)
        titleLogo.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(titleLbl!)
            make.height.equalTo(30)
            make.width.equalTo(81)
        }
        //
        board = UIScrollView()
        board?.backgroundColor = UIColor.clear
        board?.isPagingEnabled = true
        superview.addSubview(board!)
        board?.snp.makeConstraints({ (make) -> Void in
            make.top.equalTo(titleLogo.snp.bottom).offset(43)
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        })
        board?.contentSize = CGSize(width: superview.frame.size.width * 2, height: 300)
        //
        let register = self.registerView()
        board!.addSubview(register!)
        register?.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(board!)
            make.left.equalTo(board!)
            make.width.equalTo(board!)
            make.height.equalTo(board!)
        }
        board?.setContentOffset(CGPoint(x: superview.frame.size.width, y: 0), animated: false)
        board?.delegate = self
        //
        let login = self.loginView()
        board!.addSubview(login!)
        login?.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(board!)
            make.left.equalTo(register!.snp.right)
            make.width.equalTo(board!)
            make.height.equalTo(board!)
        }
        
        //
        self.inputFields = [loginPhoneInput, loginPasswordInput, registerPasswordInput, registerPhoneInput, registerAuthCode]
    }
    
    func loginView() -> UIView! {
        let container = UIView()
        //
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.white
        inputContainer.layer.cornerRadius = 4
        container.addSubview(inputContainer)
        inputContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(container)
            make.centerX.equalTo(container)
            make.height.equalTo(100)
            make.width.equalTo(container).multipliedBy(0.733)
        }
        //
        let seqLine = UIView()
        seqLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        inputContainer.addSubview(seqLine)
        seqLine.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        //
        loginPhoneInput = TextFieldWithLeadingIconView()
        loginPhoneInput?.delegate = self
        loginPhoneInput?.placeholder = NSLocalizedString("请输入您的手机号", comment: "")
        loginPhoneInput?.keyboardType = .numberPad
        loginPhoneInput?.font = UIFont.systemFont(ofSize: 14)
        loginPhoneInput?.leftViewMode = UITextFieldViewMode.always
        let loginPhoneInputIcon = UIImageView(image: UIImage(named: "account_phone_input"))
        loginPhoneInput?.leftView = loginPhoneInputIcon
        inputContainer.addSubview(loginPhoneInput!)
        loginPhoneInput!.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.5)
            make.left.equalTo(inputContainer).offset(10)
            make.right.equalTo(inputContainer).offset(-10)
            make.top.equalTo(inputContainer)
        })
        //
        loginPasswordInput = TextFieldWithLeadingIconView()
        loginPasswordInput?.delegate = self
        loginPasswordInput?.placeholder = NSLocalizedString("请输入密码", comment: "")
        loginPasswordInput?.isSecureTextEntry = true
        loginPasswordInput?.leftViewMode = UITextFieldViewMode.always
        loginPasswordInput?.font = UIFont.systemFont(ofSize: 14)
        let loginPasswordInputIcon =  UIImageView(image: UIImage(named: "account_password_input"))
        loginPasswordInput?.leftView = loginPasswordInputIcon
        container.addSubview(loginPasswordInput!)
        loginPasswordInput!.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.5)
            make.left.equalTo(inputContainer).offset(10)
            make.right.equalTo(inputContainer).offset(-10)
            make.bottom.equalTo(inputContainer)
        }
        //
        let forgetBtn = UIButton()
//        forgetBtn.setTitle(NSLocalizedString("忘记密码?", comment: ""), for: .normal)
//        forgetBtn.titleLabel?.adjustsFontSizeToFitWidth = true
//        forgetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
//        forgetBtn.setTitleColor(kTextGray28, for: .normal)
        container.addSubview(forgetBtn)
        forgetBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(17)
            make.width.equalTo(60)
            make.top.equalTo(inputContainer.snp.bottom).offset(15)
            make.right.equalTo(inputContainer)
        }
        forgetBtn.addTarget(self, action: #selector(LoginRegisterController.forgetBtnPressed), for: .touchUpInside)
        forgetBtn.addSubview(UILabel.self)
            .config(14, fontWeight: UIFontWeightRegular, textColor: kTextGray28, textAlignment: .center, text: LS("忘记密码?"))
            .layout { (make) in
                make.center.equalTo(forgetBtn)
        }
        //
        let login = UIButton()
        login.setBackgroundImage(UIImage(named: "account_login_btn"), for: .normal)
        login.layer.shadowColor = UIColor(red: 0.95, green: 0.21, blue: 0.21, alpha: 1).cgColor
        login.layer.shadowOffset = CGSize(width: 0, height: 3)
        login.layer.shadowRadius = 7
        login.layer.shadowOpacity = 1
        container.addSubview(login)
        login.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(inputContainer.snp.bottom).offset(75)
            make.centerX.equalTo(container)
        }
        login.addTarget(self, action: #selector(LoginRegisterController.loginPressed), for: .touchUpInside)
        self.loginBtn = login
        return container
    }
    
    func registerView() -> UIView! {
        let container = UIView()
        //
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.white
        inputContainer.layer.cornerRadius = 4
        container.addSubview(inputContainer)
        inputContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(container)
            make.centerX.equalTo(container)
            make.height.equalTo(150)
            make.width.equalTo(container).multipliedBy(0.733)
        }
        //
        let seqLine1 = UIView()
        seqLine1.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine1)
        seqLine1.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp.top).offset(50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        let seqLine2 = UIView()
        seqLine2.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine2)
        seqLine2.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp.bottom).offset(-50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        //
        registerPhoneInput = TextFieldWithLeadingIconView()
        registerPhoneInput?.delegate = self
        registerPhoneInput?.placeholder = NSLocalizedString("请输入您的手机号", comment: "")
        registerPhoneInput?.keyboardType = .numberPad
        registerPhoneInput?.font = UIFont.systemFont(ofSize: 14)
        registerPhoneInput?.leftViewMode = UITextFieldViewMode.always
        let registerPhoneInputIcon = UIImageView(image: UIImage(named: "account_phone_input"))
        registerPhoneInput?.leftView = registerPhoneInputIcon
        inputContainer.addSubview(registerPhoneInput!)
        registerPhoneInput?.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.3333)
            make.left.equalTo(inputContainer).offset(10)
            make.width.equalTo(inputContainer).multipliedBy(0.65)
            make.top.equalTo(inputContainer)
        })
        //
        let sendCodeBtn = AuthCodeBtnView()
        sendCodeBtn.setTitle(NSLocalizedString("获取验证码", comment: ""), for: .normal)
        sendCodeBtn.displayText = NSLocalizedString("获取验证码", comment: "")
        sendCodeBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        sendCodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        inputContainer.addSubview(sendCodeBtn)
        sendCodeBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!.snp.right)
            make.right.equalTo(inputContainer).offset(-13)
            make.centerY.equalTo(registerPhoneInput!)
        }
        sendCodeBtn.addTarget(self, action: #selector(LoginRegisterController.sendAuthCodePressed), for: .touchUpInside)
        authCodeBtn = sendCodeBtn
        //
        registerAuthCode = TextFieldWithLeadingIconView()
        registerAuthCode?.delegate = self
        registerAuthCode?.placeholder = NSLocalizedString("请输入验证码", comment: "")
        registerAuthCode?.font = UIFont.systemFont(ofSize: 14)
        registerAuthCode?.leftViewMode = UITextFieldViewMode.always
        let registerAuthCodeIcon = UIImageView(image: UIImage(named: "account_auth_code"))
        registerAuthCode?.leftView = registerAuthCodeIcon
        inputContainer.addSubview(registerAuthCode!)
        registerAuthCode!.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!)
            make.top.equalTo(registerPhoneInput!.snp.bottom)
            make.right.equalTo(sendCodeBtn)
        }
        //
        registerPasswordInput = TextFieldWithLeadingIconView()
        registerPasswordInput?.delegate = self
        registerPasswordInput?.placeholder = NSLocalizedString("请输入密码", comment: "")
        registerPasswordInput?.isSecureTextEntry = true
        registerPasswordInput?.font = UIFont.systemFont(ofSize: 14)
        registerPasswordInput?.leftViewMode = UITextFieldViewMode.always
        let registerPasswordInputIcon = UIImageView(image: UIImage(named: "account_password_input"))
        registerPasswordInput?.leftView = registerPasswordInputIcon
        inputContainer.addSubview(registerPasswordInput!)
        registerPasswordInput?.snp.makeConstraints({ (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.width.equalTo(registerAuthCode!)
            make.top.equalTo(registerAuthCode!.snp.bottom)
            make.centerX.equalTo(registerAuthCode!)
        })
        // 
        let agreementBtn = UIButton()
        agreementBtn.setTitle(NSLocalizedString("用户协议", comment: ""), for: .normal)
        agreementBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        agreementBtn.setTitleColor(kHighlightedRedTextColor, for: .normal)
        container.addSubview(agreementBtn)
        agreementBtn.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(17)
            make.width.equalTo(60)
            make.top.equalTo(inputContainer.snp.bottom).offset(15)
            make.right.equalTo(inputContainer)
        }
        agreementBtn.addTarget(self, action: #selector(LoginRegisterController.checkAgreement), for: .touchUpInside)
        
        let agreementCheckIcon = UIImageView(image: UIImage(named: "account_agreement_check"))
        container.addSubview(agreementCheckIcon)
        agreementCheckIcon.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(agreementBtn)
            make.width.equalTo(agreementCheckIcon.snp.height)
            make.top.equalTo(agreementBtn)
            make.right.equalTo(agreementBtn.snp.left)
        }
        
        let registerBtn = UIButton()
        registerBtn.setBackgroundImage(UIImage(named: "account_register_btn"), for: .normal)
        registerBtn.layer.shadowColor = UIColor(red: 0.95, green: 0.21, blue: 0.21, alpha: 1).cgColor
        registerBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerBtn.layer.shadowRadius = 7
        registerBtn.layer.shadowOpacity = 1
        container.addSubview(registerBtn)
        registerBtn.snp.makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(inputContainer.snp.bottom).offset(75)
            make.centerX.equalTo(container)
        }
        registerBtn.addTarget(self, action: #selector(LoginRegisterController.registerPressed), for: .touchUpInside)
        return container
    }
    /**
     生成navigationbar的titleview
     
     - returns: title view
     */
    func barTitleView() -> (UIView!){
        // 创建容纳整个title的容器
        let barHeight = self.navigationController?.navigationBar.frame.size.height
        let containerWidth = self.view.frame.size.width * 0.8
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerWidth, height: barHeight!))
        // 创建登录按钮
        titleLoginBtn = UIButton()
        // loginBtn.setBackgroundImage(UIImage(named: "account_header_button"), forState: .Normal)
        titleLoginBtn?.setTitleColor(kBarBgColor, for: .normal)
        titleLoginBtn?.setTitle(NSLocalizedString("登录", comment: ""), for: .normal)
        titleLoginBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleLoginBtn!)
        titleLoginBtn?.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp.centerX).offset(9)
        }
        titleLoginBtn?.addTarget(self, action: #selector(LoginRegisterController.barTitleBtnPressed(_:)), for: .touchUpInside)
        
        // 创建注册按钮
        titleRegisterBtn = UIButton()
        titleRegisterBtn?.setTitleColor(UIColor.white, for: .normal)
        titleRegisterBtn?.setTitle(NSLocalizedString("注册", comment: ""), for: .normal)
        titleRegisterBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleRegisterBtn!)
        titleRegisterBtn?.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp.centerX).offset(9)
        }
        titleRegisterBtn?.addTarget(self, action: #selector(LoginRegisterController.barTitleBtnPressed(_:)), for: .touchUpInside)

        // 创建背景ICON
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon!)
        container.sendSubview(toBack: titleBtnIcon!)
        titleBtnIcon?.snp.makeConstraints({ (make) -> Void in
            make.edges.equalTo(titleLoginBtn!)
        })
        return container
    }
    
    func leftBarBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
//        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(LoginRegisterController.backBtnPressed(_:)), for: .touchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func barTitleBtnPressed(_ sender: UIButton) {
        if sender.titleLabel?.text == "注册" && board?.contentOffset.x != 0{
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.edges.equalTo(titleRegisterBtn!)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleRegisterBtn?.setTitleColor(kBarBgColor, for: .normal)
                self.titleLoginBtn?.setTitleColor(UIColor.white, for: .normal)
                self.board?.contentOffset = CGPoint(x: 0, y: 0)
                }, completion: nil)
        }else if sender.titleLabel?.text == "登录" && board?.contentOffset.x == 0{
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.edges.equalTo(titleLoginBtn!)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleLoginBtn?.setTitleColor(kBarBgColor, for: .normal)
                self.titleRegisterBtn?.setTitleColor(UIColor.white, for: .normal)
                self.board?.contentOffset = CGPoint(x: self.view.frame.size.width, y: 0)
                }, completion: nil)
        }
    }
    // MARK: 按钮响应
    
    func backBtnPressed(_ sender: UIButton) {
//        print("haha")
    }
    
    func loginPressed() {
        // 首先确保手机号码和密码都已经填入了数据
        guard let username = loginPhoneInput?.text , username.characters.count > 0 else{
            showToast(LS("请输入手机号码"), onSelf: true)
            return
        }
        
        guard let password = loginPasswordInput?.text , password.characters.count > 0 else{
            showToast(LS("请输入密码"), onSelf: true)
            return
        }
        loginBtn?.isEnabled = false
        _ = self.requester.postToLogin(username, password: password, onSuccess: { (json) -> (Void) in
            self.loginBtn?.isEnabled = true
            let user: User = try! MainManager.sharedManager.getOrCreate(json!)
            MainManager.sharedManager.login(user, jwtToken: json!["jwt_token"].stringValue)
            let app = AppManager.sharedAppManager
            app.guideToContent()
            }) { (code) -> (Void) in
                self.loginBtn?.isEnabled = true
                // 显示错误信息
                var errorMessage = ""
                if let errorCode = code {
                    switch errorCode {
                    case "0000":
                        errorMessage = "网络错误"
                        break
                    case "1000", "Invalid username":
                        errorMessage = "该手机号码尚未注册"
                        break
                    case "1001", "Password Incorrect":
                        errorMessage = "密码错误"
                    default:
                        errorMessage = "未知错误"
                        break
                    }
                }else{
                    // 没有接收到错误信息
                    assertionFailure()
                }
                self.showToast(errorMessage, onSelf: true)
        }
    }
    
    func registerPressed() {
        // 检查所有的空是否都填写了
        guard let phone = registerPhoneInput?.text else{
            showToast(LS("请输入手机号"), onSelf: true)
            return
        }
        guard let authCode = registerAuthCode?.text else{
            showToast(LS("请输入验证码"), onSelf: true)
            return
        }
        guard let passwd = registerPasswordInput?.text else{
            showToast(LS("请输入密码"), onSelf: true)
            return
        }
    
        _ = self.requester.postToRegister(phone, passwd: passwd, authCode: authCode, onSuccess: { (json) -> (Void) in
            let user: User = try! MainManager.sharedManager.getOrCreate(json!)
            MainManager.sharedManager.login(user, jwtToken: json!["jwt_token"].stringValue)
            self.registerConfirm()
            }) { (code) -> (Void) in
                switch code! {
                case "1003":
                    self.showToast(LS("密码太短，密码长度请设置在4位以上"), onSelf: true)
                case "1002":
                    self.showToast(LS("验证码错误"), onSelf: true)
                case "0000":
                    self.showToast(LS("请检查您的网络连接"), onSelf: true)
                default:
                    self.showToast(LS("您的手机号已经被注册"), onSelf: true)
                }
        }
    }
    
    func forgetBtnPressed() {
        let ctrl = ResetPasswordController()
        let nav = BlackBarNavigationController(rootViewController: ctrl, blackNavTitle: true)
        self.present(nav, animated: true, completion: nil)
        //
//        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    func checkAgreement() {
        let agreementCtrl = AgreementController()
//        self.navigationController?.pushViewController(agreementCtrl, animated: true)
        present(agreementCtrl.toNavWrapper(), animated: true, completion: nil)
    }
    
    func sendAuthCodePressed() {
        guard let phone = registerPhoneInput?.text , phone.characters.count > 0 else{
            showToast(LS("请输入手机号"), onSelf: true)
            return
        }
        authCodeBtn?.status = AuthCodeBtnViewStatus.pending
        _ = self.requester.requestAuthCode(registerPhoneInput!.text!, onSuccess: { () -> (Void) in
            self.authCodeBtn?.status = AuthCodeBtnViewStatus.countDown
            }) { () -> (Void) in
                // 弹窗
                self.authCodeBtn?.status = AuthCodeBtnViewStatus.normal
                self.showToast(LS("获取验证码失败"), onSelf: true)
        }
    }
    
    // MARK: 网络回调
    func registerConfirm(){
        let nextStep = ProfileInfoController()
        self.navigationController?.pushViewController(nextStep, animated: true)
    }
    
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
        self.titleLbl?.snp.updateConstraints({ (make) -> Void in
            make.height.equalTo(125)
        })
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let result = super.textFieldShouldBeginEditing(textField)
        self.tapper?.isEnabled = true
        self.titleLbl?.snp.updateConstraints({ (make) -> Void in
            make.height.equalTo(0)
        })
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
        return true && result
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < self.view.frame.width/2 {
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.edges.equalTo(titleRegisterBtn!)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleRegisterBtn?.setTitleColor(kBarBgColor, for: .normal)
                self.titleLoginBtn?.setTitleColor(UIColor.white, for: .normal)
                }, completion: nil)
        }else{
            titleBtnIcon?.snp.remakeConstraints({ (make) -> Void in
                make.edges.equalTo(titleLoginBtn!)
            })
            UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleLoginBtn?.setTitleColor(kBarBgColor, for: .normal)
                self.titleRegisterBtn?.setTitleColor(UIColor.white, for: .normal)
                }, completion: nil)
        }
    }
}

class TextFieldWithLeadingIconView : UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var frame = super.leftViewRect(forBounds: bounds)
        let size = CGSize(width: 16, height: 16)
        frame.size = size
        frame.origin.y = 3 + bounds.size.height / 4
        return frame
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        var frame = super.textRect(forBounds: bounds)
        frame.origin.x = 30
        return frame
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        var frame = super.textRect(forBounds: bounds)
        frame.origin.x = 30
        return frame
    }
}
