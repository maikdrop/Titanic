//
//  AppStrings.swift
//  Titanic
//
//  Created by Maik on 05.03.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

//

import Foundation

enum AppStrings {

    enum CommonAlertAction {
        static let done = NSLocalizedString("AlertAction_Done", comment: "")
        static let cancel = NSLocalizedString("AlertAction_Cancel", comment: "")
        static let okay = NSLocalizedString("AlertAction_Ok", comment: "")
    }

    enum GameControlActionSheet {
        static let title = NSLocalizedString("GameControl_Title", comment: "")
    }

    enum ErrorAlert {
        static let title = NSLocalizedString("ErrorAlert_Title", comment: "")
    }

    enum NewHighscoreEntryAlert {
        static let title = NSLocalizedString("NewHighscoreEntryAlert_Title", comment: "")
        static let message = NSLocalizedString("NewHighscoreEntry_Message", comment: "")
        static let textFieldPlaceholder = NSLocalizedString("TextField_Placeholder", comment: "")
    }

    enum GameStatus {
        static let new = NSLocalizedString("New", comment: "")
        static let pause = NSLocalizedString("Pause", comment: "")
        static let resume = NSLocalizedString("Resume", comment: "")
    }

    enum UserInfoKey {
        static let iceberg = "iceberg"
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
