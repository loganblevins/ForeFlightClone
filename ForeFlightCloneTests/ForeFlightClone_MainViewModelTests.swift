//
//  ForeFlightClone_MainViewModelTests.swift
//  ForeFlightCloneTests
//
//  Created by Logan Blevins on 10/3/21.
//

import XCTest
@testable import ForeFlightClone

class ForeFlightClone_MainViewModelTests: XCTestCase {

    private var sut: MainViewModel!
    private var fake: FakeRequestor!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        fake = FakeRequestor()
        sut = MainViewModel(
            api: WeatherAPI(requestor: fake),
            model: Persistence(backing: .memory)
        )
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        fake = nil
    }

    func _testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        fake.result = .failure(.unknown("TODO"))
    }

    func _testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
