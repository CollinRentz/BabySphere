//
//  ContentView.swift
//  BabySphere
//
//  Created by Collin Rentz on 2/15/24.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @State private var color: Color = .blue
    @State private var rotation: SCNVector4 = SCNVector4(0, 1, 0, 0)
    @State private var lastRotation: Float = 0 // Track the last rotation

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(gradient: Gradient(colors: [self.color, .black]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("BabySphere")
                        .font(.custom("Chalkduster", size: 46))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    SphereView(color: $color, rotation: $rotation)
                        .frame(width: geometry.size.width, height: geometry.size.width)
                    
                    Spacer()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        handleGesture(value: value, in: geometry.size)
                    }
                    .onEnded { value in
                        // Update lastRotation when the gesture ends
                        lastRotation += Float(value.translation.width / geometry.size.width) * Float.pi * 2
                    }
            )
        }
    }

    private let hueSensitivity: CGFloat = 0.005
    private let saturationSensitivity: CGFloat = 0.025

    private func handleGesture(value: DragGesture.Value, in size: CGSize) {
        let width = size.width
        let height = size.height
        
        // Adjust hue for left/right swipes
        let hueAdjustment = Double(value.translation.width / width) * Double(hueSensitivity)
        // Adjust saturation for up/down swipes
        let saturationAdjustment = Double(value.translation.height / height) * Double(saturationSensitivity)
        
        color.hueSaturationBrightnessAdjust(hueAdjustment: hueAdjustment, saturationAdjustment: -saturationAdjustment)
        
        // Calculate rotation based on swipe and add to lastRotation
        let rotationDelta = Float(value.translation.width / width) * Float.pi * 2
        rotation = SCNVector4(0, 1, 0, lastRotation + rotationDelta)
    }
}

// Extension for convenient color adjustments
extension Color {
    mutating func hueSaturationBrightnessAdjust(hueAdjustment: Double = 0, saturationAdjustment: Double = 0, brightnessAdjustment: Double = 0) {
        let hsba = self.hsba
        self = Color(hue: hsba.hue + hueAdjustment, saturation: min(max(hsba.saturation + saturationAdjustment, 0), 1), brightness: hsba.brightness)
    }

    var hsba: (hue: Double, saturation: Double, brightness: Double, alpha: Double) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (Double(hue), Double(saturation), Double(brightness), Double(alpha))
    }
}
