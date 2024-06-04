import SwiftUI

struct SettingsView: View {
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertAction: (() -> Void)?

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Training Data Management")) {
                    Button(action: {
                        showAlertWith(title: "Delete Trainingsdata", message: "Are you sure you want to delete all training data?", action: {
                            UserTrainingStore.shared.resetTrainingData()
                        })
                    }) {
                        Text("Delete Training data")
                    }

                    Button(action: {
                        showAlertWith(title: "Delete Examhistory", message: "Are you sure you want to delete all exam data?", action: {
                            UserExamDataStore.shared.resetExamData()
                        })
                    }) {
                        Text("Delete all previous exams")
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .confirmPopup(isPresented: $showAlert, title: alertTitle, message: alertMessage, confirmAction: {
                alertAction?()
            })
            
        }
    }

    private func showAlertWith(title: String, message: String, action: @escaping () -> Void) {
        alertTitle = title
        alertMessage = message
        alertAction = action
        showAlert = true
    }
}
