import SwiftUI

struct CoursesView: View {
    @Binding var favorites: Set<Course>
    @State private var searchText = ""
    @State private var downloadProgress: [Course: Progress] = [:]
    @State private var isDownloading = false
    @State private var overallProgress = 0.0
    @State private var alertMessage: String?
    @State private var showAlert = false

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
            .overlay(DownloadOverlayView(isShowing: $isDownloading, progress: $overallProgress))
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Download Error"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
            }
    }
}

extension CoursesView {
    private var updateButton: some View {
        Button(action: {
            updateCourses()
        }) {
            Image(systemName: "arrow.down.circle")
        }
    }
    
    private func updateCourses() {
        isDownloading = true
        let total = Double(favorites.count)
        var completedDownloads = 0.0

        for course in favorites {
            DownloadUtility.downloadAndConvertCourse(course: course, progressHandler: { progress in
                DispatchQueue.main.async {
                    downloadProgress[course] = progress
                    let totalProgress = downloadProgress.values.map({ $0.fractionCompleted }).reduce(0, +)
                    overallProgress = totalProgress / total
                }
            }) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        completedDownloads += 1
                        overallProgress = completedDownloads / total
                        if completedDownloads == total {
                            isDownloading = false
                        }
                    case .failure(let error):
                        alertMessage = "Failed to download \(course.shortName): \(error.localizedDescription)"
                        showAlert = true
                        isDownloading = false
                    }
                }
            }
        }
    }
}
