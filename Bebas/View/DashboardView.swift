//
//  DashboardView.swift
//  Bebas
//
//  Created by Adya Muhammad Prawira on 09/06/25.
//

import SwiftUI
import AVKit
import WebKit

struct VideoView: View {
    let url = URL(string: "https://pmpk.kemdikbud.go.id/sibi/SIBI/katadasar/Kopi.webm")!
    
    var body: some View {
        VideoPlayer(player: AVPlayer(url: url))
            .aspectRatio(contentMode: .fill)
            .frame(height: 300) // sesuaikan ukuran
            .clipped()
    }
}

struct WebVideoView: UIViewRepresentable {
    let videoURL: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let html = """
        <html>
        <body style="margin:0">
        <video width="100%" height="100%" autoplay loop controls>
        <source src="\(videoURL)" type="video/webm">
        Your browser does not support WebM video.
        </video>
        </body>
        </html>
        """
        uiView.loadHTMLString(html, baseURL: nil)
    }
}

struct DashboardView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                                
                Text("Apa yang ingin kamu pelajari hari ini?")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<5) { _ in
                            VStack {
//                                Image("")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fill)
//
                                WebVideoView(videoURL: "https://pmpk.kemdikbud.go.id/sibi/SIBI/katadasar/Kopi.webm")
                                    .frame(height: 300)
                            }
                            .frame(width: 280, height: 150)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    }
                }
                
                NavigationLink(destination: LearnView()) {
                    CardButton(image: "And_4", title: "Belajar", description: "Ayo belajar guuuyyyyyyyyyyyyssssss!")
                }
                
                NavigationLink(destination: PracticeView()) {
                    CardButton(image: "And_4", title: "Latihan", description: "Ayo latihan guuuyyyyyyyyyyyyssssss!")
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("BEBAAAASSSSSSS")
        }
    }
    
    func CardButton(image: String, title: String, description: String) -> some View {
        VStack {
            VStack {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(Color(.systemGray5))
            .cornerRadius(8)
            
            VStack {
                HStack {
                    Text(title)
                        .foregroundColor(.primary)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text(description)
                        .font(.footnote)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

#Preview {
    ContentView()
}
