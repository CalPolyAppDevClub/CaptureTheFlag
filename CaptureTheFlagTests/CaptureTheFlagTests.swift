//
//  CaptureTheFlagTests.swift
//  CaptureTheFlagTests
//
//  Created by Joe Durand on 2/15/18.
//  Copyright © 2018 Joe Durand. All rights reserved.
//

import XCTest
@testable import CaptureTheFlag

class CaptureTheFlagTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetPlayers() {
        class MockRequestResponse: AsyncRequestResponse {
            func sendMessage(command: String, payLoad: Any?, callback: ((Any?, ARRError?) -> ())?) {
                callback!(["error": "gameDoesNotExist"], nil)
            }
            
            func addListener(for: String, callback: @escaping (Any?) -> ()) -> ListenerKey {
                let flagDict: Dictionary<String, Any> = [
                    "teamId":4,
                    "flag":[
                        "id": "3",
                        "location": [
                            "latitude":"53748653453",
                            "longitude":"5346834756"
                        ]
                    ]
                    
                ]
                callback(flagDict)
                return ListenerKey(command: "", key: UUID())
            }
            
            func removeListener(listenerKey: ListenerKey) {
                
            }
        }
        let serverAccess = ServerAccess(requestResponse:MockRequestResponse())
        serverAccess.addFlagAddedListener(callback: {(flag, teamId) in
            print(flag)
            XCTAssert(flag.id == "3")
        })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
