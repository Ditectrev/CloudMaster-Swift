import SwiftUI

struct IntroView: View {
    @State private var currentPage = 0
    @State private var searchText = ""
    @State private var showLoadingView = false
    
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
                    SecondPage(searchText: $searchText, favorites: $favorites, showLoadingView: $showLoadingView, isAppConfigured: $isAppConfigured)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $showLoadingView) {
            LoadingView(favorites: $favorites, isSetupComplete: $isAppConfigured)
        }
    }
}

struct FirstPage: View {
    let onNext: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
   

    var body: some View {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let imageSize: CGFloat = isIpad ? 300 : 200
        
        VStack {
            Text("Welcome to CloudMaster")
                .font(.largeTitle)
                .bold()
                .padding()
                .transition(.opacity)
                .frame(alignment: .leading)
                .multilineTextAlignment(.center)
            
            Text("Improve your knowledge and get ready for exams")
                .font(.subheadline)
                .bold()
                .padding(.bottom, 20)
            
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
    @Binding var showLoadingView: Bool
    @Binding var isAppConfigured: Bool

    var body: some View {
        VStack {
            Text("Welcome to CloudMaster")
                .font(.largeTitle)
                .bold()
                .padding()

            Text("Select your courses to study")
                .font(.subheadline)
                .bold()
            

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
                showLoadingView = true
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
