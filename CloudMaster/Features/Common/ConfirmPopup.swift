import SwiftUI

struct ConfirmPopup: ViewModifier {
    @Binding var isPresented: Bool
    var title: String
    var message: String
    var confirmAction: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: .destructive(Text("Delete")) {
                        confirmAction()
                    },
                    secondaryButton: .cancel()
                )
            }
    }
}

extension View {
    func confirmPopup(isPresented: Binding<Bool>, title: String, message: String, confirmAction: @escaping () -> Void) -> some View {
        self.modifier(ConfirmPopup(isPresented: isPresented, title: title, message: message, confirmAction: confirmAction))
    }
}
