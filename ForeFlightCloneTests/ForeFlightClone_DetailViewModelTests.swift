//
//  ForeFlightClone_DetailViewModelTests.swift
//  ForeFlightCloneTests
//
//  Created by Logan Blevins on 10/2/21.
//

import XCTest
@testable import ForeFlightClone

class ForeFlightClone_DetailViewModelTests: XCTestCase {

    private var sut: DetailViewModel!
    
    private let reportResource = "sample"
    private let conditionsResource = "conditions"
    private let forecastResource = "forecast"
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sut = DetailViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    // MARK: Happy path
    
    func testConditions() {
        // Test the existing business logic
        let reportTxt = text(forResource: reportResource)
        let conditions = sut.conditions(for: reportTxt)!
        let sutObj = obj(forText: conditions)
        
        let expectedObj = obj(forResource: conditionsResource)
        
        // Convert parsed, visible, text back to a dictionary and compare against
        // the expected json, also converted back to a dictionary.
        //
        // Since dictionaries are unordered, this makes the comparison apples-to-apples.
        XCTAssert((sutObj as NSDictionary).isEqual(to: expectedObj))
    }
    
    func testForecast() {
        let reportTxt = text(forResource: reportResource)
        let forecast = sut.forecast(for: reportTxt)!
        let sutObj = obj(forText: forecast)
        
        let expectedObj = obj(forResource: forecastResource)
        
        XCTAssert((sutObj as NSDictionary).isEqual(to: expectedObj))
    }
    
    // MARK: Failures
    
    func testConditionsMismatched() {
        let reportTxt = text(forResource: reportResource)
        let conditions = sut.conditions(for: reportTxt)!
        let sutObj = obj(forText: conditions)
        
        // Intentionally grab forecast instead of conditions
        let expectedObj = obj(forResource: forecastResource)
        
        XCTAssert((sutObj as NSDictionary).isEqual(to: expectedObj) == false)
    }
    
    func testForecastMismatched() {
        let reportTxt = text(forResource: reportResource)
        let forecast = sut.forecast(for: reportTxt)!
        let sutObj = obj(forText: forecast)
        
        let expectedObj = obj(forResource: conditionsResource)
        
        XCTAssert((sutObj as NSDictionary).isEqual(to: expectedObj) == false)
    }
    
    func testConditionsBadData() {
        let reportTxt = "bad data!"
        let conditions = sut.conditions(for: reportTxt)

        XCTAssert(conditions == nil)
    }
    
    func testConditionsNoData() {
        let reportTxt = ""
        let conditions = sut.conditions(for: reportTxt)
                
        XCTAssert(conditions == nil)
    }
    
    func testForecastBadData() {
        let forecastTxt = "bad data!"
        let forecast = sut.forecast(for: forecastTxt)

        XCTAssert(forecast == nil)
    }
    
    func testForecastNoData() {
        let forecastTxt = ""
        let forecast = sut.forecast(for: forecastTxt)

        XCTAssert(forecast == nil)
    }
}
