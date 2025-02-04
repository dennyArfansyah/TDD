//
//  RemoteCharacterSerice.swift
//  RemoteCharacterServiceTests
//
//  Created by Denny Arfansyah on 15/01/25.
//

import Moya
import XCTest
@testable import TDD

// TEST CASES
// 1. success -> fetch character ✅
// 2. success -> not found ✅
// 3. success -> different format JSON ✅
// 3. success -> server error ✅
// 3. success -> empty JSON ✅
// 4. failure -> timout ✅

final class RemoteCharacterServiceTests: XCTestCase {
    func test_load_returnTimeoutErrorOnNetworkError() async {
        let sut = makeSUT(sampleResponseClosure: { .networkError(NSError()) })
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? Error {
                XCTAssertEqual(error, .timeoutError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_whenEmptyData_returnInvalidJSONError() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(200, self.emptyJSONData()) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? Error {
                XCTAssertEqual(error, .invalidJSONError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_returnServerErrorOn500HTPPResponse() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(500, self.emptyJSONData()) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? Error {
                XCTAssertEqual(error, .serverError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_whenDifferentFormatData_returnInvalidJSONError() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(200, self.invalidJSONFormatData()) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? Error {
                XCTAssertEqual(error, .invalidJSONError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_whenValidFormatData_return200HTTPResponse() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(200, self.validJSONFormatData()) })
        
        do {
            let character = try await sut.load(id: 1)
            XCTAssertEqual(character.name, "Rick Sanchez")
            XCTAssertEqual(character.status, "Alive")
            XCTAssertEqual(character.gender, "Male")
        } catch {
            XCTFail("expecting to decode but got \(error) instead.")
        }
    }
    
    func test_load_whenNotFoundError_return200HTTPResponse() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(201, self.notFoundCharacterJSONData()) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? Error {
                XCTAssertEqual(error, .notFoundCharacterError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    // MARK: Helper
    private func makeSUT(sampleResponseClosure: @escaping Endpoint.SampleResponseClosure) -> RemoteCharacterService {
        let customEndpointClosure = { (target: CharacterTargetType) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: sampleResponseClosure,
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let stubbingProvider = MoyaProvider<CharacterTargetType>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let service = RemoteCharacterService(stubbingProvider: stubbingProvider)
        return service
    }
    
    // MARK: Helper
    
    private func invalidJSONFormatData() -> Data {
        let invalidJSOnFormatData = """
        {
            id: 1,
            name: "Rick Sanchez",
            status: "Alive",
            species: "Human",
            gender: "Male"
        }
        """.data(using: .utf8)!
        
        return invalidJSOnFormatData
    }
    
    private func emptyJSONData() -> Data {
        return "".data(using: .utf8)!
    }
    
    private func validJSONFormatData() -> Data {
        let validJSONFormatData = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "gender": "Male",
        }
        """.data(using: .utf8)!
        return validJSONFormatData
    }
    
    private func notFoundCharacterJSONData() -> Data {
        let notFoundCharacterJSONData = """
        {
            "error": "Character not found"
        }
        """.data(using: .utf8)!
        
        return notFoundCharacterJSONData
    }
}
