//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 14.06.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message:  String
    let buttonText: String
    var completion: () -> Void
}
