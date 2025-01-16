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
// 4. failure -> timout

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
    
    func load() throws {
        throw NSError()
    }
}

final class TDDTests: XCTestCase {
    func test_load_returnTimeoutErrorOnNetworkError() {
        let customEndpointClosure = { (target: CharacterTargetType) -> Endpoint in
            return Endpoint(url: URL(target: target).absoluteString,
                            sampleResponseClosure: { .networkError(NSError()) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }

        let stubbingProvider = MoyaProvider<CharacterTargetType>(endpointClosure: customEndpointClosure, stubClosure: MoyaProvider.immediatelyStub)
        let sut = RemoteCharacterSerice(stubbingProvider: stubbingProvider)
        
        XCTAssertThrowsError(try sut.load())
    }

}
