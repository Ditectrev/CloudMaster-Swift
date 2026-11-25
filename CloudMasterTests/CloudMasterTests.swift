//
//  CloudMasterTests.swift
//  CloudMasterTests
//

import XCTest
@testable import CloudMaster

final class UserExamDataStoreTests: XCTestCase {
    private var suiteName = ""
    private var defaults: UserDefaults!
    private var store: UserExamDataStore!

    override func setUpWithError() throws {
        suiteName = "CloudMasterTests.UserExamData.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        store = UserExamDataStore(userDefaults: defaults)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        store = nil
        defaults = nil
    }

    func testSavingTheSameAttemptTwiceKeepsTheFinishTime() throws {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let finished = makeAttempt(started: started, timeSpent: 40, choiceID: UUID())
        let countdownDuplicate = UserExamData(
            id: UUID(),
            courseName: finished.courseName,
            shortName: finished.shortName,
            dateTime: started.addingTimeInterval(1_800),
            questions: finished.questions,
            timeSpent: 1_800,
            isPassed: finished.isPassed,
            mode: finished.mode
        )

        store.saveExamData(finished)
        store.saveExamData(countdownDuplicate)

        XCTAssertEqual(store.exams.count, 1)
        XCTAssertEqual(store.exams[0].id, finished.id)
        XCTAssertEqual(store.exams[0].timeSpent, 40)

        let reloaded = UserExamDataStore(userDefaults: defaults)
        XCTAssertEqual(reloaded.exams.count, 1)
        XCTAssertEqual(reloaded.exams[0].id, finished.id)
    }

    func testRetakeWithNewQuestionIdsIsKept() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let first = makeAttempt(started: started, timeSpent: 40, choiceID: UUID())
        let retake = makeAttempt(started: started.addingTimeInterval(3_600), timeSpent: 55, choiceID: UUID())

        store.saveExamData(first)
        store.saveExamData(retake)

        XCTAssertEqual(store.exams.map(\.id), [first.id, retake.id])
    }

    func testSameQuestionsWithDifferentAnswersStaySeparate() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let choiceA = UUID()
        let choiceB = UUID()
        let first = makeAttempt(
            started: started,
            timeSpent: 40,
            choiceID: choiceA,
            selectedChoiceID: choiceA,
            extraChoiceID: choiceB
        )
        let second = makeAttempt(
            started: started,
            timeSpent: 41,
            choiceID: choiceA,
            selectedChoiceID: choiceB,
            extraChoiceID: choiceB
        )

        store.saveExamData(first)
        store.saveExamData(second)

        XCTAssertEqual(store.exams.count, 2)
    }

    func testEmptyExamsCollapseOnlyWhenSavedTogether() {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let first = emptyExam(at: now)
        let immediateDuplicate = emptyExam(at: now.addingTimeInterval(1))
        let laterVisit = emptyExam(at: now.addingTimeInterval(30))

        store.saveExamData(first)
        store.saveExamData(immediateDuplicate)
        store.saveExamData(laterVisit)

        XCTAssertEqual(store.exams.map(\.id), [first.id, laterVisit.id])
    }

    func testUnansweredRetakesStaySeparate() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let first = makeAttempt(started: started, timeSpent: 5, choiceID: UUID(), selectedChoiceID: nil, selectNothing: true)
        let second = makeAttempt(
            started: started.addingTimeInterval(120),
            timeSpent: 5,
            choiceID: UUID(),
            selectedChoiceID: nil,
            selectNothing: true
        )

        store.saveExamData(first)
        store.saveExamData(second)

        XCTAssertEqual(store.exams.count, 2)
    }

    func testSelectedChoiceOrderDoesNotCreateAnotherResult() {
        let choiceA = UUID()
        let choiceB = UUID()
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let first = makeMultiSelectAttempt(started: started, timeSpent: 30, selected: [choiceA, choiceB], choiceA: choiceA, choiceB: choiceB)
        let reordered = makeMultiSelectAttempt(
            started: started,
            timeSpent: 1_200,
            selected: [choiceB, choiceA],
            choiceA: choiceA,
            choiceB: choiceB,
            dateOffset: 1_200
        )

        store.saveExamData(first)
        store.saveExamData(reordered)

        XCTAssertEqual(store.exams.count, 1)
        XCTAssertEqual(store.exams[0].timeSpent, 30)
    }

    func testDifferentModeIsADifferentResult() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let choiceID = UUID()
        let quick = makeAttempt(started: started, timeSpent: 40, choiceID: choiceID, mode: "Quick")
        let real = makeAttempt(started: started, timeSpent: 40, choiceID: choiceID, mode: "Real")

        store.saveExamData(quick)
        store.saveExamData(real)

        XCTAssertEqual(store.exams.count, 2)
    }

    func testLaunchDropsStoredDuplicateAttempts() throws {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let finished = makeAttempt(started: started, timeSpent: 40, choiceID: UUID())
        let duplicate = UserExamData(
            id: UUID(),
            courseName: finished.courseName,
            shortName: finished.shortName,
            dateTime: finished.dateTime.addingTimeInterval(1),
            questions: finished.questions,
            timeSpent: finished.timeSpent,
            isPassed: finished.isPassed,
            mode: finished.mode
        )
        let stored = try JSONEncoder().encode([finished, duplicate])
        defaults.set(stored, forKey: "userExamData")

        let loaded = UserExamDataStore(userDefaults: defaults)

        XCTAssertEqual(loaded.exams.map(\.id), [finished.id])

        let savedAgain = try XCTUnwrap(defaults.data(forKey: "userExamData"))
        let persisted = try JSONDecoder().decode([UserExamData].self, from: savedAgain)
        XCTAssertEqual(persisted.map(\.id), [finished.id])
    }

    func testLaterDuplicateDoesNotReplaceTheEarlierResultWhenItIsSavedFirst() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let choiceID = UUID()
        let finished = makeAttempt(started: started, timeSpent: 40, choiceID: choiceID)
        let countdownDuplicate = UserExamData(
            id: UUID(),
            courseName: finished.courseName,
            shortName: finished.shortName,
            dateTime: started.addingTimeInterval(1_800),
            questions: finished.questions,
            timeSpent: 1_800,
            isPassed: finished.isPassed,
            mode: finished.mode
        )

        store.saveExamData(countdownDuplicate)
        store.saveExamData(finished)

        XCTAssertEqual(store.exams.map(\.id), [finished.id])
        XCTAssertEqual(store.exams[0].timeSpent, 40)
    }

    func testDeleteExamRemovesOnlyThatResult() {
        let started = Date(timeIntervalSince1970: 1_700_000_000)
        let first = makeAttempt(started: started, timeSpent: 40, choiceID: UUID())
        let second = makeAttempt(started: started.addingTimeInterval(7_200), timeSpent: 50, choiceID: UUID())
        store.saveExamData(first)
        store.saveExamData(second)

        store.deleteExam(withId: first.id)

        XCTAssertEqual(store.exams.map(\.id), [second.id])
    }

    func testReturnToMainMenuReplacesTheHomeNavigationIdentity() {
        let navigation = MainMenuNavigation()
        let original = navigation.resetID

        navigation.returnToMainMenu()
        XCTAssertNotEqual(navigation.resetID, original)

        let afterFirstReturn = navigation.resetID
        navigation.returnToMainMenu()
        XCTAssertNotEqual(navigation.resetID, afterFirstReturn)
    }

    func testAttemptSessionRecordsOnceAndStartsOneCountdown() {
        let session = ExamAttemptSession()
        var ticks = 0

        XCTAssertTrue(session.startCountdown { _ in ticks += 1 })
        XCTAssertFalse(session.startCountdown { _ in ticks += 1 })
        XCTAssertTrue(session.beginStoringResult())
        XCTAssertFalse(session.beginStoringResult())
        XCTAssertTrue(session.didStoreResult)
        XCTAssertEqual(ticks, 0)

        session.invalidateTimer()
    }

    private func emptyExam(at date: Date) -> UserExamData {
        UserExamData(
            courseName: "Certified Cloud Practitioner",
            shortName: "CLF-C02",
            dateTime: date,
            questions: [],
            timeSpent: 0,
            isPassed: false,
            mode: "Quick"
        )
    }

    private func makeAttempt(
        started: Date,
        timeSpent: Int,
        choiceID: UUID,
        selectedChoiceID: UUID? = nil,
        extraChoiceID: UUID? = nil,
        mode: String = "Quick",
        selectNothing: Bool = false
    ) -> UserExamData {
        let selected = selectedChoiceID ?? choiceID
        let choices = [
            ExamChoiceData(id: choiceID, text: "A", isCorrect: true),
            ExamChoiceData(id: extraChoiceID ?? UUID(), text: "B", isCorrect: false)
        ]
        let question = ExamQuestionData(
            question: "What is AWS?",
            choices: choices,
            selectedChoices: selectNothing ? [] : [selected]
        )
        return UserExamData(
            courseName: "Certified Cloud Practitioner",
            shortName: "CLF-C02",
            dateTime: started.addingTimeInterval(TimeInterval(timeSpent)),
            questions: [question],
            timeSpent: timeSpent,
            isPassed: true,
            mode: mode
        )
    }

    private func makeMultiSelectAttempt(
        started: Date,
        timeSpent: Int,
        selected: [UUID],
        choiceA: UUID,
        choiceB: UUID,
        dateOffset: TimeInterval? = nil
    ) -> UserExamData {
        let question = ExamQuestionData(
            question: "Pick two",
            choices: [
                ExamChoiceData(id: choiceA, text: "A", isCorrect: true),
                ExamChoiceData(id: choiceB, text: "B", isCorrect: true)
            ],
            selectedChoices: selected
        )
        return UserExamData(
            courseName: "Certified Cloud Practitioner",
            shortName: "CLF-C02",
            dateTime: started.addingTimeInterval(dateOffset ?? TimeInterval(timeSpent)),
            questions: [question],
            timeSpent: timeSpent,
            isPassed: true,
            mode: "Quick"
        )
    }
}
