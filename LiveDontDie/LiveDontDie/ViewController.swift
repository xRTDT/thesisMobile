//
//  ViewController.swift
//  LiveDontDie
//
//  Created by Timothy Yoon on 8/30/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var progress: Int = 0
    var markers: Array<SCNNode>?
    var monster: SCNNode?
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        markers = Init.initMarkers(scene: scene)
        print(markers!)
        monster = Init.initMonster(sceneView: sceneView, scene: scene)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        var timer = Timer()
        
        func scheduledTimerWithTimeInterval(){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timer), userInfo: nil, repeats: true)
        }
        
        scheduledTimerWithTimeInterval()
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            let node = hitResults[0].node
            //make sure node is a note and not a marker
            node.removeFromParentNode()
            progress = progress + 1
            let message = String(progress) + " of 8 notes collected."
            animateNotification(message: message)
        }
    }
    @objc func timer(){
        let close = Init.calculateDistances(sceneView: sceneView, markers: markers!)
        if close {
            animateNotification(message: "A note has appeared")
        }
    }
    
    func animateNotification(message: String) {
        self.progressLabel.text = message
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.progressLabel.alpha = 1.0
        }, completion: {
            (finished: Bool) -> Void in
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
                self.progressLabel.alpha = 0.0
            })
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
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
}
