//
//  AllBillViewController.swift
//  Bill
//
//  Created by 高鑫 on 2017/10/11.
//  Copyright © 2017年 高鑫. All rights reserved.
//

import UIKit
import CoreData

class AllBillViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    
    var bills : [Bill] = []
    var fc : NSFetchedResultsController<Bill>!
    var years : [String] = []
    var months : [String] = []
    var allDate : Dictionary<String, [String]> = [:]
    let todayDate = Date()

    @IBAction func backBtn(_ sender: UIButton) {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let monthView = view.instantiateViewController(withIdentifier: "monthList")
        monthView.heroModalAnimationType = .slide(direction: .up)
        self.present(monthView, animated: true, completion: nil)
    }
    @IBAction func addBtn(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.dateNow = todayDate
        
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let addView = view.instantiateViewController(withIdentifier: "addView")
        addView.heroModalAnimationType = .fade
        self.present(addView, animated: true, completion: nil)
    }
    @IBAction func menuBtn(_ sender: UIButton) {
        menuAction()
    }
    @IBOutlet weak var allBillTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allBillTableView.delegate = self
        allBillTableView.dataSource = self
        allBillTableView.tableFooterView = UIView()
        allBillTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0)
        allBillTableView.separatorColor = color.highGray
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGestureActionn(swipeGesture:)))
        self.view.addGestureRecognizer(swipeGesture)
        
        fetchDate()
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
    
    @objc func swipeGestureActionn(swipeGesture : UISwipeGestureRecognizer) {
       menuAction()
    }
    
    func menuAction() {
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let menuView = view.instantiateViewController(withIdentifier: "otherView")
        menuView.heroModalAnimationType = .slide(direction: .right)
        self.present(menuView, animated: true, completion: nil)
    }
    
    func fetchDate() {
        fetchYear()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        do {
            let billsList = try context.fetch(fetchRequest)
            allDate.removeAll()
            for i in years {
                months.removeAll()
                for bill in billsList as! [Bill] {
                    let indexD = bill.date?.index((bill.date?.startIndex)!, offsetBy: 5)
                    let date = bill.date?[indexD!...]
                    let indexM = date?.index((date?.startIndex)!, offsetBy: 3)
                    let month = date?[..<indexM!]
                    months.append(String(describing: month!))
                    let se = Set(months)
                    months = Array(se)
                    allDate[i] = months
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
        print(allDate)
    }
    
    func fetchYear() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Bill")
        do {
            let billsList = try context.fetch(fetchRequest)
            years.removeAll()
            for bill in billsList as! [Bill] {
                let index = bill.date?.index((bill.date?.startIndex)!, offsetBy: 5)
                let year = bill.date?[..<index!]
                years.append(String(describing: year!))
            }
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        let se = Set(years)
        years = Array(se)
        print(years)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return years.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = allDate[years[section]]
        return (value?.count)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        allBillTableView.deselectRow(at: indexPath, animated: true)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let value = allDate[years[indexPath.section]]
        appDelegate.dateMonth = years[indexPath.section] + (value?[indexPath.row])!
        let view = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        let monthView = view.instantiateViewController(withIdentifier: "monthList")
        monthView.heroModalAnimationType = .slide(direction: .up)
        self.present(monthView, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = color.highGray
        let titleLabel = UILabel()
        titleLabel.text = years[section]
        titleLabel.textColor = color.highBlue
        titleLabel.frame.size = CGSize(width: 200, height: 90)
        titleLabel.textAlignment = .left
        titleLabel.center.y = 45
        titleLabel.frame.origin.x = 15
        titleLabel.font = UIFont(name: "HelveticaNeue-Light", size: 35)
        headerView.addSubview(titleLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allCell", for: indexPath) as! AllBillTableViewCell
        let value = allDate[years[indexPath.section]]
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = color.highGray
        cell.label.text = value?[indexPath.row]
        return cell
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

class AllBillTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    
}
