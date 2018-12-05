//
//  ViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 04/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Creates a reference to the location for proper data storage. This is a singleton which is a globally accessible variable that will change each time you try to update it. right now we have only provided the path
        
        print(dataFilePath!)
        
        loadItems()
    
    }

    //MARK - Tableview Datasource Methods
    
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
    
    //MARK - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       //sets the opposite value for the specific selected row item. Only works because it is a boolean true or false
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        self.saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true) //deselect the row to make sure that the row is not grey anymore
        
    }

    //MARK: Add new items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey item", message: "Enter the name of the ToDo", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            
            let newItem = Item()
            newItem.title = textField.text!
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
    
    func saveItems() {
        
        //MARK: SAVING DATA TO THE CUSTOM PLIST
        //Defines the encoder property
        let encoder = PropertyListEncoder()
        
        //Defines the data and encodes it
        do {
            let data = try encoder.encode(self.itemArray)
            try data.write(to: self.dataFilePath!)
            print("Succes in encoding data!")
        } catch {
            print("Error encoding itemArray, \(error)")
            
        }
        self.tableView.reloadData()
        
    }
    
    func loadItems() {
        
        
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
            itemArray = try decoder.decode([Item].self, from: data) //for [Item] we need to specify data type explictly as Xcode cannot infer this
            } catch {
            print("Error decoding data, \(error)")
            }
        self.tableView.reloadData() //not needed
            
        }
        

        
    }

}

