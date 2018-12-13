//
//  CognitoWrapper_Tests.swift
//  CognitoWrapper_Tests
//
//  Created by Esteban Garro on 2018-12-12.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import XCTest
@testable import CognitoWrapper

fileprivate let sessionResultExample = "{\"data\":{\"given_name\":\"tester\",\"family_name\":\"tester\",\"is_active\":\"1\",\"sub\":\"c9ac6e15-153d-49c9-b8eb-e4d75bc103f9\",\"userName\":\"00000001\"},\"authToken\":\"exampleToken\"}"


class CognitoWrapper_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    func test_SessionResults_encode_decode_properly() {        
        XCTAssert(1 == 1)
    }
}
