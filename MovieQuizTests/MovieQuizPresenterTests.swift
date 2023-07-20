//
//  MovieQuizViewControllerTests.swift
//  MovieQuizTests
//
//  Created by Bogdan Fartdinov on 20.07.2023.
//

import Foundation
import XCTest
@testable import MovieQuiz


final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
        
    }
    
    func show(quiz result: QuizResultsViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingAnimation(isTrue: Bool) {
        
    }
    
    func showNetworkError(message: String) {
        
    }
    
    func blockAnswerButtons(blockButtons: Bool) {
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(movieQuizViewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
