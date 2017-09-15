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

var currentScore: Int = 0

class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {
    
    var compass : MBXCompassMapView!
    var progress: Int = 0
    var markers: Array<SCNNode>?
    var monster: SCNNode?
    var monsterRange: Float = 30
    var BGMplayer: AVAudioPlayer!
    var monsterPlayer: AVAudioPlayer!
    var SFXplayer: AVAudioPlayer!
    var ATKplayer: AVAudioPlayer!
    var monsterGotWithinrange: Bool = false
    var isCloseToNote: Bool = false
    var alive: Bool = true
    var monster_timer: Timer? = nil
    var frame_timer: Timer? = nil
    var monsterInterval: Double = 141
    var tooFar: Bool = false
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        sceneView.delegate = self
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        sceneView.scene = scene
        Animations.displayNotification(message: "Find 8 keys to survive.", label: progressLabel)
        
        
        //re-initalizing game on restart
        monsterInterval = 141
        monsterRange = 20
        monsterGotWithinrange = false
        isCloseToNote = false
        alive = true
        progress = 0
        markers = Init.initMarkers(scene: scene)
        monster = Init.initMonster()
        currentScore = 0
        
        
        compass = MBXCompassMapView.initCompass(view: view)
        compass.delegate = self
        view.addSubview(compass)
        
//        AudioPlayer.playBGM()
        let path = Bundle.main.path(forResource: "bgm", ofType: "wav")!
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
        
        monster_timer = Timer()
        frame_timer = Timer()
        func frameTimer(){
            frame_timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.FrameTimer), userInfo: nil, repeats: true)
        }
        
        func monsterTimer(){
            monster_timer = Timer.scheduledTimer(timeInterval: self.monsterInterval, target: self, selector: #selector(self.monsterTimer), userInfo: nil, repeats: true)
        }
        
        frameTimer()
        monsterTimer()
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            let node = hitResults[0].node
            if node.opacity == 1 && node.name?.range(of: "noteFor") != nil {
                print(node.name!)
                let message = String(progress) + " of 8 notes collected."
                Animations.displayNotification(message: message, label: progressLabel)
                Animations.grab(node: node, sceneView: sceneView)
                progress = progress + 1
                monsterInterval = monsterInterval - 20
                
                if progress == 1 {
                    Init.toDeathScreen(finalScore: currentScore, view: self)
                }
                
                isCloseToNote = false
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
        var closestNoteDistance: Float? = 999999
        var closestNote: SCNNode? = nil
        let distanceFromCenter = Init.calculateDistanceFromStart(sceneView: sceneView)
        print(distanceFromCenter)
        print(sceneView.pointOfView!.position)
        if distanceFromCenter > 50 && !tooFar {
            tooFar = true
            self.progressLabel.text = "You are off the map."
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 1.0
            })
        }
        
        if distanceFromCenter < 50 && tooFar {
            tooFar = false
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 0.0
            })
        }
        
        
        for node in markers! {
            if sceneView.scene.rootNode.childNode(withName: node.name!, recursively: true) != nil {
                let markerDistance = Init.calculateDistance(sceneView: sceneView, node: node)
                if markerDistance < closestNoteDistance! || closestNoteDistance == nil {
                    closestNoteDistance = markerDistance
                    closestNote = node
                }
            }
        }
        
        if closestNoteDistance! < 5 && !isCloseToNote {
            isCloseToNote = true
            self.progressLabel.text = "You are close to a key"
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 1.0
            })
        }
        
        if closestNoteDistance! < 3  && isCloseToNote {
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 0.0
            }, completion: {
                (finished: Bool) -> Void in
                Init.renderNote(sceneView: self.sceneView, node: closestNote!, label: self.progressLabel)
            })
        }
        
        if closestNoteDistance! > 15 && isCloseToNote {
            isCloseToNote = false
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                self.progressLabel.alpha = 0.0
            })
        }
        
        
        
        if monster != nil {
            if(sceneView.scene.rootNode.childNode(withName: monster!.name!, recursively: true) != nil){
                let monsterDistance = Init.calculateDistance(sceneView: sceneView, node: monster!)
                //fade out monster at large distances
                if monsterDistance > 20 && monster!.opacity == 1 {
                    Animations.fadeOut(node: monster!)
                    SFXplayer.stop()
                } else if monsterDistance < 15 && monster!.opacity == 0 {
                    monsterGotWithinrange = true
                    Animations.fadeIn(node: monster!)
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
                

                if monsterDistance > 25 && monsterGotWithinrange {
                    monster?.removeFromParentNode()
                    monsterGotWithinrange = false
                }
                
                if monsterDistance < 3 {
                    let newpath = Bundle.main.path(forResource: "attack", ofType: "wav")!
                    let atkURL = URL(fileURLWithPath: newpath)
                    do {
                        monsterPlayer!.stop()
                        ATKplayer = try AVAudioPlayer(contentsOf: atkURL)
                        ATKplayer.prepareToPlay()
                        ATKplayer.play()
                    } catch let error as NSError {
                        print(error.description)
                    }
                    monster?.removeAllActions()
                    Animations.monsterAttack(sceneView: sceneView, node: monster!, score: currentScore, view: self)
                    monster_timer!.invalidate()
                    frame_timer!.invalidate()
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
