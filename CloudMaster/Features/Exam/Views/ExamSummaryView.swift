import Foundation
import SwiftUI

struct ExamSummaryView: View {
    @State private var expandedQuestionIDs: Set<UUID> = []
    @State private var showDeleteConfirmation = false
    
    @ObservedObject var examDataStore = UserExamDataStore.shared
    let exam: UserExamData
    
    var body: some View {
        VStack {
            Text(exam.isPassed ? "Passed" : "Failed")
                .font(.largeTitle)
                .foregroundColor(exam.isPassed ? .correct : .wrong)
                .padding(.bottom)
            
            Text("\(exam.dateTime.formatted())")
                .font(.title3)
            
            Text("Correct Answers: \(correctAnswersCount) / \(exam.questions.count)")
                .font(.title2)
                .padding(.bottom)
            
            List {
                ForEach(exam.questions) { question in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(question.question)
                                .font(.headline)
                                .lineLimit(expandedQuestionIDs.contains(question.id) ? nil : 2)
                                .onTapGesture {
                                    if expandedQuestionIDs.contains(question.id) {
                                        expandedQuestionIDs.remove(question.id)
                                    } else {
                                        expandedQuestionIDs.insert(question.id)
                                    }
                                }
                            
                            Spacer()
                            
                            Image(systemName: expandedQuestionIDs.contains(question.id) ? "chevron.up" : "chevron.down")
                                .onTapGesture {
                                    if expandedQuestionIDs.contains(question.id) {
                                        expandedQuestionIDs.remove(question.id)
                                    } else {
                                        expandedQuestionIDs.insert(question.id)
                                    }
                                }
                        }
                        
                        if expandedQuestionIDs.contains(question.id) {
                            ForEach(question.choices) { choice in
                                HStack {
                                    Text(choice.text)
                                        .padding(10)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(borderColor(for: choice, in: question), lineWidth: 2)
                                                .background(backgroundColor(for: choice, in: question))
                                        )
                                        .padding(.leading)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                question.choices.filter { $0.isCorrect }.allSatisfy { question.selectedChoices.contains($0.id) } ? Color.correct : Color.wrong, lineWidth: 2
                            )
                    )
                    .listRowInsets(EdgeInsets())
                    .padding(.bottom)
                }
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .confirmPopup(isPresented: $showDeleteConfirmation, title: "Delete Exam", message: "Are you sure you want to delete this exam?", confirmAction: {
            examDataStore.deleteExam(withId: exam.id)
        })
    }
    
    private var correctAnswersCount: Int {
        exam.questions.reduce(0) { count, question in
            count + (question.choices.filter { $0.isCorrect }.allSatisfy { question.selectedChoices.contains($0.id) } ? 1 : 0)
        }
    }
    
    private func borderColor(for choice: ExamChoiceData, in question: ExamQuestionData) -> Color {
        if question.selectedChoices.contains(choice.id) {
            return choice.isCorrect ? Color.correct : Color.wrong
        } else {
            return choice.isCorrect ? Color.correct : Color.gray
        }
    }
    
    private func backgroundColor(for choice: ExamChoiceData, in question: ExamQuestionData) -> Color {
        if question.selectedChoices.contains(choice.id) {
            return choice.isCorrect ? Color.correct.opacity(0.8) : Color.red.opacity(0.8)
        } else {
            return Color.clear
        }
    }
}
