import Foundation
import SwiftUI

struct UserTrainingData: Codable, Identifiable {
    var id = UUID()
    let shortName: String
    
    var timeSpent: TimeInterval
    var correctAnswers: Int
    var wrongAnswers: Int
    var questionAttempts: [UUID: Int] // Mapping question ID to the number of attempts
    var questionStats: [UUID: QuestionStats] // Mapping question ID to the stats

    init(shortName: String) {
        self.shortName = shortName
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

class UserTrainingStore: ObservableObject {
    static let shared = UserTrainingStore()
    private let userDefaultsKeyPrefix = "userTrainingData_"
    
    private init() {}

    @Published var trainingData: [String: UserTrainingData] = [:]
    
    func loadTrainingData(forCourse shortName: String) -> UserTrainingData {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKeyPrefix + shortName),
           let decodedData = try? JSONDecoder().decode(UserTrainingData.self, from: data) {
            trainingData[shortName] = decodedData
            return decodedData
        } else {
            let newTrainingData = UserTrainingData(shortName: shortName)
            trainingData[shortName] = newTrainingData
            return newTrainingData
        }
    }
    
    func saveTrainingData(_ data: UserTrainingData) {
        trainingData[data.shortName] = data
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKeyPrefix + data.shortName)
        }
    }
    
    func deleteTrainingData(forCourse shortName: String) {
        trainingData.removeValue(forKey: shortName)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeyPrefix + shortName)
    }
    
    func deleteAllTrainingData() {
        trainingData.keys.forEach { shortName in
            UserDefaults.standard.removeObject(forKey: userDefaultsKeyPrefix + shortName)
        }
        trainingData.removeAll()
    }
}
