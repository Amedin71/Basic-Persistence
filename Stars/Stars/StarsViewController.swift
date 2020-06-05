//
//  ViewController.swift
//  Stars
//
//  Created by Andrew R Madsen on 7/31/18.
//  Copyright © 2018 Lambda Inc. All rights reserved.
//

import UIKit

class StarsViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
        
    @IBAction func createStar(_ sender: Any) {
        
    }
    
    @IBAction func printStars(_ sender: UIButton) {
    }
}

extension StarsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }
}
