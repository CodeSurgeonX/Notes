//
//  ViewController.swift
//  Notes App
//
//  Created by Shashwat  on 11/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var notesTableView: UITableView! {
        didSet{
            notesTableView.dataSource = self
            notesTableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addNewNote(_ sender: UIBarButtonItem) {
        
    }
}


extension ViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    
}
