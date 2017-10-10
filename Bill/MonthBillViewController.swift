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
    var date_price : Dictionary<String, Float> = [:]
    var fc : NSFetchedResultsController<Bill>!
    let todayDate = Date()
    let formatter = DateFormatter()

    @IBOutlet weak var monthBillTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleYearLabel: UILabel!
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
        monthBillTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15)
        
        fetchMonthData()
        fetchDate()
        fetchDatePrice()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(tapClose(tap:)))
//        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        mainView.heroModalAnimationType = .push(direction: .left)
        self.present(mainView, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "monthCell", for: indexPath) as! MonthBillTableViewCell
        let dateSort = date.sorted(){
            $1 < $0
        }
        let key = dateSort[indexPath.row]
        let index = key.index(key.startIndex, offsetBy: 5)
        let keyResult = key.substring(from: index)
        cell.dateLabel.text = keyResult
        let value = date_price[key]
        if value! >= 0 {
            cell.priceLabel.text = "净支出: " + String(describing: value!) + " 元"
            cell.priceLabel.textColor = color.blue
            cell.flagView.backgroundColor = color.blue
        } else {
            cell.priceLabel.text = "净收入: " + String(describing: -value!) + " 元"
            cell.priceLabel.textColor = color.green
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
        var priceTot : Float = 0
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        do {
            let billsList = try context.fetch(fetchRequest)
            date_price.removeAll()
            for i in date {
                priceTot = 0
                for bill in billsList as! [Bill] {
                    var priceFloat = (bill.price! as NSString).floatValue
                    if bill.date == i {
                        if bill.isOut == false {
                            priceFloat = -priceFloat
                        }
                        priceTot += priceFloat
                    }
                }
                date_price[i] = priceTot
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

class MonthBillTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var flagView: UIView!
    
}
