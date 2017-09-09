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
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {
    
    var currentScore: Int = 0
    var compass : MBXCompassMapView!
    var progress: Int = 0
    var markers: Array<SCNNode>?
    var monster: SCNNode?
    var monsterRange: Float = 50
    var BGMplayer: AVAudioPlayer!
    var monsterPlayer: AVAudioPlayer!
    var SFXplayer: AVAudioPlayer!
    var monsterGotWithinrange: Bool = false
    var isCloseToNote: Bool = false
    
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
        
//        AudioPlayer.playBGM()
        let path = Bundle.main.path(forResource: "bgm", ofType: "WAV")!
        let bgmURL = URL(fileURLWithPath: path)
        do {
            BGMplayer = try AVAudioPlayer(contentsOf: bgmURL)
            BGMplayer.numberOfLoops = -1
            BGMplayer.prepareToPlay()
            BGMplayer.play()
        } catch let error as NSError {
            print(error.description)
        }
        
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
            if node.opacity == 1 {
                progress = progress + 1
                let message = String(progress) + " of 8 notes collected."
                Animations.displayNotification(message: message, label: progressLabel)
                Animations.grab(node: node, sceneView: sceneView)
                let path = Bundle.main.path(forResource: "pickup", ofType: "wav")!
                let sfxURL = URL(fileURLWithPath: path)
                do {
                    SFXplayer = try AVAudioPlayer(contentsOf: sfxURL)
                    SFXplayer.prepareToPlay()
                    SFXplayer.play()
                } catch let error as NSError {
                    print(error.description)
                }
            }
        }
    }
    
    @objc func FrameTimer(){
        var closestNote: Float?
        
        for node in markers! {
            let markerDistance = Init.calculateDistance(sceneView: sceneView, node: node)
            if markerDistance < closestNote! || closestNote == nil {
                closestNote = markerDistance
            }
        }
        
        if closestNote! < 15 && !isCloseToNote {
            isCloseToNote = true
            self.progressLabel.text = "You are close to a key"
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 1.0
            })
        }
        
        if closestNote! < 5 {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                Animations.displayNotification(message: "A key has appeared", label: self.progressLabel)
            })
        }
        
        if closestNote! > 15 && isCloseToNote {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 0.0
            })
        }
        
        
        
        if monster != nil {
            if(sceneView.scene.rootNode.childNode(withName: monster!.name!, recursively: true) != nil){
                let monsterDistance = Init.calculateDistance(sceneView: sceneView, node: monster!)
                //fade out monster at large distances
                if monsterDistance > 45 && monster!.opacity == 1 {
                    Animations.fadeOut(node: monster!)
                    SFXplayer.stop()
                } else if monsterDistance < 30 && monster!.opacity == 0 {
                    monsterGotWithinrange = true
                    Animations.fadeIn(node: monster!)
                    print("monster has faded in")
                    let path = Bundle.main.path(forResource: "monsterClose", ofType: "wav")!
                    let sfxURL = URL(fileURLWithPath: path)
                    do {
                        monsterPlayer = try AVAudioPlayer(contentsOf: sfxURL)
                        monsterPlayer.prepareToPlay()
                        monsterPlayer.numberOfLoops = -1
                        monsterPlayer.play()
                    } catch let error as NSError {
                        print(error.description)
                    }
                    
                }
                

                if monsterDistance > 50 && monsterGotWithinrange {
                    print("monster unrendered")
                    monster?.removeFromParentNode()
                    monsterGotWithinrange = false
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
