//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 20.07.2023.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingAnimation(isTrue: Bool)
    
    func showNetworkError(message: String)
    
    func blockAnswerButtons(blockButtons: Bool)
}
