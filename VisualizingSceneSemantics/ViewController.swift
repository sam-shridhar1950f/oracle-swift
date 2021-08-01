/*
See LICENSE folder for this sample’s licensing information.
Abstract:
Main view controller for the AR experience.
*/

import RealityKit
import ARKit
import AVFoundation
import UIKit


var setDist:Float = 0.0
var points = [XYPoint]()
var objects = [SectionClassificationObject]()

struct XYPoint {
    var xVal: Double
    var yVal: Double
    
    func getX() -> Double {
        return xVal
    }
    
    func getY() -> Double {
        return yVal
    }
}

struct SectionClassificationObject {
    var direction: String
    var coord: XYPoint
    var distance: Double
    var classification: String
    
    func getDirection() -> String {
        return direction
    }
    
    func getCoord() -> XYPoint {
        return coord
    }
    
    func getDistance() -> Double {
        return distance
    }
    
    func getClassification() -> String {
        return classification
    }
}

func GeneratePoints(a: Int, b: Int) { //a is number of horizontaala boxes and b is number of vertical squaraes
    let width = 390
    let height = 840
    //create array here
    // var points = [XYPoint]()
    var x : Double = Double(1/2 * width * (1/a))
    var y : Double = Double(1/2 * height * (1/b))
    
    for _ in 1...a {
        for _ in 1...b {
            points.append(XYPoint(xVal: x, yVal: y))
            x += Double(width/a)
        }
        x = Double(1/2 * width * (1/a))
        y += Double(height/b)
    }
    
    
}

@available(iOS 14.0, *)
class ViewController: UIViewController, ARSessionDelegate {
    
    
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var hideMeshButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var planeDetectionButton: UIButton!
    
    
    let coachingOverlay = ARCoachingOverlayView()
    
    // Cache for 3D text geometries representing the classification values.
    var modelsForClassification: [ARMeshClassification: ModelEntity] = [:]

    /// - Tag: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        setupCoachingOverlay()

        arView.environment.sceneUnderstanding.options = []
        
        // Turn on occlusion from the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.occlusion)
        
        // Turn on physics for the scene reconstruction's mesh.
        arView.environment.sceneUnderstanding.options.insert(.physics)

        // Display a debug visualization of the mesh.
        arView.debugOptions.insert(.showSceneUnderstanding)
        
        // For performance, disable render options that are not required for this app.
        arView.renderOptions = [.disablePersonOcclusion, .disableDepthOfField, .disableMotionBlur]
        
        // Manually configure what kind of AR session to run since
        // ARView on its own does not turn on mesh classification.
      
        arView.automaticallyConfigureSession = false
        let configuration = ARWorldTrackingConfiguration()
        if type(of: configuration).supportsFrameSemantics(.sceneDepth) {
           // Activate sceneDepth
           configuration.frameSemantics = .sceneDepth
        }
        configuration.sceneReconstruction = .meshWithClassification

        configuration.environmentTexturing = .automatic
        
        DispatchQueue.global(qos: .background).async {
            print("WIBABBABABB")
            print("DaBby \(Thread.current)")
            configuration.planeDetection = [.horizontal, .vertical]
//            print(configuration.planeDetection.)
            self.arView.session.run(configuration)
            
        }
        
       
    /// let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
     ///arView.addGestureRecognizer(tapRecognizer)
       // sleep(5000)
       
            
            //sleep(5000)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5), execute: {
            print("DaBaby \(Thread.current)")
          
            let timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.startDetectionHelper), userInfo: nil, repeats: true)
            
                // self.startDetection()
//                sleep(2000)s
                
                
            
            
        })
        
        
        ///self.arView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interrupting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc
    func startDetectionHelper() {
        
        GeneratePoints(a: 3, b: 3)
        for i in 0...points.count - 1 {
            let coord: XYPoint = points[i]
            startDetection(coord: coord, completionHandler: { obj in
                
                  //  print("test")
//                    objects.append(obj)
                print(obj)
                print("waaajj")
                print(objects)
                let newObjects = objects.sorted {$0.distance < $1.distance}
                let classification = newObjects[0].classification
                let dist = newObjects[0].distance
                if classification != "" {
                    let utterance = AVSpeechUtterance(string: classification + "at" + String(dist) + "meters")
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // add languages audio function
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
                objects.removeAll()
                
                

            })
        }
        
        
    }
    
    
    
    func hierarchy() {
        // return distance and classification from startDetection --
        // if floor --> no utterance. Anything else --> closest object gets priority and is called out
        // insert into startDetectionHelper()
    }
    
    
    func proximityToCenter() {
        // find coordinates of the center and shoot a raycast. find the distance.
        // find distance from center, use magnitude to determine direction
    }
    
    // @objc
    func startDetection(coord: XYPoint, completionHandler: @escaping (SectionClassificationObject) -> Void) {
            // (168.0, 368.6666564941406) approx middle
        let location = CGPoint(x: coord.getX(), y: coord.getY())
            print(location)
            print("ahh")
        let result = arView.raycast(from: location, allowing: .existingPlaneInfinite, alignment: .any)
            print(result)
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
                
                // ...
               
                // 2. Visualize the intersection point of the ray with the real-world surface.
                let resultAnchor = AnchorEntity(world: result.worldTransform)
                resultAnchor.addChild(sphere(radius: 0.01, color: .lightGray))
                arView.scene.addAnchor(resultAnchor, removeAfter: 3)

                // 3. Try to get a classification near the tap location.
                //    Classifications are available per face (in the geometric sense, not human faces).
                
                nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in print(classification)
                    // ...
                    DispatchQueue.main.async {
                    print("waa")
                        print("something")
                        // 4. Compute a position for the text which is near the result location, but offset 10 cm
                        // towards the camera (along the ray) to minimize unintentional occlusions of the text by the mesh.
                        let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
                        let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
                        
                        // 5. Create a 3D text to visualize the classification result.
                        let result = self.model(for: classification)
                        let distanceAtXYPoint = result.0
                        let _classification = result.1

                        // 6. Scale the text depending on the distance, such that it always appears with
                        //    the same size on screen.
//                        let raycastDistance = distance(result.worldTransform.position, self.arView.cameraTransform.translation)
//                        textEntity.scale = .one * raycastDistance

                        // 7. Place the text, facing the camera.
                        var resultWithCameraOrientation = self.arView.cameraTransform
                        resultWithCameraOrientation.translation = textPositionInWorldCoordinates
//                        let textAnchor = AnchorEntity(world: resultWithCameraOrientation.matrix)
//                        textAnchor.addChild(textEntity)
//                        self.arView.scene.addAnchor(textAnchor, removeAfter: 3)

                        // 8. Visualize the center of the face (if any was found) for three seconds.
                        //    It is possible that this is nil, e.g. if there was no face close enough to the tap location.
                        if let centerOfFace = centerOfFace {
                            let faceAnchor = AnchorEntity(world: centerOfFace)
                            faceAnchor.addChild(self.sphere(radius: 0.01, color: classification.color))
                            self.arView.scene.addAnchor(faceAnchor, removeAfter: 3)
                        }
                        
                        // construct classification object:
                        let obj = SectionClassificationObject(direction: "wip", coord: coord, distance: distanceAtXYPoint, classification: _classification)
                        objects.append(obj)
                        completionHandler(obj)
                    }
                }
                
            } else {
                print("WIBBBAA")
            }
            
        }

    
    /// Places virtual-text of the classification at the touch-location's real-world intersection with a mesh.
    /// Note - because classification of the tapped-mesh is retrieved asynchronously, we visualize the intersection
    /// point immediately to give instant visual feedback of the tap.
//    @objc
//    func handleTap(_ sender: UITapGestureRecognizer) {
//        // 1. Perform a ray cast against the mesh.
//        // Note: Ray-cast option ".estimatedPlane" with alignment ".any" also takes the mesh into account.
//        let tapLocation = sender.location(in: arView)
//        print("tap location: ")
//        print(tapLocation)
//        if let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .any).first {
//            // ...
//            // 2. Visualize the intersection point of the ray with the real-world surface.
//            let resultAnchor = AnchorEntity(world: result.worldTransform)
//            resultAnchor.addChild(sphere(radius: 0.01, color: .lightGray))
//            arView.scene.addAnchor(resultAnchor, removeAfter: 3)
//
//            // 3. Try to get a classification near the tap location.
//            //    Classifications are available per face (in the geometric sense, not human faces).
//            nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in
//                // ...
//                DispatchQueue.main.async {
//                    // 4. Compute a position for the text which is near the result location, but offset 10 cm
//                    // towards the camera (along the ray) to minimize unintentional occlusions of the text by the mesh.
//                    let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
//                    let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
//
//                    // 5. Create a 3D text to visualize the classification result.
//                    let textEntity = self.model(for: classification)
//
//                    // 6. Scale the text depending on the distance, such that it always appears with
//                    //    the same size on screen.
//                    let raycastDistance = distance(result.worldTransform.position, self.arView.cameraTransform.translation)
//                    textEntity.scale = .one * raycastDistance
//
//                    // 7. Place the text, facing the camera.
//                    var resultWithCameraOrientation = self.arView.cameraTransform
//                    resultWithCameraOrientation.translation = textPositionInWorldCoordinates
//                    let textAnchor = AnchorEntity(world: resultWithCameraOrientation.matrix)
//                    textAnchor.addChild(textEntity)
//                    self.arView.scene.addAnchor(textAnchor, removeAfter: 3)
//
//                    // 8. Visualize the center of the face (if any was found) for three seconds.
//                    //    It is possible that this is nil, e.g. if there was no face close enough to the tap location.
//                    if let centerOfFace = centerOfFace {
//                        let faceAnchor = AnchorEntity(world: centerOfFace)
//                        faceAnchor.addChild(self.sphere(radius: 0.01, color: classification.color))
//                        self.arView.scene.addAnchor(faceAnchor, removeAfter: 3)
//                    }
//                }
//            }
//        }
//    }
    
    @IBAction func resetButtonPressed(_ sender: Any) {
        if let configuration = arView.session.configuration {
            arView.session.run(configuration, options: .resetSceneReconstruction)
        }
    }
    
    @IBAction func toggleMeshButtonPressed(_ button: UIButton) {
        let isShowingMesh = arView.debugOptions.contains(.showSceneUnderstanding)
        if isShowingMesh {
            arView.debugOptions.remove(.showSceneUnderstanding)
            button.setTitle("Show Mesh", for: [])
        } else {
            arView.debugOptions.insert(.showSceneUnderstanding)
            button.setTitle("Hide Mesh", for: [])
        }
    }
    
    /// - Tag: TogglePlaneDetection
    @IBAction func togglePlaneDetectionButtonPressed(_ button: UIButton) { // start plane detection
        guard let configuration = arView.session.configuration as? ARWorldTrackingConfiguration else {
            return
        }
        if configuration.planeDetection == [] {
            configuration.planeDetection = [.horizontal, .vertical]
            button.setTitle("Stop Plane Detection", for: [])
        } else {
            configuration.planeDetection = []
            button.setTitle("Start Plane Detection", for: [])
        }
        arView.session.run(configuration)
    }
    
    func nearbyFaceWithClassification(to location: SIMD3<Float>, completionBlock: @escaping (SIMD3<Float>?, ARMeshClassification) -> Void) {
        guard let frame = arView.session.currentFrame else {
            completionBlock(nil, .none)
            return
        }
    
        var meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor })
        
        // Sort the mesh anchors by distance to the given location and filter out
        // any anchors that are too far away (4 meters is a safe upper limit).
        let cutoffDistance: Float = 4.0
        meshAnchors.removeAll { distance($0.transform.position, location) > cutoffDistance }
        meshAnchors.sort { distance($0.transform.position, location) < distance($1.transform.position, location) }

        // Perform the search asynchronously in order not to stall rendering.
        DispatchQueue.global().async {
            for anchor in meshAnchors {
                for index in 0..<anchor.geometry.faces.count {
                    // Get the center of the face so that we can compare it to the given location.
                    let geometricCenterOfFace = anchor.geometry.centerOf(faceWithIndex: index)
                    
                    // Convert the face's center to world coordinates.
                    var centerLocalTransform = matrix_identity_float4x4
                    centerLocalTransform.columns.3 = SIMD4<Float>(geometricCenterOfFace.0, geometricCenterOfFace.1, geometricCenterOfFace.2, 1)
                    let centerWorldPosition = (anchor.transform * centerLocalTransform).position
                     
                    // We're interested in a classification that is sufficiently close to the given location––within 5 cm.
                    let distanceToFace = distance(centerWorldPosition, location)
                    
                    if distanceToFace <= 0.05 {
                        setDist = distanceToFace
                        // Get the semantic classification of the face and finish the search.
                        let classification: ARMeshClassification = anchor.geometry.classificationOf(faceWithIndex: index) // the classification
                        completionBlock(centerWorldPosition, classification)
                        return
                    }
                }
            }
            
            // Let the completion block know that no result was found.
            completionBlock(nil, .none)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) { // error handling
        // guard let depthData = arView.session.currentFrame?.sceneDepth else { return  }
        
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetButtonPressed(self)
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
        
    func model(for classification: ARMeshClassification) -> (Double, String) { // Replace this code with audio call out algorithm
        // Return cached model if available
        // dimensions: 256 x 192
        guard let depthData = arView.session.currentFrame?.sceneDepth?.depthMap else { fatalError("Wut Da Dab") }
        
        // Useful data
        
            // let width = CVPixelBufferGetWidth(depthData) //768 on an iPhone 7+
            // let height = CVPixelBufferGetHeight(depthData) //576 on an iPhone 7+
            CVPixelBufferLockBaseAddress(depthData, CVPixelBufferLockFlags(rawValue: 0))

            // Convert the base address to a safe pointer of the appropriate type
            let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthData), to: UnsafeMutablePointer<Float32>.self)

            // Read the data (returns value of type Float)
            // Accessible values : (width-1) * (height-1) = 767 * 575

        let distanceAtXYPoint = round(floatBuffer[Int(128 * 96)] * 10) / 10.0 // x and y is x,y coordinate

        
        
        if let model = modelsForClassification[classification] {
            model.transform = .identity
//            if classification.description != "None" {
//            let utterance = AVSpeechUtterance(string: classification.description + "at" + String(distanceAtXYPoint) + "meters")
//
//            utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // add languages audio function
//                //print(setDist)
//                //print(depthData)
//                print(distanceAtXYPoint)
//                let synthesizer = AVSpeechSynthesizer()
//                synthesizer.speak(utterance)
//            }

            
            // synthesizer.continueSpeaking() // Resume a paused speech
//            return model.clone(recursive: true)
            
            return (Double(distanceAtXYPoint), classification.description)
        }
        
        // Generate 3D text for the classification
//        let lineHeight: CGFloat = 0.05
//        let font = MeshResource.Font.systemFont(ofSize: lineHeight)
//        let textMesh = MeshResource.generateText(classification.description, extrusionDepth: Float(lineHeight * 0.1), font: font)
//        let textMaterial = SimpleMaterial(color: classification.color, isMetallic: true)
//        let model = ModelEntity(mesh: textMesh, materials: [textMaterial])
//        // Move text geometry to the left so that its local origin is in the center
//        model.position.x -= model.visualBounds(relativeTo: nil).extents.x / 2
//        // Add model to cache
//        modelsForClassification[classification] = model
        
//        if classification.description != "None" {
//        let utterance = AVSpeechUtterance(string: classification.description + "at" + String(distanceAtXYPoint) + "meters")
//
//        utterance.voice = AVSpeechSynthesisVoice(language: "en-US") // add languages audio function
//
//       // print(depthData)
//       // print(setDist)
//        print(distanceAtXYPoint)
//        let synthesizer = AVSpeechSynthesizer()
//        synthesizer.speak(utterance)
//        // synthesizer.continueSpeaking() // Resume a paused speech
//        }
        
//        return model
        return (Double(distanceAtXYPoint), classification.description)
    }
    
    func sphere(radius: Float, color: UIColor) -> ModelEntity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        // Move sphere up by half its diameter so that it does not intersect with the mesh
        sphere.position.y = radius
        return sphere
    }
    
    @IBAction func didTapButton(){
        present(ViewController2(),animated: true)
    }
}

class ViewController2: UIViewController, ARSessionDelegate{
    var session: ARSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        session = ARSession()
        session.delegate = self
    }
}

//class XYPoint {
//
//}
//
//class SectionClassificationObject {
//
//}
