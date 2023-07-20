//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.07.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionAmount: Int = 10
    var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private weak var movieQuizViewController: MovieQuizViewController?
    
    init(movieQuizViewController: MovieQuizViewController) {
        self.movieQuizViewController = movieQuizViewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        movieQuizViewController.showLoadingAnimation()
    }
    
    // MARK: - funcs
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionAmount - 1
    }
    
    func encreaseQuestionIndex() {
        currentQuestionIndex += 1
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
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
    
    func didLoadFromServer() {
        // hide indicator
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        movieQuizViewController?.showNetworkError(message: message)
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
