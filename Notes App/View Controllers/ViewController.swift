//
//  ViewController.swift
//  Notes App
//
//  Created by Shashwat  on 11/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    //MARK:- Outlets and Variables
    var notesArray = [Notes]()
    let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer  //Core Data Context
    @IBOutlet weak var notesTableView: UITableView! {
        didSet{
            configureTableView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        notesTableView.reloadData()
    }
    
    //MARK:- Add New Note Handler
    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        let addUpdateVC = AddUpdateViewController()
        addUpdateVC.container = self.container
        addUpdateVC.state = State.Add
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
    
    fileprivate func loadData(){
        do {
            notesArray = try container.viewContext.fetch(Notes.fetchRequest())
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
        cell.titleLabel.text = notesArray[indexPath.row].title
        cell.descriptionLabel.text = notesArray[indexPath.row].desc
        cell.createdLabel.text = "22/12/1994"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert : UIAlertController = UIAlertController(title: "What do you want?", message: "Do you want to delete or update the selected note", preferredStyle: .alert)
        weak var weakSelf = self
        let updateAction = UIAlertAction(title: "Update", style: .default) { (alertAction) in
            let addUpdateVC = AddUpdateViewController()
            addUpdateVC.container = weakSelf?.container
            addUpdateVC.state = State.Update
            addUpdateVC.model = weakSelf?.notesArray[indexPath.row]
            weakSelf?.navigationController?.pushViewController(addUpdateVC, animated: true)
        }
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in
            if let Object = weakSelf?.notesArray[indexPath.row]{
                weakSelf?.deleteObject(Object: Object)
            }
        }
        alert.addAction(updateAction)
        alert.addAction(deleteAction)
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
