//
//  ViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 04/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    //MARK: - Declare initial properties
    var todoItems: Results<Item>?
    let realm = try! Realm()
    //The variable below only gets a value if triggered through the segue defined in the Category viewcontroller prepare for Segue. this will be set with a specific entry in the array ( destinationVC.selectedCategory = categoryArray[indexPath.row] )
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Creates a reference to the location for proper data storage. This is a singleton which is a globally accessible variable that will change each time you try to update it. right now we have only provided the path
        
       searchBar.delegate = self
        
        //commented out because it will get called when we trigger the Segue from the previous viewController anyway
        //loadItems()
    
    }

    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
            //Using the Ternary Operator below. removing true as that is apparently redundant
            cell.accessoryType = item.done ? .checkmark:.none
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
         
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving to Realm: \(error)")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true) //deselect the row to make sure that the row is not grey anymore
        tableView.reloadData()
        
    }

    //MARK: - Add new items with button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey item", message: "Enter the name of the ToDo", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                    print("Success saving in Realm")
                } catch {
                    print("Error saving to Realm: \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)

        }
        
        alert.addTextField { (alertTextField) in
        alertTextField.placeholder = "todo description" // not necessary if no placeholder is needed. already tested
        
        textField = alertTextField
        
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Save and load data to/from Realm
    
    func loadItems() {
        

        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        self.tableView.reloadData()
    }
    
    
}

//MARK: - searchBar functionality

extension TodoListViewController: UISearchBarDelegate {
   
    //This button gets triggered once the user presses Search on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        self.tableView.reloadData()
        
    }
  
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            
            //Removes the keyboard from the view. Explained in lecture 244 bookmarked.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
 
    
}

