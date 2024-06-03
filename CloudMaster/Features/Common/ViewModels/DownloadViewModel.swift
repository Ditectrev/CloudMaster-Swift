import Foundation
import Combine

class DownloadViewModel: ObservableObject {
    @Published var isDownloading: Bool = false
    @Published var overallProgress: Double = 0.0
    @Published var statusMessage: String = ""
    @Published var showAlert: Bool = false
    @Published var downloadCompleted: Bool = false
    @Published var completedDownloads: Int = 0
    var alertMessage: String = ""
    var cancellables = Set<AnyCancellable>()

    private var downloadProgress: [Course: Progress] = [:]
    var totalCourses: Double = 0

    func downloadCourses(_ favorites: Set<Course>) {
        totalCourses = Double(favorites.count)
        completedDownloads = 0
        isDownloading = true
        downloadCompleted = false

        for course in favorites {
            downloadCourse(course)
        }
    }

    func downloadCourse(_ course: Course) {
        isDownloading = true
        DownloadUtility.downloadAndConvertCourse(course: course, progressHandler: { [weak self] progress, status in
            DispatchQueue.main.async {
                self?.downloadProgress[course] = progress
                self?.statusMessage = status
                let totalProgress = self?.downloadProgress.values.map({ $0.fractionCompleted / 2 }).reduce(0, +) ?? 0
                self?.overallProgress = totalProgress / self!.totalCourses
            }
        }) { [weak self] result in
            DispatchQueue.main.async {
                self?.isDownloading = false
                switch result {
                case .success:
                    self?.completedDownloads += 1
                    self?.overallProgress = Double(self!.completedDownloads) / self!.totalCourses
                    if self?.completedDownloads == Int(self!.totalCourses) {
                        self?.isDownloading = false
                        self?.downloadCompleted = true
                    }
                case .failure(let error):
                    self?.alertMessage = "Failed to download \(course.shortName): \(error.localizedDescription)"
                    self?.showAlert = true
                    self?.isDownloading = false
                }
            }
        }
    }

    func cancelDownloads() {
        for (course, _) in downloadProgress {
            DownloadUtility.cancelDownload(for: course)
        }
        downloadProgress.removeAll()
        statusMessage = "Download cancelled"
        isDownloading = false
    }
}
