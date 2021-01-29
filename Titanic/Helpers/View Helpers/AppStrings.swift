/*
 MIT License

Copyright (c) 2020 Maik Müller (maikdrop) <maik_mueller@me.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation

enum AppStrings {

    enum ActionCommand {
        static let done = NSLocalizedString("Action_Done", comment: "")
        static let cancel = NSLocalizedString("Action_Cancel", comment: "")
        static let okay = NSLocalizedString("Action_Ok", comment: "")
        static let delete = NSLocalizedString("Action_Delete", comment: "")
        static let edit = NSLocalizedString("Action_Edit", comment: "")
    }

    enum AppInformation {
        static let appInfoTitle = NSLocalizedString("AppInfoTitle_Txt", comment: "")
        static let aboutTheAppLblTxt = NSLocalizedString("AboutTheAppLbl_Txt", comment: "")
        static let conceptLblTxt = NSLocalizedString("ConceptLbl_Txt", comment: "")
        static let rulesLblTxt = NSLocalizedString("RulesLbl_Txt", comment: "")
        static let legalLblTxt = NSLocalizedString("LegalLbl_Txt", comment: "")
    }

    enum Concept {
        static let designPatternTitle = NSLocalizedString("Concept_DesignPatternTitle", comment: "")
        static let avoidMassiveVCTitle = NSLocalizedString("Concept_AvoidMassiveVCTitle", comment: "")
        static let layoutTitle = NSLocalizedString("Concept_LayoutTitle", comment: "")
    }

    enum DeletionAction {
        static let title = NSLocalizedString("DeletionConfirmation_Title", comment: "")
        static let messageSingle = NSLocalizedString("SingleDeletionConfirmation_Message", comment: "")
        static let messageMultiple = NSLocalizedString("MultipleDeletionConfirmation_Message", comment: "")
        static let number = NSLocalizedString("Number", comment: "")
    }

    enum ErrorAlert {
        static let title = NSLocalizedString("ErrorAlert_Title", comment: "")
        static let fileReadingErrorMessage = NSLocalizedString("File_Reading_Error", comment: "")
        static let jsonDecodingErrorMessage = NSLocalizedString("JSON_Decoding_Error", comment: "")
        static let fileWritingErrorMessage = NSLocalizedString("File_Writing_Error", comment: "")
        static let jsonEncodingErrorMessage = NSLocalizedString("JSON_Encoding_Error", comment: "")
        static let databaseReadingErrorMessage = NSLocalizedString("Database_Reading_Error", comment: "")
        static let databaseWritingErrorMessage = NSLocalizedString("Database_Writing_Error", comment: "")
        static let databaseDeletingErrorMessage = NSLocalizedString("Database_Deleting_Error", comment: "")
    }

    enum FileNames {
        static let aboutFileName = "AboutTheApp"
        static let legalNotices = "LegalNotices"
        static let designPatternFileName = "MVP"
        static let avoidMassiveVCFileName = "AvoidMassiveGameVC"
        static let adaptingLayoutFileName = "AdaptingLayout"
        static let animationFileName = "Animation"
        static let txtExt = "txt"
    }

    enum HowToPlay {
        static let hideNxtTimeLblTxt = NSLocalizedString("FirstUseInstructions_Hide", comment: "")
        static let buttonSectionTitle = "Buttons"
        static let storedGamesBtn = NSLocalizedString("FirstUseInstructions_Stored_Games_Btn", comment: "")
        static let speedOptionBtn = NSLocalizedString("FirstUseInstructions_Speed_Options_Btn", comment: "")
        static let ctrlGameBtn = NSLocalizedString("FirstUseInstructions_Ctrl_Game_Btn", comment: "")
        static let rulesSectionTitle = NSLocalizedString("FirstUseInstructions_Rules_Section", comment: "")
        static let rulesSectionFooter = NSLocalizedString("FirstUseInstructions_Rules_Footer", comment: "")
        static let title = NSLocalizedString("FirstUseInstructions_Title", comment: "")
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

    enum GameControl {
        static let title = NSLocalizedString("GameControl_Title", comment: "")
        static let savedSuccessfully = NSLocalizedString("GameControl_Saved", comment: "")
    }

    enum GameState {
        static let new = NSLocalizedString("New", comment: "")
        static let pause = NSLocalizedString("Pause", comment: "")
        static let resume = NSLocalizedString("Resume", comment: "")
        static let save = NSLocalizedString("Save", comment: "")
    }

    enum Highscore {
        static let fileName = NSLocalizedString("File_Name", comment: "")
        static let listTitle = "Top 10"
        static let storyboardName = "HighscoreList"
    }

    enum ImageNames {
        static let circle = "circle.fill"
        static let iceberg = "iceberg"
        static let ship = "ship"
        static let slow = "tortoise.fill"
        static let medium = "figure.walk"
        static let fast = "hare.fill"
        static let launch = "LaunchImage"
        static let storedGames = "list.bullet"
        static let speedometer = "speedometer"
        static let gameController = "gamecontroller"
    }

    enum NewHighscoreEntryAlert {
        static let title = NSLocalizedString("NewHighscoreEntryAlert_Title", comment: "")
        static let message = NSLocalizedString("NewHighscoreEntry_Message", comment: "")
        static let textFieldPlaceholder = NSLocalizedString("TextField_Placeholder", comment: "")
    }

    enum Rules {
        static let subheadlineTitle = NSLocalizedString("Rules_SubheadlineTitle", comment: "")
        static let goalSectionTitle = NSLocalizedString("Rules_GoalSectionTitle", comment: "")
        static let goalSectionContent = NSLocalizedString("Rules_GoalSectionContent", comment: "")
        static let usageSectionTitle = NSLocalizedString("Rules_UsageSectionTitle", comment: "")
        static let firstRule = NSLocalizedString("Rules_UsageSectionContent_Rule1", comment: "")
        static let secondRule = NSLocalizedString("Rules_UsageSectionContent_Rule2", comment: "")
        static let thirdRule = NSLocalizedString("Rules_UsageSectionContent_Rule3", comment: "")
        static let fourthRule = NSLocalizedString("Rules_UsageSectionContent_Rule4", comment: "")
        static let fifthRule = NSLocalizedString("Rules_UsageSectionContent_Rule5", comment: "")
    }

    enum SpeedOption {
        static let slow = NSLocalizedString("SpeedOption_Slow", comment: "")
        static let medium = NSLocalizedString("SpeedOption_Medium", comment: "")
        static let fast = NSLocalizedString("SpeedOption_Fast", comment: "")
    }

    enum Storage {
        static let title = NSLocalizedString("Storage_Title", comment: "")
    }

    enum Storyboard {
        static let concept = "Concept"
        static let conceptVcIdentifier = "ConceptViewController"
        static let gameRules = "GameRules"
        static let gameRulesVcIdentifier = "GameRulesViewController"
    }

    enum UserDefaultKeys {
        static let rules = "rules"
        static let speed = "speed"
    }

    enum UserInfoKey {
        static let iceberg = "iceberg"
        static let ship = "ship"
    }

    enum Welcome {
        static let title = NSLocalizedString("Welcome_Title", comment: "")
        static let appInfoBtnTitle =  "App Information"
        static let rightBarBtnTitle = NSLocalizedString("Welcome_RightBarBtnTitle", comment: "")
    }
}
