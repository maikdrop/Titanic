//
//  AppInfoViewController.swift
//  Titanic
//
//  Created by Maik on 05.12.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import UIKit

class AppInfoViewController: UIViewController {

    // MARK: - Properties
    private let dataSource = Category.all
    private lazy var tableView = setupTableView()
    private var seperatorView = UIView()

    deinit {
        print("DEINIT AppInformationTableViewController")
    }
}

// MARK: - Default Lifecycle Methods
extension AppInfoViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        title = AppStrings.AppInformation.appInfoTitle
        seperatorView.backgroundColor = .tertiarySystemGroupedBackground
        view.addSubview(seperatorView)
        view.addSubview(tableView)
        setupTableViewConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        seperatorView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.safeAreaInsets.top)
    }
}

// MARK: - Private methods for setting up table view
private extension AppInfoViewController {

    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.seperatorView.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    private func setupTableView() -> UITableView {
        let tableView = UITableView(frame: view.frame, style: .grouped)
        let customHeaderRect = CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        let customHeaderView = UIView.init(frame: customHeaderRect)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: informationCell)
        tableView.tableHeaderView = customHeaderView
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }
}

// MARK: - Delegate and data source methods
extension AppInfoViewController: UITableViewDelegate, UITableViewDataSource {

    //DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: informationCell, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont().scalableFont(forTextStyle: .body, fontSize: fontSize)
        cell.textLabel?.text = dataSource[indexPath.row].stringValue
        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
       version
    }

     //Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        AppInfoDetailsNaviPresenter().present(in: self, for: dataSource[indexPath.row])
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textAlignment = .center
        }
    }
}

private extension AppInfoViewController {
    private var fontSize: CGFloat {17}
    private var headerHeight: CGFloat {25}
    private var informationCell: String {"informationCell"}
    private var version: String {"Version " + (UIApplication.appVersion ?? "")}
}
