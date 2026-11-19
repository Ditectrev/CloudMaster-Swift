import Combine
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

    /// True when both records were written for one sitting.
    ///
    /// Finishing an exam used to save from the result button, from the
    /// countdown, and again when the exam screen disappeared. Those writes
    /// share the in-memory choice ids. A retake loads the questions again and
    /// gets new ids, so it stays as its own result.
    func isSameAttempt(as other: UserExamData) -> Bool {
        guard courseName == other.courseName,
              shortName == other.shortName,
              mode == other.mode,
              questions.count == other.questions.count else {
            return false
        }

        if questions.isEmpty {
            return abs(dateTime.timeIntervalSince(other.dateTime)) < 3
        }

        for (lhs, rhs) in zip(questions, other.questions) {
            guard lhs.question == rhs.question,
                  lhs.choices.count == rhs.choices.count,
                  Set(lhs.selectedChoices) == Set(rhs.selectedChoices) else {
                return false
            }
            for (leftChoice, rightChoice) in zip(lhs.choices, rhs.choices) {
                guard leftChoice.id == rightChoice.id,
                      leftChoice.text == rightChoice.text,
                      leftChoice.isCorrect == rightChoice.isCorrect else {
                    return false
                }
            }
        }
        return true
    }

    /// Keeps one row per attempt. The earlier timestamp is the one recorded
    /// when the person finished; a later countdown write repeats that sitting.
    static func removingDuplicateAttempts(from exams: [UserExamData]) -> [UserExamData] {
        var unique: [UserExamData] = []
        for exam in exams {
            if let matchIndex = unique.firstIndex(where: { $0.isSameAttempt(as: exam) }) {
                if exam.dateTime < unique[matchIndex].dateTime {
                    unique[matchIndex] = exam
                }
                continue
            }
            unique.append(exam)
        }
        return unique
    }
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

/// One in-progress exam. The result is recorded once, and the countdown cannot
/// be started twice when the exam screen appears again.
final class ExamAttemptSession {
    private(set) var didStoreResult = false
    private var timer: Timer?

    @discardableResult
    func beginStoringResult() -> Bool {
        guard !didStoreResult else { return false }
        didStoreResult = true
        invalidateTimer()
        return true
    }

    /// Starts the countdown once. A repeated `onAppear` does not arm a second timer.
    @discardableResult
    func startCountdown(onTick: @escaping (Timer) -> Void) -> Bool {
        guard timer == nil, !didStoreResult else { return false }
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self, !self.didStoreResult else {
                timer.invalidate()
                return
            }
            onTick(timer)
        }
        self.timer = timer
        return true
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

class UserExamDataStore: ObservableObject {
    static let shared = UserExamDataStore()
    private let userDefaultsKey = "userExamData"
    private let userDefaults: UserDefaults

    @Published private(set) var exams: [UserExamData] = []

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let stored = Self.readStoredExams(from: userDefaults, key: userDefaultsKey)
        let unique = UserExamData.removingDuplicateAttempts(from: stored)
        self.exams = unique
        if unique.map(\.id) != stored.map(\.id) {
            persist()
        }
    }

    func saveExamData(_ examData: UserExamData) {
        if let matchIndex = exams.firstIndex(where: { $0.isSameAttempt(as: examData) }) {
            if examData.dateTime < exams[matchIndex].dateTime {
                exams[matchIndex] = examData
                persist()
            }
            return
        }
        exams.append(examData)
        persist()
    }

    func fetchAllExamData() -> [UserExamData] {
        UserExamData.removingDuplicateAttempts(from: Self.readStoredExams(from: userDefaults, key: userDefaultsKey))
    }

    func resetExamData() {
        exams.removeAll()
        userDefaults.removeObject(forKey: userDefaultsKey)
    }

    func deleteExam(withId id: UUID) {
        if let index = exams.firstIndex(where: { $0.id == id }) {
            exams.remove(at: index)
            persist()
        }
    }

    private func persist() {
        if let encoded = try? JSONEncoder().encode(exams) {
            userDefaults.set(encoded, forKey: userDefaultsKey)
        }
    }

    private static func readStoredExams(from userDefaults: UserDefaults, key: String) -> [UserExamData] {
        guard let savedData = userDefaults.data(forKey: key),
              let decodedData = try? JSONDecoder().decode([UserExamData].self, from: savedData) else {
            return []
        }
        return decodedData
    }
}
