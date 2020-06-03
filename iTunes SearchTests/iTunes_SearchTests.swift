//
//  iTunes_SearchTests.swift
//  iTunes SearchTests
//
//  Created by Breena Greek on 6/2/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import XCTest
@testable import iTunes_Search

class iTunes_SearchTests: XCTestCase {
    
    func testSuccessfulSearchResults() {
        let searchResultsController = SearchResultController()
        
        let expectation = self.expectation(description: "Waiting for iTunes API")
        
        
        let goodResultData = """
            {
              "resultCount": 2,
              "results": [
                    {
                      "trackName": "GarageBand",
                      "artistName": "Apple",
                    },
                    {
                      "trackName": "Garage Virtual Drumset Band",
                      "artistName": "Nexogen Private Limited",
                    }
                ]
            }
        """.data(using: .utf8)!
        
        let mockSession = MockURLSession(data: goodResultData, error: nil)
        
        searchResultsController.performSearch(for: "Candy Crush", resultType: .software, urlSession: mockSession) { (result) in
            switch result {
            case .success(let searchResultsArray):
                XCTAssert(searchResultsArray.count > 0)
                
            case .failure(let error):
                XCTFail("The iTunes API failed \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }
}
