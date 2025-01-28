//
//  CharacterViewModelTests.swift
//  TDDTests
//
//  Created by Denny Arfansyah on 28/01/25.
//

import XCTest
@testable import TDD

final class CharacterViewModel {
    let service: CharacterService
    
    init(service: CharacterService) {
        self.service = service
    }
    
    func load(id: Int) async {
        _ = try? await service.load(id: id)
    }
}

final class CharacterViewModelTests: XCTestCase {

    func test_init_doesNotLoadUser() {
        let service = ServiceSpy()
        let sut = CharacterViewModel(service: service)
        
        XCTAssertEqual(service.loadUserCallCount, 0)
    }
    
    func test_load_doesLoadUser() async {
        let service = ServiceSpy()
        let sut = CharacterViewModel(service: service)
        
        await sut.load(id: 1)
        
        XCTAssertEqual(service.loadUserCallCount, 1)
    }
    
    private final class ServiceSpy: CharacterService {
        private(set) var loadUserCallCount = 0
        
        func load(id: Int) async throws -> TDD.Character {
            loadUserCallCount += 1
            return Character(id: 0, name: "", status: "", species: "", gender: "")
        }
        
        
    }

}
