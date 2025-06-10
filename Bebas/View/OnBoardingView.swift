//
//  OnBoardingView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI

struct OnBoardingView: View {
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false

    var body: some View {
        VStack {
            Text("Bebas")
                .font(.title)
                .bold()
            
            Spacer()
            
            Image(systemName: "hand.wave")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
            Text("Selamat Datang!")
                .font(.title)
                .bold()
            Text("Mulai perjalanan belajar bahasa isyarat dengan aplikasi Bebas.")
                .multilineTextAlignment(.center)

            Spacer()
            
            Button("Mulai Belajar") {
                
            }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .semibold))
                .cornerRadius(8)
            Text("Teman-teman kita yang tuli pakai aplikasi ini loh!")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    OnBoardingView()
}
