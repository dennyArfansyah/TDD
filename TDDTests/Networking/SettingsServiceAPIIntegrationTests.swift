//
//  SettingsServiceAPIIntegrationTests.swift
//  TDDTests
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Moya
import XCTest
@testable import TDD

class SettingsServiceAPIIntegrationTests: XCTestCase {
    func test_load_returnMenu() async {
        let stubbingProvider = MoyaProvider<SettingsTargetType>()
        let sut = SettingsServiceImplmentation(stubbingProvider: stubbingProvider)
        
        do {
            let menu = try await sut.getMenus()
            XCTAssertEqual(menu.sourceSystem, "OCTOMOBILE_ID")
            XCTAssertEqual(menu.responseKey, "SUCCESS")
        } catch {
            XCTFail("expacting to get real response got \(error) instead")
        }
    }
}
