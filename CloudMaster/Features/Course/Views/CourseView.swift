import SwiftUI

struct CourseView: View {
    @State private var isLoading = false
    @State private var downloadProgress: [Course: Progress] = [:]
    @State private var userTrainingData = UserTrainingData()
    @State private var showingNotificationSettings = false
    @State private var notificationsEnabled = false
    
    let course: Course

    var body: some View {
        VStack {
            VStack {
                Text(course.fullName)
                    .font(.title)
                    .bold()
                    .padding()
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.center)
                Text(course.description)
                    .font(.caption)
                    .frame(alignment: .leading)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(formatTimeSpent(userTrainingData.timeSpent))
                        .font(.subheadline)
                }
                .padding(.top, 20)
                
                Spacer()
                VStack(spacing: 20) {
                    NavigationLink(destination: TrainingView(course: course, intelligentLearning: false)) {
                        VStack {
                            Text("Training")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Practice and learn random questions")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.customAccent, Color.training]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: TrainingView(course: course, intelligentLearning: true)) {
                        VStack {
                            Text("Intelligent Training")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Train based on your learning history")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.training, Color.exam]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ExamModeView(course: course)) {
                        VStack {
                            Text("Exam")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Challenge yourself with timed exams")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [Color.exam, Color.customPrimary]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                    }
                }
                Spacer()
                
                HStack(spacing: 20) {
                    Link("Certification", destination: URL(string: course.url)!)
                        .padding()
                        .font(.subheadline)
                    
                    Link("Sources", destination: URL(string: course.url)!)
                        .padding()
                        .font(.subheadline)
                }
            }
            .onAppear {
                loadUserTrainingData(for: course)
                checkNotificationSettings()
            }
        }
        .navigationBarTitle(course.shortName, displayMode: .inline)
        .navigationBarItems(trailing: notificationButton)
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView(isPresented: $showingNotificationSettings, notificationsEnabled: $notificationsEnabled, course: course)
                .onDisappear {
                    checkNotificationSettings()
                }
        }
    }
    
    private var notificationButton: some View {
        Button(action: {
            if notificationsEnabled {
                disableNotifications(for: course)
            } else {
                showingNotificationSettings = true
            }
        }) {
            Image(systemName: notificationsEnabled ? "bell.fill" : "bell")
                .foregroundColor(notificationsEnabled ? Color.correct : .gray)
        }
    }
    
    func loadUserTrainingData(for course: Course) {
        if let data = UserDefaults.standard.data(forKey: course.shortName) {
            if let decodedData = try? JSONDecoder().decode(UserTrainingData.self, from: data) {
                userTrainingData = decodedData
            }
        }
    }
    
    func formatTimeSpent(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    func checkNotificationSettings() {
        let frequency = UserDefaults.standard.integer(forKey: "\(course.shortName)_notificationFrequency")
        notificationsEnabled = frequency > 0
    }
    
    func disableNotifications(for course: Course) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [course.shortName])
        UserDefaults.standard.removeObject(forKey: "\(course.shortName)_notificationFrequency")
        notificationsEnabled = false
    }
}
