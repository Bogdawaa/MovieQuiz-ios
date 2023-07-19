//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.07.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionAmount: Int = 10
    
    var currentQuestion: QuizQuestion?
    weak var movieQuizViewController: MovieQuizViewController?

    private var currentQuestionIndex = 0
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func encreaseQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    //MARK: - Actions
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        movieQuizViewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        movieQuizViewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}
