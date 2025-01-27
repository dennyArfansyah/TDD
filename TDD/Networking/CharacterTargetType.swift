//
//  CharacterTargetType.swift
//  TDD
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Foundation
import Moya

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
