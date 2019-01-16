//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 07/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    
    //MARK: - Declare initial properties
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
        
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
       
        //Nil Coalescing Operator
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No Categories Added Yet"
        
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
        let alert = UIAlertController(title: "Add new Todoey list", message: "Enter the name of the Todoey list", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add list", style: .default) { (UIAlertAction) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            
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
    
    //MARK: - Save and load data to/from Core Data
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
            print("Success saving context")
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
        //Need the loaditems here in order to update the view properly when new data is added. should also be included in a refresh funtionality. commented out for now.
        loadCategories()
    }
    
    
    //Legacy from coredata. can be deleted once working
    func loadCategories() {
        
    categoryArray = realm.objects(Category.self)
        
    self.tableView.reloadData()
    }
    
    
//    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
//
//        request.sortDescriptors = [NSSortDescriptor(key:"name", ascending:true, selector:#selector(NSString.caseInsensitiveCompare(_:)))]
//
//        do {
//            categoryArray = try context.fetch(request)
//        } catch {
//            print("Error fetching data \(error)")
//        }
//        self.tableView.reloadData()
//
//    }
    
}
