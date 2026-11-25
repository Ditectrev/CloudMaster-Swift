import SwiftUI

struct ExamModeView: View {
    let course: Course
    @ObservedObject var examDataStore = UserExamDataStore.shared
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            Spacer()
            
            NavigationLink(destination: ExamView(questionCount: course.exam.quick.questionCount, timeLimit: course.exam.quick.time * 60, course: course, mode: "Quick")) {
                VStack {
                    Text("Quick")
                        .font(.brandHeading(.title))
                    HStack {
                        Text("\(course.exam.quick.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.quick.time) mins")
                    }
                    .font(.brandBody(.subheadline))
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
                        .font(.brandHeading(.title))
                    HStack {
                        Text("\(course.exam.intermediate.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.intermediate.time) mins")
                    }
                    .font(.brandBody(.subheadline))
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
                        .font(.brandHeading(.title))
                    HStack {
                        Text("\(course.exam.real.questionCount) Questions")
                        Image(systemName: "timer")
                        Text("\(course.exam.real.time) mins")
                    }
                    .font(.brandBody(.subheadline))
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
                        .font(.brandHeading(.title3))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    Text("Exam History")
                        .font(.brandHeading(.title3))
                        .foregroundColor(filteredExams.isEmpty ? .gray : (colorScheme == .dark ? .white : .black))
                }
                .padding()
            }
            .disabled(filteredExams.isEmpty)
        }
        .navigationBarTitle("Exam Mode", displayMode: .inline)
    }
    
    private var filteredExams: [UserExamData] {
        examDataStore.exams.filter { $0.courseName == course.fullName }
    }
}
