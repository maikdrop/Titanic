//
//  AppInformationTableViewController.swift
//  Titanic
//
//  Created by Maik on 28.06.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class AppInformationTableViewController: UITableViewController {
    
    // MARK: - Properties
    let dataSource = [AppStrings.AppInformation.aboutTheAppLblTxt, AppStrings.AppInformation.conceptLblTxt, AppStrings.AppInformation.legalLblTxt]
}

 // MARK: - Default Methods
extension AppInformationTableViewController {
    
    override func viewDidLoad() {
        navigationItem.largeTitleDisplayMode = .always
        setupTableView()
    }
}

// MARK: - Private methods for setting up layout of table view
private extension AppInformationTableViewController {
    
    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
        tableView.sectionHeaderHeight = headerHeight
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: informationCell)
    }
}

// MARK: - Delegate and DataSource Methods
extension AppInformationTableViewController {
    
    //DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: informationCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont().scalableFont(forTextStyle: .body, fontSize: fontSize)
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UITableViewHeaderFooterView()
        footer.textLabel?.text = version
        return footer
    }
    
     //Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath), let cellText = cell.textLabel?.text {
            AppInformationContentPresenter().present(in: self, for: cellText)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: headerHeight))
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = .center
        }
    }
}

// MARK: - Constants
extension AppInformationTableViewController {
    private var fontSize: CGFloat {17}
    private var headerHeight: CGFloat {25}
    private var informationCell: String {"informationCell"}
    private var version: String {"Version " + (UIApplication.appVersion ?? "")}
    private var navigationItemTitle: String {"App Information"}
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
