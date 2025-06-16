//
//  LearnChoosenWordView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 16/06/25.
//

import SwiftUI

struct LearnChoosenWordView: View {
    @Environment(\.dismiss) var dismiss
    @State var word: String
    @State var image: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack {
                    Text("Cara mempraktikkan kata")
                        .font(.title2)
                    Text("\"\(word)\"")
                        .font(.title2)
                        .bold()
                }
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 340, height: 340)
                    .clipped()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                Text("Mari simak video panduan berikut sebelum kamu mulai praktik.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                Spacer()
                NavigationLink(destination: OnBoardingView(destination: "learn")) {
                    VStack {
                        Text("Mulai")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                    }
                    .frame(width: 250, height: 50)
                    .background(Color(hex: "#18C0A1"))
                    .cornerRadius(10)
                }
            }
            .padding()
            .navigationTitle("Belajar")
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    LearnChoosenWordView(word: "Saya", image: "belajar_saya")
}
