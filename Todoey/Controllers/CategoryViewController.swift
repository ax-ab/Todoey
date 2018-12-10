//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 07/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    //MARK: - Declare initial properties
    var categoryArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadItems()
        
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
        
    }
        
        
    
    

    //MARK: - Add new categories with button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new Todoey list", message: "Enter the name of the Todoey list", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add list", style: .default) { (UIAlertAction) in
            
            let newCategory = Category(context: self.context)
            
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveItems()
            
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
    func saveItems() {
        
        do {
            try context.save()
            print("Success saving context")
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
        //Need the loaditems here in order to update the view properly when new data is added. should also be included in a refresh funtionality. commented out for now.
        loadItems()
    }
    
    func loadItems(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        request.sortDescriptors = [NSSortDescriptor(key:"name", ascending:true, selector:#selector(NSString.caseInsensitiveCompare(_:)))]
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data \(error)")
        }
        self.tableView.reloadData()
        
    }
    
}
