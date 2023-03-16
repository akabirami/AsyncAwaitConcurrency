//
//  JokeService.swift
//  AsyncAwaitConcurrency
//
//  Created by Abirami Kalyan on 14/03/2023.
//

import Foundation

enum FetchJokeError: Error {
    case failed
}


actor JokeStore {
    func fetch(url: URL) async throws -> String {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchJokeError.failed
        }
        
        guard let decodedValue = try? JSONDecoder().decode(Joke.self, from: data) else {
            throw FetchJokeError.failed
        }
        
        return decodedValue.value
    }
}

class JokeService: ObservableObject {
    
    @Published var joke: String = "Joke appears here"
    @Published var isFetching: Bool = false
    
    private var jokeStore = JokeStore()
    
    private var url: URL {
      // swiftlint:disable:next force_unwrapping
      urlComponents.url!
    }
    
    private var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.chucknorris.io"
        components.path = "/jokes/random"
        components.setQueryItems(with: ["category": "dev"])
        return components
    }
    
    // This is one option to set the published values on main thread. One more option is to create a sibiling actor which runs on the background thread
    // and return the joke. In main thread, value can be assigned. See Below for example.
    func fetchJokeAlt() async throws {
        await MainActor.run {
            isFetching = true
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw FetchJokeError.failed
        }
        
        guard let decodedResponse = try? JSONDecoder().decode(Joke.self, from: data) else {
            throw FetchJokeError.failed
        }
        await MainActor.run {
            joke = decodedResponse.value
            isFetching = false
        }
      }

    
    // Adding MainActor for this function and delegating the data fetch to background thread in the actor.
    @MainActor
    func fetchJoke() async throws {
        isFetching = true
        defer {
            isFetching = false
        }
        joke = try await jokeStore.fetch(url: url)
    }
}

struct Joke: Codable {
    var value: String
}


public extension URLComponents {
  /// Maps a dictionary into `[URLQueryItem]` then assigns it to the
  /// `queryItems` property of this `URLComponents` instance.
  /// From [Alfian Losari's blog.](https://www.alfianlosari.com/posts/building-safe-url-in-swift-using-urlcomponents-and-urlqueryitem/)
  /// - Parameter parameters: Dictionary of query parameter names and values
  mutating func setQueryItems(with parameters: [String: String]) {
    self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
  }
}
