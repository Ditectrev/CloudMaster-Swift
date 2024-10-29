import SwiftUI

struct DownloadOverlayView: View {
    @Binding var isShowing: Bool
    @StateObject var viewModel: DownloadViewModel
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("\(viewModel.completedDownloads) / \(Int(viewModel.totalCourses)) courses")
                        .font(.title2)
                        .foregroundColor(.white)
        
                    CircularProgressView(progress: $viewModel.overallProgress)
                        .frame(width: 250, height: 250)
                        .shadow(radius: 10)
                    
                    Text(viewModel.statusMessage)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                }
            }
        }
    }
    
    struct CircularProgressView: View {
        @Binding var progress: Double
        
        var body: some View {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10.0)
                    .opacity(0.5)
                    .foregroundColor(Color.customSecondary)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.customAccent)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                if progress < 1.0 {
                    Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.white)
                } else {
                    withAnimation(.spring()) {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .foregroundColor(Color.correct)
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .padding(40)
        }
    }
}
