//
//  ActivityViewController.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit
import CoreData

class ActivityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var textFieldKeyword: UITextField!
    @IBOutlet weak var tableViewActivity: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let standardUserDefault = UserDefaults.standard
    var arrayCategory: [Category] = []
    var arrayActivityNoCategory: [Activity] = []
    var mode = "Navigation"
    var keyword: String = ""
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textFieldKeyword.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        textFieldKeyword.leftView = imageView
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.visibleViewController?.navigationItem.title = "Activity"
        
        let addButton = UIBarButtonItem.init(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(self.addActivity(_:)))
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButton, animated: false)
        
        getCategoryData()
        getActivityData(contains: keyword)
        tableViewActivity.reloadData()
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        dismissKeyboard()
    }
    
    @IBAction func textFieldDidEndOnExit(_ sender: UITextField)
    {
        dismissKeyboard()
    }
    
    @IBAction func textFieldEditingDidEnd(_ sender: UITextField)
    {
        if sender == textFieldKeyword
        {
            keyword = StaticFunction.trimAndLowercaseString(string: sender.text!)
            getActivityData(contains: keyword)
            tableViewActivity.reloadData()
        }
    }
    
    func getCategoryData()
    {
        arrayCategory.removeAll()
        let context = appDelegate.persistentContainer.viewContext
        do
        {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
            let result = try context.fetch(fetchRequest)
            arrayCategory = result
        }
        catch let error
        {
            print("getCategoryData: ", error.localizedDescription)
        }
    }
    
    func getActivityData(contains: String)
    {
        arrayActivityNoCategory.removeAll()
        let context = appDelegate.persistentContainer.viewContext
        do
        {
            let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest(contains: contains)
            let result = try context.fetch(fetchRequest)
            
            for activity in result
            {
                if activity.isPartOf?.allObjects.count == 0
                {
                    arrayActivityNoCategory.append(activity)
                }
            }
        }
        catch let error
        {
            print("getActivityData: ", error.localizedDescription)
        }
    }
    
    @objc func addActivity(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToAddActivitySegue", sender: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arrayCategory.count + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return section < arrayCategory.count ? arrayCategory[section].name : "No Categories"
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section < arrayCategory.count
        {
            let category = arrayCategory[section]
            var filteredArray = category.has?.allObjects as! [Activity]
            filteredArray = filteredArray.filter
            {
                (val) -> Bool in
                if keyword == ""
                {
                    return true
                }
                else
                {
                    return StaticFunction.trimAndLowercaseString(string: val.name!).contains(keyword) == true
                }
            }
            return filteredArray.count
        }
        else
        {
            return arrayActivityNoCategory.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellActivity")!
        
        var activityArray = arrayActivityNoCategory
        
        if indexPath.section < arrayCategory.count
        {
            activityArray = arrayCategory[indexPath.section].has?.allObjects as! [Activity]
            activityArray = activityArray.filter
            {
                (val) -> Bool in
                if keyword == ""
                {
                    return true
                }
                else
                {
                    return StaticFunction.trimAndLowercaseString(string: val.name!).contains(keyword) == true
                }
            }
        }
        
        let activity = activityArray[indexPath.row]
        let schedules = activity.includedIn?.allObjects as! [Schedule]
        var duration = 0
        for schedule in schedules
        {
            duration += StaticFunction.getMinuteDifferences(startDate: schedule.startTime!, endDate: schedule.endTime!)
        }
        if schedules.count > 0
        {
            duration /= schedules.count
        }
        cell.textLabel?.text = activity.name
        cell.detailTextLabel?.text = "Average Time Elapsed: \(StaticFunction.createDurationString(duration))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        if mode == "Navigation"
        {
            performSegue(withIdentifier: "goToEditActivitySegue", sender: self)
        }
        else if mode == "Select"
        {
            performSegue(withIdentifier: "goToScheduleDetailSegue", sender: self)
        }
    }
    
    @IBAction func unwindToActivityViewController(segue: UIStoryboardSegue)
    {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToAddActivitySegue"
        {
            let destination = segue.destination as! ActivityDetailViewController
            destination.mode = "Add"
            let context = appDelegate.persistentContainer.viewContext
            
            do
            {
                let activity = Activity(context: context)
                activity.id = Int32(standardUserDefault.integer(forKey: keyActivityLastId) + 1)
                
                standardUserDefault.set(activity.id, forKey: keyActivityLastId)
                destination.activity = activity
                
                context.insert(activity)
                try context.save()
            }
            catch
            {
                print("goToAddActivitySeguePrepare: ", error.localizedDescription)
            }
        }
        else if segue.identifier == "goToEditActivitySegue"
        {
            let destination = segue.destination as! ActivityDetailViewController
           
            var activityArray = arrayActivityNoCategory
            
            if selectedIndexPath!.section < arrayCategory.count
            {
                activityArray = arrayCategory[selectedIndexPath!.section].has?.allObjects as! [Activity]
                activityArray = activityArray.filter
                {
                    (val) -> Bool in
                    if keyword == ""
                    {
                        return true
                    }
                    else
                    {
                        return StaticFunction.trimAndLowercaseString(string: val.name!).contains(keyword) == true
                    }
                }
            }
            
            destination.activity = activityArray[selectedIndexPath!.row]
            destination.mode = "Edit"
        }
        else if segue.identifier == "goToScheduleDetailSegue"
        {
        }
    }
}
