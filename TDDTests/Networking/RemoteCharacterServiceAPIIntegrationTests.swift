//
//  RemoteCharacterServiceAPIIntegrationTests.swift
//  TDDTests
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Moya
import XCTest
@testable import TDD

final class RemoteCharacterServiceAPIIntegrationTests: XCTestCase {

    func test_load_returnRightCharacter() async {
        let stubbingProvider = MoyaProvider<CharacterTargetType>()
        let sut = RemoteCharacterService(stubbingProvider: stubbingProvider)
        
        do {
            let character = try await sut.load(id: 1)
            XCTAssertEqual(character.name, "Rick Sanchez")
            XCTAssertEqual(character.status, "Alive")
            XCTAssertEqual(character.gender, "Male")
        } catch {
            XCTFail("expacting to get real response got \(error) instead")
        }
    }
}
