//
//  RemoteCharacterSerice.swift
//  TDDTests
//
//  Created by Denny Arfansyah on 15/01/25.
//

import Moya
import XCTest

// TEST CASES
// 1. success -> fetch character
// 2. success -> not found
// 3. success -> different format JSON
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
    }
    
    func load(id: Int) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            stubbingProvider.request(.fetchCharacter(id: id)) { result in
                switch result {
                case .success:
                    continuation.resume(with: .failure(Error.invalidJSONError))
                case .failure:
                    continuation.resume(throwing: Error.timeoutError)
                }
            }
        }
    }
}

final class TDDTests: XCTestCase {
    func test_load_returnTimeoutErrorOnNetworkError() async {
        let customEndpointClosure = { (target: CharacterTargetType) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(NSError()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }

        let stubbingProvider = MoyaProvider<CharacterTargetType>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let sut = RemoteCharacterSerice(stubbingProvider: stubbingProvider)
        
        do {
            try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .timeoutError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
    
    func test_load_returnInvalidJSONErrorOn200HTPPResponse() async {
        let customEndpointClosure = { (target: CharacterTargetType) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkResponse(200, "".data(using: .utf8)!) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        
        let stubbingProvider = MoyaProvider<CharacterTargetType>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let sut = RemoteCharacterSerice(stubbingProvider: stubbingProvider)
        
        do {
            try await sut.load(id: 1)
        } catch {
            if let error = error as? RemoteCharacterSerice.Error {
                XCTAssertEqual(error, .invalidJSONError)
            } else {
                XCTFail("expecting timoutError but got \(error) instead.")
            }
        }
    }
}
