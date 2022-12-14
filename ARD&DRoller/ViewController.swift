//
//  ViewController.swift
//  ARD&DRoller
//
//  Created by Ken Maready on 8/12/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [Dice]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // can show highlight points on screen for debug purposes
//        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
    
        // random experimenting with shapes and materials:
//        let material1 = SCNMaterial()
//        material1.diffuse.contents = UIColor.systemPurple
//
//        let cube1 = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.03)
//        cube1.materials = [material1]
//
//        let node1 = SCNNode()
//        node1.position = SCNVector3(x: -0.11, y: 0.1, z: -0.5)
//        node1.geometry = cube1
//
//        sceneView.scene.rootNode.addChildNode(node1)
//
//        let material2 = SCNMaterial()
//        material2.diffuse.contents = UIColor.systemOrange
//
//        let cube2 = SCNBox(width: 0.08, height: 0.08, length: 0.08, chamferRadius: 0.02)
//        cube2.materials = [material2]
//
//        let node2 = SCNNode()
//        node2.position = SCNVector3(x: 0.01, y: 0.1, z: -0.5)
//        node2.geometry = cube2
//
//        let material3 = SCNMaterial()
//        material3.diffuse.contents = UIImage(named: "art.scnassets/sun.jpeg")
//        let sphere3 = SCNSphere(radius: 0.5)
//        sphere3.materials = [material3]
//        let node3 = SCNNode()
//        node3.position = SCNVector3(x: 0.6, y: 0.92, z: -2.66)
//        node3.geometry = sphere3
//
//        let material4 = SCNMaterial()
//        material4.diffuse.contents = UIImage(named: "art.scnassets/jupiter.jpeg")
//        let sphere4 = SCNSphere(radius: 0.3)
//        sphere4.materials = [material4]
//        let node4 = SCNNode()
//        node4.position = SCNVector3(x: -0.3, y: 0.10, z: -1.16)
//        node4.geometry = sphere4
//
//
//        sceneView.scene.rootNode.addChildNode(node2)
//        sceneView.scene.rootNode.addChildNode(node3)
//        sceneView.scene.rootNode.addChildNode(node4)
//        sceneView.autoenablesDefaultLighting = true
        
//         Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        
        // dice scene floating in space in front of user:
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: -0.01, y:-0.01, z: -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//            sceneView.autoenablesDefaultLighting = true
//        }
        
//         Set the scene to the view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    @IBAction func rollDiceButtonTapped(_ sender: UIButton) {
        rollAllDice()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAllDice()
    }
    
    @IBAction func clearDiceButtonTapped(_ sender: UIButton) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.remove()
            }
            diceArray.removeAll()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            if let query = sceneView.raycastQuery(from: touchLocation, allowing: .existingPlaneGeometry, alignment: .any) {
                let results = sceneView.session.raycast(query)
                if let hitResult = results.first {
                    let newDice = Dice(at: hitResult)
                    print("newDice created...")
                    diceArray.append(newDice)
                    if newDice.node != nil {
                        print("ading newDice.node to scene...")
                        sceneView.scene.rootNode.addChildNode(newDice.node!)
                        newDice.roll()
                    }
                }
            }
        }
    }
    
    func rollAllDice() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.roll()
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        node.addChildNode(createPlane(with: planeAnchor))
    }

    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func createPlane(with anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: anchor.center.x, y: 0.0, z: anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1.0, 0.0, 0.0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        
        return planeNode
    }
}
