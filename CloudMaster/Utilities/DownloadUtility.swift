import Foundation

class DownloadUtility {
    static func downloadAndConvertCourse(course: Course, progressHandler: @escaping (Progress) -> Void, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: course.questionURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1, userInfo: nil)))
            return
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsURL.appendingPathComponent("\(course.shortName).md")
        
        let task = URLSession.shared.downloadTask(with: url) { (tempURL, response, error) in
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
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                try convertMarkdownToJSON(fileURL: destinationURL, shortName: course.shortName)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        progressHandler(task.progress)
        task.resume()
    }
    
    static func convertMarkdownToJSON(fileURL: URL, shortName: String) throws {
        do {
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            let jsonData = try parseMarkdown(markdown: fileContents)
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let jsonFileURL = documentsURL.appendingPathComponent("\(shortName).json")
            if FileManager.default.fileExists(atPath: jsonFileURL.path) {
                try FileManager.default.removeItem(at: jsonFileURL)
            }
            try jsonData.write(to: jsonFileURL)
        } catch {
            print("Error converting file: \(error)")
            throw error
        }
    }
    
    static func parseMarkdown(markdown: String) throws -> Data {
        let lines = markdown.components(separatedBy: .newlines)
        var questions: [[String: Any]] = []
        var currentQuestion: [String: Any] = [:]
        var choices: [[String: Any]] = []
        var correctCount = 0
        
        let questionPattern = try? NSRegularExpression(pattern: "### (.+)")
        let choicePattern = try? NSRegularExpression(pattern: "- \\[([ x])\\] (.+)")
        
        for line in lines {
            if let questionMatch = questionPattern?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                if !currentQuestion.isEmpty && !choices.isEmpty {
                    currentQuestion["choices"] = choices
                    if correctCount > 1 {
                        currentQuestion["multiple_response"] = true
                        currentQuestion["response_count"] = correctCount
                    }
                    questions.append(currentQuestion)
                    currentQuestion = [:]
                    choices = []
                    correctCount = 0
                }
                let question = String(line[Range(questionMatch.range(at: 1), in: line)!])
                currentQuestion["question"] = question
            } else if let choiceMatch = choicePattern?.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)) {
                let isCorrect = line[Range(choiceMatch.range(at: 1), in: line)!] == "x"
                if isCorrect {
                    correctCount += 1
                }
                let choice = String(line[Range(choiceMatch.range(at: 2), in: line)!])
                choices.append(["id": UUID().uuidString, "text": choice, "correct": isCorrect])
            } else if line.trimmingCharacters(in: .whitespacesAndNewlines) == "**[⬆ Back to Top](#table-of-contents)**" {
                if !currentQuestion.isEmpty && !choices.isEmpty {
                    currentQuestion["choices"] = choices
                    if correctCount > 1 {
                        currentQuestion["multiple_response"] = true
                        currentQuestion["response_count"] = correctCount
                    }
                    questions.append(currentQuestion)
                    currentQuestion = [:]
                    choices = []
                    correctCount = 0
                }
            }
        }
        
        if !currentQuestion.isEmpty && !choices.isEmpty {
            currentQuestion["choices"] = choices
            if correctCount > 1 {
                currentQuestion["multiple_response"] = true
                currentQuestion["response_count"] = correctCount
            }
            questions.append(currentQuestion)
        }
        
        if questions.isEmpty {
            throw NSError(domain: "com.example.error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Course has no questions, please contact developer"])
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: questions, options: .prettyPrinted)
        return jsonData
    }
}
