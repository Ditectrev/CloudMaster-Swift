import SwiftUI

struct HomeView: View {
    @Binding var favorites: Set<Course>
    
    @Environment(\.colorScheme) var colorScheme
    
    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        return "\(version)"
    }


    var body: some View {
        NavigationView {
            VStack {
                if favorites.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "circle.dashed")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("No Courses")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List(Array(favorites)) { course in
                        ZStack {
                            StyledCourseRow(course: course)
                            NavigationLink(destination: CourseView(course: course)) {
                                EmptyView()
                            }
                            .opacity(0) // Make the NavigationLink invisible
                        }
                        .padding(.vertical, 3)
                    }
                    .listStyle(PlainListStyle())
                    Spacer()
                }

                NavigationLink(destination: CoursesView(favorites: $favorites)) {
                    HStack {
                        Text(favorites.isEmpty ? "Add Courses" : "Manage Courses")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.customPrimary)
                    .cornerRadius(10)
                }
                .padding(.top, 10)
                
                Link(destination: URL(string: "https://github.com/Ditectrev/CloudMaster")!) {
                    Image("githubIcon")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(colorScheme == .dark ? .gray : .black)
                        .frame(width: 24, height: 24)
                }
                .padding(.bottom, 5)
                
                Text(appVersion)
                     .font(.footnote)
                     .foregroundColor(.gray)
                     .padding(.bottom, 10)
            }
            .navigationBarTitle("CloudMaster", displayMode: .inline)
            .navigationBarItems( trailing: settingsButton)
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
    }

    func saveFavoritesOnDismiss() {
        FavoritesStorage.shared.saveFavorites(favorites)
    }
}

extension HomeView {

    private var settingsButton: some View {
        NavigationLink(destination: SettingsView()) {
            Image(systemName: "gearshape")
        }
    }
}

struct StyledCourseRow: View {
    let course: Course

    var body: some View {
        HStack {
            // Icon based on the company
            Image(iconForCompany(course.company))
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(course.shortName)
                    .font(.headline)
                Text(course.fullName)
                    .font(.subheadline)
                    .lineLimit(1) // Ensure the text doesn't exceed one line
            }

            Spacer()
        }
        .padding()
        .frame(height: 60) // Set a fixed height for the row
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(gradientForCompany(course.company), lineWidth: 2)
                .cornerRadius(10)
        )
    }

    func iconForCompany(_ company: CourseCompany) -> String {
        switch company {
        case .aws:
            return "awsIcon"
        case .azure:
            return "azureIcon"
        case .gcp:
            return "gcpIcon"
        case .other:
            return "otherIcon"
        }
    }

    func gradientForCompany(_ company: CourseCompany) -> LinearGradient {
        switch company {
        case .aws:
            return LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow]), startPoint: .leading, endPoint: .trailing)
        case .azure:
            let color1 = Color(red: 21/255, green: 74/255, blue: 137/255)
            let color2 = Color(red: 65/255, green: 197/255, blue: 241/255)
            return LinearGradient(gradient: Gradient(colors: [color1, color2]), startPoint: .leading, endPoint: .trailing)
        case .gcp:
            return LinearGradient(gradient: Gradient(colors: [.red, .green, .yellow, .blue]), startPoint: .leading, endPoint: .trailing)
        case .other:
            let color1 = Color.purple
            let color2 = Color.pink
            let color3 = Color.orange
            return LinearGradient(gradient: Gradient(colors: [color1, color2, color3]), startPoint: .leading, endPoint: .trailing)
        }
    }
}
