//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 07/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

//SwipeTableViewController already inherits from UITableViewController so it is accessed through there
class CategoryViewController: SwipeTableViewController {

    
    //MARK: - Declare initial properties
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        tableView.separatorStyle = .none
        
    }
    
    //MARK: - Tableview Datasource Methods
    //Inheriting from SwipeTableViewController superclass so that is why only so little code is provided
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //tabs into the cell from the SwipeTableViewController superclass. It is just a generic reference so we can use it below with the text table. It basically triggers all the code from this function in SwipeTableViewController
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        
        
        if let category = categoryArray?[indexPath.row] {
        
            //Nil Coalescing Operator
           
            cell.textLabel?.text = category.name
            
            guard let categoryColor = UIColor(hexString: category.color) else {fatalError()}
            
            cell.backgroundColor = categoryColor
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            //TODO: - Need to fix the below
            //cell.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
            //cell.accessoryView?.tintColor = ContrastColorOf(categoryColor, returnFlat: true)
            
            
            
        } else {
            print("Could not set category")
        }
            
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //If categoryArray (an optional) is nil return 1
        return categoryArray?.count ?? 1
    
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
        
    }
    

    //MARK: - Add new categories with button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey list", message: "Type the name of the Todoey list", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add list", style: .default) { (UIAlertAction) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            //Below can be deleted as Realm automatically updates the database by saving directly without having to use the Array
            //self.categoryArray.append(newCategory)
            self.save(category: newCategory)
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Todoey list description"
            
        textField = alertTextField //Important. we do this to make a reference to the textfield so we can parse whatever is in on to the list. It is used specifically up in the action constant above. If we dont use it then the data will not get parsed as there is no link between the 2.
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Save and load data to/from Realm
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
            print("Success saving category to Realm")
        } catch {
            print("Error saving category to Realm: \(error)")
        }
        
        self.tableView.reloadData()
        //Need the loaditems here in order to update the view properly when new data is added. should also be included in a refresh funtionality. commented out for now.
        loadCategories()
    }
    
    

    func loadCategories() {
        
    categoryArray = realm.objects(Category.self)
        
    self.tableView.reloadData()
    }
    
    //MARK: - Delete from Realm
    override func updateModel(at indexPath: IndexPath) {
        
        if let categoryForDeletion = self.categoryArray?[indexPath.row] {
            
            do {
                try self.realm.write {
                    //Deleting all subitems before deleting the main category
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting from Realm: \(error)")
            }
        }
        //Below is commented out as swipecellkit does this automatically and that is why it conflicts
        //tableView.reloadData()
    }
    
    //MARK: - Rename in Realm
    override func renameEntry(at indexPath: IndexPath) {
        
        if let categoryForRenaming = self.categoryArray?[indexPath.row] {
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Rename Todoey list", message: "Type new title for \(categoryForRenaming.name)", preferredStyle: .alert)

            let action = UIAlertAction(title: "Rename", style: .default) { (UIAlertAction) in

                do {
                    try self.realm.write {
                        categoryForRenaming.name = textField.text!
                    }
                } catch {
                    print("Error renaming in Realm: \(error)")
                }
                self.tableView.reloadData()

            }

            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }

            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = categoryForRenaming.name

                textField = alertTextField //Important. we do this to make a reference to the textfield so we can parse whatever is in on to the list. It is used specifically up in the action constant above. If we dont use it then the data will not get parsed as there is no link between the 2.
            }

            alert.addAction(action)
            alert.addAction(cancel)

            present(alert, animated: true, completion: nil)

            }
 
        }
    
    override func reColorCategory(at indexPath: IndexPath) {
        
        if let categoryForRecoloring = self.categoryArray?[indexPath.row] {
            
            do {
                try self.realm.write {
                    categoryForRecoloring.color = UIColor.randomFlat.hexValue()
                }
            } catch {
                print("Error rewriting to Realm \(error)")
            }
            
        }
            
        self.tableView.reloadData()
            
    }
    
}

