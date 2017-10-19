//
//  OtherMenuViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/10/19.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import MessageUI

class OtherMenuViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBAction func backBtn(_ sender: UIButton) {
        backAction()
    }
    @IBOutlet weak var helpView: UIView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var gradeView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureActionn(swipeGesture:)))
        swipeGesture.direction = .left
        self.view.addGestureRecognizer(swipeGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(feedbackAction(tapGesture:)))
        feedbackView.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func swipeGestureActionn(swipeGesture : UISwipeGestureRecognizer) {
        backAction()
    }
    
    func backAction() {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let allView = view.instantiateViewController(withIdentifier: "allBill")
        allView.heroModalAnimationType = .slide(direction: .left)
        self.present(allView, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self

        mailComposeVC.setToRecipients(["18640868097@163.com"])
        mailComposeVC.setSubject("意见反馈")
        mailComposeVC.setMessageBody("", isHTML: false)
        
        return mailComposeVC
    }
    
    func showSendMailErrorAlert() {
        
        let sendMailErrorAlert = UIAlertController(title: "无法发送邮件", message: "您的设备尚未设置邮箱，请在“邮件”应用中设置后再尝试发送。", preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "确定", style: .default) { _ in })
        self.present(sendMailErrorAlert, animated: true){}
        
    }
    
    @objc func feedbackAction(tapGesture : UITapGestureRecognizer) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposeViewController = configuredMailComposeViewController()
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
