//
//  Dice.swift
//  ARD&DRoller
//
//  Created by Ken Maready on 8/13/22.
//

import Foundation
import SceneKit
import ARKit

class Dice {
    var node: SCNNode?
    
    init(at location: ARRaycastResult) {
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        node = diceScene.rootNode.childNode(withName: "Dice", recursively: true) ?? nil
        
        if node != nil {
            node?.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + (node?.boundingSphere.radius)!,
                z: location.worldTransform.columns.3.z)
        }
    }
    
    func roll() {
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi / 2)
        
        node?.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 3),
            y: 0.0,
            z: CGFloat(randomZ * 3),
            duration: 0.7)
        )
    }
}
