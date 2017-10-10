//
//  AddBillViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/9/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData
import Hero

class AddBillViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    var bill : Bill!
    let todayDate = Date()
    let formatter = DateFormatter()
    var dateToStr : Date?

    @IBOutlet weak var titleStack: UIStackView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addView: UIView!
    @IBAction func closeBtn(_ sender: UIButton) {
        hero_dismissViewController()
    }
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBAction func flagBtn(_ sender: UIButton) {
        detailTextView.resignFirstResponder()
        titleTextField.resignFirstResponder()
        priceTextField.resignFirstResponder()
        flagAction()
    }
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var priceTextField: UITextField!
    @IBAction func saveBtn(_ sender: UIButton) {
        saveAction()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shapeTime : CAShapeLayer = CAShapeLayer()
        let bepathTime : UIBezierPath = UIBezierPath(roundedRect: timeView.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.bottomLeft], cornerRadii: CGSize(width: 15, height: 15))
        shapeTime.path = bepathTime.cgPath
        timeView.layer.mask = shapeTime
        let tapDPGesture = UITapGestureRecognizer(target: self, action: #selector(datePickerAction(tapDPGesture:)))
        timeView.addGestureRecognizer(tapDPGesture)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dateToStr = appDelegate.dateNow
        formatter.dateFormat = "MM月dd日 HH:mm"
        let datetimeStr = formatter.string(from: dateToStr!)
        formatter.dateFormat = "MM月dd日 HH:mm"
        let datetimeStrToday = formatter.string(from: todayDate)
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateString = formatter.string(from: dateToStr!)
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateStrToday = formatter.string(from: todayDate)
        print(dateStrToday, dateString, datetimeStrToday, datetimeStr)
        if dateString == dateStrToday {
            timeLabel.text = datetimeStrToday
        } else {
            timeLabel.text = datetimeStr
        }
        
        titleTextField.placeholder = "请输入标题"
        titleTextField.textAlignment = .left
        titleTextField.contentVerticalAlignment = .center
        titleTextField.clearButtonMode = UITextFieldViewMode.whileEditing
        titleTextField.returnKeyType = UIReturnKeyType.done
        titleTextField.delegate = self
        detailTextView.inputAccessoryView = AddToolBar()
        detailTextView.delegate = self
        priceTextField.inputAccessoryView = AddToolBar()
        priceTextField.textAlignment = .left
        priceTextField.contentVerticalAlignment = .center
        priceTextField.clearButtonMode=UITextFieldViewMode.whileEditing
        priceTextField.delegate = self
        
        let bgView = UIView()
        bgView.frame = self.view.frame
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0
        bgView.isHidden = true
        bgView.tag = 100
        self.view.addSubview(bgView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeFlagAction(tapGesture:)))
        bgView.addGestureRecognizer(tapGesture)
        
        let flagView = UIView()
        flagView.frame.size = CGSize(width: 300, height: 400)
        flagView.center.x = self.view.center.x
        flagView.frame.origin.y = UIScreen.main.bounds.size.height
        flagView.isHidden = true
        flagView.alpha = 1
        flagView.backgroundColor = UIColor.white
        flagView.tag = 101
        flagView.layer.cornerRadius = 25
        self.view.addSubview(flagView)
        
        let outBtn = UIButton()
        outBtn.tag = 200
        outBtn.alpha = 0
        outBtn.frame.size = FlagFrame.btnSize
        outBtn.center = FlagFrame.out_C
        outBtn.setImage(#imageLiteral(resourceName: "out"), for: .normal)
        flagView.addSubview(outBtn)
        
        let shoppingBtn = UIButton()
        shoppingBtn.tag = 201
        shoppingBtn.alpha = 0
        shoppingBtn.frame.size = FlagFrame.btnSize
        shoppingBtn.center = FlagFrame.shopping_C
        shoppingBtn.setImage(#imageLiteral(resourceName: "shopping"), for: .normal)
        flagView.addSubview(shoppingBtn)
        
        let shoppingOLBtn = UIButton()
        shoppingOLBtn.tag = 202
        shoppingOLBtn.alpha = 0
        shoppingOLBtn.frame.size = FlagFrame.btnSize
        shoppingOLBtn.center = FlagFrame.shoppingOL_C
        shoppingOLBtn.setImage(#imageLiteral(resourceName: "online-shopping"), for: .normal)
        flagView.addSubview(shoppingOLBtn)
        
        let foodBtn = UIButton()
        foodBtn.tag = 203
        foodBtn.alpha = 0
        foodBtn.frame.size = FlagFrame.btnSize
        foodBtn.center = FlagFrame.food_C
        foodBtn.setImage(#imageLiteral(resourceName: "food"), for: .normal)
        flagView.addSubview(foodBtn)
        
        let goBtn = UIButton()
        goBtn.tag = 204
        goBtn.alpha = 0
        goBtn.frame.size = FlagFrame.btnSize
        goBtn.center = FlagFrame.go_C
        goBtn.setImage(#imageLiteral(resourceName: "go"), for: .normal)
        flagView.addSubview(goBtn)
        
        let fareBtn = UIButton()
        fareBtn.tag = 205
        fareBtn.alpha = 0
        fareBtn.frame.size = FlagFrame.btnSize
        fareBtn.center = FlagFrame.fare_C
        fareBtn.setImage(#imageLiteral(resourceName: "fare"), for: .normal)
        flagView.addSubview(fareBtn)
        
        let movieBtn = UIButton()
        movieBtn.tag = 206
        movieBtn.alpha = 0
        movieBtn.frame.size = FlagFrame.btnSize
        movieBtn.center = FlagFrame.movie_C
        movieBtn.setImage(#imageLiteral(resourceName: "movie"), for: .normal)
        flagView.addSubview(movieBtn)
        
        let clothsBtn = UIButton()
        clothsBtn.tag = 207
        clothsBtn.alpha = 0
        clothsBtn.frame.size = FlagFrame.btnSize
        clothsBtn.center = FlagFrame.clothes_C
        clothsBtn.setImage(#imageLiteral(resourceName: "clothes"), for: .normal)
        flagView.addSubview(clothsBtn)
        
        let transferBtn = UIButton()
        transferBtn.tag = 208
        transferBtn.alpha = 0
        transferBtn.frame.size = FlagFrame.btnSize
        transferBtn.center = FlagFrame.transfer_C
        transferBtn.setImage(#imageLiteral(resourceName: "transfer"), for: .normal)
        flagView.addSubview(transferBtn)
        
        let giftBtn = UIButton()
        giftBtn.tag = 209
        giftBtn.alpha = 0
        giftBtn.frame.size = FlagFrame.btnSize
        giftBtn.center = FlagFrame.gift_C
        giftBtn.setImage(#imageLiteral(resourceName: "gift"), for: .normal)
        flagView.addSubview(giftBtn)
        
        let cityBtn = UIButton()
        cityBtn.tag = 210
        cityBtn.alpha = 0
        cityBtn.frame.size = FlagFrame.btnSize
        cityBtn.center = FlagFrame.city_C
        cityBtn.setImage(#imageLiteral(resourceName: "city"), for: .normal)
        flagView.addSubview(cityBtn)
        
        let inBtn = UIButton()
        inBtn.tag = 211
        inBtn.alpha = 0
        inBtn.frame.size = FlagFrame.btnSize
        inBtn.center = FlagFrame.in_C
        inBtn.setImage(#imageLiteral(resourceName: "in"), for: .normal)
        flagView.addSubview(inBtn)
        
        let outLb = UILabel()
        outLb.text = "支出"
        outLb.center = FlagFrame.outT_C
        let shoppingLb = UILabel()
        shoppingLb.text = "购物"
        shoppingLb.center = FlagFrame.shoppingT_C
        let shoppingOLLb = UILabel()
        shoppingOLLb.text = "线上购物"
        shoppingOLLb.center = FlagFrame.shoppingOLT_C
        let foodLb = UILabel()
        foodLb.text = "饮食"
        foodLb.center = FlagFrame.foodT_C
        let goLb = UILabel()
        goLb.text = "出行"
        goLb.center = FlagFrame.goT_C
        let fareLb = UILabel()
        fareLb.text = "手机缴费"
        fareLb.center = FlagFrame.fareT_C
        let movieLb = UILabel()
        movieLb.text = "电影"
        movieLb.center = FlagFrame.movieT_C
        let clothesLb = UILabel()
        clothesLb.text = "衣服"
        clothesLb.center = FlagFrame.clothesT_C
        let transferLb = UILabel()
        transferLb.text = "转账"
        transferLb.center = FlagFrame.transferT_C
        let giftLb = UILabel()
        giftLb.text = "礼物"
        giftLb.center = FlagFrame.giftT_C
        let cityLb = UILabel()
        cityLb.text = "生活缴费"
        cityLb.center = FlagFrame.cityT_C
        let inLb = UILabel()
        inLb.text = "收入"
        inLb.center = FlagFrame.inT_C

        let labels : [UILabel] = [outLb, shoppingLb, shoppingOLLb, foodLb, goLb, fareLb, movieLb, clothesLb, transferLb, giftLb, cityLb, inLb]
        let flagBtns : [UIButton] = [outBtn, shoppingBtn, shoppingOLBtn, foodBtn, goBtn, fareBtn, movieBtn, clothsBtn, transferBtn, giftBtn, cityBtn, inBtn]
        for i in 0...11 {
            labels[i].textColor = UIColor.lightGray
            labels[i].frame.size = CGSize(width: 50, height: 30)
            labels[i].textAlignment = .center
            labels[i].font = UIFont(name: "Marker Felt", size: 12)
            flagView.addSubview(labels[i])
            
            flagBtns[i].addTarget(self, action: #selector(flagChoice(_:)), for: .touchUpInside)
        }
        
        let hintView = UIView()
        hintView.frame.size = CGSize(width: FlagFrame.screen_W * 0.95, height: 50)
        hintView.center.x = self.view.center.x
        hintView.frame.origin.y = -50
        hintView.backgroundColor = color.red
        hintView.isHidden = true
        hintView.tag  = 230
        hintView.layer.cornerRadius = 10
        hintView.layer.shadowColor = UIColor.darkGray.cgColor
        hintView.layer.shadowOpacity = 0.8
        hintView.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.view.addSubview(hintView)
        
        let hintImage = UIImageView()
        hintImage.image = #imageLiteral(resourceName: "hint")
        hintImage.frame = CGRect(x: 10, y: 10, width: 30, height: 30)
        hintView.addSubview(hintImage)
        
        let hintText = UILabel()
        hintText.text = "请填写完整信息"
        hintText.frame = CGRect(x: 50, y: 10, width: 130, height: 30)
        hintText.textColor = UIColor.white
        hintText.font = UIFont.systemFont(ofSize: 15)
        hintText.textAlignment = .center
        hintView.addSubview(hintText)
        
        let datePickerView = UIView()
        datePickerView.frame.size = CGSize(width: FlagFrame.screen_W, height: 300)
        datePickerView.center.x = self.view.center.x
        datePickerView.frame.origin.y = UIScreen.main.bounds.size.height
        datePickerView.isHidden = true
        datePickerView.alpha = 1
        datePickerView.backgroundColor = UIColor.white
        datePickerView.tag = 290
        let shapeAct : CAShapeLayer = CAShapeLayer()
        let bepathAct : UIBezierPath = UIBezierPath(roundedRect: datePickerView.bounds, byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize(width: 10, height: 10))
        shapeAct.path = bepathAct.cgPath
        datePickerView.layer.mask = shapeAct
        self.view.addSubview(datePickerView)
        
        
        let datetimePicker = UIDatePicker()
        datetimePicker.frame.size = CGSize(width: FlagFrame.screen_W * 0.95, height: 200)
        datetimePicker.center.x = datePickerView.center.x
        datetimePicker.frame.origin.y = 20
        datetimePicker.setValue(UIColor.darkGray, forKey: "textColor")
        datetimePicker.tag = 291
        datetimePicker.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "MM月dd日 HH:mm"
        datetimePicker.date = formatter.date(from: timeLabel.text!)!
        datetimePicker.addTarget(self, action: #selector(datePickerAction(datetimePicker:)), for: .valueChanged)
        datePickerView.addSubview(datetimePicker)
        
        let doneActionBtn = UIButton()
        doneActionBtn.frame.size = CGSize(width: FlagFrame.screen_W * 0.7, height: 50)
        doneActionBtn.center.x = datePickerView.center.x
        doneActionBtn.frame.origin.y = 10
        doneActionBtn.frame.origin.y = datePickerView.frame.size.height * 0.75
        doneActionBtn.backgroundColor = color.blue
        doneActionBtn.setTitle("完成", for: .normal)
        doneActionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        doneActionBtn.setTitleColor(UIColor.white, for: .normal)
        doneActionBtn.layer.cornerRadius = 10
        doneActionBtn.addTarget(self, action: #selector(datePickerCloseAction), for: .touchUpInside)
        datePickerView.addSubview(doneActionBtn)
        
        // Do any additional setup after loading the view.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        animateViewUp()
//    }
//    func textViewDidEndEditing(_ textView: UITextView) {
//        animateViewDown()
//    }
//    func animateViewUp() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.addView.frame = self.addView.frame.offsetBy(dx: 0, dy: -60)
//            self.titleStack.frame = self.titleStack.frame.offsetBy(dx: 0, dy: -60)
//        }) { (_) in
//
//        }
//    }
//    func animateViewDown() {
//        UIView.animate(withDuration: 0.3, animations: {
//            self.addView.frame = self.addView.frame.offsetBy(dx: 0, dy: 60)
//            self.titleStack.frame = self.titleStack.frame.offsetBy(dx: 0, dy: 60)
//        }) { (_) in
//
//        }
//    }
    
    @objc func closeFlagAction(tapGesture : UITapGestureRecognizer) {
        let dpV = (self.view.viewWithTag(290))
        if dpV?.isHidden == true {
            closeAction()
        } else {
            datePickerCloseAction()
        }
    }
    
    @objc func datePickerAction(datetimePicker : UIDatePicker) {
        formatter.dateFormat = "MM月dd日 HH:mm:ss"
        let timeStr = formatter.string(from: datetimePicker.date)
        let index = timeStr.index(timeStr.startIndex, offsetBy: 12)
        let timeStrIndex = timeStr.substring(to: index)
        timeLabel.text = timeStrIndex
    }
    
    @objc func flagChoice(_ sender : UIButton) {
        
        let tag = sender.tag
        switch tag {
        case 200:
            flagButton.setImage(#imageLiteral(resourceName: "out"), for: .normal)
        case 201:
            flagButton.setImage(#imageLiteral(resourceName: "shopping"), for: .normal)
        case 202:
            flagButton.setImage(#imageLiteral(resourceName: "online-shopping"), for: .normal)
        case 203:
            flagButton.setImage(#imageLiteral(resourceName: "food"), for: .normal)
        case 204:
            flagButton.setImage(#imageLiteral(resourceName: "go"), for: .normal)
        case 205:
            flagButton.setImage(#imageLiteral(resourceName: "fare"), for: .normal)
        case 206:
            flagButton.setImage(#imageLiteral(resourceName: "movie"), for: .normal)
        case 207:
            flagButton.setImage(#imageLiteral(resourceName: "clothes"), for: .normal)
        case 208:
            flagButton.setImage(#imageLiteral(resourceName: "transfer"), for: .normal)
        case 209:
            flagButton.setImage(#imageLiteral(resourceName: "gift"), for: .normal)
        case 210:
            flagButton.setImage(#imageLiteral(resourceName: "city"), for: .normal)
        case 211:
            flagButton.setImage(#imageLiteral(resourceName: "in"), for: .normal)
        default:
            break
        }
        
        closeAction()
    }
    
    func closeAction() {
        let bgV = (self.view.viewWithTag(100))
        let flagV = (self.view.viewWithTag(101))
        let flagTag = [200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211]
        UIView.animate(withDuration: 0.3, animations: {
            flagV?.frame.origin.y = UIScreen.main.bounds.size.height
            bgV?.alpha = 0
            for i in 0...11 {
                (self.view.viewWithTag(flagTag[i]) as! UIButton).alpha = 0
            }
        }) { (_) in
            flagV?.isHidden = true
            bgV?.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    func saveAction() {
        
        if  priceTextField.text == "" || (titleTextField.text == "" && detailTextView.text == "") {
            let hintV = (self.view.viewWithTag(230))
            
            hintV?.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                hintV?.frame.origin.y = 20
            }, completion: { (_) in
                _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
                    UIView.animate(withDuration: 0.3, animations: {
                        hintV?.frame.origin.y = -50
                    }, completion: { (_) in
                        hintV?.isHidden = true
                    })
                })
            })
            
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            bill = Bill(context: appDelegate.persistentContainer.viewContext)
            
            if titleTextField.text == "" {
                bill.title = detailTextView.text
            } else {
                bill.title = titleTextField.text
            }
            bill.detail = detailTextView.text
            bill.price = priceTextField.text
            formatter.dateFormat = "MM月dd日 HH:mm:ss"
            let dp = (self.view.viewWithTag(291) as! UIDatePicker)
            bill.time = formatter.string(from: dp.date)
            let index = timeLabel.text?.index((timeLabel.text?.startIndex)!, offsetBy: 6)
            let timeStrIndex = timeLabel.text?.substring(to: index!)
            formatter.dateFormat = "yyyy年"
            bill.date = formatter.string(from: todayDate) + timeStrIndex!
            appDelegate.date = bill.date
            bill.isEdit = false
            
            let flagImage = flagButton.imageView?.image
            switch flagImage {
            case #imageLiteral(resourceName: "out")?:
                bill.type = "out"
            case #imageLiteral(resourceName: "shopping")?:
                bill.type = "shopping"
            case #imageLiteral(resourceName: "online-shopping")?:
                bill.type = "online-shopping"
            case #imageLiteral(resourceName: "food")?:
                bill.type = "food"
            case #imageLiteral(resourceName: "go")?:
                bill.type = "go"
            case #imageLiteral(resourceName: "fare")?:
                bill.type = "fare"
            case #imageLiteral(resourceName: "movie")?:
                bill.type = "movie"
            case #imageLiteral(resourceName: "clothes")?:
                bill.type = "clothes"
            case #imageLiteral(resourceName: "transfer")?:
                bill.type = "transfer"
            case #imageLiteral(resourceName: "gift")?:
                bill.type = "gift"
            case #imageLiteral(resourceName: "city")?:
                bill.type = "city"
            case #imageLiteral(resourceName: "in")?:
                bill.type = "in"
            default:
                break
            }
            
            if bill.type == "in" {
                bill.isOut = false
            } else {
                bill.isOut = true
            }
            appDelegate.saveContext()
            let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
            let mainView = view.instantiateViewController(withIdentifier: "mainList")
            mainView.heroModalAnimationType = .fade
            self.present(mainView, animated: true, completion: nil)
        }
        
        
    }
    
    func flagAction() {
        let bgV = (self.view.viewWithTag(100))
        let flagV = (self.view.viewWithTag(101))
        let flagTag = [200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211]
        bgV?.isHidden = false
        flagV?.isHidden = false
        UIView.animate(withDuration: 0.3) {
            bgV?.alpha = 0.3
            flagV?.center = self.view.center
            for i in 0...11 {
                (self.view.viewWithTag(flagTag[i]) as! UIButton).alpha = 1
            }
        }
    }
    
    @objc func datePickerAction(tapDPGesture : UITapGestureRecognizer) {
        let bgV = (self.view.viewWithTag(100))
        let dpV = (self.view.viewWithTag(290))
        bgV?.isHidden = false
        dpV?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            bgV?.alpha = 0.3
            dpV?.frame.origin.y = FlagFrame.screen_H - 300
        }) { (_) in
            
        }
    }
    
    @objc func datePickerCloseAction() {
        let bgV = (self.view.viewWithTag(100))
        let dpV = (self.view.viewWithTag(290))
        UIView.animate(withDuration: 0.3, animations: {
            bgV?.alpha = 0
            dpV?.frame.origin.y = FlagFrame.screen_H
        }) { (_) in
            bgV?.isHidden = true
            dpV?.isHidden = true
        }
    }
    
    func AddToolBar() -> UIToolbar {
        let toolBar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 35))
        toolBar.backgroundColor = UIColor.white
        toolBar.alpha = 1
        let spaceBtn = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barBtn = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(doneNum))
        barBtn.tintColor = color.blue
        toolBar.items = [spaceBtn, barBtn]
        return toolBar
    }
    
    @objc func doneNum() {
        self.view.endEditing(true)
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
