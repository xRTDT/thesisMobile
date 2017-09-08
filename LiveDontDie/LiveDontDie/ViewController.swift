//
//  ViewController.swift
//  LiveDontDie
//
//  Created by Timothy Yoon on 8/30/17.
//  Copyright © 2017 Timothy Yoon. All rights reserved.
//

import Mapbox
import UIKit
import SceneKit
import ARKit
import Mapbox

class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {
    var currentScore: Int = 0
    var compass : MBXCompassMapView!
    var progress: Int = 0
    var markers: Array<SCNNode>?
    var monster: SCNNode?
    var monsterRange: Float = 30
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        sceneView.scene = scene
        
        markers = Init.initMarkers(scene: scene)
        monster = Init.initMonster()
        
        compass = MBXCompassMapView.initCompass(view: view)
        compass.delegate = self
        view.addSubview(compass)
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        var timer = Timer()
        func frameTimer(){
            timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.FrameTimer), userInfo: nil, repeats: true)
        }
        
        func monsterTimer(){
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.monsterTimer), userInfo: nil, repeats: true)
        }
        
        frameTimer()
        monsterTimer()
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            let node = hitResults[0].node
            progress = progress + 1
            let message = String(progress) + " of 8 notes collected."
            Animations.displayNotification(message: message, label: progressLabel)
            Animations.grab(node: node, sceneView: sceneView)
        }
    }
    
    @objc func FrameTimer(){
        
        for node in markers! {
            let markerDistance = Init.calculateDistance(sceneView: sceneView, node: node)
            if markerDistance < 5 {
                Animations.displayNotification(message: "You are close to a note", label: progressLabel)
                if markerDistance < 3 {
                    Init.renderNote(sceneView: sceneView, node: node)
                }
            }
        }
        if monster != nil {
            if(sceneView.scene.rootNode.childNode(withName: monster!.name!, recursively: true) != nil){
                let monsterDistance = Init.calculateDistance(sceneView: sceneView, node: monster!)
                //fade out monster at large distances
                if monsterDistance > 30 && monster!.opacity == 1 {
                    Animations.fadeOut(node: monster!)
                } else if monsterDistance < 30 && monster!.opacity == 0 {
                    Animations.fadeIn(node: monster!)
                }
                
                //remove monster from game is player is too far from monster
                if monsterDistance > 35 {
                    monster?.removeFromParentNode()
                }
                
                if monsterDistance < 3 {
                    monster?.removeAllActions()
                    Animations.monsterAttack(sceneView: sceneView, node: monster!)
                } else {
                    Animations.moveMonster(sceneView: sceneView, node: monster!)
                }
            }
        }
       currentScore = Init.calculateScore(score: currentScore, currentProgress: progress)
    }
    
    @objc func monsterTimer(){
        monsterRange = monsterRange - 1
        if monster == nil || sceneView.scene.rootNode.childNode(withName: monster!.name!, recursively: true) == nil {
            Init.renderMonster(sceneView: sceneView, range: monsterRange, monster: monster!)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
