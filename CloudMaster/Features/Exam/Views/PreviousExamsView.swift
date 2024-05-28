import Foundation
import SwiftUI

struct PreviousExamsView: View {
    let exams: [UserExamData]
    
    var body: some View {
        List(exams) { exam in
            NavigationLink(destination: ExamSummaryView(exam: exam)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(exam.mode)
                            .font(.caption)
                            .bold()
                        Text(exam.shortName)
                            .font(.headline)
                        Text(exam.courseName)
                            .font(.subheadline)
                        Text("\(exam.dateTime.formatted())")
                            .font(.caption)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Text(exam.isPassed ? "Passed" : "Failed")
                        .foregroundColor(exam.isPassed ? .green : .red)
                        .font(.subheadline)
                        .frame(maxHeight: .infinity)
                        .padding(.leading)
                }
            }
        }
        .navigationTitle("Previous Exams")
    }
}
