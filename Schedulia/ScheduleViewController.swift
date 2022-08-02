//
//  ScheduleViewController:.swift
//  Schedulia
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit
import CoreData

class ScheduleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    class GroupedSchedule
    {
        var date: Date
        var schedules: [Schedule]
        
        init(date: Date)
        {
            self.date = date
            self.schedules = []
        }
    }
    
    @IBOutlet weak var tableViewSchedule: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let standardUserDefault = UserDefaults.standard
    var arraySchedule: [GroupedSchedule] = []
    var selectedIndexPath: IndexPath?

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.visibleViewController?.navigationItem.title = "Schedule"
        
        let addButton = UIBarButtonItem.init(image: UIImage(systemName: "plus"), style: .done, target: self, action: #selector(addSchedule))
        self.navigationController?.visibleViewController?.navigationItem.setRightBarButton(addButton, animated: false)
        
        getScheduleData()
    }
    
    @objc func addSchedule(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToAddScheduleSegue", sender: self)
    }

    func getScheduleData()
    {
        arraySchedule.removeAll()
        let context = appDelegate.persistentContainer.viewContext
        do
        {
            let fetchRequest: NSFetchRequest<Schedule> = Schedule.fetchRequest()
            let result = try context.fetch(fetchRequest)
            
            if result.isEmpty == false
            {
                arraySchedule.append(GroupedSchedule(date: StaticFunction.getStartOfDate(result[0].startTime!)))
                for schedule in result
                {
                    if arraySchedule[arraySchedule.count-1].date != StaticFunction.getStartOfDate(schedule.startTime!)
                    {
                        arraySchedule.append(GroupedSchedule(date: StaticFunction.getStartOfDate(schedule.startTime!)))
                    }
                    arraySchedule[arraySchedule.count-1].schedules.append(schedule)
                }
            }
            tableViewSchedule.reloadData()
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    @objc func addActivity(_ sender: UIButton)
    {
        performSegue(withIdentifier: "goToAddActivitySegue", sender: self)
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return arraySchedule.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return StaticFunction.dateToNameOfDay(arraySchedule[section].date)
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
        return arraySchedule[section].schedules.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellSchedule")!
        let schedule = arraySchedule[indexPath.section].schedules[indexPath.row]
        cell.textLabel?.text = "\(StaticFunction.dateToTimeString(schedule.startTime!)) - \(StaticFunction.dateToTimeString(schedule.endTime!))"
        cell.detailTextLabel?.text = schedule.has?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedIndexPath = indexPath
        tableView.cellForRow(at: indexPath)?.isSelected = false
        performSegue(withIdentifier: "goToEditScheduleSegue", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        let context = appDelegate.persistentContainer.viewContext
        if editingStyle == .delete
        {
            do
            {
                context.delete(arraySchedule[indexPath.section].schedules[indexPath.row])
                try context.save()
            }
            catch
            {
                print(error.localizedDescription)
            }
            arraySchedule[indexPath.section].schedules.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
    }
    
    @IBAction func unwindToScheduleViewController(segue: UIStoryboardSegue)
    {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToAddScheduleSegue"
        {
            let destination = segue.destination as! ScheduleDetailViewController
            destination.mode = "Add"
            let context = appDelegate.persistentContainer.viewContext

            do
            {
                let schedule = Schedule(context: context)
                schedule.id = Int32(standardUserDefault.integer(forKey: keyScheduleLastId) + 1)
                schedule.startTime = Date()
                schedule.endTime = Date()
                standardUserDefault.set(schedule.id, forKey: keyScheduleLastId)
                destination.schedule = schedule
                context.insert(schedule)
                try context.save()
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        else if segue.identifier == "goToEditScheduleSegue"
        {
            let destination = segue.destination as! ScheduleDetailViewController
            destination.mode = "Edit"
            destination.schedule = arraySchedule[selectedIndexPath!.section].schedules[selectedIndexPath!.row]
        }
    }
}

