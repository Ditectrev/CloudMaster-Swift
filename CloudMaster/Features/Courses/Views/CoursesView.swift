import SwiftUI

struct CoursesView: View {
    @Binding var favorites: Set<Course>
    @State private var searchText = ""
    @StateObject private var viewModel = DownloadViewModel()
    @State private var alertMessage: String?

    var body: some View {
        VStack {
            AllCourses(favorites: $favorites)
        }
        .navigationBarTitle("All Courses", displayMode: .inline)
        .navigationBarItems(trailing: updateButton)
        .overlay(
            DownloadOverlayView(
                isShowing: $viewModel.isDownloading,
                viewModel: viewModel
            )
        )
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Download Error"), message: Text(viewModel.alertMessage ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    private var updateButton: some View {
        Button(action: {
            viewModel.downloadCourses(favorites)
        }) {
            Image(systemName: "arrow.down.circle")
                .foregroundColor(viewModel.isDownloading ? .gray : .accentColor) // Change color based on state (optional)
        }
        .disabled(viewModel.isDownloading)
    }
}
