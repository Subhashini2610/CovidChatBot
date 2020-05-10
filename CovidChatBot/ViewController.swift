//
//  ViewController.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 10/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit
import CSVImporter

//TODO: loader to be seen initially

enum SenderType {
    case user
    case computer
}

class ViewController: UIViewController {

    var recordsArray = Array<Any>()
    var data = Array<[SenderType: Any]>()
    
    @IBOutlet weak var bottomEditView: UIVisualEffectView!
    @IBOutlet weak var loaderView: LoaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loadCSVFile()
        data.append([.computer: "Hi! I'm your chatbot. What is your name? Hi! I'm your chatbot. What is your name? Hi! I'm your chatbot. What is your name? Hi! I'm your chatbot. What is your name?"])
        data.append([.user: "Hi! I'm Subhashini. Just trying some new stuff!!!"])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            let bottomInset = view.safeAreaInsets.bottom
            bottomConstraint?.constant = isKeyboardShowing ? keyboardFrame!.height - bottomInset : 0
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
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
    
    @IBAction func btnSendPressed(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let datum = data[indexPath.row]
        if let userData = datum[.user] as? String {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserTableViewCell {
                cell.messageLabel.text = userData
                cell.setupUI()
                return cell
            }
        }
        
        if let computerData = datum[.computer] as? String {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ComputerCell") as? ComputerTableViewCell {
                cell.messageLabel.text = computerData
                cell.setupUI()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}


class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: PaddedLabel!
    
    func setupUI() {
        self.backgroundColor = .clear
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 8.0
    }
}

class ComputerTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: PaddedLabel!
    
    func setupUI() {
        self.backgroundColor = .clear
        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 8.0
    }
}

