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
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Score: \(usedWords.count)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                List {
                    Section {
                        TextField("Enter you word", text: $newWord)
                            .textInputAutocapitalization(.never)
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).square.fill")
                                    .font(.title2)
                                Text(word)
                                    .font(.title2)
                                    .padding(.horizontal)
                            }
                            .accessibilityElement()
                            .accessibilityLabel(word)
                            .accessibilityHint("\(word.count) letters")
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .navigationBarTitleDisplayMode(.large)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {} message: {
                Text(errorMessage)
            }
            .toolbar {
                Button {
                    startGame()
                    newWord = ""
                    usedWords = []
                } label: {
                    Text("New Game")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(5)
                        .background(.black)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isNotShort(word: answer) else {
            wordError(title: "Word is too short", message: "Try to use word more than 3 letters long")
            return
        }
        
        guard isNotSimilarToRootWord(word: answer) else {
            wordError(title: "Word is similar to start word", message: "Do not use start word")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                let allWords = startWords.split(separator: "\n")
                rootWord = String(allWords.randomElement() ?? "")
                return
            }
        }
        fatalError( "Couldn't load start words!" )
    }
    
    func isNotShort(word: String) -> Bool {
        return word.count >= 3 ? true : false
    }
    
    func isNotSimilarToRootWord(word: String) -> Bool {
        return word != rootWord ? true : false
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
