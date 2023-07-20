//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.07.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService!
    private var currentQuestionIndex = 0
    private let questionAmount: Int = 10
    private var correctAnswers = 0
    
    private weak var movieQuizViewController: MovieQuizViewControllerProtocol?
    
    init(movieQuizViewController: MovieQuizViewControllerProtocol) {
        self.movieQuizViewController = movieQuizViewController
        
        statisticService = StatisticServiceImplementation()

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        movieQuizViewController.showLoadingAnimation(isTrue: true)
    }
    
    // MARK: - QuestionFactory Delegate
    
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
        movieQuizViewController?.showLoadingAnimation(isTrue: false)
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        movieQuizViewController?.showNetworkError(message: message)
    }
    
    // MARK: - funcs
    func makeResultMessage() -> String {
        let bestGame = statisticService.store(correct: correctAnswers, total: questionAmount)
        
        let gamesCount = statisticService.gamesCount
        let totalAccuracy = statisticService.totalAccuracy
        
        let text =
            """
            Вы ответили на: \(correctAnswers) из \(questionAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)(\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", totalAccuracy))%
            """
        return text
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        
        didAnswer(isCorrectAnswer: isCorrect)
        
        movieQuizViewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            self.proceedToNextQuestionOrResults()
        }
        movieQuizViewController?.blockAnswerButtons(blockButtons: false)
    }
    
    func proceedToNextQuestionOrResults() {
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
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes

        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}
