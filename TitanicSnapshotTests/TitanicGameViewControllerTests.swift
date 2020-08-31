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

//SnapshotTesting only works on simulator and 2 test runs needed (for creating and verifing image)
class TitanicGameViewControllerTests: XCTestCase {

    func testGameView() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        if let welcome = storyboard.instantiateViewController(
            withIdentifier: "WelcomeViewController") as? WelcomeViewController {
            TitanicGameViewPresenter().presentGameView(in: welcome)
            if let gameVc = welcome.presentedViewController {
                 assertSnapshot(matching: gameVc, as: .image)
            }
        }
    }

}
