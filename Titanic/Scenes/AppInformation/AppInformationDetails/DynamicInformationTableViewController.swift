/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class DynamicInformationTableViewController: UITableViewController {

    // MARK: - Properties
    var dataSource = [String]()

    deinit {
        print("DEINIT AppInformationTableViewController")
    }
}

// MARK: - Default methods
extension DynamicInformationTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        setupTableView()
    }

    // Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: informationCell, for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.font = .preferredFont(forTextStyle: .body)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textAlignment = .justified
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
}

 // MARK: - Private setup methods
private extension DynamicInformationTableViewController {

    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: informationCell)
        let customHeaderFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: headerHeight)
        tableView.tableHeaderView = UIView(frame: customHeaderFrame)
    }
}

// MARK: - Constants
private extension DynamicInformationTableViewController {
    private var informationCell: String { "informationCell" }
    private var headerHeight: CGFloat { 25 }
}
