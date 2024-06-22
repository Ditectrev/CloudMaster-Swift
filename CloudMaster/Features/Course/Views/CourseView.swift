import SwiftUI

struct CourseView: View {
    @State private var isLoading = false
    @State private var downloadProgress: [Course: Progress] = [:]
   
    @State private var showingNotificationSettings = false
    @State private var notificationsEnabled = false
    @State private var showingInfoPopup = false
    
    @StateObject private var viewModel = DownloadViewModel()
    @StateObject private var questionLoader: QuestionLoader

    @ObservedObject var userTrainingStore = UserTrainingStore.shared

    @Environment(\.colorScheme) var colorScheme
    
    let course: Course

    init(course: Course) {
        self.course = course
        _questionLoader = StateObject(wrappedValue: QuestionLoader(filename: course.shortName + ".json", intelligentLearning: false))
    }

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
                    Text(formatTimeSpent(userTrainingStore.trainingData[course.shortName]?.timeSpent ?? 0))
                        .font(.subheadline)
                }
                .padding(.top, 20)

                Spacer()
                VStack(spacing: 20) {
                    NavigationLink(destination: TrainingView(course: course)) {
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

                    NavigationLink(destination: TrainingView(course: course)) {
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

                NavigationLink(destination: BookmarksView()) {
                    HStack {
                        Image(systemName: "bookmark")
                            .font(.title3)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Text("Bookmarks")
                            .font(.title3)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .cornerRadius(10)
                }
            }
            .onAppear {
                loadUserTrainingData()
                checkNotificationSettings()
                if questionLoader.questions.isEmpty {
                    downloadCourse()
                }
            }
        }
        .navigationBarTitle(course.shortName, displayMode: .inline)
        .navigationBarItems(trailing: HStack {
            notificationButton
            infoButton
        })
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView(isPresented: $showingNotificationSettings, notificationsEnabled: $notificationsEnabled, course: course)
                .onDisappear {
                    checkNotificationSettings()
                }
        }
        .sheet(isPresented: $showingInfoPopup) {
            CourseInformationPopup(course: course)
        }
        .overlay(
            DownloadOverlayView(
                isShowing: $viewModel.isDownloading,
                viewModel: viewModel
            )
        )
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Download Error"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK")))
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
        }
    }

    private var infoButton: some View {
        Button(action: {
            showingInfoPopup = true
        }) {
            Image(systemName: "info.circle")
        }
    }

    func loadUserTrainingData() {
        _ = userTrainingStore.loadTrainingData(forCourse: course.shortName)
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

    func downloadCourse() {
        viewModel.downloadCourse(course)
        viewModel.$isDownloading.sink { isDownloading in
            if (!isDownloading) {
                DispatchQueue.main.async {
                    questionLoader.reloadQuestions(from: course.shortName + ".json")
                }
            }
        }
        .store(in: &viewModel.cancellables)

        viewModel.$showAlert.sink { showAlert in
            if showAlert {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust the delay as needed
                    // Handle dismissal if needed
                }
            }
        }
        .store(in: &viewModel.cancellables)
    }
}

struct CourseInformationPopup: View {
    let course: Course
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Course information")
                .font(.title2)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image(systemName: "book.pages.fill")
                    Text("Certification")
                    Spacer()
                }
                Link(course.url, destination: URL(string: course.url)!)
            }
            
            VStack(spacing: 10) {
                HStack {
                    Spacer()
                    Image(systemName: "link")
                    Text("Sources")
                    Spacer()
                }
                Link(course.repositoryURL, destination: URL(string: course.repositoryURL)!)
            }
            
            Spacer()
        }
        .padding()
    }
}
