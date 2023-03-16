//
//  ContentView.swift
//  AsyncAwaitConcurrency
//
//  Created by Abirami Kalyan on 13/03/2023.
//

import SwiftUI
import Foundation

struct AsyncImageContentView: View {
    var body: some View {
        VStack {
            
            AsyncImage(url: URL(string: "abi")) {
                imagePhase in
                
                if let image = imagePhase.image {
                    image
                        .resizable()
                } else if imagePhase.error != nil {
                    Image(systemName: "exclamationmark.triangle")
                } else {
                    ProgressView()
                }
            }.frame(width: 200, height: 200)
            
            Image(systemName: "swift")
                .frame(width: 150, height: 150)
                .background(Color.red)
            Text("Hello, world!")
            
            AsyncImage(url: URL(string: "https://picsum.photos/200/300")) {
                image in
                image
                    .resizable()
                
            } placeholder: {
               ProgressView()
            }.frame(width: 200, height: 200)
        }
        .padding()
    }
}

struct ListLoadView: View {
    @ObservedObject var model = ConcurrencyModel()
    var body: some View {
        VStack {
            if model.messages.count == 0 {
                Text("No messages")
            } else {
                List(model.messages) { message in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(message.from)
                        Text(message.text)
                    }
                }
                .listItemTint(.blue)
                .cornerRadius(25)
            }
        }
        .padding()
        .task{
            do {
                try await model.fetchMessages()
            } catch {
                print("Error")
            }
        }
    }
}

struct AsyncSequenceExample: View {
    @ObservedObject var model = ConcurrencyModel()
    var body: some View {
        VStack {
            if model.messages.count == 0 {
                Text("No messages")
            } else {
                List(model.messages) { message in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(message.from)
                        Text(message.text)
                    }
                }
                .listItemTint(.blue)
                .cornerRadius(25)
            }
        }
        .padding()
        .task{
            do {
                try await model.fetchMessages()
            } catch {
                print("Error")
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncSequenceExample()
    }
}
