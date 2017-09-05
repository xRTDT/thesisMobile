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

class Init {
    
    class func initMarkers(scene: SCNScene) -> Array<SCNNode> {
        var markers: Array<SCNNode> = []
        for index in 1...8 {
            //change range to make playing area bigger/smaller
            let range = 30.0
            
            let node = SCNNode()
            let cube = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.red
            cube.materials = [material]
            node.geometry = cube
            node.opacity = 0.99
            let xPos = Float((drand48() - 0.5) * range)
            let zPos = Float((drand48() - 0.5) * range)
            node.name = "Marker" + String(describing: index)
            node.position = SCNVector3Make(xPos, 0, zPos)
            scene.rootNode.addChildNode(node)
            markers.append(node)
        }
        
        return markers
    }
    
    class func initMonster(sceneView: ARSCNView, scene: SCNScene, range: Float) -> SCNNode {
        
        let current = sceneView.pointOfView!.position
        let obj = SCNScene(named: "../art.scnassets/ship.scn")
        let monster = obj?.rootNode.childNode(withName: "ship", recursively: true)!
        monster?.scale = SCNVector3Make(1, 1, 1)
        monster?.name = "Monster"
        //monster is positioned to render 360 degrees around player at radius
        let angle = Float.pi * Float(drand48()) * 2
        let positionx = current.x + (range * sin(angle))
        let positionz = current.z + (range * cos(angle))
        monster?.position = SCNVector3Make(positionx, current.y, positionz)
        
        sceneView.scene.rootNode.addChildNode(monster!)
        
        // Forces monster to be facing you at all times
        let targetNode = SCNLookAtConstraint(target: sceneView.pointOfView)
        monster?.constraints = [targetNode]
        self.initDeath(sceneView: sceneView, node: monster!)
        return monster!
    }
    
    class func initDeath(sceneView: ARSCNView, node: SCNNode) {
        let current = sceneView.pointOfView!.position
            let distance = sqrt(
                pow(current.x - node.position.x, 2) +
                pow(current.y - node.position.y, 2) +
                pow(current.z - node.position.z, 2)
            )
            if(distance < 3){
                print("you are dead")
            }
    }
    
    class func calculateDistances(sceneView: ARSCNView, markers:Array<SCNNode>) -> Bool {
        let current = sceneView.pointOfView!.position
        for node in markers {
            let distance = sqrt(
                pow(current.x - node.position.x, 2) +
                pow(current.y - node.position.y, 2) +
                pow(current.z - node.position.z, 2)
            )
            if(distance < 3){
                node.removeFromParentNode()
                print(distance)
                let name = "noteFor" + node.name!
                //fix this later
                if sceneView.scene.rootNode.childNode(withName: name, recursively: true) == nil {
                    let obj = SCNScene(named: "../art.scnassets/ship.scn")
                    let note = obj?.rootNode.childNode(withName: "ship", recursively: true)!
                    note?.scale = SCNVector3Make(1, 1, 1)
                    note?.name = name
                    note?.position = SCNVector3Make(current.x, current.y-2, current.z)
                    sceneView.scene.rootNode.addChildNode(note!)
                    return true
                }
                }
            }
        return false
        }
    }

