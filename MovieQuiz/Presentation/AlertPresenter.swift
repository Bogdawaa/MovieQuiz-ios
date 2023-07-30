//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 14.06.2023.
//

import Foundation
import UIKit

class AlertPresenter {
    
    private var viewController: UIViewController?
    private var statisticService: StatisticService?
        
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // отображение алерта
    func show(in presenter: UIViewController, alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        alert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: {
            print("Алерт отобразился")
        })
    }
}
