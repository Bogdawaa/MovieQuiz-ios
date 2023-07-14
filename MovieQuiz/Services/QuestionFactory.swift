//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 12.06.2023.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    private enum ImageError: Error {
        case codeError
    }
    
    private var moviesLoader: MoviesLoading
    private var movies: [MostPopularMovie] = []
    
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            
            
            let index = (0..<movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImage)
            } catch {
                print("Failed to load image")
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
            let rating = Float(movie.rating) ?? 0
            let generatedRating = generateMovieRating()
            let text = "Рейтинг этого фильма больше чем \(generatedRating)?"
            let correctAnswer = Int(rating) > generatedRating
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didRecieveNextQuestion(question: question)
            }
        }
    }
    
    func generateMovieRating() -> Int {
        return Int.random(in: 1...9)
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
