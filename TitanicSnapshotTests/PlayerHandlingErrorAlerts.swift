/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import SnapshotTesting
import XCTest
@testable import Titanic

struct MockPlayerHandling: DataHandling {

    var fetchingError = false

    typealias DataTyp = [TitanicGame.Player]

    typealias Handler = (Result<DataTyp, Error>) -> Void

    func save(player: DataTyp, then completion: Handler) {

        completion(.failure(DataHandlingError.writingError(message: AppStrings.ErrorAlert.writingErrorMessage)))
    }

    func fetch(then completion: Handler) {
        if fetchingError {
            completion(.failure(DataHandlingError.readingError(message: AppStrings.ErrorAlert.readingErrorMessage)))
        } else {
            let player = Array(repeating: TitanicGame.Player(name: "maikdrop", drivenMiles: 0.0), count: 5)
            completion(.success(player))
        }
    }
}

class MockGameViewPresenter: TitanicGameViewPresenter {

    var game: TitanicGame!

    override func gameViewDidLoad(icebergs: [ImageView]) {

        game = TitanicGame(icebergs: [TitanicGame.Iceberg](), dataHandler: MockPlayerHandling())
    }

    override func nameForHighscoreEntry(userName: String, completion: @escaping (Error?) -> Void) {
        game?.savePlayer(userName: userName) {error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

class MockHigscoreListTVC: HighscoreListTableViewController {

    var presentViewControllerTarget: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewControllerTarget = viewControllerToPresent
    }
}

//SnapshotTesting only works on simulator and 2 test runs needed (for creating and verifing image)
class PlayerHandlingErrorAlerts: XCTestCase {

    func testHighscoreListWritingErrorAlert() {

        let mockedGameViewPresenter = MockGameViewPresenter()

        let sut = TitanicGameViewController(gameViewPresenter: mockedGameViewPresenter)

        mockedGameViewPresenter.gameViewDidLoad(icebergs: [ImageView]())

        if mockedGameViewPresenter.game.drivenSeaMilesInHighscoreList {

            mockedGameViewPresenter.nameForHighscoreEntry(userName: "testName") {error in

                if let dataHandlingError = error as? DataHandlingError {
                    let alertController = self.setupAlert(
                        message: dataHandlingError.getErrorMessage())
                    self.layoutFor(alertController, in: sut.view)
                    assertSnapshot(matching: sut, as: .windowedImage)
                }
            }
        }
    }

    func testHighscoreListReadingErrorAlert() {

        var mockPlayerHandling = MockPlayerHandling()
        mockPlayerHandling.fetchingError = true

        let sut = MockHigscoreListTVC(dataHandler: mockPlayerHandling)
        sut.viewDidLoad()

        if let presentedAlertController = sut.presentViewControllerTarget as? UIAlertController {
            let alertController = self.setupAlert(
                message: presentedAlertController.message ?? "")
            self.layoutFor(alertController, in: sut.view)
            assertSnapshot(matching: sut, as: .windowedImage)
        }
    }
}

// MARK: - setup methods
extension PlayerHandlingErrorAlerts {

    func setupAlert(message: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: AppStrings.ErrorAlert.title,
            message: message,
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: AppStrings.ActionCommands.okay, style: .default)
        alertController.addAction(okAction)
        return alertController
    }

    func layoutFor(_ alert: UIAlertController, in view: UIView) {
        view.addSubview(alert.view)
        alert.view.translatesAutoresizingMaskIntoConstraints = false
        alert.view.centerXAnchor.constraint(
            equalTo: view.centerXAnchor).isActive = true
        alert.view.centerYAnchor.constraint(
            equalTo: view.centerYAnchor).isActive = true
    }

}

// MARK: - extension in order to allow snapshots at window level because "alerts dont`t render in the view controller that presents them."
//source: https://www.pointfree.co/episodes/ep86-swiftui-snapshot-testing#t657
extension Snapshotting where Value: UIViewController, Format == UIImage {
  static var windowedImage: Snapshotting {
    return Snapshotting<UIImage, UIImage>.image.asyncPullback { viewController in
      Async<UIImage> { callback in
        UIView.setAnimationsEnabled(false)
        let window = UIApplication.shared.windows.first!
        window.rootViewController = viewController
        DispatchQueue.main.async {
          let image = UIGraphicsImageRenderer(bounds: window.bounds).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
          }
          callback(image)
          UIView.setAnimationsEnabled(true)
        }
      }
    }
  }
}
