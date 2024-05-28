import SwiftUI

struct LoadingView: View {
    @Binding var favorites: Set<Course>
    @Binding var isSetupComplete: Bool
    @State private var overallProgress = 0.0
    @State private var completedDownloads = 0
    
    var body: some View {
        VStack {
            Text("Downloading Courses...")
                .font(.headline)
                .padding()
            ProgressView(value: overallProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle())
                .padding()
            Spacer()
        }
        .onAppear(perform: downloadCourses)
    }
    
    private func downloadCourses() {
        let total = Double(favorites.count)
        for course in favorites {
            DownloadUtility.downloadAndConvertCourse(course: course, progressHandler: { progress in
                progress.completedUnitCount = 1
                DispatchQueue.main.async {
                    self.overallProgress = (Double(completedDownloads) + progress.fractionCompleted) / total
                }
            }) {_ in 
                DispatchQueue.main.async {
                    completedDownloads += 1
                    self.overallProgress = Double(completedDownloads) / total
                    if completedDownloads == favorites.count {
                        self.isSetupComplete = true // Transition to HomeView
                    }
                }
            }
        }
    }
}
