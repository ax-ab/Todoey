//
//  ViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 04/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    //MARK: - Declare initial properties
    var itemArray = [Item]()
    //The variable below only gets a value if triggered through the segue defined in the Category viewcontroller prepare for Segue. this will be set with a specific entry in the array ( destinationVC.selectedCategory = categoryArray[indexPath.row] )
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //defining context for core data. this is explained in lecture 236. bookmarked!
    //The context can be viewed as the staging area for our data
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        //Using the Ternary Operator below. removing true as that is apparently redundant
        cell.accessoryType = item.done ? .checkmark:.none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Deleting items in context and Array below for testing now which is why it is commented out.
        //Very important is the order below as we have to remove the entry from the context first before we remove it from the itemArray
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        //sets the opposite value for the specific selected row item. Only works because it is a boolean true or false
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) //deselect the row to make sure that the row is not grey anymore
        
    }

    //MARK: - Add new items with button
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey item", message: "Enter the name of the ToDo", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            

            let newItem = Item(context: self.context)
            
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory //We make sure that it gets the proper parent category relevant to the todoey lists.
            self.itemArray.append(newItem)
            self.saveItems()
            
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
    
    //MARK: - Save and load data to/from Core Data
    func saveItems() {
        
        do {
        try context.save()
        print("Success saving context")
        } catch {
        print("Error saving context: \(error)")
        }
       
        self.tableView.reloadData()
        loadItems()
    }
    
    //below we are defining a default value to go into the parameter which is the stuff that comes after =. for the predicate it is simply nothing if nothing is parsed in.
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        //Specifies a request that simply fetches the whole database part for Item but we need to specify the data type <Item>. Commented out as we now use it as a default value for loadItems as per above
       // let request:NSFetchRequest<Item> = Item.fetchRequest()
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        //the below makes sure that we only parse the additional predicate in case that the additional predicate is set. that is the predicate!
        if let additionalPredicate = predicate {
            
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
            
        } else {
            
            request.predicate = categoryPredicate
            
        }
        
       
        let titleDescriptor = NSSortDescriptor(key:"title", ascending:true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
        
        let doneDescriptor = NSSortDescriptor(key:"done", ascending:true, selector:#selector(NSString.caseInsensitiveCompare(_:)))
        
        request.sortDescriptors = [doneDescriptor, titleDescriptor]
        
//        request.sortDescriptors = [NSSortDescriptor(key:"title", ascending:true, selector:#selector(NSString.caseInsensitiveCompare(_:)))]
        
        
        //request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        
        do {
            //Putting the fetch request inside itemArray
            itemArray = try context.fetch(request)
            } catch {
                print("Error fetching data \(error)")
            }
        
            self.tableView.reloadData()
    

    }
    
}

//MARK: - searchBar functionality
extension TodoListViewController: UISearchBarDelegate {
   
    //This button gets triggered once the user presses Search on the keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //So then our query becomes for all the items in the item array look for the ones where the title of the item contains this text (searchBar.text!).
        //let request:NSFetchRequest<Item> = Item.fetchRequest()
        
        //the [cd] below means that it is now NON-sensitive towards case and diacritics

        
        //Previosly
//        let sortDescriptor = NSSortDescriptor(key:"title", ascending:true)
//        request.sortDescriptors = [sortDescriptor]
    
        //request.sortDescriptors = [NSSortDescriptor(key:"title", ascending:true)]

        //here we previosly had the code from load items but instead we included the load item function to have a request as input.
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        loadItems(predicate: predicate)
        
        //My previous solution
//        loadItems(predicate: NSPredicate(format: "title CONTAINS[cd] %@ AND parentCategory.name MATCHES %@", searchBar.text!, selectedCategory!.name!))
        
       // tableView.reloadData() //redundant as we already have this in loadItems?
        
    }
    
    //Using the below to check whether the cross button was pressed by infering it through the below method.
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
