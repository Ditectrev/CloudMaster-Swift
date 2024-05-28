//
//  DownloadView.swift
//  Cloud-Master
//
//  Created by Benedikt Wagner on 24.05.24.
//

import Foundation
import SwiftUI

struct DownloadOverlayView: View {
    @Binding var isShowing: Bool
    @Binding var progress: Double

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)

                CircularProgressView(progress: $progress)
                    .frame(width: 250, height: 250)
                    .shadow(radius: 10)
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
                .foregroundColor(Color.customPrimary)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            if progress < 1.0 {
                Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                    .font(.largeTitle)
                    .bold()
            } else {
                withAnimation(.spring()) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .foregroundColor(Color.green)
                        .frame(width: 50, height: 50)
                }
            }
        }
        .padding(40)
    }
}


