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
//    init(){
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
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
    
    let requester = AccountRequester.sharedRequester
    
    // 一些需要干预状态的按钮
    var authCodeBtn: AuthCodeBtnView?
    var loginBtn: UIButton?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.updateConstraints()
        self.view.layoutIfNeeded()
        bgImgView.snp_remakeConstraints { (make) -> Void in
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.width.equalTo(bgImgView.snp_height).multipliedBy(0.807)
        }
        UIView.animateWithDuration(10, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
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
        superview.backgroundColor = UIColor.blackColor()
        //
        bgImgView = UIImageView(image: UIImage(named: "account_bg_image"))
        superview.addSubview(bgImgView)
        bgImgView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(superview).offset(-50)
            make.top.equalTo(superview)
            make.bottom.equalTo(superview)
            make.width.equalTo(bgImgView.snp_height).multipliedBy(0.807)
        }
        //
        titleLbl = UILabel()
        titleLbl?.clipsToBounds = true
//        titleLbl?.text = "跑车范"
        titleLbl?.font = UIFont.systemFontOfSize(30, weight: UIFontWeightBold)
        titleLbl?.textColor = UIColor.whiteColor()
        titleLbl?.textAlignment = NSTextAlignment.Center
        superview.addSubview(titleLbl!)
        titleLbl!.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(superview)
            make.height.equalTo(125)
            make.centerX.equalTo(superview)
            make.top.equalTo(superview)
        }
        //
        titleLogo = UIImageView(image: UIImage(named: "account_title_logo"))
        titleLbl?.addSubview(titleLogo)
        titleLogo.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(titleLbl!)
            make.height.equalTo(23)
            make.width.equalTo(81)
        }
        //
        board = UIScrollView()
        board?.backgroundColor = UIColor.clearColor()
        board?.pagingEnabled = true
        superview.addSubview(board!)
        board?.snp_makeConstraints(closure: { (make) -> Void in
            make.top.equalTo(titleLogo.snp_bottom).offset(43)
            make.bottom.equalTo(superview)
            make.left.equalTo(superview)
            make.right.equalTo(superview)
        })
        board?.contentSize = CGSize(width: superview.frame.size.width * 2, height: 300)
        //
        let register = self.registerView()
        board!.addSubview(register)
        register.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(board!)
            make.left.equalTo(board!)
            make.width.equalTo(board!)
            make.height.equalTo(board!)
        }
        board?.setContentOffset(CGPoint(x: superview.frame.size.width, y: 0), animated: false)
        board?.delegate = self
        //
        let login = self.loginView()
        board!.addSubview(login)
        login.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(board!)
            make.left.equalTo(register.snp_right)
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
        inputContainer.backgroundColor = UIColor.whiteColor()
        inputContainer.layer.cornerRadius = 4
        container.addSubview(inputContainer)
        inputContainer.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(container)
            make.centerX.equalTo(container)
            make.height.equalTo(100)
            make.width.equalTo(container).multipliedBy(0.733)
        }
        //
        let seqLine = UIView()
        seqLine.backgroundColor = UIColor(white: 0.933, alpha: 1)
        inputContainer.addSubview(seqLine)
        seqLine.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        //
        loginPhoneInput = TextFieldWithLeadingIconView()
        loginPhoneInput?.delegate = self
        loginPhoneInput?.placeholder = NSLocalizedString("请输入您的手机号", comment: "")
        loginPhoneInput?.font = UIFont.systemFontOfSize(12)
        loginPhoneInput?.leftViewMode = UITextFieldViewMode.Always
        let loginPhoneInputIcon = UIImageView(image: UIImage(named: "account_phone_input"))
        loginPhoneInput?.leftView = loginPhoneInputIcon
        inputContainer.addSubview(loginPhoneInput!)
        loginPhoneInput!.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.5)
            make.left.equalTo(inputContainer).offset(10)
            make.right.equalTo(inputContainer).offset(-10)
            make.top.equalTo(inputContainer)
        })
        //
        loginPasswordInput = TextFieldWithLeadingIconView()
        loginPasswordInput?.delegate = self
        loginPasswordInput?.placeholder = NSLocalizedString("请输入密码", comment: "")
        loginPasswordInput?.secureTextEntry = true
        loginPasswordInput?.leftViewMode = UITextFieldViewMode.Always
        loginPasswordInput?.font = UIFont.systemFontOfSize(12)
        let loginPasswordInputIcon =  UIImageView(image: UIImage(named: "account_password_input"))
        loginPasswordInput?.leftView = loginPasswordInputIcon
        container.addSubview(loginPasswordInput!)
        loginPasswordInput!.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.5)
            make.left.equalTo(inputContainer).offset(10)
            make.right.equalTo(inputContainer).offset(-10)
            make.bottom.equalTo(inputContainer)
        }
        //
        let forgetBtn = UIButton()
        forgetBtn.setTitle(NSLocalizedString("忘记密码?", comment: ""), forState: .Normal)
        forgetBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        forgetBtn.setTitleColor(UIColor(white: 0.72, alpha: 1), forState: .Normal)
        container.addSubview(forgetBtn)
        forgetBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(17)
            make.width.equalTo(60)
            make.top.equalTo(inputContainer.snp_bottom).offset(15)
            make.right.equalTo(inputContainer)
        }
        forgetBtn.addTarget(self, action: #selector(LoginRegisterController.forgetBtnPressed), forControlEvents: .TouchUpInside)
        //
        let login = UIButton()
        login.setBackgroundImage(UIImage(named: "account_login_btn"), forState: .Normal)
        login.layer.shadowColor = UIColor(red: 0.95, green: 0.21, blue: 0.21, alpha: 1).CGColor
        login.layer.shadowOffset = CGSize(width: 0, height: 3)
        login.layer.shadowRadius = 7
        login.layer.shadowOpacity = 1
        container.addSubview(login)
        login.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(inputContainer.snp_bottom).offset(75)
            make.centerX.equalTo(container)
        }
        login.addTarget(self, action: #selector(LoginRegisterController.loginPressed), forControlEvents: .TouchUpInside)
        self.loginBtn = login
        return container
    }
    
    func registerView() -> UIView! {
        let container = UIView()
        //
        let inputContainer = UIView()
        inputContainer.backgroundColor = UIColor.whiteColor()
        inputContainer.layer.cornerRadius = 4
        container.addSubview(inputContainer)
        inputContainer.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(container)
            make.centerX.equalTo(container)
            make.height.equalTo(150)
            make.width.equalTo(container).multipliedBy(0.733)
        }
        //
        let seqLine1 = UIView()
        seqLine1.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine1)
        seqLine1.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp_top).offset(50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        let seqLine2 = UIView()
        seqLine2.backgroundColor = UIColor(white: 0.953, alpha: 1)
        inputContainer.addSubview(seqLine2)
        seqLine2.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(1)
            make.centerY.equalTo(inputContainer.snp_bottom).offset(-50)
            make.left.equalTo(inputContainer).offset(13)
            make.right.equalTo(inputContainer).offset(-13)
        }
        //
        registerPhoneInput = TextFieldWithLeadingIconView()
        registerPhoneInput?.delegate = self
        registerPhoneInput?.placeholder = NSLocalizedString("请输入您的手机号", comment: "")
        registerPhoneInput?.font = UIFont.systemFontOfSize(12)
        registerPhoneInput?.leftViewMode = UITextFieldViewMode.Always
        let registerPhoneInputIcon = UIImageView(image: UIImage(named: "account_phone_input"))
        registerPhoneInput?.leftView = registerPhoneInputIcon
        inputContainer.addSubview(registerPhoneInput!)
        registerPhoneInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(inputContainer).multipliedBy(0.3333)
            make.left.equalTo(inputContainer).offset(10)
            make.width.equalTo(inputContainer).multipliedBy(0.65)
            make.top.equalTo(inputContainer)
        })
        //
        let sendCodeBtn = AuthCodeBtnView()
        sendCodeBtn.setTitle(NSLocalizedString("获取验证码", comment: ""), forState: .Normal)
        sendCodeBtn.displayText = NSLocalizedString("获取验证码", comment: "")
        sendCodeBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        sendCodeBtn.titleLabel?.font = UIFont.systemFontOfSize(12)
        inputContainer.addSubview(sendCodeBtn)
        sendCodeBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!.snp_right)
            make.right.equalTo(inputContainer).offset(-13)
            make.centerY.equalTo(registerPhoneInput!)
        }
        sendCodeBtn.addTarget(self, action: #selector(LoginRegisterController.sendAuthCodePressed), forControlEvents: .TouchUpInside)
        authCodeBtn = sendCodeBtn
        //
        registerAuthCode = TextFieldWithLeadingIconView()
        registerAuthCode?.delegate = self
        registerAuthCode?.placeholder = NSLocalizedString("请输入验证码", comment: "")
        registerAuthCode?.font = UIFont.systemFontOfSize(12)
        registerAuthCode?.leftViewMode = UITextFieldViewMode.Always
        let registerAuthCodeIcon = UIImageView(image: UIImage(named: "account_auth_code"))
        registerAuthCode?.leftView = registerAuthCodeIcon
        inputContainer.addSubview(registerAuthCode!)
        registerAuthCode!.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.left.equalTo(registerPhoneInput!)
            make.top.equalTo(registerPhoneInput!.snp_bottom)
            make.right.equalTo(sendCodeBtn)
        }
        //
        registerPasswordInput = TextFieldWithLeadingIconView()
        registerPasswordInput?.delegate = self
        registerPasswordInput?.placeholder = NSLocalizedString("请输入密码", comment: "")
        registerPasswordInput?.secureTextEntry = true
        registerPasswordInput?.font = UIFont.systemFontOfSize(12)
        registerPasswordInput?.leftViewMode = UITextFieldViewMode.Always
        let registerPasswordInputIcon = UIImageView(image: UIImage(named: "account_password_input"))
        registerPasswordInput?.leftView = registerPasswordInputIcon
        inputContainer.addSubview(registerPasswordInput!)
        registerPasswordInput?.snp_makeConstraints(closure: { (make) -> Void in
            make.height.equalTo(registerPhoneInput!)
            make.width.equalTo(registerAuthCode!)
            make.top.equalTo(registerAuthCode!.snp_bottom)
            make.centerX.equalTo(registerAuthCode!)
        })
        // 
        let agreementBtn = UIButton()
        agreementBtn.setTitle(NSLocalizedString("用户协议", comment: ""), forState: .Normal)
        agreementBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        agreementBtn.setTitleColor(kHighlightedRedTextColor, forState: .Normal)
        container.addSubview(agreementBtn)
        agreementBtn.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(17)
            make.width.equalTo(60)
            make.top.equalTo(inputContainer.snp_bottom).offset(15)
            make.right.equalTo(inputContainer)
        }
        agreementBtn.addTarget(self, action: #selector(LoginRegisterController.checkAgreement), forControlEvents: .TouchUpInside)
        
        let agreementCheckIcon = UIImageView(image: UIImage(named: "account_agreement_check"))
        container.addSubview(agreementCheckIcon)
        agreementCheckIcon.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(agreementBtn)
            make.width.equalTo(agreementCheckIcon.snp_height)
            make.top.equalTo(agreementBtn)
            make.right.equalTo(agreementBtn.snp_left)
        }
        
        let registerBtn = UIButton()
        registerBtn.setBackgroundImage(UIImage(named: "account_register_btn"), forState: .Normal)
        registerBtn.layer.shadowColor = UIColor(red: 0.95, green: 0.21, blue: 0.21, alpha: 1).CGColor
        registerBtn.layer.shadowOffset = CGSize(width: 0, height: 3)
        registerBtn.layer.shadowRadius = 7
        registerBtn.layer.shadowOpacity = 1
        container.addSubview(registerBtn)
        registerBtn.snp_makeConstraints { (make) -> Void in
            make.width.equalTo(100)
            make.height.equalTo(40)
            make.top.equalTo(inputContainer.snp_bottom).offset(75)
            make.centerX.equalTo(container)
        }
        registerBtn.addTarget(self, action: #selector(LoginRegisterController.registerPressed), forControlEvents: .TouchUpInside)
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
        titleLoginBtn?.setTitleColor(kBarBgColor, forState: .Normal)
        titleLoginBtn?.setTitle(NSLocalizedString("登录", comment: ""), forState: .Normal)
        titleLoginBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleLoginBtn!)
        titleLoginBtn?.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.left.equalTo(container.snp_centerX).offset(9)
        }
        titleLoginBtn?.addTarget(self, action: #selector(LoginRegisterController.barTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)
        
        // 创建注册按钮
        titleRegisterBtn = UIButton()
        titleRegisterBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        titleRegisterBtn?.setTitle(NSLocalizedString("注册", comment: ""), forState: .Normal)
        titleRegisterBtn?.titleLabel?.font = kBarTextFont
        container.addSubview(titleRegisterBtn!)
        titleRegisterBtn?.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(30)
            make.width.equalTo(80)
            make.centerY.equalTo(container)
            make.right.equalTo(container.snp_centerX).offset(9)
        }
        titleRegisterBtn?.addTarget(self, action: #selector(LoginRegisterController.barTitleBtnPressed(_:)), forControlEvents: .TouchUpInside)

        // 创建背景ICON
        titleBtnIcon = UIImageView(image: UIImage(named: "account_header_button"))
        container.addSubview(titleBtnIcon!)
        container.sendSubviewToBack(titleBtnIcon!)
        titleBtnIcon?.snp_makeConstraints(closure: { (make) -> Void in
            make.edges.equalTo(titleLoginBtn!)
        })
        return container
    }
    
    func leftBarBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
//        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: #selector(LoginRegisterController.backBtnPressed(_:)), forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func barTitleBtnPressed(sender: UIButton) {
        if sender.titleLabel?.text == "注册" && board?.contentOffset.x != 0{
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleRegisterBtn!)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleRegisterBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                self.titleLoginBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.board?.contentOffset = CGPoint(x: 0, y: 0)
                }, completion: nil)
        }else if sender.titleLabel?.text == "登录" && board?.contentOffset.x == 0{
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleLoginBtn!)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleLoginBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                self.titleRegisterBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                self.board?.contentOffset = CGPoint(x: self.view.frame.size.width, y: 0)
                }, completion: nil)
        }
    }
    // MARK: 按钮响应
    
    func backBtnPressed(sender: UIButton) {
//        print("haha")
    }
    
    func loginPressed() {
        // 首先确保手机号码和密码都已经填入了数据
        guard let username = loginPhoneInput?.text where username.characters.count > 0 else{
            self.displayAlertController("请输入手机号码", message: "")
            return
        }
        
        guard let password = loginPasswordInput?.text where password.characters.count > 0 else{
            self.displayAlertController("请输入密码", message: "")
            return
        }
        loginBtn?.enabled = false
        self.requester.postToLogin(username, password: password, onSuccess: { (json) -> (Void) in
            self.loginBtn?.enabled = true
            let user: User = try! MainManager.sharedManager.getOrCreate(json!)
            MainManager.sharedManager.login(user)
            let app = AppManager.sharedAppManager
            app.guideToContent()
            }) { (code) -> (Void) in
                self.loginBtn?.enabled = true
                // 显示错误信息
                var errorMessage = ""
                if let errorCode = code {
                    switch errorCode {
                    case "0000":
                        errorMessage = "网络连接不畅或者服务器内部发生了错误"
                        break
                    case "1000":
                        errorMessage = "该手机号码尚未注册或者手机号码格式错误"
                        break
                    case "1001":
                        errorMessage = "密码错误"
                    default:
                        errorMessage = "未知错误"
                        break
                    }
                }else{
                    // 没有接收到错误信息
                    assertionFailure()
                }
                self.displayAlertController(NSLocalizedString("登录错误", comment: ""), message: errorMessage)
        }
    }
    
    func registerPressed() {
        // TODO: 完成注册接口
        // 检查所有的空是否都填写了
        guard let phone = registerPhoneInput?.text else{
            self.displayAlertController(NSLocalizedString("错误", comment: ""), message: NSLocalizedString("请输入手机号", comment: ""))
            return
        }
        guard let authCode = registerAuthCode?.text else{
            self.displayAlertController(NSLocalizedString("错误", comment: ""), message: NSLocalizedString("请输入验证码", comment: ""))
            return
        }
        guard let passwd = registerPasswordInput?.text else{
            self.displayAlertController(NSLocalizedString("错误", comment: ""), message: NSLocalizedString("请输入密码", comment: ""))
            return
        }
    
        self.requester.postToRegister(phone, passwd: passwd, authCode: authCode, onSuccess: { (json) -> (Void) in
            let user: User = try! MainManager.sharedManager.getOrCreate(json!)
            MainManager.sharedManager.login(user)
            self.registerConfirm()
            }) { (code) -> (Void) in
                switch code! {
                case "1003":
                    self.displayAlertController("注册失败", message: "密码太短，密码长度请设置在8位以上")
                    break
                case "1002":
                    self.displayAlertController("注册失败", message: "验证码输入失败")
                    break
                case "0000":
                    self.displayAlertController("注册失败", message: "请检查您的网络连接")
                    break
                default:
                    self.displayAlertController("注册失败", message: "您的手机号已经被注册")
                }
        }
    }
    
    func forgetBtnPressed() {
        let ctrl = ResetPasswordController()
        let nav = BlackBarNavigationController(rootViewController: ctrl)
        self.presentViewController(nav, animated: true, completion: nil)
        //
//        self.navigationController?.pushViewController(ctrl, animated: true)
    }
    
    func checkAgreement() {
        let agreementCtrl = AgreementController()
        self.navigationController?.pushViewController(agreementCtrl, animated: true)
    }
    
    func sendAuthCodePressed() {
        guard let phone = registerPhoneInput?.text where phone.characters.count > 0 else{
            self.displayAlertController("请输入手机号码", message: "")
            return
        }
        authCodeBtn?.status = AuthCodeBtnViewStatus.Pending
        self.requester.requestAuthCode(registerPhoneInput!.text!, onSuccess: { () -> (Void) in
            self.authCodeBtn?.status = AuthCodeBtnViewStatus.CountDown
            }) { () -> (Void) in
                // 弹窗
                self.authCodeBtn?.status = AuthCodeBtnViewStatus.Normal
                self.displayAlertController("未能获取验证码", message: "可能是网络原因或者服务器内部错误")
        }
//        self.requester.requestAuthCode(registerPhoneInput!.text!) { (code) -> (Void) in
//            print("\(code)")
//        }
    }
    
    // MARK: 网络回调
    func registerConfirm(){
        // TODO: 首先应当在CoreData中创建本用户条目，以及设置NSUserDefault中的内容
        
        let nextStep = ProfileInfoController()
        self.navigationController?.pushViewController(nextStep, animated: true)
    }
    
    
    override func dismissKeyboard() {
        super.dismissKeyboard()
//        self.loginPasswordInput?.resignFirstResponder()
//        self.loginPhoneInput?.resignFirstResponder()
//        self.registerPhoneInput?.resignFirstResponder()
//        self.registerPasswordInput?.resignFirstResponder()
//        self.registerAuthCode?.resignFirstResponder()
//        self.tapper?.enabled = false
        self.titleLbl?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(125)
        })
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    override func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        super.textFieldShouldBeginEditing(textField)
        self.tapper?.enabled = true
        self.titleLbl?.snp_updateConstraints(closure: { (make) -> Void in
            make.height.equalTo(0)
        })
        UIView.animateWithDuration(0.2) { () -> Void in
            self.view.layoutIfNeeded()
        }
        return true
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.contentOffset.x < self.view.frame.width/2 {
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleRegisterBtn!)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleRegisterBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                self.titleLoginBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }, completion: nil)
        }else{
            titleBtnIcon?.snp_remakeConstraints(closure: { (make) -> Void in
                make.edges.equalTo(titleLoginBtn!)
            })
            UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
                self.titleBtnIcon?.superview?.layoutIfNeeded()
                self.titleLoginBtn?.setTitleColor(kBarBgColor, forState: .Normal)
                self.titleRegisterBtn?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }, completion: nil)
        }
    }
}

class TextFieldWithLeadingIconView : UITextField {
    override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        var frame = super.leftViewRectForBounds(bounds)
        let size = CGSize(width: 16, height: 16)
        frame.size = size
        frame.origin.y = 3 + bounds.size.height / 4
        return frame
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var frame = super.textRectForBounds(bounds)
        frame.origin.x = 30
        return frame
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var frame = super.textRectForBounds(bounds)
        frame.origin.x = 30
        return frame
    }
}
