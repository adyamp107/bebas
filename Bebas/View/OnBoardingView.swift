import SwiftUI

struct OnBoardingView: View {
    @Environment(\.dismiss) var dismiss

    @State var destination: String
    @State private var currentOnBoardingIndex: Int = 0

    let onboardingData: [(image: String, direction: String, description: String)] = [
        ("orientasi0", "Pastikan jaraknya aman (duduk)", "Jarak yang aman kurang lebih 1 meter dengan syarat area pinggang ke atas dan bentangan tangan terlihat"),
        ("orientasi1", "Pastikan jaraknya aman (berdiri)", "Jarak yang aman kurang lebih 1 meter dengan syarat area pinggang ke atas dan bentangan tangan terlihat"),
        ("orientasi2", "Pastikan pencahayaan cukup terang", "Pencahayaan dari lampu untuk yang di dalam ruangan atau setara dengan cahaya matahari di waktu siang"),
        ("orientasi3", "Gunakan pakaian berwarna kontras dari warna kulit", "Gunakan baju warna cerah untuk yang berkulit gelap dan gunakan baju berwarna gelap untuk yang berkulit cerah"),
        ("orientasi4", "Cari background yang kontras dengan warna kulit", "Background yang cerah untuk warna kulit gelap dan background gelap untuk warna kulit cerah")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 8) {
//                    Spacer()
//                    if destination == "learn" {
//                        NavigationLink(destination: LearnCameraView()) {
//                            Image(systemName: "xmark")
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 15, height: 15)
//                                .bold()
//                                .foregroundColor(.primary)
//                        }
//                    } else {
//                        NavigationLink(destination: PracticeCameraView()) {
//                            Image(systemName: "xmark")
//                                .resizable()
//                                .aspectRatio(contentMode: .fill)
//                                .frame(width: 15, height: 15)
//                                .bold()
//                                .foregroundColor(.primary)
//                        }
//                    }
//                    Spacer()
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        Capsule()
                            .frame(width: 40, height: 5)
                            .foregroundColor(currentOnBoardingIndex == index ? .black : .gray.opacity(0.4))
                    }
                    
//                    Spacer()
//                    VStack {
//                        
//                    }
//                    .frame(width: 15, height: 15)
//                    Spacer()
                }
                .padding(.top)

                TabView(selection: $currentOnBoardingIndex) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        OnBoardingCameraView(
                            image: onboardingData[index].image,
                            direction: onboardingData[index].direction,
                            description: onboardingData[index].description
                        )
                        .tag(index)
                        .padding()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentOnBoardingIndex)
                
                if currentOnBoardingIndex < 4 {
                    Button(
                        action: {
                            currentOnBoardingIndex += 1
                        }, label: {
                            VStack {
                                Text("Berikutnya")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .frame(width: 250, height: 50)
                            .background(Color(hex: "#18C0A1"))
                            .cornerRadius(10)
                        }
                    )
                } else {
                    if destination == "learn" {
                        NavigationLink(destination: LearnCameraView()) {
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
                    } else {
                        NavigationLink(destination: PracticeCameraView()) {
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
                }
            }
            .padding()
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func OnBoardingCameraView(image: String, direction: String, description: String) -> some View {
        VStack(spacing: 16) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 340, height: 340)
                .clipped()
                .cornerRadius(10)
            Text(direction)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            Text(description)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
    }
    
}

#Preview {
    OnBoardingView(destination: "learn")
}

