//
//  ViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 04/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

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
    
    
    //We put the new color of the navigation bar inside here instead of viewdidload because this get called after viewdid load and when the navigationcontroller does exist (not nil) in contrast to in viewdidload
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHex = selectedCategory?.color else { fatalError() }
        navBarUpdate(colorHex: colorHex)

        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
        searchBar.barTintColor = navBarColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(hexString: colorHex)!.cgColor
        
    }
    
    override func willMove(toParent parent: UIViewController?) {
        navBarUpdate(colorHex: "0A568C")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Creates a reference to the location for proper data storage. This is a singleton which is a globally accessible variable that will change each time you try to update it. right now we have only provided the path
       
        
        tableView.separatorStyle = .none
        
        searchBar.delegate = self
        
        //commented out because it will get called when we trigger the Segue from the previous viewController anyway
        //loadItems()
    
    }

    //MARK: - Navbar update function
    
    func navBarUpdate(colorHex: String) {
        
        guard let navBar = navigationController?.navigationBar else { fatalError() }
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
        
        navBar.barTintColor = navBarColor
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
    
    }
    
    
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {

            cell.textLabel?.text = item.title
            cell.detailTextLabel?.text = item.deadline
            cell.accessoryType = item.done ? .checkmark:.none
            
            //below example of optionally chaining
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.detailTextLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                cell.tintColor = ContrastColorOf(color, returnFlat: true)
                
            }
            
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
    
    //MARK: - Load data from Realm. Save is done locally above
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        self.tableView.reloadData()
    }
    
    //MARK: - Delete from Realm
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemForDeletion = self.todoItems?[indexPath.row] {
            
            do {
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
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
        
        if let itemForRenaming = self.todoItems?[indexPath.row] {
            
            var textField = UITextField()
            let alert = UIAlertController(title: "Rename title", message: "Type new title for \(itemForRenaming.title)", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Rename", style: .default) { (UIAlertAction) in
                
                do {
                    try self.realm.write {
                        itemForRenaming.title = textField.text!
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
                alertTextField.placeholder = itemForRenaming.title
                
                textField = alertTextField //Important. we do this to make a reference to the textfield so we can parse whatever is in on to the list. It is used specifically up in the action constant above. If we dont use it then the data will not get parsed as there is no link between the 2.
            }
            
            alert.addAction(action)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    //MARK: - set deadline
    override func setDeadline(_ data: String,_ indexPath:IndexPath) {

        if let itemForSettingDeadline = self.todoItems?[indexPath.row] {

        print("Successfully parsed in \(data)")
        print("Successfully parsed in \(indexPath)")

        do {
            try self.realm.write {
                itemForSettingDeadline.deadline = data
            }
        } catch {
            print("Error setting deadline in Realm: \(error)")
        }
        self.tableView.reloadData()

        }
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

