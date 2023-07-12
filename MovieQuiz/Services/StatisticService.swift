//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Bogdan Fartdinov on 19.06.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    func store(correct count: Int, total amount: Int) -> GameRecord
}


final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    private let userDefaults = UserDefaults.standard
   
    
    // общая точность ответов
    var totalAccuracy: Double {
            Double(correct) /  Double(total) * 100
    }
    
    // сумма всех сыгранных игр
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    // общее кол-во отвеченных вопросов
    var total: Int {
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    // общее кол-во верных ответов за все время
    var correct: Int {
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Unable to save bestGame")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) -> GameRecord {
        gamesCount += 1
        total += amount
        correct += count
        
        let bestGameNew = GameRecord(correct: count, total: amount, date: Date())
        
        if bestGame <= bestGameNew {
            guard let data = try? JSONEncoder().encode(bestGameNew) else {
                print("Unable to save new record")
                return bestGame
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            return bestGameNew
        } else { return bestGame }
    }
}
