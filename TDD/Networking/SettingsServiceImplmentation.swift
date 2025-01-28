//
//  SettingsService.swift
//  TDD
//
//  Created by Denny Arfansyah on 28/01/25.
//

import Foundation
import Moya

protocol SettingsService {
    func getMenus() async throws -> GeneralRespons
}

class SettingsServiceImplmentation: SettingsService {
    private let stubbingProvider: MoyaProvider<SettingsTargetType>
    
    init(stubbingProvider: MoyaProvider<SettingsTargetType>) {
        self.stubbingProvider = stubbingProvider
    }
    
    func getMenus() async throws -> GeneralRespons {
        return try await withCheckedThrowingContinuation { continuation in
            getMenus { result in
                continuation.resume(with: result)
            }
        }
    }
}

extension SettingsServiceImplmentation {
    private func getMenus(completion: @escaping (Result<GeneralRespons, Error>) -> Void) {
        stubbingProvider.request(.getSettings) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                completion(self.mapping(response))
            case .failure:
                completion(.failure(.timeoutError))
            }
        }
    }
                                 
     private func mapping(_ response: Response) -> Result<GeneralRespons, Error> {
         if response.statusCode == 201 {
             return .failure(Error.notFoundCharacterError)
         } else if response.statusCode == 500 {
             return .failure(Error.serverError)
         } else {
             do {
                 let decoder = JSONDecoder()
                 decoder.keyDecodingStrategy = .convertFromSnakeCase
                 let character = try decoder.decode(GeneralRespons.self, from: response.data)
                 return .success(character)
             } catch {
                 return .failure(Error.invalidJSONError)
             }
         }
     }
}
