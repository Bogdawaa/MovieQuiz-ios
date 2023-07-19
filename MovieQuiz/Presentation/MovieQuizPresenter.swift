//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.07.2023.
//

import UIKit

final class MovieQuizPresenter {
    
    // общее кол-во вопросов
    let questionAmount: Int = 10
    // Индекс текущего вопроса
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
}
