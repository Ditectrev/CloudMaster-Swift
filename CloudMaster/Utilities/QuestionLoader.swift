import Foundation

struct Question: Identifiable, Codable {
    let id = UUID()
    let question: String
    let choices: [Choice]
    var multipleResponse: Bool
    var responseCount: Int
    let images: [ImageInfo]

    enum CodingKeys: String, CodingKey {
        case question, choices, multipleResponse = "multiple_response", responseCount = "response_count", images
    }

    struct ImageInfo: Codable {
        let path: String
        let url: String?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = try container.decode(String.self, forKey: .question)
        choices = try container.decode([Choice].self, forKey: .choices)
        multipleResponse = try container.decodeIfPresent(Bool.self, forKey: .multipleResponse) ?? false
        responseCount = try container.decodeIfPresent(Int.self, forKey: .responseCount) ?? 0
        images = try container.decodeIfPresent([ImageInfo].self, forKey: .images) ?? []
    }
}


struct Choice: Identifiable, Codable {
    var id = UUID()
    let text: String
    let correct: Bool
    
    enum CodingKeys: String, CodingKey {
        case text, correct
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        correct = try container.decode(Bool.self, forKey: .correct)
        // id is generated automatically
    }
}

class QuestionLoader: ObservableObject {
    @Published var questions: [Question] = []
    private let intelligentLearning: Bool

    init(filename: String = "default.json", intelligentLearning: Bool = false) {
        self.intelligentLearning = intelligentLearning
        loadQuestions(from: filename)
    }

    func loadQuestions(from filename: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonFileURL = documentsURL.appendingPathComponent(filename)

        if fileManager.fileExists(atPath: jsonFileURL.path) {
            do {
                let data = try Data(contentsOf: jsonFileURL)
                var questions = try JSONDecoder().decode([Question].self, from: data)

                if intelligentLearning {
                    questions = reorderQuestions(questions)
                } else {
                    questions.shuffle()
                }
                self.questions = questions
            } catch {
                print("Error loading questions: \(error)")
            }
        } else {
            print("Warning: File does not exist at path: \(jsonFileURL.path)")
        }
    }

    private func reorderQuestions(_ questions: [Question]) -> [Question] {
        guard let trainingData = UserTrainingStore.shared.trainingData[questions.first?.id.uuidString ?? ""] else {
            return questions
        }

        let newQuestions = questions.filter { trainingData.questionStats[$0.id] == nil }
        let incorrectQuestions = questions.filter {
            if let stats = trainingData.questionStats[$0.id] {
                return stats.timesIncorrect > stats.timesCorrect
            }
            return false
        }
        let knownQuestions = questions.filter {
            if let stats = trainingData.questionStats[$0.id] {
                return stats.timesIncorrect <= stats.timesCorrect
            }
            return false
        }

        return newQuestions + incorrectQuestions + knownQuestions
    }
    
    func reloadQuestions(from filename: String) {
        loadQuestions(from: filename)
    }
}
