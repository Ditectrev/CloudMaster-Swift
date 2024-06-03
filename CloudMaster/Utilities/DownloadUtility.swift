import Foundation

class DownloadUtility {
    private static var downloadTasks: [String: URLSessionDownloadTask] = [:]
    private static let downloadQueue = DispatchQueue(label: "com.example.downloadQueue")

    static func downloadAndConvertCourse(course: Course, progressHandler: @escaping (Progress, String) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: course.questionURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent("\(course.shortName).md")
        
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
            downloadQueue.async {
                downloadTasks[course.shortName] = nil
            }
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            guard let tempURL = tempURL else {
                let error = NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to download file"])
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            do {
                try FileManager.default.removeItemIfExists(at: destinationURL)
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                
                let markdown = try String(contentsOf: destinationURL, encoding: .utf8)
                var questions = try parseMarkdown(markdown: markdown, course: course)
                
                let totalTasks = questions.count + 1 // +1 for downloading questions
                var progress = Progress(totalUnitCount: Int64(totalTasks))
                progress.completedUnitCount = 1
                progressHandler(progress, "Questions for \(course.shortName)")
                
                questions = try downloadImages(for: questions, course: course) { completedImages in
                    progress.completedUnitCount = Int64(completedImages + 1)
                    progressHandler(progress, "Assets for \(course.shortName)")
                }
                
                progress.completedUnitCount = Int64(totalTasks)
                progressHandler(progress, "Completed downloading \(course.shortName)")
                
                let jsonData = try JSONSerialization.data(withJSONObject: questions, options: .prettyPrinted)
                let jsonFileURL = documentsURL.appendingPathComponent("\(course.shortName).json")
                try FileManager.default.removeItemIfExists(at: jsonFileURL)
                try jsonData.write(to: jsonFileURL)
                
                DispatchQueue.main.async {
                    print("Downloaded course: \(course.shortName)")
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        downloadQueue.async {
            downloadTasks[course.shortName] = task
        }
        
        task.resume()
    }
    
    static func cancelDownload(for course: Course) {
        downloadQueue.async {
            if let task = downloadTasks[course.shortName] {
                task.cancel()
                downloadTasks[course.shortName] = nil
            }
        }
    }

    static func parseMarkdown(markdown: String, course: Course) throws -> [[String: Any]] {
        let lines = markdown.components(separatedBy: .newlines)
        var questions: [[String: Any]] = []
        var currentQuestion: [String: Any] = [:]
        var choices: [[String: Any]] = []
        var correctCount = 0
        var currentImagePath: String?
        
        let questionPattern = try NSRegularExpression(pattern: "### (.+)")
        let choicePattern = try NSRegularExpression(pattern: "- \\[([ x])\\] (.+)")
        let imagePattern = try NSRegularExpression(pattern: "!\\[.*\\]\\((images/.+?)\\)")
        
        for line in lines {
            if let questionMatch = questionPattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                if !currentQuestion.isEmpty {
                    currentQuestion["choices"] = choices
                    if correctCount > 1 {
                        currentQuestion["multiple_response"] = true
                        currentQuestion["response_count"] = correctCount
                    }
                    currentQuestion["imagePath"] = currentImagePath
                    questions.append(currentQuestion)
                    currentQuestion = [:]
                    choices = []
                    correctCount = 0
                    currentImagePath = nil
                }
                let question = String(line[Range(questionMatch.range(at: 1), in: line)!])
                currentQuestion["question"] = question
            } else if let choiceMatch = choicePattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                let isCorrect = line[Range(choiceMatch.range(at: 1), in: line)!] == "x"
                if isCorrect {
                    correctCount += 1
                }
                let choice = String(line[Range(choiceMatch.range(at: 2), in: line)!])
                choices.append(["id": UUID().uuidString, "text": choice, "correct": isCorrect])
            } else if let imageMatch = imagePattern.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                let imagePath = String(line[Range(imageMatch.range(at: 1), in: line)!])
                currentImagePath = "images/\(course.shortName)/\(imagePath)"
            }
        }
        
        if !currentQuestion.isEmpty {
            currentQuestion["choices"] = choices
            if correctCount > 1 {
                currentQuestion["multiple_response"] = true
                currentQuestion["response_count"] = correctCount
            }
            currentQuestion["imagePath"] = currentImagePath
            questions.append(currentQuestion)
        }
        
        if questions.isEmpty {
            throw NSError(domain: "com.example.error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Course has no questions, please contact developer"])
        }
        
        return questions
    }
    
    static func downloadImages(for questions: [[String: Any]], course: Course, progressHandler: @escaping (Int) -> Void) throws -> [[String: Any]] {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imagesDirectoryURL = documentsURL.appendingPathComponent("images/\(course.shortName)")
        
        try FileManager.default.createDirectory(at: imagesDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        
        var updatedQuestions = questions
        
        for (index, question) in questions.enumerated() {
            if let imagePath = question["imagePath"] as? String {
                if imagePath.contains("discord") {
                    continue
                }
                let imageUrlString = "\(course.repositoryURL)/blob/main/\(imagePath.replacingOccurrences(of: "images/\(course.shortName)/", with: ""))".replacingOccurrences(of: "github.com", with: "raw.githubusercontent.com").replacingOccurrences(of: "/blob/", with: "/")
                if let imageUrl = URL(string: imageUrlString) {
                    let imageData = try Data(contentsOf: imageUrl)
                    let imageFileName = imagePath.replacingOccurrences(of: "images/\(course.shortName)/", with: "")
                    let imageFileURL = imagesDirectoryURL.appendingPathComponent(imageFileName)
                    
                    let imageFileDirectory = imageFileURL.deletingLastPathComponent()
                    try FileManager.default.createDirectory(at: imageFileDirectory, withIntermediateDirectories: true, attributes: nil)
                    
                    try FileManager.default.removeItemIfExists(at: imageFileURL)
                    try imageData.write(to: imageFileURL)
                    
                    updatedQuestions[index]["imagePath"] = "images/\(course.shortName)/\(imageFileName)"
                    
                    progressHandler(index + 1)
                }
            }
        }
        
        return updatedQuestions
    }
}

extension FileManager {
    func removeItemIfExists(at url: URL) throws {
        if fileExists(atPath: url.path) {
            try removeItem(at: url)
        }
    }
}
