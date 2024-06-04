import SwiftUI

struct QuestionNavbar: View {
    @Environment(\.presentationMode) var presentationMode
    let currentQuestionIndex: Int
    let totalQuestions: Int
    
    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Text("\(currentQuestionIndex + 1) of \(totalQuestions)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
