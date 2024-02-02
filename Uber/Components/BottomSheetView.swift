//
//  BottomSheetView.swift
//  Uber
//
//  Created by Игорь Михайлов on 11.01.2024.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    
    let backgroundColor: Color
    let offsets: [Double]
    @Binding var currentOffset: Double
    @ViewBuilder let content: Content
    @State private var translation = 0.0
    @State private var viewHeight = 0.0
    
    var animation: Animation { .interactiveSpring(response: 0.5, dampingFraction: 0.7) }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(.bottom, 40)
        .background(backgroundColor)
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { viewHeight = geo.size.height }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
        .background(alignment: .bottom) {
            backgroundColor
                .frame(height: 1000)
                .offset(y: 975)
        }
        .offset(y: translation + currentOffset * viewHeight)
        .gesture(
            DragGesture()
                .onChanged { value in
                    translation = value.translation.height
                }
                .onEnded { value in
                    let offset = (value.predictedEndTranslation.height / viewHeight) + currentOffset
                    
                    currentOffset = offsets.min(by: { prev, cur in abs(prev-offset) < abs(cur-offset) })!
                    
                    withAnimation(animation) {
                        translation = 0
                    }
                }
        )
        .onAppear { currentOffset = 0 }
        .animation(animation, value: currentOffset)
        .transition(.move(edge: .bottom))
    }
}

struct PreviewBottomSheetView: View {
    @State private var currentOffset = 0.0
    let offsets: [Double] = [0, 0.8]
    
    var body: some View {
        VStack(spacing: 0) {
//            Button {
//                currentOffset = currentOffset == offsets[0] ? offsets[1] : offsets[0]
//            } label: {
//                Text("Text")
//            }
//            .padding(.top, 50)
            Spacer()
            BottomSheetView(backgroundColor: Color(.systemGray6), offsets: offsets, currentOffset: $currentOffset) {
                TripLoadingView()
//                RideRequestView(routeInfo: MockData.routeInfo, requestTrip: { _ in })
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    PreviewBottomSheetView()
}
