//
//  LearnCameraView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 12/06/25.
//

import SwiftUI

struct LearnCameraView: View {
    @Environment(\.dismiss) var dismiss

    @State private var handPoints: [CGPoint] = []
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraView(handPoints: $handPoints)
                linesView
                pointsView
                
                VStack {
                    
                }
            }
            .offset(y: -350)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("List")
                        }
                    }
                }
            }
        }
    }

    private var linesView: some View {
        Path { path in
            let fingerJoints = [
                [1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12],
                [13, 14, 15, 16],
                [17, 18, 19, 20],
            ]

            let handCount = handPoints.count / 21
            for handIndex in 0..<handCount {
                let base = handIndex * 21

                for joints in fingerJoints {
                    guard joints.count > 1 else { continue }

                    if base + joints[0] < handPoints.count {
                        let firstJoint = handPoints[base + joints[0]]
                        let wristPoint = handPoints[base + 0]
                        path.move(to: wristPoint)
                        path.addLine(to: firstJoint)
                    }

                    for i in 0..<(joints.count - 1) {
                        if base + joints[i] < handPoints.count
                            && base + joints[i + 1] < handPoints.count
                        {
                            let startPoint = handPoints[base + joints[i]]
                            let endPoint = handPoints[base + joints[i + 1]]
                            path.move(to: startPoint)
                            path.addLine(to: endPoint)
                        }
                    }
                }
            }
        }
        .stroke(.white, lineWidth: 3)
    }

    private var pointsView: some View {
        ForEach(handPoints.indices, id: \.self) { index in
            let point = handPoints[index]

            Circle()
                .fill(.orange)
                .frame(width: 8)
                .position(x: point.x, y: point.y)
        }
    }

}

#Preview {
    LearnCameraView()
}
