/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import UIKit

class ChooseSpeedTableViewController: UITableViewController {

    typealias Options = TitanicGame.SpeedOption

    // MARK: - Properties
    private var loadedSpeedOption: Int? = UserDefaults.standard.value(forKey: AppStrings.UserDefaultKeys.speed) as? Int

    deinit {
        print("DEINIT ChooseSpeedTableViewController")
    }
}

// MARK: - Default methods
extension ChooseSpeedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    // Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        TitanicGame.SpeedOption.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: speedCell, for: indexPath)
        let speedOption = Options.all[indexPath.row]

        cell.textLabel?.text = speedOption.stringValue
        cell.tintColor = .black

        if let image = UIImage(systemName: speedOption.systemImageName) {
            cell.imageView?.image = image
            cell.tintColor = UIColor.label
            setDefaultStyle(for: cell, at: indexPath.row)
        }
        if loadedSpeedOption == speedOption.rawValue {
            setBoldStyle(for: cell, at: indexPath.row)
        }
        return cell
    }

    // Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        if loadedSpeedOption != nil, let index = Options.all.firstIndex(where: { $0.rawValue == loadedSpeedOption }) {

            if let previousCell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                setDefaultStyle(for: previousCell, at: indexPath.row)
            }
        }

        if let chosenCell = tableView.cellForRow(at: indexPath) {
            setBoldStyle(for: chosenCell, at: indexPath.row)
        }
        let speed = Options.all[indexPath.row].rawValue
        UserDefaults.standard.setValue(speed, forKey: AppStrings.UserDefaultKeys.speed)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private setup methods
private extension ChooseSpeedTableViewController {

    private func setupTableView() {
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: speedCell)
    }
}

// MARK: - Private cell style methods
private extension ChooseSpeedTableViewController {

    /**
     Sets the default style of a table view cell.
     
     - Parameter cell: The table view cell to modify.
     - Parameter index: The index of the row in the table.
     */
    private func setDefaultStyle(for cell: UITableViewCell, at index: Int) {
            cell.accessoryType = .none
            cell.textLabel?.font = UIFont().scalableFont(
                forTextStyle: .body,
                fontSize: defaultFontSize)
    }

    private func setBoldStyle(for cell: UITableViewCell, at index: Int) {
            cell.accessoryType = .checkmark
            cell.textLabel?.font = UIFont().scalableFontWeight(
                forTextStyle: .body,
                fontSize: increasedFontSize,
                weight: .bold)
        }
}

// MARK: - Constants
private extension ChooseSpeedTableViewController {

    private var speedCell: String { "speedCell" }
    private var defaultFontSize: CGFloat { 17 }
    private var increasedFontSize: CGFloat { 18 }
}
