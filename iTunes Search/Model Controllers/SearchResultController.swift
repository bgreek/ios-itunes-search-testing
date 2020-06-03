//
//  SearchResultController.swift
//  iTunes Search
//
//  Created by Spencer Curtis on 8/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

protocol NetworkSessionProtocol {
    func fetch(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: NetworkSessionProtocol {
    func fetch(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        let dataTask = self.dataTask(with: request, completionHandler: completionHandler)
        
        dataTask.resume()
    }
}

class MockURLSession: NetworkSessionProtocol {
    
    let data: Data?
    let error: Error?
    init(data: Data?, error: Error?) {
        self.data = data
        self.error = error
    }
    
    func fetch(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        DispatchQueue.global().async {
            completionHandler(self.data, nil, self.error)
        }
    }
}

class SearchResultController {
    
    enum PerformSearchError: Error {
        case requestURLisNil
        case network(Error)
        case invalidStatNoErrorButNoData
        case invalidJSON(Error)
    }
    
    // Properties
    let baseURL = URL(string: "https://itunes.apple.com/search")!
    
    // Preparing the parameters for our URL request
    func performSearch(for searchTerm: String, resultType: ResultType,
                       urlSession: NetworkSessionProtocol, completion: @escaping (Result<[SearchResult], PerformSearchError>) -> Void) {
        
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        let parameters = ["term": searchTerm,
                          "entity": resultType.rawValue]
        
        // Compact Map -> Transforms the individual elements of a collections into some other element type while ignoring any optionals that return a nil value
        // (key, value) -> (URLQueryItem)
        let queryItems = parameters.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents?.queryItems = queryItems
        
        // Prevent excecution if requestURL is nil.
        guard let requestURL = urlComponents?.url else {
            completion(.failure(.requestURLisNil))
            return
        }
        
        // requestURL is not nil, continued after guard.
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        
        urlSession.fetch(with: request) { (possibleData, _, possibleError) in
        
            
            // What queue are we in?
            // We are in a background queue, we dont know which queue but not main.
            // There are no networking errors.
            guard possibleError == nil else {
                // We are done.
                completion(.failure(.network(possibleError!)))
                return
            }
            
            // We did recieve data from the API. Completions means we are done.
            guard let data = possibleData else {
                completion(.failure(.invalidStatNoErrorButNoData))
                return
            }
            
            do {
                // Decode the data ewe recieved into JSON.
                let jsonDecoder = JSONDecoder()
                let searchResults = try jsonDecoder.decode(SearchResults.self, from: data)
                completion(.success(searchResults.results))
            } catch {
                completion(.failure(.invalidJSON(error)))
            }
        }
    }
}
