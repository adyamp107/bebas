//
//  DashboardView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI
import AVKit
import WebKit

struct DashboardView: View {
    @State private var currentIndex: Int = 0
    private var images: [String] = ["beranda_iklan1", "beranda_iklan2", "beranda_iklan3", "beranda_iklan4"]
    private let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            VStack {
                // Header
                HStack {
                    Text("Selamat datang di")
                        .font(.title2)
                    Text("BEBAS")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                Text("Apa yang ingin kamu pelajari hari ini?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color(.systemGray))
                    .font(.subheadline)
                
                TabView(selection: $currentIndex) {
                    ForEach(0..<images.count, id: \.self) { index in
                        DashboardImage(image: images[index])
                            .tag(index)
                    }
                }
                .frame(height: 180)
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .cornerRadius(10)
                .onReceive(timer) { _ in
                    withAnimation {
                        currentIndex = (currentIndex + 1) % images.count
                    }
                }
                
                Spacer()
                    .frame(height: 24)
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Aktivitas di Bebas")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    HStack(spacing: 16) {
                        NavigationLink(destination: LearnChooseWordView()) {
                            DashboardButton(title: "Belajar", image: "beranda_belajar", color: .green)
                        }
                        NavigationLink(destination: OnBoardingView(destination: "praktik")) {
                            DashboardButton(title: "Praktik", image: "beranda_praktik", color: .blue)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        NavigationLink(destination: DictionaryView()) {
                            DashboardButton(title: "Kamus", image: "beranda_kamus", color: .orange)
                        }
                        DashboardButton(title: "Eja Kata", image: "beranda_ejakata", color: .red)
                    }
                }
            }
            .padding(24)
        }
    }
    
    func DashboardImage(image: String) -> some View {
        HStack {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
    }
    
    func DashboardButton(title: String, image: String, color: Color) -> some View {
        VStack {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 130)
            Spacer()
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.primary)
        }
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 2)
        )
    }
}

#Preview {
    DashboardView()
}
