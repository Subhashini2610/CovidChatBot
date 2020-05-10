//
//  ViewController.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 10/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit
import CSVImporter

class ViewController: UIViewController {

    var recordsArray = Array<Any>()
    @IBOutlet weak var loaderView: LoaderView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadCSVFile()
    }
    
    func loadCSVFile() {
        DispatchQueue.main.async {
            self.loaderView.isHidden = false
        }
        if let csvPath = Bundle.main.path(forResource: "Bing-COVID19-Data", ofType: "csv") {
            let importer = CSVImporter<[String: String]>(path: csvPath)
            importer.startImportingRecords(structure: { (headerValues) -> Void in
                
                print(headerValues)
                
            }) { $0 }.onFinish { importedRecords in
                
                //                for record in importedRecords {
                //                    // a record is now a Dictionary with the header values as keys
                ////                    print(record) // => e.g. ["firstName": "Harry", "lastName": "Potter"]
                ////                    print(record["Confirmed"]) // prints "Harry" on first, "Hermione" on second run
                ////                    print(record["ConfirmedChange"]) // prints "Potter" on first, "Granger" on second run
                //                }
                self.recordsArray = importedRecords
                DispatchQueue.main.async {
                    self.loaderView.isHidden = true
                }
            }
        }
    }
    
}

