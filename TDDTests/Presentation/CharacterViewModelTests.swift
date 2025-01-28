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
    var character: Character?
    
    init(service: CharacterService) {
        self.service = service
    }
    
    func load(id: Int) async {
        do {
            character = try await service.load(id: id)
        } catch {
            errorMesasge = "Opps, an error occur. Please try again later"
        }
    }
}

final class CharacterViewModelTests: XCTestCase {
    func test_init_doesNotLoadUser() {
        let (_, service) = makeSUT()
        XCTAssertEqual(service.loadUserCallCount, 0)
    }
    
    func test_load_doesLoadUser() async {
        let (sut, service) = makeSUT()
        await sut.load(id: 1)
        
        XCTAssertEqual(service.loadUserCallCount, 1)
    }
    
    func test_load_showsError() async {
        let errors = Error.allCases
        for (index, error) in errors.enumerated() {
            let sut = makeSUT(result: .failure(error))
            await sut.load(id: 1)
            
            XCTAssertEqual(sut.errorMesasge, "Opps, an error occur. Please try again later", "Fail at: \(index) with error \(error)")
        }
    }
    
    func test_load_showsCharacter() async {
        let expectedCharacter = sampleCharacter()
        let sut = makeSUT(result: .success(sampleCharacter()))
        await sut.load(id: 1)
        XCTAssertEqual(sut.character, expectedCharacter)
    }
    
    func sampleCharacter() -> Character {
        return Character(id: 1, name: "'", status: "", species: "", gender: "")
    }
    
    // MARK: Helper
    private func makeSUT() -> (sut: CharacterViewModel, service: ServiceSpy) {
        let service = ServiceSpy()
        let sut = CharacterViewModel(service: service)
        
        return (sut, service)
    }
    
    func makeSUT(result: Result<Character, Error>) -> CharacterViewModel {
        let service = CharaterServiceStub(result: result)
        let sut = CharacterViewModel(service: service)
        return sut
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
        
        init(result: Result<Character, Error>) {
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
