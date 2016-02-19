//
//  File.swift
//  SportCarClient
//
//  Created by 黄延 on 15/12/10.
//  Copyright © 2015年 WoodyHuang. All rights reserved.
//

import UIKit
import SnapKit


class AgreementController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        let board = UIScrollView()
        self.view.addSubview(board)
        board.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view!).inset(23)
        }
        
        let screenFrame = self.view.frame
        let agreementLbl = UILabel(frame: CGRect(x: 0, y: 0, width: screenFrame.width - 23 * 2, height: CGFloat.max))
        agreementLbl.numberOfLines = 0
        agreementLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping
        agreementLbl.font = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        agreementLbl.attributedText = readAgreementFromFile()
        agreementLbl.sizeToFit()
        board.addSubview(agreementLbl)
        board.contentSize = agreementLbl.frame.size
        //
        self.navigationItem.title = NSLocalizedString("用户协议", comment: "")
        self.navigationItem.leftBarButtonItem = leftBarBtn()
    }
    
    func readAgreementFromFile() -> NSAttributedString?{
        let filename = "agreement"
        let fileURL = NSBundle.mainBundle().URLForResource(filename, withExtension: "rtf")
        do{
            let text = try NSAttributedString(URL: fileURL!, options: [NSDocumentTypeDocumentAttribute: NSRTFTextDocumentType], documentAttributes: nil)

            return text
        }
        catch{
            return nil
        }
    }
    
    func leftBarBtn() -> UIBarButtonItem! {
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage(named: "account_header_back_btn"), forState: .Normal)
        backBtn.addTarget(self, action: "backBtnPressed", forControlEvents: .TouchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 10.5, height: 18)
        
        let leftBtnItem = UIBarButtonItem(customView: backBtn)
        return leftBtnItem
    }
    
    func backBtnPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
