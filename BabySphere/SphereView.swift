//
//  SphereView.swift
//  BabySphere
//
//  Created by Collin Rentz on 2/15/24.
//

import SwiftUI
import SceneKit

struct SphereView: UIViewRepresentable {
    @Binding var color: Color
    @Binding var rotation: SCNVector4

    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.scene = createScene()
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.backgroundColor = UIColor.clear
        scnView.pointOfView?.position = SCNVector3(x: 1, y: 1, z: 5)
        scnView.pointOfView?.look(at: SCNVector3(0, 1, 0))
        return scnView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if let sphereNode = uiView.scene?.rootNode.childNode(withName: "sphere", recursively: false) {
            sphereNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "sphereTexture.png")
            sphereNode.geometry?.firstMaterial?.emission.contents = UIColor(color).withAlphaComponent(0.5)
            sphereNode.rotation = rotation
        }
    }

    private func createScene() -> SCNScene {
        let scene = SCNScene()

        let sphereGeometry = SCNSphere(radius: 1.0)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "sphereTexture.png") // Apply texture
        // Adjust initial emission for lower brightness
        material.emission.contents = UIColor(color).withAlphaComponent(0.3) // Lower alpha for dimmer initial emission
        sphereGeometry.materials = [material]


        let sphereNode = SCNNode(geometry: sphereGeometry)
        sphereNode.name = "sphere"
        sphereNode.position = SCNVector3(x: 0, y: 1, z: 0)

        scene.rootNode.addChildNode(sphereNode)
        
        // Adjusted lighting setup
        let directionalLightNode = SCNNode()
        directionalLightNode.light = SCNLight()
        directionalLightNode.light?.type = .directional
        directionalLightNode.light?.intensity = 500 // Adjust based on desired darkness threshold
        directionalLightNode.position = SCNVector3(x: -1, y: 5, z: 2)
        directionalLightNode.eulerAngles = SCNVector3(x: 0, y: .pi / 4, z: 0)
        scene.rootNode.addChildNode(directionalLightNode)

        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.intensity = 100 // Lower for increased darkness
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Shadow
            let shadowPlane = SCNPlane(width: 3, height: 3)
            shadowPlane.firstMaterial?.diffuse.contents = UIColor.clear
            shadowPlane.firstMaterial?.lightingModel = .constant
            shadowPlane.firstMaterial?.writesToDepthBuffer = true
            shadowPlane.firstMaterial?.colorBufferWriteMask = []

            let shadowNode = SCNNode(geometry: shadowPlane)
            shadowNode.position = SCNVector3(x: 0, y: 0, z: 0)
            shadowNode.eulerAngles.x = -.pi / 2
            scene.rootNode.addChildNode(shadowNode)

        return scene
            }
        }

extension UIColor {
    func brighterColor() -> UIColor {
        return self.withAlphaComponent(min(self.cgColor.alpha + 0.3, 1.0))
    }
}
