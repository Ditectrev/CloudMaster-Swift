import Foundation

enum DownloadProgress {
    /// One step for the question file, plus one step for each image.
    static func stepCount(imageCount: Int) -> Int {
        max(imageCount, 0) + 1
    }

    /// Equal share of every course. A finished course is 1, so the spinner can reach 100%.
    static func overall(courseFractions: [Double], totalCourses: Int) -> Double {
        guard totalCourses > 0 else { return 0 }
        let sum = courseFractions.reduce(0, +)
        return min(max(sum / Double(totalCourses), 0), 1)
    }
}
