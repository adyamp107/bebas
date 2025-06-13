import SwiftUI

// MARK: - Card Model
struct Card: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let color: Color
    let rotation: Double
    var description: String
    var isFlipped: Bool = false

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}

struct DictionaryView: View {
    @State private var cards: [Card] = DictionaryView.generateCards()
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                ZStack {
                    ForEach(Array(cards.enumerated()), id: \.1.id) { index, _ in
                        if abs(index - currentIndex) <= 2 {
                            CardView(card: $cards[index])
                                .offset(offsetForCard(at: index))
                                .rotationEffect(.degrees(rotationForCard(at: index)))
                                .scaleEffect(scaleForCard(at: index))
                                .opacity(opacityForCard(at: index))
                                .zIndex(Double(100 - abs(index - currentIndex)))
                        }
                    }
                }
                .frame(height: 420)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            dragOffset = gesture.translation
                        }
                        .onEnded { _ in
                            let threshold: CGFloat = 100
                            if dragOffset.width < -threshold {
                                showNext()
                            } else if dragOffset.width > threshold {
                                showPrevious()
                            } else {
                                withAnimation {
                                    dragOffset = .zero
                                }
                            }
                        }
                )
                .animation(.spring(), value: dragOffset)

                Spacer()

                Button("Ulangi") {
                    withAnimation {
                        cards = DictionaryView.generateCards()
                        currentIndex = 0
                        dragOffset = .zero
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()

                Text("Kartu \(currentIndex + 1)/\(cards.count)")
                    .foregroundColor(.gray)

                Spacer()
            }
            .padding()
            .navigationTitle("Kamus")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func showNext() {
        if currentIndex < cards.count - 1 {
            withAnimation(.spring()) {
                currentIndex += 1
                dragOffset = .zero
            }
        } else {
            withAnimation {
                dragOffset = .zero
            }
        }
    }

    func showPrevious() {
        if currentIndex > 0 {
            withAnimation(.spring()) {
                currentIndex -= 1
                dragOffset = .zero
            }
        } else {
            withAnimation {
                dragOffset = .zero
            }
        }
    }

    func offsetForCard(at index: Int) -> CGSize {
        if index == currentIndex {
            return dragOffset
        } else {
            let dx = CGFloat(index - currentIndex) * 20
            return CGSize(width: dx, height: CGFloat(abs(index - currentIndex)) * 10)
        }
    }

    func rotationForCard(at index: Int) -> Double {
        if index == currentIndex {
            return Double(dragOffset.width / 20)
        } else {
            return cards[index].rotation
        }
    }

    func scaleForCard(at index: Int) -> CGFloat {
        index == currentIndex ? 1.0 : 0.95
    }

    func opacityForCard(at index: Int) -> Double {
        abs(index - currentIndex) > 2 ? 0 : 1
    }

    static func generateCards() -> [Card] {
        let symbols = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        return symbols.enumerated().map { (i, c) in
            Card(
                value: String(c),
                color: Color(hue: Double(i) / 26.0, saturation: 0.8, brightness: 0.9),
                rotation: Double.random(in: -8...8),
                description: "This is the explanation for the letter \(c)."
            )
        }
    }
}

struct CardView: View {
    @Binding var card: Card
    @State private var rotationDegrees: Double = 0

    var body: some View {
        ZStack {
            frontView
                .opacity(rotationDegrees.truncatingRemainder(dividingBy: 360) < 90 || rotationDegrees.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)

            backView
                .opacity(rotationDegrees.truncatingRemainder(dividingBy: 360) >= 90 && rotationDegrees.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 250, height: 350)
        .rotation3DEffect(.degrees(rotationDegrees), axis: (x: 0, y: 1, z: 0))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.6)) {
                rotationDegrees += 180
                card.isFlipped.toggle()
            }
        }
    }

    var frontView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(card.color)
                .shadow(radius: 10)

            Text(card.value)
                .font(.system(size: 100, weight: .bold))
                .foregroundColor(.white)
        }
    }

    var backView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(card.color.opacity(0.85))
                .shadow(radius: 10)

            Text(card.description)
                .font(.title3)
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(.white)
        }
    }
}


#Preview {
    DictionaryView()
}
