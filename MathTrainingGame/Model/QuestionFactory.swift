//
//  QuestionFactory.swift
//  MathTrainingGame
//
//  Created by Yanunsey on 21/12/22.
//

import Foundation

class QuestionFactory {
    
    private var questions = [Question]()
    public private(set) var score = 0
    
    public private(set) var pointsPerQuestion = 100
    
    
    init() {
            addNewQuestion()
    }
    
    func restartData(){
        self.score = 0
        self.questions.removeAll()
        addNewQuestion()
    }
    
    func addNewQuestion() {
        let question = createQuestion()
        questions.insert(question, at: 0)
    }
    
    func getQuestionAt(position: Int) -> Question? {
        
        if position < 0 || position >= questions.count  {
            return nil
        }
        return self.questions[position]
    }
    
    func updateQuestion(at index: Int, with answer: Int) {
        questions[index].userAnswer = answer
    }
    
    func validateQuestion(at index: Int){
        if questions[index].userAnswer == questions[index].answer{
            self.score += pointsPerQuestion
        }
    }
    
    func numberOfQuestions() -> Int {
        return questions.count
    }
    
    func createQuestion() -> Question {
        var question = ""
        var correctAnswer = 0
        
        var questionIsNeeded = true
        while questionIsNeeded {
            let firstNumber = Int.random(in: 0...9)
            let secondNumber = Int.random(in: 0...9)
            
            if Bool.random(){
                
                let result = firstNumber + secondNumber
                
                if result < 10 {
                    question = "\(firstNumber) + \(secondNumber)"
                    correctAnswer = result
                    questionIsNeeded = false
                }
            } else {
               
                let result = firstNumber - secondNumber
                
                if result >= 0 {
                    question = "\(firstNumber) - \(secondNumber)"
                    correctAnswer = result
                    questionIsNeeded = false
                }
            }
        }
        return Question(text: question, answer: correctAnswer, userAnswer: nil)
    }
}
