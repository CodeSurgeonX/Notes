//
//  ViewController.swift
//  Notes App
//
//  Created by Shashwat  on 11/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ViewController: UIViewController {
    //MARK:- Outlets and Variables

    @IBOutlet weak var searchBar: UITableView!
    var notesArray = [Notes]()
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer  //Core Data Context
    var jsonData : Data?
    @IBOutlet weak var notesTableView: UITableView! {
        didSet{
            configureTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncModels()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        
    }
    
    //MARK:- Add New Note Handler
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        let addUpdateVC = AddUpdateViewController()
        addUpdateVC.container = self.container
        addUpdateVC.state = AddUpdateViewControllerState.Add
        navigationController?.pushViewController(addUpdateVC, animated: true)
    }
    
    
    //MARK:- Table View Basic Setup
    fileprivate func configureTableView() {
        notesTableView.dataSource = self
        notesTableView.delegate = self
        notesTableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "notesReusableCell")
        notesTableView.estimatedRowHeight = 200
        notesTableView.rowHeight = UITableView.automaticDimension
        notesTableView.separatorStyle = .none
    }
    
    //Core Data Methods
    fileprivate func saveData(){
        do{
            try container.viewContext.save()
        }catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func loadData(with request : NSFetchRequest<Notes> = Notes.fetchRequest(), predicate : NSPredicate? = nil){
        do {
            request.predicate = predicate
            request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
            notesArray = try container.viewContext.fetch(request)
            notesTableView.reloadData()
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func deleteObject(Object : NSManagedObject){
        container.viewContext.delete(Object)
        saveData()
        loadData()
        notesTableView.reloadData()
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = notesTableView.dequeueReusableCell(withIdentifier: "notesReusableCell", for: indexPath) as! CustomTableViewCell
        let model = notesArray[indexPath.row]
        cell.titleLabel.text = model.title
        cell.descriptionLabel.text = model.desc
        let dFormat = DateFormatter()
        dFormat.dateFormat = "dd/MM/yyyy"
        cell.createdLabel.text = "\(dFormat.string(from: model.created ?? Date()))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert : UIAlertController = UIAlertController(title: "What do you want?", message: "Do you want to delete or update the selected note", preferredStyle: .actionSheet)
        weak var weakSelf = self
        let updateAction = UIAlertAction(title: "Update", style: .default) { (alertAction) in
            let addUpdateVC = AddUpdateViewController()
            addUpdateVC.container = weakSelf?.container
            addUpdateVC.state = AddUpdateViewControllerState.Update
            addUpdateVC.model = weakSelf?.notesArray[indexPath.row]
            weakSelf?.navigationController?.pushViewController(addUpdateVC, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
            if let Object = weakSelf?.notesArray[indexPath.row]{
                weakSelf?.deleteObject(Object: Object)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(updateAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        notesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.deleteObject(Object: notesArray[indexPath.row])
    }
    
}

extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Notes> = Notes.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        loadData(with:request,predicate: NSPredicate(format: "desc CONTAINS[c] %@", searchBar.text!))
//        notesTableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


extension ViewController {
    //MARK:- Network Requests
    func syncModels(){
        do {
            let request : NSFetchRequest<Notes> = Notes.fetchRequest()
            request.predicate = NSPredicate(format: "isSynced == %@", false)
            let unSyncedNotesArray : [Notes] = try container.viewContext.fetch(request)
            jsonData = try JSONEncoder().encode(unSyncedNotesArray)
            if let _ = jsonData, let serverUrl = URL(string:"Enter Url Here") {
                var urlRequest = URLRequest(url: serverUrl)
                urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                urlRequest.httpMethod = "POST"
                urlRequest.httpBody = jsonData
                URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                    if error != nil {
                        for item in unSyncedNotesArray {
                            item.isSynced = true
                        }
                    }else{
                        print("Error")
                    }
                }
                
            }
        }catch{
            print("Error Getting Data")
        }
    }
}
