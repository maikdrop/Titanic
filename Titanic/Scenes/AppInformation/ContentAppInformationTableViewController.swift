/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class ContentAppInformationTableViewController: UITableViewController {

    // MARK: - Properties
    var cellIdentifierFromParentVC = ""
    private lazy var dataSource = getDataSource()

    deinit {
        print("DEINIT ContentAppInformationTableViewController")
    }

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
