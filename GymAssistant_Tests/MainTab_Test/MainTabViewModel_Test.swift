//
//  MainTabViewModel_Test.swift
//  GymAssistant_Tests
//
//  Created by Kerem RESNENLİ on 27.12.2024.
//

import XCTest
@testable import GymAssistant

final class MainTabViewModel_Test: XCTestCase {
    var sut: MainTabViewModel!
    
    override func setUp() {
        super.setUp()
        self.sut = MainTabViewModel()
    }
    
    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }
    
    func testChangeTab() {
        //Given
        XCTAssertEqual(sut.currentTab, .Home)
        
        //When
        sut.currentTab = .Search
        
        //Then
        XCTAssertEqual(sut.currentTab, .Search)
    }
}
