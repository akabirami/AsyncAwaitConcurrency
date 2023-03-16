//
//  ConcurrencyModel.swift
//  AsyncAwaitConcurrency
//
//  Created by Abirami Kalyan on 13/03/2023.
//

import Foundation

struct Message: Decodable, Identifiable {
    let id: Int
    let from: String
    let text: String
}

enum ConcurrencyModelError: Error {
    case messageFetchFailed
}

class ConcurrencyModel: ObservableObject {
    
    @Published var messages = [Message]()
    
    // Example using concurrent binding
    func fetchMessages() async throws  {
        print("This statement is before concurrent call")
        async let (data, response) = try await URLSession.shared.data(from: URL(string: "https://www.hackingwithswift.com/samples/messages.json")!)

        print("This statement should not wait fot the fetch")
        guard let httpResponse = try await response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ConcurrencyModelError.messageFetchFailed
        }
        print("This statement waits for the fetch")
        messages = try await JSONDecoder().decode([Message].self, from: data)
    }
}
