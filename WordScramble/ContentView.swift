//
//  ContentView.swift
//  WordScramble
//
//  Created by Fazliddin Abdazimov on 28/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter you word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        Text(word)
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
}

#Preview {
    ContentView()
}
