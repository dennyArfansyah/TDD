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
    
    var errorMesasge = ""
    
    init(service: CharacterService) {
        self.service = service
    }
    
    func load(id: Int) async {
        do {
            _ = try await service.load(id: id)
        } catch {
            errorMesasge = "Opps, pelase try again later"
        }
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
    
    func test_load_showsError() async {
        let service = CharaterServiceStub(result: .failure(RemoteCharacterService.Error.serverError))
        let sut = CharacterViewModel(service: service)
        
        await sut.load(id: 1)
        
        XCTAssertEqual(sut.errorMesasge, "Opps, pelase try again later")
    }
    
    private final class ServiceSpy: CharacterService {
        private(set) var loadUserCallCount = 0
        
        func load(id: Int) async throws -> TDD.Character {
            loadUserCallCount += 1
            return Character(id: 0, name: "", status: "", species: "", gender: "")
        }
    }
    
    class CharaterServiceStub: CharacterService {
        let result: Result<Character, Error>
        
        init(result: Result<Character, any Error>) {
            self.result = result
        }
        
        func load(id: Int) async throws -> TDD.Character {
            switch result {
            case .success(let character):
                return character
            case .failure(let error):
                throw error
            }
        }
    }
}
