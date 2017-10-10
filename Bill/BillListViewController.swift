//
//  BillListViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/9/23.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

class BillListViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var bills : [Bill] = []
    var prices : [Float] = []
    var fc : NSFetchedResultsController<Bill>!
    var iip = [NSIndexPath]()
    var dip = [NSIndexPath]()
    let todayDate = Date()
    let formatter = DateFormatter()
    var date : String?
    var dateStr : String?
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBAction func monthBtn(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let monthView = view.instantiateViewController(withIdentifier: "monthList")
        monthView.heroModalAnimationType = .pull(direction: .right)
        self.present(monthView, animated: true, completion: nil)
    }
    @IBOutlet weak var billListCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        date = appDelegate.date
        
//        self.view.heroModifiers = [.fade, .translate(x: FlagFrame.screen_W, y:0)]
        
        billListCollectionView.delegate = self
        billListCollectionView.dataSource = self
        
        formatter.dateFormat = "MM月dd日"
        formatter.locale = Locale(identifier: "zh_CN")
        if date == nil {
            titleLabel.text = formatter.string(from: todayDate)
        } else {
            let index = date?.index((date?.startIndex)!, offsetBy: 5)
            let dateMD = date?.substring(from: index!)
            titleLabel.text = dateMD
        }
        
        
        let addBtn = UIButton()
        addBtn.frame = CGRect(x: FlagFrame.addBtn_W, y: FlagFrame.addBtn_H, width: 45, height: 45)
        addBtn.setImage(#imageLiteral(resourceName: "add"), for: .normal)
        addBtn.tag = 300
        addBtn.heroID = "addBtn"
        addBtn.addTarget(self, action: #selector(btnsAction(_:)), for: .touchUpInside)
        self.view.addSubview(addBtn)
        
        let allDeleteBtn = UIButton()
        allDeleteBtn.frame = CGRect(x: FlagFrame.addBtn_W, y: FlagFrame.addBtn_H, width: 45, height: 45)
        allDeleteBtn.setImage(#imageLiteral(resourceName: "delete"), for: .normal)
        allDeleteBtn.tag = 302
        allDeleteBtn.isHidden = true
        allDeleteBtn.alpha = 0
        allDeleteBtn.addTarget(self, action: #selector(btnsAction(_:)), for: .touchUpInside)
        self.view.addSubview(allDeleteBtn)
        
        let bgView = UIView()
        bgView.frame = self.view.frame
        bgView.backgroundColor = UIColor.black
        bgView.alpha = 0
        bgView.isHidden = true
        bgView.tag = 304
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
        actionView.tag = 305
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
        allDeleteActionTitleLabel.text = "您将要删除所有 支出/收入 记录的详细信息"
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
        allDeleteActionBtn.addTarget(self, action: #selector(allDeleteAction(_:)), for: .touchUpInside)
        actionView.addSubview(allDeleteActionBtn)
        
        let cancelDeleteActionBtn = UIButton()
        cancelDeleteActionBtn.frame.size = CGSize(width: FlagFrame.screen_W * 0.7, height: 50)
        cancelDeleteActionBtn.center.x = actionView.center.x
        cancelDeleteActionBtn.frame.origin.y = actionView.frame.size.height * 0.75
        cancelDeleteActionBtn.backgroundColor = UIColor.groupTableViewBackground
        cancelDeleteActionBtn.setTitle("取消", for: .normal)
        cancelDeleteActionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelDeleteActionBtn.setTitleColor(UIColor.darkGray, for: .normal)
        cancelDeleteActionBtn.layer.cornerRadius = 10
        cancelDeleteActionBtn.addTarget(self, action: #selector(cancelDeleteAction(_:)), for: .touchUpInside)
        actionView.addSubview(cancelDeleteActionBtn)
        
        fetchDayData()
        fetchCancelEdit()
        fetchTodayDate()
        
        let notificationName = Notification.Name("fetchToday")
        NotificationCenter.default.addObserver(self, selector: #selector(fetchTodayDate), name: notificationName, object: nil)
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
    
    @objc func closeAction(tapGesture : UITapGestureRecognizer) {
        cancelActionAnimate()
    }
    
    @objc func btnsAction(_ sender : UIButton) {
        let tag = sender.tag
        switch tag {
        case 300:
            if titleView.backgroundColor == UIColor.white {
                closeEditAction()
            } else {
                addAction()
            }
        case 302:
            actionAnimate()
            
        default:
            break
        }
    }
    
    func addAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if date == nil {
            appDelegate.dateNow = todayDate
        } else {
            formatter.dateFormat = "yyyy年MM月dd日"
            let dateFromStr = formatter.date(from: date!)
            appDelegate.dateNow = dateFromStr
        }
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let addView = view.instantiateViewController(withIdentifier: "addView")
        addView.heroModalAnimationType = .fade
        self.present(addView, animated: true, completion: nil)
    }
    
    func closeEditAction() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            
            for bill in billsList as! [Bill] {
                if bill.isEdit == true {
                    bill.isEdit = false
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
        cancelAnimate()
        fetchTodayDate()
    }

    @objc func allDeleteAction(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            
            for bill in billsList as! [Bill] {
                if bill.isEdit == true {
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
    }
    
    @objc func cancelDeleteAction(_ sender: UIButton) {
        cancelActionAnimate()
    }
    
    func fetchCancelEdit() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            
            for bill in billsList as! [Bill] {
                if bill.isEdit == true {
                    bill.isEdit = false
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
    }
    
    @objc func fetchTodayDate() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        formatter.dateFormat = "yyyy年MM月dd日"
        if date == nil {
            dateStr = formatter.string(from: todayDate)
        } else {
            dateStr = date!
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")

        do {
            let billsList = try context.fetch(fetchRequest)
            prices.removeAll()
            for bill in billsList as! [Bill] {
                var priceFloat = (bill.price! as NSString).floatValue
                if bill.date == dateStr {
                    if bill.isOut == false {
                        priceFloat = -priceFloat
                    }
                    prices.append(priceFloat)
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
        sumOut()
        
    }
    
    func sumOut() {
        var totalOut : Float = 0
        for i in prices {
            totalOut += i
        }
        if totalOut >= 0 {
            priceLabel.text = "今日净支出: " + String(totalOut) + " 元"
        } else {
            priceLabel.text = "今日净收入: " + String(-totalOut) + " 元"
        }
        if prices.count == 0 {
            priceLabel.text = "今日暂无账单记录"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bills.count
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            dip.append(indexPath! as NSIndexPath)
        case .insert:
            iip.append(newIndexPath! as NSIndexPath)
        case .update:
            billListCollectionView.reloadItems(at: [indexPath!])
        default:
            billListCollectionView.reloadData()
        }
        if let object = controller.fetchedObjects {
            bills = object as! [Bill]
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        billListCollectionView.performBatchUpdates({
            self.billListCollectionView.insertItems(at: self.iip as [IndexPath])
            self.billListCollectionView.deleteItems(at: self.dip as [IndexPath])
        }) { (_) in
            self.iip.removeAll(keepingCapacity: false)
            self.dip.removeAll(keepingCapacity: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        billListCollectionView.deselectItem(at: indexPath, animated: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.bill = bills[indexPath.item]
        
        let detail = DetailBillViewController()
        let transitionDelegate = DeckTransitioningDelegate()
        detail.transitioningDelegate = transitionDelegate
        detail.modalPresentationStyle = .custom
        present(detail, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BillListCollectionViewCell
        let bill = bills[indexPath.item]
        let index = bill.time?.index((bill.time?.startIndex)!, offsetBy: 12)
        let time = bill.time?.substring(to: index!)
        cell.timeLabel.text = time
        cell.detailLabel.text = bill.title
        cell.priceLabel.text = bill.price! + " 元"
        cell.typeImage.image = UIImage(named: bill.type!)
        cell.deleteBtn.tag = indexPath.item
        cell.deleteBtn.isHidden = bill.isEdit ? false : true
        cell.deleteBtn.addTarget(self, action: #selector(deleteAction(deleteBtn:)), for: .touchUpInside)
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(editLongAction(longGesture:)))
        longGesture.delegate = self as? UIGestureRecognizerDelegate
        longGesture.minimumPressDuration = 1
        cell.addGestureRecognizer(longGesture)
            
        return cell
    }
    
    @objc func editLongAction(longGesture : UILongPressGestureRecognizer) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        
        do {
            let billsList = try context.fetch(fetchRequest)
            
            for bill in billsList as! [Bill] {
                if bill.isEdit == false {
                    bill.isEdit = true
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
        if longGesture.state == .began {
            editAnimate()
        }
    }
    
    @objc func deleteAction(deleteBtn : UIButton) {
        self.billListCollectionView.performBatchUpdates({
            let indexPath = IndexPath.init(item: deleteBtn.tag, section: 0)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            context.delete(self.fc.object(at: indexPath))
            appDelegate.saveContext()
            if self.bills.count == 0 {
                self.cancelAnimate()
            }
        }) { (_) in
            self.billListCollectionView.reloadData()
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

extension BillListViewController {
    
    func editAnimate() {
        let addButton = (self.view.viewWithTag(300) as! UIButton)
        let allDeleteButton = (self.view.viewWithTag(302) as! UIButton)
        allDeleteButton.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.titleLabel.alpha = 0
            self.priceLabel.text = "编辑"
            self.priceLabel.textColor = color.blue
            self.view.backgroundColor = UIColor.white
            self.titleView.backgroundColor = UIColor.white
            UIApplication.shared.statusBarStyle = .default
            addButton.transform = addButton.transform.rotated(by: 0.25 * .pi)
            allDeleteButton.alpha = 1
            allDeleteButton.frame.origin.y = FlagFrame.alldeleteBtn_H
        }) { (_) in
            self.titleLabel.isHidden = true
        }
    }
    
    func cancelAnimate() {
        let addButton = (self.view.viewWithTag(300) as! UIButton)
        let allDeleteButton = (self.view.viewWithTag(302) as! UIButton)

        self.titleLabel.isHidden = false
        fetchTodayDate()
        UIView.animate(withDuration: 0.3, animations: {
            self.titleLabel.alpha = 1
            self.priceLabel.textColor = UIColor.white
            self.titleView.backgroundColor = color.blue
            self.view.backgroundColor = color.blue
            UIApplication.shared.statusBarStyle = .lightContent
            addButton.transform = addButton.transform.rotated(by: 1.75 * .pi)
            allDeleteButton.alpha = 0
            allDeleteButton.frame.origin.y = FlagFrame.addBtn_H
        }) { (_) in
            allDeleteButton.isHidden = true
        }
    }
    
    func actionAnimate() {
        let bg = (self.view.viewWithTag(304))
        let av = (self.view.viewWithTag(305))
        
        bg?.isHidden = false
        av?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            av?.frame.origin.y = FlagFrame.screen_H - 300
            bg?.alpha = 0.3
        }) { (_) in
            
        }
    }
    
    func cancelActionAnimate() {
        let bg = (self.view.viewWithTag(304))
        let av = (self.view.viewWithTag(305))
        UIView.animate(withDuration: 0.3, animations: {
            av?.frame.origin.y = UIScreen.main.bounds.size.height
            bg?.alpha = 0
        }) { (_) in
            av?.isHidden = true
            bg?.isHidden = true
            self.closeEditAction()
        }
    }

}

extension BillListViewController : NSFetchedResultsControllerDelegate {
    
    func fetchDayData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<Bill> = Bill.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "time", ascending: false)
        formatter.dateFormat = "yyyy年MM月dd日"
        let dateStr = formatter.string(from: todayDate)
        if date == nil {
            let predicate = NSPredicate(format: "date = '\(dateStr)'")
            request.predicate = predicate
        } else {
            let predicateSel = NSPredicate(format: "date = '\(date!)'")
            request.predicate = predicateSel
        }
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
        
        billListCollectionView.reloadData()
    }
}

class BillListCollectionViewCell : UICollectionViewCell {
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
}
