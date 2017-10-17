//
//  MonthBillViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/10/1.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData

class MonthBillViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bills : [Bill] = []
    var date : [String] = []
    var valuePrice : [Float] = []
    var date_price : Dictionary<String, [Float]> = [:]
    var fc : NSFetchedResultsController<Bill>!
    let todayDate = Date()
    let formatter = DateFormatter()

    @IBOutlet weak var monthBillTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleYearLabel: UILabel!
    @IBAction func addBtn(_ sender: UIButton) {
        addAction()
    }
    @IBAction func delBtn(_ sender: UIButton) {
        actionAnimate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "MMMM"
        self.formatter.locale = Locale(identifier: "zh_CN")
        titleLabel.text = formatter.string(from: todayDate)
        formatter.dateFormat = "yyyy"
        titleYearLabel.text = formatter.string(from: todayDate)
        
        monthBillTableView.delegate = self
        monthBillTableView.dataSource = self
        monthBillTableView.tableFooterView = UIView()
        monthBillTableView.separatorInset = UIEdgeInsetsMake(0, 35, 0, 15)
        
        let bgView = UIView()
        bgView.frame = self.view.frame
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0
        bgView.isHidden = true
        bgView.tag = 30
        self.view.addSubview(bgView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeAction(tapGesture:)))
        bgView.addGestureRecognizer(tapGesture)
        
        let actionView = UIView()
        actionView.frame.size = CGSize(width: FlagFrame.screen_W, height: 300)
        actionView.center.x = self.view.center.x
        actionView.frame.origin.y = UIScreen.main.bounds.size.height
        actionView.isHidden = true
        actionView.alpha = 1
        actionView.backgroundColor = UIColor.white
        actionView.tag = 31
        let shapeAct : CAShapeLayer = CAShapeLayer()
        let bepathAct : UIBezierPath = UIBezierPath(roundedRect: actionView.bounds, byRoundingCorners: [UIRectCorner.topLeft,UIRectCorner.topRight], cornerRadii: CGSize(width: 10, height: 10))
        shapeAct.path = bepathAct.cgPath
        actionView.layer.mask = shapeAct
        self.view.addSubview(actionView)
        
        let allDeleteActionTitleImage = UIImageView()
        allDeleteActionTitleImage.frame.size = CGSize(width: 50, height: 50)
        allDeleteActionTitleImage.image = #imageLiteral(resourceName: "delete")
        allDeleteActionTitleImage.center.x = actionView.center.x
        allDeleteActionTitleImage.frame.origin.y = 20
        actionView.addSubview(allDeleteActionTitleImage)
        
        let allDeleteActionTitleLabel = UILabel()
        allDeleteActionTitleLabel.text = "您将要删除本月所有 支出/收入 记录的详细信息"
        allDeleteActionTitleLabel.font = UIFont.systemFont(ofSize: 14)
        allDeleteActionTitleLabel.textAlignment = .center
        allDeleteActionTitleLabel.frame.origin.x = FlagFrame.screen_W * 0.1
        allDeleteActionTitleLabel.frame.origin.y = 70
        allDeleteActionTitleLabel.frame.size = CGSize(width: FlagFrame.screen_W * 0.8, height: 70)
        allDeleteActionTitleLabel.textColor = UIColor.darkGray
        actionView.addSubview(allDeleteActionTitleLabel)
        
        let allDeleteActionBtn = UIButton()
        allDeleteActionBtn.frame.size = CGSize(width: FlagFrame.screen_W * 0.7, height: 50)
        allDeleteActionBtn.center.x = actionView.center.x
        allDeleteActionBtn.frame.origin.y = actionView.frame.size.height * 0.55
        allDeleteActionBtn.backgroundColor = color.red
        allDeleteActionBtn.setTitle("全部删除", for: .normal)
        allDeleteActionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        allDeleteActionBtn.layer.cornerRadius = 10
        allDeleteActionBtn.addTarget(self, action: #selector(delAction(_:)), for: .touchUpInside)
        actionView.addSubview(allDeleteActionBtn)
        
        let cancelDeleteActionBtn = UIButton()
        cancelDeleteActionBtn.frame.size = CGSize(width: FlagFrame.screen_W * 0.7, height: 50)
        cancelDeleteActionBtn.center.x = actionView.center.x
        cancelDeleteActionBtn.frame.origin.y = actionView.frame.size.height * 0.77
        cancelDeleteActionBtn.backgroundColor = UIColor.groupTableViewBackground
        cancelDeleteActionBtn.setTitle("取消", for: .normal)
        cancelDeleteActionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelDeleteActionBtn.setTitleColor(UIColor.darkGray, for: .normal)
        cancelDeleteActionBtn.layer.cornerRadius = 10
        cancelDeleteActionBtn.addTarget(self, action: #selector(cancelDeleteAction(_:)), for: .touchUpInside)
        actionView.addSubview(cancelDeleteActionBtn)
        
        fetchMonthData()
        fetchDate()
        fetchDatePrice()
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
    
    func addAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dateNow = todayDate
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let addView = view.instantiateViewController(withIdentifier: "addView")
        addView.heroModalAnimationType = .fade
        self.present(addView, animated: true, completion: nil)
    }
    
    @objc func cancelDeleteAction(_ sender: UIButton) {
        cancelActionAnimate()
    }
    
    @objc func tapClose(tap : UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return date_price.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        monthBillTableView.deselectRow(at: indexPath, animated: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let dateSort = date.sorted(){
            $1 < $0
        }
        appDelegate.date = dateSort[indexPath.row]
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let mainView = view.instantiateViewController(withIdentifier: "mainList")
        mainView.heroModalAnimationType = .slide(direction: .left)
        self.present(mainView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monthCell", for: indexPath) as! MonthBillTableViewCell
        let dateSort = date.sorted(){
            $1 < $0
        }
        let key = dateSort[indexPath.row]
        let index = key.index(key.startIndex, offsetBy: 8)
        let keyResult = key.substring(from: index)
        cell.dateLabel.text = keyResult
        let value = date_price[key]
        cell.priceLabel.text = "支出: " + String(describing: value![0]) + " 元"
        cell.priceInLabel.text = "收入: " + String(describing: value![1]) + " 元"
        if value![0] >= value![1] {
            cell.flagView.backgroundColor = color.blue
        } else {
            cell.flagView.backgroundColor = color.green
        }
        return cell
    }
    
    func fetchDate() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            date.removeAll()
            for bill in billsList as! [Bill] {
                date.append(bill.date!)
            }
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        let se = Set(date)
        date = Array(se)
    }
    
    func fetchDatePrice() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var priceOut : Float = 0
        var priceIn : Float = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        do {
            let billsList = try context.fetch(fetchRequest)
            date_price.removeAll()
            for i in date {
                priceOut = 0
                priceIn = 0
                valuePrice = []
                for bill in billsList as! [Bill] {
                    let priceFloat = (bill.price! as NSString).floatValue
                    if bill.date == i {
                        if bill.isOut == true {
                            priceOut += priceFloat
                        } else {
                            priceIn += priceFloat
                        }
                    }
                }
                valuePrice.append(priceOut)
                valuePrice.append(priceIn)
                date_price[i] = valuePrice
            }
            
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        print(date_price)
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

extension MonthBillViewController: NSFetchedResultsControllerDelegate {
    func fetchMonthData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<Bill> = Bill.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: false)
        formatter.dateFormat = "yyyy年MM月"
        let monthStr = formatter.string(from: todayDate)
        let predicate = NSPredicate(format: "date CONTAINS %@","\(monthStr)")
        request.predicate = predicate
        request.sortDescriptors = [sortDescriptors]
        
        fc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fc.delegate = self
        
        do {
            
            try fc.performFetch()
            if let object = fc.fetchedObjects {
                bills = object
                print ("取回成功")
            }
            
        } catch {
            print ("取回失败")
        }
        
        monthBillTableView.reloadData()
    }
}

extension MonthBillViewController {
    @objc func closeAction(tapGesture : UITapGestureRecognizer) {
        cancelActionAnimate()
    }
    @objc func delAction(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            for bill in billsList as! [Bill] {
                formatter.dateFormat = "yyyy年MM月dd日"
                let toDate = formatter.date(from: bill.date!)
                formatter.dateFormat = "yyyy MM"
                let toMonth = formatter.string(from: toDate!)
                formatter.dateFormat = "yyyy MM"
                let toNowMonth = formatter.string(from: todayDate)
                print(toMonth, toNowMonth)
                if toMonth == toNowMonth {
                    context.delete(bill)
                }
            }
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        cancelActionAnimate()
        date = []
        date_price = [:]
        self.monthBillTableView.reloadData()
    }
    func cancelActionAnimate() {
        let bg = (self.view.viewWithTag(30))
        let av = (self.view.viewWithTag(31))
        UIView.animate(withDuration: 0.3, animations: {
            av?.frame.origin.y = UIScreen.main.bounds.size.height
            bg?.alpha = 0
        }) { (_) in
            av?.isHidden = true
            bg?.isHidden = true
        }
    }
    func actionAnimate() {
        let bg = (self.view.viewWithTag(30))
        let av = (self.view.viewWithTag(31))
        
        bg?.isHidden = false
        av?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            av?.frame.origin.y = FlagFrame.screen_H - 300
            bg?.alpha = 0.3
        }) { (_) in
            
        }
    }
}

class MonthBillTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var flagView: UIView!
    @IBOutlet weak var priceInLabel: UILabel!
    
}
