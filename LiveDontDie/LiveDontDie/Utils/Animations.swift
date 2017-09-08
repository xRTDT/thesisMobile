//
//  Animations.swift
//  LiveDontDie
//
//  Created by Timothy Yoon on 9/1/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Animations {
    class func displayNotification(message: String, label: UILabel) {
        label.text = message
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            label.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
                label.alpha = 0.0
            })
        })
    }
    
    class func grab(node: SCNNode, sceneView: ARSCNView) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        if node.opacity == 1 {
            node.parent?.position = sceneView.pointOfView!.position
        } else {
            node.position = sceneView.pointOfView!.position
        }
        SCNTransaction.completionBlock = {
            node.removeFromParentNode()
        }
        SCNTransaction.commit()
    }
    
    class func fadeIn(node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        node.opacity = 1.0
        SCNTransaction.commit()
    }
    
    class func fadeOut(node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        node.opacity = 0.0
        SCNTransaction.commit()
    }
    
    class func moveMonster(sceneView: ARSCNView, node: SCNNode) {
        let currentPosition = sceneView.pointOfView!.position
        let theta = atan2(currentPosition.z - node.position.z, currentPosition.x - node.position.x)
        let newX = node.position.x + (1.7/60 * cos(theta))
        let newZ = node.position.z + (1.7/60 * sin(theta))
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1/60
        node.position = SCNVector3Make(newX, node.position.y, newZ)
        SCNTransaction.commit()
    }
    
    class func monsterAttack(sceneView: ARSCNView, node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        node.position = sceneView.pointOfView!.position
        SCNTransaction.commit()
    }

}
