import Foundation

struct UserExamData: Codable, Identifiable {
    var id = UUID()
    let courseName: String
    let shortName: String
    let dateTime: Date
    let questions: [ExamQuestionData]
    let timeSpent: Int
    let isPassed: Bool
    let mode: String
}

struct ExamQuestionData: Codable, Identifiable {
    var id = UUID()
    let question: String
    let choices: [ExamChoiceData]
    let selectedChoices: [UUID]
}

struct ExamChoiceData: Codable, Identifiable {
    let id: UUID
    let text: String
    let isCorrect: Bool
}

class UserExamDataStore: ObservableObject {
    static let shared = UserExamDataStore()
    private let userDefaultsKey = "userExamData"
    
    @Published private(set) var exams: [UserExamData] = []
    
    init() {
        self.exams = fetchAllExamData()
    }

    func saveExamData(_ examData: UserExamData) {
        exams.append(examData)
        if let encoded = try? JSONEncoder().encode(exams) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    func fetchAllExamData() -> [UserExamData] {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedData = try? JSONDecoder().decode([UserExamData].self, from: savedData) {
            return decodedData
        }
        return []
    }
    
    func resetExamData() {
        exams.removeAll()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func deleteExam(withId id: UUID) {
        if let index = exams.firstIndex(where: { $0.id == id }) {
            exams.remove(at: index)
            if let encoded = try? JSONEncoder().encode(exams) {
                UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            }
        }
    }
}
