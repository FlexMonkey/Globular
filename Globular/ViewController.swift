//
//  ViewController.swift
//  Globular
//
//  Created by Simon Gladman on 09/10/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
// maybe dragField() ?

import UIKit
import SpriteKit

class ViewController: UIViewController
{
    let skView = SKView()
    let scene = SKScene()
    
    let effectNode = SKEffectNode()
    
    let radialGravity = SKFieldNode.radialGravityField()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        skView.backgroundColor = UIColor.grayColor()
        view.addSubview(skView)
        
        for _ in 0 ... 100
        {
            let blobOne = SKShapeNode(circleOfRadius: 10)
            
            blobOne.position = CGPoint(x: CGFloat(drand48()) * view.frame.width,
                y: CGFloat(drand48()) * view.frame.height)
            
            blobOne.fillColor = UIColor.redColor()
            scene.addChild(blobOne)
            
            let blobOnePhysicsBody = SKPhysicsBody(polygonFromPath: blobOne.path!)
            blobOnePhysicsBody.restitution = 1
            blobOne.physicsBody = blobOnePhysicsBody
            
            let radialGravityOne = SKFieldNode.radialGravityField()
            radialGravityOne.strength = 0.025
            radialGravityOne.falloff = 0.85
            blobOne.addChild(radialGravityOne)
        }
        
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        radialGravity.strength = 0
        scene.addChild(radialGravity)
        
        createWalls()
        
        // ----
        
        /*
        effectNode.filter = CIFilter(name: "CIGaussianBlur")
        scene.addChild(effectNode)
        */
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        radialGravity.strength = -2.5
        radialGravity.falloff = 1
        
        radialGravity.position = CGPoint(x: touches.first!.locationInView(skView).x,
            y: view.frame.height - touches.first!.locationInView(skView).y)
    }
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        radialGravity.position = CGPoint(x: touches.first!.locationInView(skView).x,
                y: view.frame.height - touches.first!.locationInView(skView).y)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        radialGravity.strength = 0
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewDidLayoutSubviews()
    {
        skView.frame = view.frame
    }
    
    func createWalls()
    {
        let leftWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: view.frame.height))
        leftWall.position = CGPoint(x: -2, y: view.frame.height / 2)
        leftWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: view.frame.height))
        leftWall.physicsBody?.dynamic = false
        leftWall.physicsBody?.restitution = 0
        scene.addChild(leftWall)
        
        let rightWall = SKShapeNode(rectOfSize: CGSize(width: 2, height: view.frame.height))
        rightWall.position = CGPoint(x: view.frame.width + 2, y: view.frame.height / 2)
        rightWall.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2, height: view.frame.height))
        rightWall.physicsBody?.dynamic = false
        rightWall.physicsBody?.restitution = 0
        scene.addChild(rightWall)
        
        let floor = SKShapeNode(rectOfSize: CGSize(width: view.frame.width, height: 2))
        floor.position = CGPoint(x: view.frame.width / 2, y: -2)
        floor.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: view.frame.width, height: 2))
        floor.physicsBody?.dynamic = false
        floor.physicsBody?.restitution = 0
        scene.addChild(floor)

        let ceiling = SKShapeNode(rectOfSize: CGSize(width: view.frame.width, height: 2))
        ceiling.position = CGPoint(x: view.frame.width / 2, y: view.frame.height - 2)
        ceiling.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: view.frame.width, height: 2))
        ceiling.physicsBody?.dynamic = false
        ceiling.physicsBody?.restitution = 0
        scene.addChild(ceiling)
        
    }
    
}

