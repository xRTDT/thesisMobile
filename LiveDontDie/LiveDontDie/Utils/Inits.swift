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
            let obj = SCNScene(named: "../art.scnassets/ship.scn")
            let node = obj?.rootNode.childNode(withName: "ship", recursively: true)!
            node?.scale = SCNVector3Make(1, 1, 1)
            let xRand = drand48() - 0.5
            let zRand = drand48() - 0.5
            
            //change range to make playing area bigger/smaller
            let range = 30
            
            let xPos = Float(xRand * range)
            let zPos = Float(zRand * range)
            node?.name = "Marker" + String(describing: index)
            node?.position = SCNVector3Make(xPos, 0, zPos)
            scene.rootNode.addChildNode(node!)
            markers.append(node!)
        }
        
        return markers
    }
    
}
