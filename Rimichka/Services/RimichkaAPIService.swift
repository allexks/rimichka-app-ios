//
//  RimichkaAPIService.swift
//  Rimichka
//
//  Created by Alexander Ignatov on 23.07.20.
//  Copyright © 2020 Yalishanda. All rights reserved.
//

import Combine
import Foundation

class RimichkaAPIService {
    
    private lazy var decoder = JSONDecoder()
    
    func rhymesForWord(_ word: String) -> AnyPublisher<[FetchedRhyme], APIError> {
        guard let url = url(forWord: word) else {
            return Fail(error: .domainChanged).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: URLRequest(url: url))
            .mapError { _ -> APIError in .noConnection }
            .flatMap { [unowned self] pair -> AnyPublisher<[FetchedRhyme], APIError> in
                self.decode(pair.data)
            }.eraseToAnyPublisher()
    }
}

extension RimichkaAPIService {
    enum APIError: Error {
        case unknown
        case domainChanged
        case noConnection
        case serizalizationFailed
    }
}

private extension RimichkaAPIService {
    func url(forWord word: String) -> URL? {
        return URL(string: "https://rimichka.com/?json=1&word=\(word.URLescaped)")
    }
    
    func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, APIError> {
        return Just(data)
            .decode(type: T.self, decoder: decoder)
            .mapError { _ in .serizalizationFailed }
            .eraseToAnyPublisher()
    }
}
