//
//  ContentAppInformationTableViewController.swift
//  Titanic
//
//  Created by Maik on 10.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class ContentAppInformationTableViewController: UITableViewController {
    
    // MARK: - Properties
    var cellIdentifierFromParentVC = ""
    private lazy var dataSource = getDataSource()
    
}

// MARK: - Default Methods
extension ContentAppInformationTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}

// MARK: - DataSource Methods
extension ContentAppInformationTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: contentInformationCell, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = UIFont().scalableFont(forTextStyle: .body, fontSize: 17)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .natural
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
}

 // MARK: - Private methods for setting up layout of table view and data source
private extension ContentAppInformationTableViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: contentInformationCell)
        tableView.sectionHeaderHeight = headerHeight
    }
    
    private func getDataSource() -> [String] {
        var stringArray = [String]()
        if cellIdentifierFromParentVC == AppStrings.AppInformation.aboutTheAppLblTxt {
            stringArray.append(readTextFromFile(fileName: aboutTheAppFileName, with: txtExt))
            
        } else if cellIdentifierFromParentVC == AppStrings.AppInformation.legalLblTxt {
            stringArray.append(readTextFromFile(fileName: licenseFileName, with: txtExt))
        }
        return stringArray
    }
    
}

// MARK: - Constants
extension ContentAppInformationTableViewController {
    private var aboutTheAppFileName: String {"AboutTheApp"}
    private var licenseFileName: String {"MIT_License"}
    private var txtExt: String {"txt"}
    private var contentInformationCell: String {"contentInformationCell"}
    private var headerHeight: CGFloat {25}
}
