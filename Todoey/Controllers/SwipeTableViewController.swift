//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 17/01/2019.
//  Copyright © 2019 Axel Abildtrup. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    var rowNumber:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

            tableView.rowHeight = 80.0
       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
      
        let recolorAction = SwipeAction(style: .destructive, title: "Recolor") { action, indexPath in
            self.reColorCategory(at: indexPath)
        }
    
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
           self.updateModel(at: indexPath)
        }
    
        let renameAction = SwipeAction(style: .destructive, title: "Rename") { action, indexPath in
            self.renameEntry(at: indexPath)
        }
        
        let deadlineAction = SwipeAction(style: .destructive, title: "Deadline") { action, indexPath in
    
            self.rowNumber = indexPath
            self.performSegue(withIdentifier: "goToDatePicker", sender: self)
            
        }
        
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        renameAction.image = UIImage(named: "rename-icon")
        recolorAction.image = UIImage(named: "recolor-icon")
        deadlineAction.image = UIImage(named: "recolor-icon")
        renameAction.backgroundColor = UIColor(red:0.16, green:0.50, blue:0.73, alpha:1.0)
        recolorAction.backgroundColor = UIColor.gray
        deadlineAction.backgroundColor = UIColor.black

        //recolorAction.backgroundColor = UIColor(red:0.86, green:0.90, blue:0.13, alpha:1.0)
        
        if self is CategoryViewController {
           return [deleteAction,renameAction,recolorAction]
        } else {
            return [deleteAction,renameAction,deadlineAction]
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        //placeholder to be overwritten in local viewcontroller
    }
    
    func renameEntry(at indexPath: IndexPath) {
         //placeholder to be overwritten in local viewcontroller
    }
    
    func reColorCategory(at indexPath: IndexPath) {
        //placeholder to be overwritten in local viewcontroller
    }
    
    func setDeadline(_ data:String,_ indexPath:IndexPath) -> () {
        //placeholder to be overwritten in local viewcontroller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDatePicker" {
            
            let destinationVC = segue.destination as! DatePickerViewController
            destinationVC.setDeadline = self.setDeadline
            destinationVC.indexPath = rowNumber
            
        }
        
    }

}
