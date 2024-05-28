import SwiftUI

struct ExamModeView: View {
    let course: Course
    @ObservedObject var examDataStore = UserExamDataStore.shared
    
    var body: some View {
        VStack {
            
            Spacer()
            
            NavigationLink(destination: ExamView(questionCount: course.exam.quick.questionCount, timeLimit: course.exam.quick.time * 60, course: course, mode: "Quick")) {
                VStack {
                    Text("Quick")
                        .font(.title)
                    HStack {
                        Text("\(course.exam.quick.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.quick.time) mins")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.quickMode)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            NavigationLink(destination: ExamView(questionCount: course.exam.intermediate.questionCount, timeLimit: course.exam.intermediate.time * 60, course: course, mode: "Intermediate")) {
                VStack {
                    Text("Intermediate")
                        .font(.title)
                    HStack {
                        Text("\(course.exam.intermediate.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.intermediate.time) mins")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.intermediateMode)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            NavigationLink(destination: ExamView(questionCount: course.exam.real.questionCount, timeLimit: course.exam.real.time * 60, course: course, mode: "Real")) {
                VStack {
                    Text("Real Exam")
                        .font(.title)
                    HStack {
                        Text("\(course.exam.real.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.real.time) mins")
                    }
                    .font(.subheadline)
                }
                .padding()
                .background(Color.realMode)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            
            Spacer()
            
            NavigationLink(destination: PreviousExamsView(exams: filteredExams)) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Exam History")
                }
                .padding()
                .background(filteredExams.isEmpty ? Color.customAccent : Color.customPrimary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(filteredExams.isEmpty)
        }
        .navigationBarTitle("Exam Mode", displayMode: .inline)
    }
    
    private var filteredExams: [UserExamData] {
        examDataStore.exams.filter { $0.courseName == course.fullName }
    }
}
