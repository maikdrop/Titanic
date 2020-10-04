/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

enum AppStrings {

    enum CommonAlertAction {
        static let done = NSLocalizedString("AlertAction_Done", comment: "")
        static let cancel = NSLocalizedString("AlertAction_Cancel", comment: "")
        static let okay = NSLocalizedString("AlertAction_Ok", comment: "")
    }

    enum TitanicGameControlActionSheet {
        static let title = NSLocalizedString("TitanicGameControl_Title", comment: "")
    }

    enum ErrorAlert {
        static let title = NSLocalizedString("ErrorAlert_Title", comment: "")
        static let readingErrorMessage = NSLocalizedString("Reading_Error", comment: "")
        static let decodingErrorMessage = NSLocalizedString("Decoding_Error", comment: "")
        static let writingErrorMessage = NSLocalizedString("Writing_Error", comment: "")
        static let encodingErrorMessage = NSLocalizedString("Encoding_Error", comment: "")
    }

    enum NewHighscoreEntryAlert {
        static let title = NSLocalizedString("NewHighscoreEntryAlert_Title", comment: "")
        static let message = NSLocalizedString("NewHighscoreEntry_Message", comment: "")
        static let textFieldPlaceholder = NSLocalizedString("TextField_Placeholder", comment: "")
    }

    enum GameState {
        static let new = NSLocalizedString("New", comment: "")
        static let pause = NSLocalizedString("Pause", comment: "")
        static let resume = NSLocalizedString("Resume", comment: "")
    }

    enum UserInfoKey {
        static let iceberg = "iceberg"
        static let ship = "ship"
    }

    enum Welcome {
        static let headlineTitle = NSLocalizedString("Welcome_HeadLineTitle", comment: "")
        static let leftBarBtnTitle =  NSLocalizedString("Welcome_LeftBarBtnTitle", comment: "")
        static let rightBarBtnTitle = NSLocalizedString("Welcome_RightBarBtnTitle", comment: "")
    }

    enum Rules {
        static let subheadlineTitle = NSLocalizedString("Rules_SubheadlineTitle", comment: "")
        static let goalSectionTitle = NSLocalizedString("Rules_GoalSectionTitle", comment: "")
        static let goalSectionContent = NSLocalizedString("Rules_GoalSectionContent", comment: "")
        static let usageSectionTitle = NSLocalizedString("Rules_UsageSectionTitle", comment: "")
        static let usageSectionContent = NSLocalizedString("Rules_UsageSectionContent", comment: "")
    }

    enum Game {
        static let goLblTxt = NSLocalizedString("GoLbl_Txt", comment: "")
        static let knotsLblTxt = NSLocalizedString("KnotsLbl_Txt", comment: "")
        static let drivenSeaMilesLblTxt = NSLocalizedString("MilesLbl_Txt", comment: "")
        static let crashesLblTxt = NSLocalizedString("CrashesLbl_Txt", comment: "")
        static let gameOverLblTxt = NSLocalizedString("GameOverLbl_Txt", comment: "")
        static let gameEndLblTxt = NSLocalizedString("GameEndLbl_Txt", comment: "")
        static let youWinLblTxt = NSLocalizedString("YouWinLbl_Txt", comment: "")
    }

    enum AppInformation {
        static let aboutTheAppLblTxt = NSLocalizedString("AboutTheAppLbl_Txt", comment: "")
        static let conceptLblTxt = NSLocalizedString("ConceptLbl_Txt", comment: "")
        static let legalLblTxt = NSLocalizedString("LegalLbl_Txt", comment: "")
    }

    enum Concept {
        static let designPatternTitle = NSLocalizedString("Concept_DesignPatternTitle", comment: "")
        static let avoidMassiveVCTitle = NSLocalizedString("Concept_AvoidMassiveVCTitle", comment: "")
        static let layoutTitle = NSLocalizedString("Concept_LayoutTitle", comment: "")
    }
}
