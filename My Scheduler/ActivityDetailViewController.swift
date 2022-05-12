//
//  ActivityDetailViewController.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit
import CoreData

class ActivityDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var textFieldActivityName: UITextField!
    @IBOutlet weak var labelCategories: UILabel!
    @IBOutlet weak var tableViewHistory: UITableView!
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var activity: Activity?
    var deleteData = true
    var mode = "Edit"
    var arraySchedule: [Schedule] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        textFieldActivityName.text = activity?.name
        if activity?.name == ""
        {
            activity?.name = "Untitled \(activity!.id)"
        }
        getScheduleData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        deleteData = mode == "Add" ? true : false
        updateCategoryLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let context = appDelegate.persistentContainer.viewContext
        if deleteData == true
        {
            do
            {
                context.delete(activity!)
                try context.save()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
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
    
    func updateCategoryLabel()
    {
        var text = ""
        let arrayCategory = activity?.isPartOf?.allObjects as! [Category]
        
        for category in arrayCategory
        {
            if text != ""
            {
                text += ", "
            }
            text += category.name!
        }
        
        labelCategories.text = text == "" ? "No Category" : text
    }
    
    func getScheduleData()
    {
        arraySchedule = activity?.includedIn?.allObjects as! [Schedule]
        tableViewHistory.reloadData()
    }
    
    @IBAction func saveActivity(_ sender: UIBarButtonItem)
    {
        let context = appDelegate.persistentContainer.viewContext
        let activityName = textFieldActivityName.text!
        
        guard activityName.count > 0
        else
        {
            present(StaticFunction.prepareWarning(warningMessage: "Activity Name cannot be empty. Please try again!"), animated: true)
            return
        }
        
        do
        {
            let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest(name: activityName)
            let result = try context.fetch(fetchRequest)
            
            if result.isEmpty == false
            {
                present(StaticFunction.prepareWarning(warningMessage: "Activity Name has already existed. Please try again!"), animated: true)
            }
            else
            {
                do
                {
                    activity?.name = activityName
                    try context.save()
                }
                catch
                {
                    print(error.localizedDescription)
                }
                performSegue(withIdentifier: "goToActivitySavedSegue", sender: self)
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arraySchedule.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellHistory")!
        let schedule = arraySchedule[indexPath.row]
        cell.textLabel?.text = StaticFunction.dateToNameOfDay(schedule.startTime!)
        cell.detailTextLabel?.text = "\(StaticFunction.dateToTimeString(schedule.startTime!)) - \(StaticFunction.dateToTimeString(schedule.endTime!))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToActivitySavedSegue"
        {
            deleteData = false
        }
        else if segue.identifier == "goToCategoryScene"
        {
            let destination = segue.destination as! CategoriesViewController
            
            deleteData = false
            destination.activity = activity
        }
    }
}
