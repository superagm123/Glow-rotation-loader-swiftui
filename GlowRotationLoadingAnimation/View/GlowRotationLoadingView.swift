//
//  GlowRotationLoadingView.swift
//  GlowRotationLoadingAnimation
//
//  Created by Alfonso Gonzalez Miramontes on 09/07/25.
//
import SwiftUI

struct GlowRotationLoadingView: View {
    let dim: CGFloat
    let numOfRings: Int
    let color: Color
    let radius: CGFloat
    
    init(
        dim: CGFloat = 25,
        numOfRings: Int = 8,
        color: Color = .cyan,
        radius: CGFloat = 50
    ) {
        self.dim = dim
        self.numOfRings = numOfRings
        self.color = color
        self.radius = radius
    }
    
    @State private var rotationAngle: Double = 0
    @State private var currentIndex: Int? = nil
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            FixedRings()

            Circle()
                .fill(.green.gradient)
                .frame(width: dim, height: dim)
                .offset(x: radius)
                .rotationEffect(.degrees(rotationAngle))
                .shadow(radius: 1)
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    @ViewBuilder
    private func FixedRings() -> some View {
        ForEach(0..<numOfRings, id: \.self) { index in
            let angle = 2 * .pi * Double(index) / Double(numOfRings)
            let x = radius * cos(angle)
            let y = radius * sin(angle)
            
            Circle()
                .fill(currentIndex == index ? Color.green.gradient : color.gradient)
                .frame(width: dim, height: dim)
                .opacity(0.7)
                .offset(x: x, y: y)
                .shadow(radius: 1)
                .scaleEffect(currentIndex == index ? 1.10 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: currentIndex)
        }
    }
    
    private func startAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        let animationDuration = 2.0
        let steps = 120
        let stepAngle = 360.0 / Double(steps)
        let stepDuration = animationDuration / Double(steps)

        func animateStep(step: Int) {
            guard isAnimating else { return }
            
            withAnimation(.linear(duration: stepDuration)) {
                rotationAngle += stepAngle
                if rotationAngle >= 360 { rotationAngle = 0 }
                
                let currentAngle = rotationAngle * .pi / 180
                let closestIndex = Int(round(currentAngle / (2 * .pi / Double(numOfRings)))) % numOfRings
                currentIndex = closestIndex
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * 0.5) {
                currentIndex = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration) {
                animateStep(step: (step + 1) % steps)
            }
        }

        animateStep(step: 0)
    }
}
#Preview {
    GlowRotationLoadingView()
}
