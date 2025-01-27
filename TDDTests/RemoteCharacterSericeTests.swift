//
//  RemoteCharacterSerice.swift
//  TDDTests
//
//  Created by Denny Arfansyah on 15/01/25.
//

import Moya
import XCTest

// TEST CASES
// 1. success -> fetch character ✅
// 2. success -> not found ✅
// 3. success -> different format JSON ✅
// 3. success -> server error ✅
// 3. success -> empty JSON ✅
// 4. failure -> timout ✅

enum CharacterTargetType: TargetType {
    case fetchCharacter(id: Int)
    
    var baseURL: URL { URL(string: "https://rickandmortyapi.com/api/")! }
    var path: String {
        switch self {
        case let .fetchCharacter(id):
            return "/character/\(id)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .fetchCharacter:
            return .get
        }
    }
    var task: Moya.Task { .requestPlain }
    var headers: [String : String]? { nil }
}

class RemoteCharacterSerice {
    private let stubbingProvider: MoyaProvider<CharacterTargetType>
    
    init(stubbingProvider: MoyaProvider<CharacterTargetType>) {
        self.stubbingProvider = stubbingProvider
    }
    
    enum Error: Swift.Error {
        case timeoutError
        case invalidJSONError
        case serverError
        case notFoundCharacterError
    }
    
    func load(id: Int) async throws -> Character {
        return try await withCheckedThrowingContinuation { continuation in
            stubbingProvider.request(.fetchCharacter(id: id)) { result in
                switch result {
                case .success(let response):
                    if response.statusCode == 201 {
                        continuation.resume(with: .failure(Error.notFoundCharacterError))
                    } else if response.statusCode == 500 {
                        continuation.resume(with: .failure(Error.serverError))
                    } else {
                        do {
                            let character = try JSONDecoder().decode(Character.self, from: response.data)
                            continuation.resume(with: .success(character))
                        } catch {
                            continuation.resume(with: .failure(Error.invalidJSONError))
                        }
                    }
                case .failure:
                    continuation.resume(throwing: Error.timeoutError)
                }
            }
        }
    }
}

struct Character: Decodable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let gender: String
}

final class TDDTests: XCTestCase {
    func test_load_returnTimeoutErrorOnNetworkError() async {
        let sut = makeSUT(sampleResponseClosure: { .networkError(NSError()) })
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .timeoutError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_whenEmptyData_returnInvalidJSONError() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(200, "".data(using: .utf8)!) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .invalidJSONError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_returnServerErrorOn500HTPPResponse() async {
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(500, "".data(using: .utf8)!) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
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
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .invalidJSONError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_whenValidFormatData_return200HTTPResponse() async {
        let validJSONFormatData = """
        {
            "id": 1,
            "name": "Rick Sanchez",
            "status": "Alive",
            "species": "Human",
            "gender": "Male",
        }
        """.data(using: .utf8)!
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(200, validJSONFormatData) })
        
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
        let notFoundCharacterJSONData = """
        {
            "error": "Character not found"
        }
        """.data(using: .utf8)!
        let sut = makeSUT(sampleResponseClosure: { .networkResponse(201, notFoundCharacterJSONData) })
        
        do {
            _ = try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .notFoundCharacterError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    // MARK: Helper
    private func makeSUT(sampleResponseClosure: @escaping Endpoint.SampleResponseClosure) -> RemoteCharacterSerice {
        let customEndpointClosure = { (target: CharacterTargetType) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: sampleResponseClosure,
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let stubbingProvider = MoyaProvider<CharacterTargetType>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let service = RemoteCharacterSerice(stubbingProvider: stubbingProvider)
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
}
