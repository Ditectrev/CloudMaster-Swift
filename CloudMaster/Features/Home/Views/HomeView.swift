import SwiftUI

struct HomeView: View {
    @Binding var favorites: Set<Course>
    
    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "Version \(version) (\(build))"
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
                
                Text(appVersion)
                     .font(.footnote)
                     .foregroundColor(.gray)
                     .padding(.bottom, 10)
            }
            .navigationBarTitle("CloudMaster", displayMode: .inline)
            .navigationBarItems( trailing: settingsButton)
        }
        .navigationBarBackButtonHidden(true)
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
            }

            Spacer()
        }
        .padding()
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
        }
    }
}

