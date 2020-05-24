//
//  ViewController.swift
//  CovidChatBot
//
//  Created by Narayanaswamy, Subhashini (623) on 10/05/20.
//  Copyright © 2020 Narayanaswamy, Subhashini (623). All rights reserved.
//

import UIKit

//TODO: loader to be seen initially

enum SenderType {
    case user
    case computer
}

class ViewController: UIViewController {

    var data = Array<[SenderType: Any]>()
    
    let nlpManager = NLPManager.shared
    
    @IBOutlet weak var bottomEditView: UIVisualEffectView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        data.append([.computer: "Hi! I'm your ChatBuddy. I can help you with some Covid19 stats. What is your name?"])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        textField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowOrHide), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShowOrHide), name: UIResponder.keyboardDidHideNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardDidShowOrHide(_ notification: Notification) {
        tableView.scrollToRow(at: IndexPath(row: data.count - 1, section: 0), at: .bottom, animated: false)
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
    
    @IBAction func btnSendPressed(_ sender: Any) {
        if let message = textField.text {
            data.append([.user: message])
            textField.text = ""
            textField.resignFirstResponder()
            tableView.reloadData()
            if let computerReply = nlpManager.processText(message: message) {
                data.append([.computer: computerReply])
                tableView.reloadData()
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.text = ""
        textField.resignFirstResponder()
        return true
    }
    
}


class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: PaddedLabel!
    
    func setupUI() {
        self.backgroundColor = .clear
        
    }
}

class ComputerTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: PaddedLabel!
    
    func setupUI() {
        self.backgroundColor = .clear
        
    }
}

