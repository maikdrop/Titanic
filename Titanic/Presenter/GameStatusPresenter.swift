//
//  GameStatusPresenter.swift
//  Titanic
//
//  Created by Maik on 01.07.20.
//  Copyright © 2020 maikdrop. All rights reserved.
//

import Foundation
import UIKit

//source: https://www.swiftbysundell.com/articles/lightweight-presenters-in-swift/
struct GameStatusPresenter {
    
    let status: GamePresenter.GameStatus
    let handler: (Outcome) -> Void
    
    func present(in viewController: UIViewController) {
        let alert = UIAlertController(
            title: ACTION_TITLE,
            message: "",
            preferredStyle: .actionSheet)
        
        status.list.forEach({status in
            let style = status == .reset ? UIAlertAction.Style.destructive : UIAlertAction.Style.default
            
            alert.addAction(UIAlertAction(title: status.rawValue, style: style) {_ in
                self.handler(.newStatus(status))
            })
        })
        alert.addAction(UIAlertAction(title: ACTION_TITLE_CANCEL_ACTION, style: .cancel))
        viewController.present(alert, animated: true)
    }
    
    enum Outcome {
        case newStatus(GamePresenter.GameStatus)
        case rejected
    }
}
