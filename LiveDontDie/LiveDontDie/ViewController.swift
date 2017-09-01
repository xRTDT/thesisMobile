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

class MBXCompassMapView: MGLMapView, MGLMapViewDelegate {
    
    var isMapInteractive : Bool = true {
        didSet {
            
            // Disable individually, then add custom gesture recognizers as needed.
            self.isZoomEnabled = false
            self.isScrollEnabled = false
            self.isPitchEnabled = false
            self.isRotateEnabled = false
        }
    }
    
    // Create a map view and set the style.
    override convenience init(frame: CGRect, styleURL: URL?) {
        self.init(frame: frame)
        self.styleURL = styleURL
    }
    
    // Create a map view.
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.alpha = 0.8
        self.delegate = self
        hideMapSubviews()
    }
    
    // Make the map view a circle.
    override func layoutSubviews() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    // Hide the Mapbox wordmark, attribution button, and compass view. Move the attribution button and wordmark based on your design. See www.mapbox.com/help/how-attribution-works/#how-attribution-works for more information about attribution requirements.
    private func hideMapSubviews() {
        self.logoView.isHidden = true
        self.attributionButton.isHidden = true
        self.compassView.isHidden = true
    }
    
    // Set the user tracking mode to `.followWithHeading`. This rotates the map based on the direction that the user is facing.
    func mapViewWillStartLoadingMap(_ mapView: MGLMapView) {
        self.userTrackingMode = .followWithHeading
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Adds a border to the map view.
    func setMapViewBorderColorAndWidth(color: CGColor, width: CGFloat) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
}

extension MBXCompassMapView {
    func setupUserTrackingMode() {
        self.showsUserLocation = true
        self.setUserTrackingMode(.followWithHeading, animated: false)
        self.displayHeadingCalibration = false
    }
}

class ViewController: UIViewController, ARSCNViewDelegate, MGLMapViewDelegate {
    var compass : MBXCompassMapView!
    var progress: Int = 0
    var markers: Array<SCNNode>?
    var monster: SCNNode?
    var monsterRange: Double = 30
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        compass = MBXCompassMapView(frame: CGRect(x: 20,
                                                  y: 20,
                                                  width: view.bounds.width / 3,
                                                  height: view.bounds.width / 3),
                                    styleURL: URL(string: "mapbox://styles/jordankiley/cj5eeueie1bsa2rp4swgcteml"))
        
        compass.isMapInteractive = false
        compass.tintColor = .black
        compass.delegate = self
        view.addSubview(compass)
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene and initialize markers
        let scene = SCNScene(named: "art.scnassets/main.scn")!
        markers = Init.initMarkers(scene: scene)
        
        // Set the scene to the view
        sceneView.scene = scene
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tap)
        
        var timer = Timer()
        
        //timer to calculate distance
        
        func scheduledTimerWithTimeInterval(){
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timer), userInfo: nil, repeats: true)
        }
        
        //timer to instantiate monster
        
        func monsterTimer(){
            timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.monsterTimer), userInfo: nil, repeats: true)
        }
        
        scheduledTimerWithTimeInterval()
        monsterTimer()
    }
    
    @objc func handleTap(_ gestureRecognizer: UIGestureRecognizer) {
        let p = gestureRecognizer.location(in: sceneView)
        let hitResults = sceneView.hitTest(p, options: [:])
        
        if hitResults.count > 0 {
            let node = hitResults[0].node
            //make sure node is a note and not a marker
            progress = progress + 1
            let message = String(progress) + " of 8 notes collected."
            animateNotification(message: message)
            grab(node)
        }
    }
    
    @objc func timer(){
        let close = Init.calculateDistances(sceneView: sceneView, markers: markers!)
        if close {
            animateNotification(message: "A note has appeared")
        }
    }
    
    @objc func monsterTimer(){
        monsterRange = monsterRange - 0.5
        //if there's already a monster, delete him first
        monster?.removeFromParentNode()
        monster = Init.initMonster(sceneView: sceneView, scene: self.sceneView.scene, range: monsterRange)
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
    
    func grab(_ node: SCNNode) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.5
        node.position = self.sceneView.pointOfView!.position
        SCNTransaction.completionBlock = {
            node.removeFromParentNode()
        }
        SCNTransaction.commit()
        
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
