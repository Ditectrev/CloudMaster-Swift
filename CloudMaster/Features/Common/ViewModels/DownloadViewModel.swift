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
        downloadProgress.removeAll()
        overallProgress = 0
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
                self?.publishOverallProgress()
            }
        }) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.markCourseFinished(course)
                case .failure(let error):
                    self?.alertMessage = "Failed to download \(course.shortName): \(error.localizedDescription)"
                    self?.showAlert = true
                    self?.isDownloading = false
                }
            }
        }
    }

    private func markCourseFinished(_ course: Course) {
        completedDownloads += 1
        if let progress = downloadProgress[course] {
            progress.completedUnitCount = max(progress.totalUnitCount, 1)
        } else {
            let finished = Progress(totalUnitCount: 1)
            finished.completedUnitCount = 1
            downloadProgress[course] = finished
        }
        publishOverallProgress()
        if totalCourses > 0, completedDownloads == Int(totalCourses) {
            overallProgress = 1
            isDownloading = false
            downloadCompleted = true
        }
    }

    private func publishOverallProgress() {
        let fractions = downloadProgress.values.map(\.fractionCompleted)
        overallProgress = DownloadProgress.overall(
            courseFractions: fractions,
            totalCourses: Int(totalCourses)
        )
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
