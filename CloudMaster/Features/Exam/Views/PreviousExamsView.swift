import Foundation
import SwiftUI

struct PreviousExamsView: View {
    let exams: [UserExamData]
    
    var body: some View {
        List(exams) { exam in
            NavigationLink(destination: ExamSummaryView(exam: exam, afterExam: false)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(exam.mode)
                            .font(.brandBody(.caption))
                            .bold()
                        Text(exam.shortName)
                            .font(.brandHeading(.headline))
                        Text(exam.courseName)
                            .font(.brandBody(.subheadline))
                        Text("\(exam.dateTime.formatted())")
                            .font(.brandBody(.caption))
                            .bold()
                    }
                    
                    Spacer()
                    
                    Text(exam.isPassed ? "Passed" : "Failed")
                        .foregroundColor(exam.isPassed ? .green : .red)
                        .font(.brandBody(.subheadline))
                        .frame(maxHeight: .infinity)
                        .padding(.leading)
                }
            }
        }
        .navigationTitle("Previous Exams")
    }
}
