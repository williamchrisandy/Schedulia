//
//  ScheduleDetailViewController.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit
import CoreData

class ScheduleDetailViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelActivity: UILabel!
    @IBOutlet weak var datePickerStartTime: UIDatePicker!
    @IBOutlet weak var datePickerEndTime: UIDatePicker!
    @IBOutlet weak var textViewNotes: UITextView!
    
    unowned let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var schedule: Schedule?
    var deleteData = true
    var mode = "Edit"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        textViewNotes.text = schedule?.note == "" ? "Insert your notes here..." : schedule?.note
        
        datePickerStartTime.date = schedule?.startTime ?? Date()
        datePickerEndTime.date = schedule?.endTime ?? Date()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        deleteData = mode == "Add" ? true : false
        labelActivity.text = schedule?.has == nil ? "No Activity" : schedule?.has?.name
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        let context = appDelegate.persistentContainer.viewContext
        if deleteData == true
        {
            do
            {
                context.delete(schedule!)
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
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        dismissKeyboard()
        if textView == textViewNotes
        {
            if textView.text == ""
            {
                textView.text = "Insert your notes here..."
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView == textViewNotes
        {
            if textView.text == "Insert your notes here..."
            {
                textViewNotes.text = ""
            }
        }
    }
    
    @IBAction func saveSchedule(_ sender: UIBarButtonItem)
    {
        let context = appDelegate.persistentContainer.viewContext
        
        if schedule?.has == nil
        {
            present(StaticFunction.prepareWarning(warningMessage: "Activity cannot be empty. Please try again!"), animated: true)
        }
        else if datePickerStartTime.date > datePickerEndTime.date
        {
            present(StaticFunction.prepareWarning(warningMessage: "Start Time cannot be earlier than End Time. Please try again!"), animated: true)
        }
        else
        {
            do
            {
                schedule?.startTime = datePickerStartTime.date
                schedule?.endTime = datePickerEndTime.date
                schedule?.note = textViewNotes.text == "Insert your notes here..." ? "" : textViewNotes.text
                try context.save()
            }
            catch
            {
                print(error.localizedDescription)
            }
            performSegue(withIdentifier: "goToScheduleSavedSegue", sender: self)
        }
    }
    
    @IBAction func unwindToScheduleDetailViewController(segue: UIStoryboardSegue)
    {
        if segue.identifier == "goToScheduleDetailSegue"
        {
            let source = segue.source as! ActivityViewController
            
            var activityArray = source.arrayActivityNoCategory
            
            if source.selectedIndexPath!.section < source.arrayCategory.count
            {
                activityArray = source.arrayCategory[source.selectedIndexPath!.section].has?.allObjects as! [Activity]
            }
            
            schedule?.has = activityArray[source.selectedIndexPath!.row]
        }
        else
        {
            print("Test")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "goToScheduleSavedSegue"
        {
            deleteData = false
        }
        else if segue.identifier == "goToSelectActivitySegue"
        {
            deleteData = false
            
            let destination = segue.destination as! ActivityViewController
            destination.mode = "Select"
        }
    }
}
