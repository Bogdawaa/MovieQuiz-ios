//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.07.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    
    let questionAmount: Int = 10
    
    var correctAnswers = 0
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var movieQuizViewController: MovieQuizViewController?
    
    private var currentQuestionIndex = 0
    
    // MARK: - funcs
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
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
       guard let question = question else {
           return
       }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.movieQuizViewController?.show(quiz: viewModel)
       }
    }
    
    // вызывает следующий вопрос или показывает результат квиза
    func showNextQuestionOrResults() {
        
        if self.isLastQuestion() {
            let text = "Вы ответили на \(correctAnswers) из \(questionAmount), попробуйте еще раз!"
            
            let resultsViewModel = QuizResultsViewModel(title: "Раунд окончен!",
                                                        text: text,
                                                        buttonText: "Сыграть еще раз")
            
            movieQuizViewController?.show(quiz: resultsViewModel)
        } else {
            self.encreaseQuestionIndex()
            questionFactory?.requestNextQuestion()
        }
        movieQuizViewController?.blockAnswerButtons(blockButtons: true)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes

        movieQuizViewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}
