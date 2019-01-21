//
//  DatePickerViewController.swift
//  Todoey
//
//  Created by Axel Abildtrup on 21/01/2019.
//  Copyright © 2019 Axel Abildtrup. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    var setDeadline: ((_ data:String,_ indexPath: IndexPath) -> ())?
    var indexPath:IndexPath?
    
    var formattedDate: String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: datePickerWheel.date)
        
    }
    
    @IBOutlet weak var datePickerWheel: UIDatePicker!
    @IBAction func saveDateButton(_ sender: Any) {
        
        //Optional chaining
        
        guard let indexPath = indexPath else {fatalError()}
        
        setDeadline?(formattedDate,indexPath)

        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerWheel.backgroundColor = UIColor(hexString: "0A568C")
        datePickerWheel.setValue(UIColor.white, forKey: "textColor")
        
    }


    

}
