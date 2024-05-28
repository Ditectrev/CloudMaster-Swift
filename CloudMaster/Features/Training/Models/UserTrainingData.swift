import Foundation

struct UserTrainingData: Codable {
    var timeSpent: TimeInterval
    var correctAnswers: Int
    var wrongAnswers: Int
    var questionAttempts: [UUID: Int] // Mapping question ID to the number of attempts
    var questionStats: [UUID: QuestionStats] // Mapping question ID to the stats

    init() {
        self.timeSpent = 0
        self.correctAnswers = 0
        self.wrongAnswers = 0
        self.questionAttempts = [:]
        self.questionStats = [:]
    }

    mutating func updateStats(for questionID: UUID, correctChoices: Set<UUID>, selectedChoices: Set<UUID>) {
        // Update question attempts
        if let attempts = questionAttempts[questionID] {
            questionAttempts[questionID] = attempts + 1
        } else {
            questionAttempts[questionID] = 1
        }

        // Track if the answer was correct or incorrect
        if var questionStats = questionStats[questionID] {
            questionStats.timesViewed += 1
            if selectedChoices == correctChoices {
                questionStats.timesCorrect += 1
            } else {
                questionStats.timesIncorrect += 1
            }
            self.questionStats[questionID] = questionStats
        } else {
            let timesCorrect = selectedChoices == correctChoices ? 1 : 0
            let timesIncorrect = timesCorrect == 1 ? 0 : 1
            self.questionStats[questionID] = QuestionStats(timesViewed: 1, timesCorrect: timesCorrect, timesIncorrect: timesIncorrect)
        }
    }

}

struct QuestionStats: Codable {
    var timesViewed: Int
    var timesCorrect: Int
    var timesIncorrect: Int
}

class UserTrainingStore {
    static let shared = UserTrainingStore()
    private let userDefaultsKey = "userTrainingData"
    
    private init() {
        loadTrainingData()
    }

    var trainingData: UserTrainingData = UserTrainingData()
    
    func loadTrainingData() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedData = try? JSONDecoder().decode(UserTrainingData.self, from: data) {
                trainingData = decodedData
            }
        }
    }
    
    func saveTrainingData() {
        if let data = try? JSONEncoder().encode(trainingData) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    func resetTrainingData() {
        trainingData = UserTrainingData()
        saveTrainingData()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
