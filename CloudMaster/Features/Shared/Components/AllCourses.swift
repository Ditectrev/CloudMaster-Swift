import SwiftUI

struct AllCourses: View {
    @Binding var favorites: Set<Course>
    @State private var searchText = ""

    var filteredCourses: [Course] {
        Course.allCourses.filter { course in
            searchText.isEmpty ? true : course.fullName.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding()

            List {
                ForEach(CourseCompany.allCases, id: \.self) { company in
                    let companyCourses = filteredCourses.filter { $0.company == company }
                    if !companyCourses.isEmpty {
                        Section(header: Text(company.rawValue.uppercased()).font(.title3)) {
                            ForEach(companyCourses) { course in
                                CourseRow(
                                    course: course,
                                    isBookmarked: favorites.contains(course),
                                    toggleBookmark: {
                                        if favorites.contains(course) {
                                            favorites.remove(course)
                                        } else {
                                            favorites.insert(course)
                                        }
                                        FavoritesStorage.shared.saveFavorites(favorites)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
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
