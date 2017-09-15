//
//  Inits.swift
//  LiveDontDie
//
//  Created by Timothy Yoon on 8/30/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import Foundation
import SceneKit
import ARKit
import Firebase

var highScoreVal: Int = 0;

class Init {
    
    class func initMarkers(scene: SCNScene) -> Array<SCNNode> {
        var markers: Array<SCNNode> = []
        for index in 1...8 {
            let range = 100.0
            let node = SCNNode()
            let cube = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            cube.materials = [material]
            node.geometry = cube
            node.opacity = 0
            let xPos = Float((drand48() - 0.5) * range)
            let zPos = Float((drand48() - 0.5) * range)
            node.name = "Marker" + String(describing: index)
            node.position = SCNVector3Make(xPos, 0, zPos)
            scene.rootNode.addChildNode(node)
            markers.append(node)
        }
        return markers
    }
    
    class func initMonster() -> SCNNode {
        let obj = SCNScene(named: "../art.scnassets/resizedMonster.scn")
        let monster = obj?.rootNode.childNode(withName: "creepygirl1", recursively: true)!
        monster?.name = "Monster"
        monster?.opacity = 0.0
        monster?.scale = SCNVector3Make(0.1, 0.1, 0.1)
        for node in (monster?.childNodes)! {
            print(node)
            node.scale = SCNVector3Make(0.1, 0.1,0.1)
        }
        return monster!
    }
    
    class func renderMonster(sceneView: ARSCNView, range: Float, monster: SCNNode) {
        let current = sceneView.pointOfView!.position
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand48(Int(time))
        let angle = Float.pi * Float(drand48() * 2)
        let positionx = current.x + (range * sin(angle))
        let positionz = current.z + (range * cos(angle))
        monster.position = SCNVector3Make(positionx, current.y - 1.618, positionz)
        sceneView.scene.rootNode.addChildNode(monster)
        let target = SCNBillboardConstraint()
        monster.constraints = [target]
    }

    class func calculateDistance(sceneView: ARSCNView, node:SCNNode) -> Float {
        let current = sceneView.pointOfView!.position
            let distance = sqrt(
                pow(current.x - node.position.x, 2) +
                pow(current.y - node.position.y, 2) +
                pow(current.z - node.position.z, 2)
            )
        return distance
                }
    
    class func calculateDistanceFromStart(sceneView: ARSCNView) -> Float {
        let current = sceneView.pointOfView!.position
        let distance = sqrt(
            pow(current.x, 2) +
                pow(current.z, 2)
        )
        return distance
    }
    
    class func renderNote(sceneView: ARSCNView, node: SCNNode, label: UILabel) {
            node.removeFromParentNode()
            let current = sceneView.pointOfView!.position
            let name = "noteFor" + node.name!
            if sceneView.scene.rootNode.childNode(withName: name, recursively: true) == nil {
                let obj = SCNScene(named: "../art.scnassets/resizedKey2.scn")
                let note = obj?.rootNode.childNode(withName: "Key_01", recursively: true)!
                note?.name = name
                note?.position = SCNVector3Make(current.x, current.y-1.5, current.z)
                note?.opacity = 0
                sceneView.scene.rootNode.addChildNode(note!)
                Animations.fadeIn(node: note!)
                Animations.displayNotification(message: "A key has appeared.", label: label)
            }
    }
    
    class func calculateScore(score: Int, currentProgress: Int) -> Int{
        var currentScore = score
        var levelArray: [Int] = [2, 4, 8, 16, 32, 64, 128, 256];
        
        currentScore = currentScore + levelArray[currentProgress]        
        
        return currentScore
    }
    
    class func toDeathScreen(finalScore: Int, view: UIViewController) {
        let usersDB = FIRDatabase.database().reference().child("Users")
        let userID = FIRAuth.auth()?.currentUser?.uid
        usersDB.child(userID!).child("HighScore").observe(FIRDataEventType.value, with: {(snapshot) in
            highScoreVal = snapshot.value as! Int
            print("final score is \(finalScore)")
            print("highScoreVal is \(highScoreVal)")
            if finalScore > highScoreVal {
                highScoreVal = finalScore
                usersDB.child(userID!).child("HighScore").setValue(finalScore) {
                    (error, ref) in
                    if error != nil {
                        print(error!)
                    } else {
                        print("score sent to DB")
                    }
                }
            }
            view.performSegue(withIdentifier: "toDeath", sender: view)
        })
    }

}

