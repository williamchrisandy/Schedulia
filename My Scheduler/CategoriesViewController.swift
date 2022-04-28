//
//  CategoriesViewController.swift
//  My Scheduler
//
//  Created by William Chrisandy on 27/04/22.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    class CategoryInActivity
    {
        var category: Category
        var isInActivity: Bool
        
        init(category: Category, isInActivity: Bool)
        {
            self.category = category
            self.isInActivity = isInActivity
        }
    }
    
    @IBOutlet weak var textFieldKeyword: UITextField!
    @IBOutlet weak var tableViewCategory: UITableView!
    
    var addCategoryAlertController: UIAlertController?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let standardUserDefault = UserDefaults.standard
    var arrayCategory: [CategoryInActivity] = []
    var activity: Activity?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addCategoryAlertController = prepareSaveCategoryDialog()
        
        textFieldKeyword.leftViewMode = UITextField.ViewMode.always
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "magnifyingglass")
        textFieldKeyword.leftView = imageView
        
        getCategoryData(contains: "")
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
            let contains = StaticFunction.trimAndLowercaseString(string: sender.text!)
            getCategoryData(contains: contains.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
        }
    }
    
    func prepareSaveCategoryDialog() -> UIAlertController
    {
        let alert = UIAlertController(title: "Category Detail", message: "Input new category detail", preferredStyle: .alert)
        
        alert.addTextField
        {
            textField in
            textField.placeholder = "Category Name"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: saveCategory)
        
        alert.addAction(saveAction)
        
        return alert
    }
    
    func saveCategory(action: UIAlertAction)
    {
        let context = appDelegate.persistentContainer.viewContext
        
        let textFieldCategoryName = addCategoryAlertController!.textFields![0]
        let categoryName = textFieldCategoryName.text!
        
        guard categoryName.count > 0
        else
        {
            present(StaticFunction.prepareWarning(warningMessage: "Action is reborted.\n\nCategory Name cannot be empty. Please try again!"), animated: true)
            return
        }
        
        do
        {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest(name: categoryName)
            let result = try context.fetch(fetchRequest)

            if result.isEmpty == false
            {
                present(StaticFunction.prepareWarning(warningMessage: "Action is reborted.\n\nCategory Name has already existed. Please try again!"), animated: true)
            }
            else
            {
                let category = Category(context: context)
                category.id = Int16(standardUserDefault.integer(forKey: keyCategoryLastId) + 1)
                category.name = categoryName

                standardUserDefault.set(category.id, forKey: keyCategoryLastId)

                context.insert(category)
                    try context.save()
                arrayCategory.append(CategoryInActivity(category: category, isInActivity: false))
                tableViewCategory.insertRows(at: [IndexPath(row: arrayCategory.count-1, section: 0)], with: .bottom)
            }
        }
        catch
        {
            print(error.localizedDescription)
        }
        textFieldCategoryName.text = ""
    }
   
    func getCategoryData(contains: String)
    {
        arrayCategory.removeAll()
        let context = appDelegate.persistentContainer.viewContext
        do
        {
            let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest(contains: contains)
            let result = try context.fetch(fetchRequest)
            
            for category in result
            {
                let arrayActivity = category.has?.allObjects as! [Activity]
                var isInActivity = false
                
                for searchedActivity in arrayActivity
                {
                    if searchedActivity == activity
                    {
                        isInActivity = true
                        break
                    }
                }
                arrayCategory.append(CategoryInActivity(category: category, isInActivity: isInActivity))
            }
            tableViewCategory.reloadData()
        }
        catch let error
        {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem)
    {
        present(addCategoryAlertController!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCellCategory")!
        
        let category = arrayCategory[indexPath.row]
        
        cell.textLabel?.text = category.category.name
        cell.accessoryType = category.isInActivity == true ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let context = appDelegate.persistentContainer.viewContext
        let category = arrayCategory[indexPath.row]
        
        do
        {
            if category.isInActivity == true
            {
                category.category.removeFromHas(activity!)
                category.isInActivity = false
            }
            else
            {
                category.category.addToHas(activity!)
                category.isInActivity = true
            }
            try context.save()
        }
        catch
        {
            print(error.localizedDescription)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let context = appDelegate.persistentContainer.viewContext
        let category = arrayCategory[indexPath.row]
        let editAction = UIContextualAction(style: .normal, title: "Edit")
        {
            action, view, handler in
            
            let editAlertController = UIAlertController(title: "Edit Category", message: "Input new category detail", preferredStyle: .alert)
            
            editAlertController.addTextField
            {
                textField in
                textField.text = category.category.name!
                textField.placeholder = "Category Name"
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default)
            {
                action in
                let textFieldCategoryName = editAlertController.textFields![0]
                let categoryName = textFieldCategoryName.text!
                
                guard categoryName.count > 0
                else
                {
                    self.present(StaticFunction.prepareWarning(warningMessage: "Action is reborted.\n\nCategory Name cannot be empty. Please try again!"), animated: true)
                    return
                }
                
                do
                {
                    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest(name: categoryName)
                    let result = try context.fetch(fetchRequest)
                    
                    if result.isEmpty == false
                    {
                        self.present(StaticFunction.prepareWarning(warningMessage: "Action is reborted.\n\nCategory Name has already existed. Please try again!"), animated: true)
                    }
                    else
                    {
                        category.category.name = categoryName
                        try context.save()
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
            
            editAlertController.addAction(saveAction)
            self.present(editAlertController, animated: true)
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete")
        {
            action, view, handler in
            do
            {
                context.delete(category.category)
                try context.save()
                self.arrayCategory.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}
