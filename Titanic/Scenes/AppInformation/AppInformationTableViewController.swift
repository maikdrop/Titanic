/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class AppInformationTableViewController: UITableViewController {

    // MARK: - Properties
    let dataSource = [
        AppStrings.AppInformation.aboutTheGameLblTxt,
        AppStrings.AppInformation.conceptLblTxt,
        AppStrings.AppInformation.legalLblTxt]

    deinit {
        print("DEINIT AppInformationTableViewController")
    }
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
