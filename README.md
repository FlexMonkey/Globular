# Globular
Colourful Metaballs Controlled by 3D Touch

_Companion project to: http://flexmonkey.blogspot.co.uk/2015/10/globular-colourful-metaballs-controlled.html_

I've seen a few articles this week about a beautiful looking app called Pause. One of Pause's features is the ability to move a fluid-like blob around the screen which obviously got me thinking, "how could I create something similar in Swift". The result is another little experiment, Globular, which allows a user to move metaballs around the screen by touch where the touch location acts as a radial gravity source with its strength determined by the force of that touch.

There are a few steps in creating this effect: a SpriteKit based "skeleton" for overall liquid mass followed by a Core Image post processing step to render the smooth metaball visuals.

##Creating the SpriteKit "Skeleton" 

The structure of the liquid mass is formed from 150 individual circles of different colours. Each circle is actually a SKShapeNode with a radial gravity field that attracts it to every other circle.

Creating this is pretty simple, my main view controller is a standard UIViewController and I add to its view a SKView. The view needs an SKScene to present:

    let skView = SKView()
    let scene = SKScene()

    skView.presentScene(scene)

Inside viewDidLoad(), I create a loop to create each node:

    for i in 0 ... 150
    {

        let blob = SKShapeNode(circleOfRadius: 10)

I want each blob to have a random position:

    blob.position = CGPoint(x: CGFloat(drand48()) * view.frame.width,
        y: CGFloat(drand48()) * view.frame.height)

...and to be one of six colours:

    blob.fillColor = [UIColor.redColor(),
        UIColor.greenColor(),
        UIColor.blueColor(),
        UIColor.cyanColor(),
        UIColor.magentaColor(),
        UIColor.yellowColor()][i % 6]
    

    blob.strokeColor = blob.fillColor

Now the blob is instantiated, I can add it to my scene:

    scene.addChild(blob)

Next, I want to make the blob physics enabled. To do this, I create a physics body with the same visual path as the blob and link the pair. To make the blobs bounce of each other, I set their restitution to 1:

    let blobPhysicsBody = SKPhysicsBody(polygonFromPath: blob.path!)
    blobPhysicsBody.restitution = 1

    blob.physicsBody = blobPhysicsBody

Finally, to make every blob attract every other blob, I need to create a radial gravity field with a limited radius and falloff and attach that to the blob:

    let radialGravity = SKFieldNode.radialGravityField()
    radialGravity.strength = 0.015
    radialGravity.falloff = 0.5
    radialGravity.region = SKRegion(radius: 100)
    

    blob.addChild(radialGravity)

The end result is the raw multicoloured circles that form the liquid's scaffold. Each individual circle is attracted to every other and, with the help of an additional drag field, they move serenely and appear to have a surface tension like effect.

##Core Image Post Processing

Now the basic physics is in place, I want to convert those discrete circles into a joined metaballs. The basic technique to do this is blur the image and then tweak the tone curve to knock out the mid-tones. Often the latter part of this effect is achieved with a threshold filter, but since Core Image doesn't have one of those, a CIToneCurve does something similar.

The scene is a subclass of SKEffectNode which has a filter property of type CIFilter. However, because my post processing step requires two filters, I need to create my own filter, MetaBallFilter.

This is pretty simple, my new class extends CIFilter and in the outputImage getter, I chain together a CIGaussianBlur and a CIToneCurve:

    override var outputImage: CIImage!
    {
        guard let inputImage = inputImage else
        {
            return nil
        }
        
        let blur = CIFilter(name: "CIGaussianBlur")!
        let edges = CIFilter(name: "CIToneCurve")!
        
        blur.setValue(25, forKey: kCIInputRadiusKey)
        blur.setValue(inputImage, forKey: kCIInputImageKey)
        
        edges.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        edges.setValue(CIVector(x: 0.25, y: 0), forKey: "inputPoint1")
        edges.setValue(CIVector(x: 0.5, y: 0), forKey: "inputPoint2")
        edges.setValue(CIVector(x: 0.75, y: 2), forKey: "inputPoint3")
        edges.setValue(CIVector(x: 1,y: 0), forKey: "inputPoint4")
        
        edges.setValue(blur.outputImage, forKey: kCIInputImageKey)
        
        return edges.outputImage

    }

I can now set an instance of my new filter as the scene's filter and ensure its effects are enabled:

    scene.filter = MetaBallFilter()
    scene.shouldEnableEffects = true

The end result now looks a lot more "liquidy":

 
##Touch Handling

All that's left now is to have the individual blobs react to the user's touch. To do this, I create another "master" radial gravity field:

    let radialGravity = SKFieldNode.radialGravityField()

...and in both touchesBegan and touchesMoved I set the strength and position of that gravity field based on the touch. It's worth remembering that the vertical coordinates in a SpriteKit scene are inverted:

    radialGravity.falloff = 0.5
    radialGravity.region = SKRegion(radius: 200)
    
    radialGravity.strength = (traitCollection.forceTouchCapability == UIForceTouchCapability.Available) ?
        Float(touch.force / touch.maximumPossibleForce) * 6 :
        3
    
    radialGravity.position = CGPoint(x: touch.locationInView(skView).x,

        y: view.frame.height - touch.locationInView(skView).y)

##Source Code

All the source code for this project is available in my GitHub repository here. Enjoy!
