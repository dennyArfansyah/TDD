//
//  RemoteCharacterService.swift
//  TDD
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Foundation
import Moya

protocol CharacterService {
    func load(id: Int) async throws -> Character
}

class RemoteCharacterService: CharacterService {
    private let stubbingProvider: MoyaProvider<CharacterTargetType>
    
    init(stubbingProvider: MoyaProvider<CharacterTargetType>) {
        self.stubbingProvider = stubbingProvider
    }
    
    enum Error: Swift.Error, CaseIterable {
        case timeoutError
        case invalidJSONError
        case serverError
        case notFoundCharacterError
    }
    
    func load(id: Int) async throws -> Character {
        return try await withCheckedThrowingContinuation { continuation in
            load(id: id) { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension RemoteCharacterService {
    private func load(id: Int, completion: @escaping (Result<Character, Error>) -> Void) {
        stubbingProvider.request(.fetchCharacter(id: id)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                completion(self.mapping(response))
            case .failure:
                completion(.failure(.timeoutError))
            }
        }
    }
    
    private func mapping(_ response: Response) -> Result<Character, Error> {
        if response.statusCode == 201 {
            return .failure(Error.notFoundCharacterError)
        } else if response.statusCode == 500 {
            return .failure(Error.serverError)
        } else {
            do {
                let character = try JSONDecoder().decode(Character.self, from: response.data)
                return .success(character)
            } catch {
                return .failure(Error.invalidJSONError)
            }
        }
    }
}
