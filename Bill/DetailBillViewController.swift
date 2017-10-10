//
//  DetailBillViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/10/6.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

class DetailBillViewController: UIViewController {
    var bill : Bill?
    var flag = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        bill = appDelegate.bill
        
        self.view.backgroundColor = (bill?.isOut)! ? color.blue : color.green
        
        fetchFlagLabel()
        
        let titleLabel = UILabel()
        titleLabel.text = "您好,"
        titleLabel.textColor = UIColor.white
        titleLabel.frame = CGRect(x: 15, y: 80, width: 130, height: 60)
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 45)
        self.view.addSubview(titleLabel)
        
        let titleThinLabel = UILabel()
        titleThinLabel.text = "以下是支出 / 收入的详细信息"
        titleThinLabel.textColor = UIColor.white
        titleThinLabel.frame = CGRect(x: 15, y: 145, width: 200, height: 17)
        titleThinLabel.textAlignment = .left
        titleThinLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 14)
        self.view.addSubview(titleThinLabel)
        
        let preView = UIView()
        preView.backgroundColor = UIColor.white
        preView.frame.size = CGSize(width: FlagFrame.screen_W * 0.95, height: 480)
        preView.center.x = self.view.center.x
        preView.frame.origin.y = FlagFrame.screen_H - preView.frame.size.height
        let shapePre : CAShapeLayer = CAShapeLayer()
        let bepathPre : UIBezierPath = UIBezierPath(roundedRect: preView.bounds, byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize(width: 25, height: 25))
        shapePre.path = bepathPre.cgPath
        preView.layer.mask = shapePre
        self.view.addSubview(preView)
        
        let flagImg = UIImageView()
        flagImg.frame = CGRect(x: 20, y: 20, width: 50, height: 50)
        flagImg.image = UIImage(named: (bill?.type!)!)
        preView.addSubview(flagImg)
        
        let titleLael = UILabel()
        titleLael.frame.size = CGSize(width: 200, height: 50)
        titleLael.center.y = flagImg.center.y
        titleLael.frame.origin.x = 80
        titleLael.text = bill?.title
        titleLael.textAlignment = .left
        titleLael.textColor = UIColor.darkGray
        titleLael.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        preView.addSubview(titleLael)
        
        let detView = UIView()
        detView.frame = CGRect(x: 0, y: 90, width: preView.frame.size.width, height: 280)
        detView.backgroundColor = (bill?.isOut)! ? color.lightBlue : color.lightGreen
        preView.addSubview(detView)
        
        let dateLable = UILabel()
        dateLable.frame = CGRect(x: 20, y: 15, width: FlagFrame.screen_W - 20, height: 30)
        dateLable.text = "时间: " + (bill?.time)!
        dateLable.textColor = UIColor.darkGray
        dateLable.textAlignment = .left
        dateLable.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        detView.addSubview(dateLable)
        
        let flagLabel = UILabel()
        flagLabel.frame = CGRect(x: 20, y: 60, width: 200, height: 30)
        flagLabel.text = "标签: " + flag
        flagLabel.textColor = UIColor.darkGray
        flagLabel.textAlignment = .left
        flagLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        detView.addSubview(flagLabel)
        
        let lineView_1 = UIView()
        lineView_1.frame.size = CGSize(width: detView.frame.size.width * 0.9 , height: 0.5)
        lineView_1.backgroundColor = color.lightGray
        lineView_1.center.x = detView.center.x
        lineView_1.frame.origin.y = 140
        detView.addSubview(lineView_1)

        let detLabel = UILabel()
        detLabel.frame = CGRect(x: 20, y: 105, width: 50, height: 30)
        detLabel.text = "详情"
        detLabel.textColor = UIColor.darkGray
        detLabel.textAlignment = .left
        detLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        detView.addSubview(detLabel)
        
        let detTextView = UITextView()
        detTextView.frame.size = CGSize(width: detView.frame.size.width * 0.9, height: 120)
        detTextView.center.x = detView.center.x
        detTextView.frame.origin.y = 141
        detTextView.text = bill?.detail
        detTextView.isEditable = false
        detTextView.showsVerticalScrollIndicator = false
        detTextView.showsHorizontalScrollIndicator = false
        detTextView.textColor = UIColor.darkGray
        detTextView.backgroundColor = (bill?.isOut)! ? color.lightBlue : color.lightGreen
        detTextView.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
        detTextView.textAlignment = .natural
        detView.addSubview(detTextView)
        
        let priceLable = UILabel()
        priceLable.text = "￥ " + (bill?.price)!
        priceLable.frame = CGRect(x: preView.frame.size.width - 220, y: 390, width: 200, height: 50)
        priceLable.textAlignment = .right
        priceLable.textColor = UIColor.darkGray
        priceLable.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        preView.addSubview(priceLable)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func fetchFlagLabel() {
        switch bill?.type {
        case "out"?:
            flag = "支出"
        case "shopping"?:
            flag = "购物"
        case "online-shopping"?:
            flag = "线上购物"
        case "food"?:
            flag = "饮食"
        case "go"?:
            flag = "出行"
        case "fare"?:
            flag = "手机缴费"
        case "movie"?:
            flag = "电影"
        case "clothes"?:
            flag = "衣服"
        case "transfer"?:
            flag = "转账"
        case "gift"?:
            flag = "礼物"
        case "city"?:
            flag = "生活缴费"
        case "in"?:
            flag = "收入"
        default:
            break
        }
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

