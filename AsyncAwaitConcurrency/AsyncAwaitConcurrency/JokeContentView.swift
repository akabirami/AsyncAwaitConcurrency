//
//  JokeContentView.swift
//  AsyncAwaitConcurrency
//
//  Created by Abirami Kalyan on 14/03/2023.
//

import SwiftUI

struct JokeContentView: View {
    @StateObject private var jokeService = JokeService()
    var body: some View {
        VStack {
            Text(jokeService.joke)
                .multilineTextAlignment(.leading)
                .padding()
            Spacer()
            Button("Fetch Joke") {
                Task {
                    do {
                        try await jokeService.fetchJoke()
                    } catch {
                        
                    }
                }
            }
            .padding()
            .opacity(jokeService.isFetching ? 0 : 1)
            .overlay {
              if jokeService.isFetching { ProgressView() }
            }
        }
    }
}


struct RefreshableJokeContentView: View {
    
    @StateObject var jokeService = JokeService()
    var body: some View {
        List {
            VStack {
                Spacer()
                Text(jokeService.joke)
                    .multilineTextAlignment(.center)
                Spacer()
            }
        }.task {
            do {
                try await jokeService.fetchJoke()
            } catch {
                
            }
        }.refreshable {
            do {
                try await jokeService.fetchJoke()
            } catch {
                
            }
        }
    }
}

struct JokeContentView_Previews: PreviewProvider {
    static var previews: some View {
        RefreshableJokeContentView()
    }
}
