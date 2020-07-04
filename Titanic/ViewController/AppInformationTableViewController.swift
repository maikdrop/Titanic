//
//  AppInformationTableViewController.swift
//  Titanic
//
//  Created by Maik on 28.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class AppInformationTableViewController: UITableViewController {

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = .center
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         
        if let cell = sender as? UITableViewCell{
            if let identifier = segue.identifier {
                switch identifier {
                    case "chooseInfoType":
                        if let vc = segue.destination as? ContentAppInformationViewController {
                            vc.cellIdentifierFromParentVC = cell.reuseIdentifier ?? ""
                            vc.title = cell.textLabel?.text
                        }
                    case "conceptSegue":
                        if let vc = segue.destination as? ConceptViewController {
//                            vc.cellIdentifierFromParentVC = cell.reuseIdentifier
                            vc.title = cell.textLabel?.text
                        }
                    default:
                        break
                }
                
            }
            
            
            
            if segue.identifier == "chooseInfoType" {
                
            }
        }
    }
}
