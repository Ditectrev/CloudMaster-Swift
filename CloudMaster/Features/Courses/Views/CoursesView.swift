import SwiftUI

struct CoursesView: View {
    @Binding var favorites: Set<Course>
    @State private var searchText = ""
    @StateObject private var viewModel = DownloadViewModel()
    @State private var alertMessage: String?

    var body: some View {
        VStack {
            SearchBar(text: $searchText)
                .padding()

            List(Course.allCourses.filter({ searchText.isEmpty ? true : $0.fullName.lowercased().contains(searchText.lowercased()) })) { course in
                CourseRow(course: course, isBookmarked: favorites.contains(course)) {
                    if favorites.contains(course) {
                        favorites.remove(course)
                    } else {
                        favorites.insert(course)
                    }
                    FavoritesStorage.shared.saveFavorites(favorites)
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationBarTitle("All Courses", displayMode: .inline)
        .navigationBarItems(trailing: updateButton)
        .overlay(
            DownloadOverlayView(
                isShowing: $viewModel.isDownloading,
                viewModel: viewModel
            )
        )
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Download Error"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    private var updateButton: some View {
        Button(action: {
            viewModel.downloadCourses(favorites)
        }) {
            Image(systemName: "arrow.down.circle")
        }
    }
}

