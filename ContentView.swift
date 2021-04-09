//
//  ContentView.swift
//  WordScramble
//
//  Created by om on 07/04/21.
//

import SwiftUI
struct ContentView: View
{
    
    @State private var usedWords=[String]()
    @State private var rootWord=""
    @State private var newWord=""
    @State private var showingError=false
    @State private var errorTitle=""
    @State private var errorMessage=""
    @State private var score=0
    func addNewWord()
    {
        let answer = newWord.lowercased().trimmingCharacters(in:.whitespacesAndNewlines)
        guard answer.count>1 else{return}
        guard isOriginal(word:answer) else
        {
            wordError(title:"Word used originally", message:"Be more original")
            score=score-1
            return
        }
        guard isPossible(word:answer) else
        {
            wordError(title:"word not recognized", message:"You cant just make them up")
            score=score-2
            return
        }
        guard isReal(word: answer) else
        {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            score=score-3
            return
        }
        usedWords.insert(answer,at:0)
        score=score+answer.count
        newWord = ""
    }
    func isOriginal(word:String)->Bool
    {
        usedWords.contains(word) ? false : true
    }
    func isPossible(word:String)->Bool
    {
        var temp = rootWord
        for x in word
        {
            if let pos = temp.firstIndex(of:x)
            {
                temp.remove(at:pos)
            }
            else
            {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool
    {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String)
    {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    func startGame()
    {
        if let gameContentUrl = Bundle.main.url(forResource:"start", withExtension:".txt")
        {
            if let gameContentString = try? String(contentsOf:gameContentUrl)
            {
                let wordArray = gameContentString.components(separatedBy:"\n")
                rootWord=wordArray.randomElement() ?? "silkworm"
                if score > 0
                {
                    score=score-5
                }
                return
            }
        }
        
        fatalError("Could not load start.txt from bundle.")
    }
    func newGame()
    {
        startGame()
        score=0
    }
    var body: some View
    {
        NavigationView
        {
            VStack
            {
                TextField("Enter your word",text:$newWord,onCommit:addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                Text("Your score is \(score)")
                List(usedWords, id: \.self)
                {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .navigationBarItems(leading:Button(action:newGame)
            {
                Text("New Game")
            }
            ,trailing:Button(action:startGame)
            {
                Text("New Word")
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
