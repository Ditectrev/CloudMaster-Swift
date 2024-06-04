import SwiftUI

struct IntroView: View {
    @State private var currentPage = 0
    @State private var searchText = ""
    @State private var showDownloadOverlayView = false
    @StateObject private var viewModel = DownloadViewModel()

    @Binding var favorites: Set<Course>
    @Binding var isAppConfigured: Bool

    var body: some View {
        NavigationView {
            VStack {
                if currentPage == 0 {
                    FirstPage {
                        withAnimation {
                            currentPage = 1
                        }
                    }
                } else {
                    SecondPage(searchText: $searchText, favorites: $favorites, showDownloadOverlayView: $showDownloadOverlayView, isAppConfigured: $isAppConfigured)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showDownloadOverlayView) {
            DownloadOverlayView(
                isShowing: $showDownloadOverlayView,
                viewModel: viewModel
            )
            .onAppear {
                viewModel.downloadCourses(favorites)
            }
        }
        .onChange(of: viewModel.downloadCompleted) { completed in
            if completed {
                isAppConfigured = true
            }
        }
    }
}

struct FirstPage: View {
    let onNext: () -> Void
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let imageSize: CGFloat = isIpad ? 300 : 200

        VStack() {
            Text("WELCOME TO")
                .font(.system(size: 24, weight: .light, design: .default))
                .transition(.opacity)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)

            Text("Cloudmaster")
                .font(.system(size: 36, weight: .bold, design: .default))
                .transition(.opacity)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)

            Text("Improve your knowledge and get ready for exams")
                .font(.system(size: 18, weight: .light, design: .default))
                .bold()
                .padding(.bottom, 20)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Image(colorScheme == .dark ? "CM_white" : "CM_black")
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)

            Spacer()

            Button(action: onNext) {
                Text("Select Courses")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.customPrimary)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

struct SecondPage: View {
    @Binding var searchText: String
    @Binding var favorites: Set<Course>
    @Binding var showDownloadOverlayView: Bool
    @Binding var isAppConfigured: Bool

    var body: some View {
        VStack {
            Text("WELCOME TO")
                .font(.system(size: 24, weight: .light, design: .default))
                .transition(.opacity)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)

            Text("Cloudmaster")
                .font(.system(size: 36, weight: .bold, design: .default))
                .transition(.opacity)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
            
            Text("Select your courses to study")
                .font(.system(size: 18, weight: .light, design: .default))
                .bold()
                .padding(.bottom, 20)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
                .padding()

            SearchBar(text: $searchText)
                .padding()

            List(Course.allCourses.filter({ searchText.isEmpty ? true : $0.fullName.lowercased().contains(searchText.lowercased()) })) { course in
                CourseRow(course: course, isBookmarked: favorites.contains(course)) {
                    if favorites.contains(course) {
                        favorites.remove(course)
                    } else {
                        favorites.insert(course)
                    }
                }
            }
            .listStyle(PlainListStyle())

            Spacer()

            Button("Finish Setup") {
                UserDefaults.standard.set(true, forKey: "isFirstStart")
                showDownloadOverlayView = true
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.customPrimary)
            .cornerRadius(10)
            .disabled(favorites.isEmpty)
        }
        .padding()
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search courses", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct CourseRow: View {
    let course: Course
    let isBookmarked: Bool
    let toggleBookmark: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(course.company.rawValue)
                    .font(.caption)
                Text(course.shortName)
                    .font(.headline)
                Text(course.fullName)
                    .font(.subheadline)
            }

            Spacer()

            Button(action: toggleBookmark) {
                Image(systemName: isBookmarked ? "star.fill" : "star")
                    .foregroundColor(Color.customSecondary)
            }
        }
    }
}
