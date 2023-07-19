//
//  MovieQuizTests.swift
//  MovieQuizTests
//
//  Created by Bogdan Fartdinov on 16.07.2023.
//

import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // given
        let arr = [1, 2, 2, 3, 5]
        
        // when
        let value = arr[safe: 2]
        
        // then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // given
        let arr = [1, 2, 2, 3, 5]
        
        // when
        let value = arr[safe: 20]
        
        // then
        XCTAssertNil(value)
    }
}
