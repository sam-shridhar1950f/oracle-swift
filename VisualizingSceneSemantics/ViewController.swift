/*
See LICENSE folder for this sample’s licensing information.
Abstract:
Main view controller for the AR experience.
*/
import RealityKit
import ARKit
import AVFoundation
import UIKit
import CoreML
import SwiftUI
//import RealmSwift
var setDist:Float = 0.0
//var points = [XYPoint]()
var objects = [SectionClassificationObject]()
var currentMLClassification = ""
var current_classification = ""
var currMinDistance = 10000.0
var globalInterval = 3
var globalLanguage:String = "en-US"
var globalLang:String = "english"
var globalSystem:String = "centimeters"
var globalSystemCall:String = "centimeters"
var hapticBool = true

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

let english = ["ceiling", "door", "floor", "none", "seat", "table", "wall", "window", "box", "cars", "desk", "fences", "garage", "people", "stairs", "table", "toilet", "Warning, obstacle at", "centimeters", "inches"]
let spanish = ["techo", "puerta", "piso", "ninguno", "asiento", "mesa", "pared", "ventana", "caja", "autos", "escritorio", "vallas", " garaje "," gente "," escaleras "," mesa "," baño", "Advertencia, obstáculo en", "centímetros", "pulgadas"]
let french = ["plafond", "porte", "sol", "aucun", "siège", "table", "mur", "fenêtre", "boîte", "voitures", "bureau", "clôtures", " garage", "personnes", "escaliers", "table", "toilettes", "Attention, obstacle à", "centimètres", "pouces"]
let mandarin = ["天花板","门","地板","无","座位","桌子","墙壁","窗户","盒子","汽车","桌子","围栏"," 车库", "人", "楼梯", "桌子", "厕所", "警告, 障碍物", "厘米","英寸"]
let hindi = ["छत", "दरवाजा", "फर्श", "कोई नहीं", "सीट", "टेबल", "दीवार", "खिड़की", "बॉक्स", "कार", "डेस्क", "बाड़", " गेराज", "लोग", "सीढ़ियां", "टेबल", "शौचालय", "चेतावनी, बाधा", "सेंटीमीटर", "इंच"]
let arabic = ["سقف" , "باب" , "أرضية" , "بلا" , "مقعد" , "طاولة" , "جدار" , "نافذة" , "صندوق" , "سيارات" , "مكتب" , "أسوار" , " جراج "," أشخاص "," سلالم "," طاولة "," مرحاض "," تحذير , عقبة عند "," سم "," بوصة "]
let bengali = ["সিলিং", "দরজা", "মেঝে", "কিছুই নয়", "সিট", "টেবিল", "ওয়াল", "জানালা", "বাক্স", "গাড়ি", "ডেস্ক", "বেড়া", "গ্যারেজ", "মানুষ", "সিঁড়ি", "টেবিল", "টয়লেট", "সতর্কতা, বাধা", "সেন্টিমিটার", "ইঞ্চি"]
let russian = ["потолок", "дверь", "пол", "нет", "сиденье", "стол", "стена", "окно", "коробка", "машины", "стол", "заборы", " гараж", "люди", "лестница", "стол", "туалет", "Предупреждение, препятствие в", "сантиметры", "дюймы"]
let portuguese = ["teto", "porta", "piso", "nenhum", "assento", "mesa", "parede", "janela", "caixa", "carros", "mesa", "cercas", " garagem", "pessoas", "escadas", "mesa", "banheiro", "Aviso, obstáculo em", "centímetros", "polegadas"]
let korean = ["천장", "문", "바닥", "없음", "좌석", "테이블", "벽", "창문", "상자", "자동차", "책상", "담장", " 차고", "사람", "계단", "테이블", "화장실", "경고, 장애물", "센티미터", "인치"]
let japanese = ["天井", "ドア", "床", "なし", "座席", "テーブル", "壁", "窓", "ボックス", "車", "机", "フェンス", " ガレージ」","「人」","「階段」", "「テーブル」","「トイレ」", "「警告,障害物」","「センチメートル」", "「インチ」"]
let german = ["Decke", "Tür", "Boden", "keine", "Sitz", "Tisch", "Wand", "Fenster", "Box", "Autos", "Schreibtisch", "Zäune", " Garage", "Personen", "Treppe", "Tisch", "Toilette", "Warnung, Hindernis bei", "Zentimeter", "Zoll"]
let hausa = ["rufi", "kofa", "kasa", "babu", "wurin zama", "tebur", "bango", "taga", "akwatin", "motoci", "tebur", "fences", " gareji", "mutane", "matakala", "tebur", "bayan gida", "Gargadi, cikas a", "centimeters", "inci"]
let turkish = ["tavan", "kapı", "zemin", "yok", "koltuk", "masa", "duvar", "pencere", "kutu", "arabalar", "masa", "çitler", " garaj", "insanlar", "merdiven", "masa", "tuvalet", "Uyarı, engel", "santimetre", "inç"]
let dutch = ["plafond", "deur", "vloer", "geen", "stoel", "tafel", "muur", "raam", "doos", "auto's", "bureau", "hekken", " garage", "mensen", "trappen", "tafel", "toilet", "Waarschuwing, obstakel bij", "centimeter", "inch"]
let vietnamese = ["trần", "cửa", "sàn", "không", "ghế", "bàn", "tường", "cửa sổ", "hộp", "xe hơi", "bàn", "hàng rào", " nhà để xe "," người "," cầu thang "," bàn "," nhà vệ sinh ", "Cảnh báo, chướng ngại vật tại", "centimet", "inch"]
let indonesian = ["langit-langit", "pintu", "lantai", "tidak ada", "kursi", "meja", "dinding", "jendela", "kotak", "mobil", "meja", "pagar", " garasi", "orang", "tangga", "meja", "toilet", "Peringatan, rintangan di", "sentimeter", "inci"]
               
var spanishDict: [String: String] = [:]
var frenchDict: [String: String] = [:]
var mandarinDict: [String: String] = [:]
var hindiDict: [String: String] = [:]
var arabicDict: [String: String] = [:]
var bengaliDict: [String: String] = [:]
var russianDict: [String: String] = [:]
var portugueseDict: [String: String] = [:]
var koreanDict: [String: String] = [:]
var japaneseDict: [String: String] = [:]
var germanDict: [String: String] = [:]
var hausaDict: [String: String] = [:]
var turkishDict: [String: String] = [:]
var dutchDict: [String: String] = [:]
var vietnameseDict: [String: String] = [:]
var indonesianDict: [String: String] = [:]


func fillDicts() {
    for i in 0...english.count - 1 {
        spanishDict[english[i]] = spanish[i]
        frenchDict[english[i]] = french[i]
        mandarinDict[english[i]] = mandarin[i]
        hindiDict[english[i]] = hindi[i]
        arabicDict[english[i]] = arabic[i]
        bengaliDict[english[i]] = bengali[i]
        russianDict[english[i]] = russian[i]
        portugueseDict[english[i]] = portuguese[i]
        koreanDict[english[i]] = korean[i]
        japaneseDict[english[i]] = japanese[i]
        germanDict[english[i]] = german[i]
        hausaDict[english[i]] = hausa[i]
        turkishDict[english[i]] = turkish[i]
        dutchDict[english[i]] = dutch[i]
        vietnameseDict[english[i]] = vietnamese[i]
        indonesianDict[english[i]] = indonesian[i]
    }
}

//function generate points that are the midpoints of rectangles generated by passed in dimensions
func GeneratePoints(widthParam: Int, heightParam: Int, a: Int, b: Int, array: inout [XYPoint]) -> [XYPoint] { //a is number of horizontal boxes and b is number of vertical squaraes
    //width and height of the frame to divide
    let width = widthParam
    let height = heightParam
    //create array here
    // var points = [XYPoint]()
    //starting point on the x and y coordinates
    var x : Double = Double(1/2 * width * (1/a))
    var y : Double = Double(1/2 * height * (1/b))
    
    for _ in 1...a {
        for _ in 1...b {
            //adds the values to the array
            array.append(XYPoint(xVal: x, yVal: y))
            // increments through all x values boxes fro the given y midpoint
            x += Double(width/a)
        }
        x = Double(1/2 * width * (1/a)) //resets the x coord to initial
        y += Double(height/b) //increment the y coord to the next set of boxes
    }
    
    return array
}

@available(iOS 15.0, *)
class ViewController: UIViewController, ARSessionDelegate {
    
    @IBOutlet var arView: ARView!
    @IBOutlet weak var imageView: UIImageView!
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
        
        fillDicts()
        
        DispatchQueue.global(qos: .background).async {
            //print("WIBABBABABB")
            //print("DaBby \(Thread.current)")
            configuration.planeDetection = [.horizontal, .vertical]
//            print(configuration.planeDetection.)
            self.arView.session.run(configuration)
            
        }
        
       
    /// let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
     ///arView.addGestureRecognizer(tapRecognizer)
       // sleep(5000)
       
            
            //sleep(5000)
       
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            //print("imageMLy \(Thread.current)")
          
            let timer = Timer.scheduledTimer(timeInterval: TimeInterval(globalInterval), target: self, selector: #selector(self.startDetectionHelper), userInfo: nil, repeats: true)
            
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
        var count = 1
        let res = self.snapShotCamera()
                let ciImage = res.0
                 let classificationRequest: VNCoreMLRequest? = {
                    do {
                    
                        let model = try VNCoreMLModel(for: version4().model)
                        var classificationList: [String] = []
                    let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                        self?.processClassifications(for: request, error: error, completionHandler: {classification in
                            classificationList.append(classification)
                            print(classification + " CoreML")
                            if (count == 1) {
                                currentMLClassification = classification
                                count+=1
                            }
                            
                        })
                        count = 1

//                        var classification: String = self?.processClassifications(for: request, error: error)
//                        print(classification + "CoreML")
                    })
                    request.imageCropAndScaleOption = .centerCrop
                    return request
                        
                    } catch {
                      print("eror :(")
                        return nil
                    }
                }()
                
                var uiImage = res.1
                
             //   uiImage = uiImage!
               // self.imageView.image = uiImage
        //        let orientation = CGImagePropertyOrientation(rawValue: uiImage.orientation)
           // let orientation = uiImage?.imageOrientation
                DispatchQueue.global(qos: .userInitiated).async {
                  //  print("DIBA WABA SEX BAB")
                    let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: 3)!)
                    do {
                        try handler.perform([classificationRequest!])
                    } catch {
                        /*
                         This handler catches general image processing errors. The `classificationRequest`'s
                         completion handler `processClassifications(_:error:)` catches errors specific
                         to processing that request.
                         */
                        print("Failed to perform classification.\n\(error.localizedDescription)")
                    }
                }
        objects.removeAll()
        //var objects = [SectionClassificationObject]()
        var points = [XYPoint]()
        points.append(XYPoint(xVal: 195, yVal: 420))
//        points.append(XYPoint(xVal: 195, yVal: 420))
//        points.append(XYPoint(xVal: 300, yVal: 420))
//        points.append(XYPoint(xVal: 200, yVal: 200))
        for i in 0...points.count - 1 {
            let coord: XYPoint = points[i]
            print(coord)
            startDetection(coord: coord, completionHandler: {
                //adding if it doesnt see anythin
                if objects.count != points.count && objects.count < 9{
                    //print(String(objects.count) + "yessir")
                    objects += [SectionClassificationObject](repeating: SectionClassificationObject(direction: "None", coord: XYPoint(xVal: 0, yVal: 0), distance: 100000, classification: "None"), count: (objects.count))
                }
                
                if objects.count == points.count {
                    print(String(objects.count) + " " + String(points.count))
                    var newObj:SectionClassificationObject = objects[0]
                    let newObjects = objects.sorted {$0.distance < $1.distance}
                    
                   // print(newObjects.count)
                    for i in 0...newObjects.count - 1 {
                        if newObjects[i].classification != "None" && newObjects[i].classification != ""{
                            newObj = newObjects[i]
                            break
                        }
                    }
                    
                    for k in 0...objects.count-1 {
                        print(objects[k].distance)
                    }
                    
                    var absMin = objects[0].distance
                    var absMinObject = objects[0]
                    print(objects.count)
                    for j in 0...objects.count - 1 {
                        if (objects[j].distance < absMin) {
                            absMin = objects[j].distance
                            absMinObject = objects[j]
//                            print(j)
                        }
                    }
                    
                    var classification_apple = absMinObject.classification
                    //var dist = (round(absMinObject.distance * 10) / 10.0)*3.281
                    //currMinDistance = (round(currMinDistance * 10) / 10.0)*3.281
                    currMinDistance = currMinDistance * 100
                    currMinDistance.round()
                    if currMinDistance < 75 && hapticBool {
                        AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { } } }
                    }
                    var newDistance = String(currMinDistance).replacingOccurrences(of: ".0", with: "")
                    
                    print("classification: " + absMinObject.classification + ", distance: " + newDistance + " cm")
                    
                    //hierarchy
                    let temp = currentMLClassification
                    var confidence = ""
                    for char in temp {
                       confidence.append(char)
                            if char == ")" {
                              break
                        }
                    }
                        confidence = confidence.replacingOccurrences(of: "(", with: "")
                        confidence = confidence.replacingOccurrences(of: ")", with: "")
                        confidence = confidence.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if (confidence.count < 1) {
                            return
                        }
                        
                        let confidenceFloat = Double(confidence)
                    //                   print(confidenceFloat)
                        if (confidenceFloat! < 0.85) {
                            
                            if classification_apple != "None" {
                                var appleCall: String = classification_apple.lowercased()
                                print(globalLang)
                                switch globalLang {
                                case "spanish":
                                    appleCall = spanishDict[appleCall]!
                                    globalLanguage = "es-ES"
                                case "french":
                                    appleCall = frenchDict[appleCall]!
                                    globalLanguage = "fr-FR"
                                case "mandarin":
                                    appleCall = mandarinDict[appleCall]!
                                    globalLanguage = "zh-Hans"
                                case "hindi":
                                    appleCall = hindiDict[appleCall]!
                                    globalLanguage = "hi-IN"
                                case "arabic":
                                    appleCall = arabicDict[appleCall]!
                                    globalLanguage = "ar-SA"
                                case "bengali":
                                    appleCall = bengaliDict[appleCall]!
                                    globalLanguage = "hi-IN"
                               case "russian":
                                    appleCall = russianDict[appleCall]!
                                    globalLanguage = "ru-RU"
                               case "portuguese":
                                    appleCall = portugueseDict[appleCall]!
                                    globalLanguage = "pt-BR"
                               case "korean":
                                    appleCall = koreanDict[appleCall]!
                                    globalLanguage = "ko-KR"
                               case "japanese":
                                    appleCall = japaneseDict[appleCall]!
                                    globalLanguage = "ja-JP"
                               case "german":
                                    appleCall = germanDict[appleCall]!
                                    globalLanguage = "de-DE"
                               case "hausa":
                                    appleCall = hausaDict[appleCall]!
                                    globalLanguage = "en-US"
                               case "turkish":
                                    appleCall = turkishDict[appleCall]!
                                    globalLanguage = "tr-TR"
                               case "dutch":
                                    appleCall = dutchDict[appleCall]!
                                    globalLanguage = "nl-NE"
                               case "vietnamese":
                                    appleCall = vietnameseDict[appleCall]!
                                    globalLanguage = "en-US"
                               case "indonesian":
                                    appleCall = indonesianDict[appleCall]!
                                    globalLanguage = "id-ID"
                              
                                default:
                                    appleCall = classification_apple.lowercased()
                                    globalLanguage = "en-US"
                                }
                                if globalSystem == "inches" {
                                    
                                    var newDistanceTemp = currMinDistance / 2.54
                                    newDistanceTemp.round()
                                    
                                    
                                    
                                    newDistance = String(newDistanceTemp).replacingOccurrences(of: ".0", with: "")
                                }

                                print(classification_apple + " after")
                                let utterance = AVSpeechUtterance(string: appleCall + " at" + newDistance + " " + globalSystemCall)
                                print(classification_apple + "at" + newDistance + globalSystemCall)
                                utterance.voice = AVSpeechSynthesisVoice(language: globalLanguage) // add languages audio function
                                let synthesizer = AVSpeechSynthesizer()
                                synthesizer.speak(utterance)
                                return
                            }
                            if (currMinDistance < 75) {
                                var warningCall: String = "Warning, obstacle at"
                                switch globalLang {
                                    case "spanish":
                                        warningCall = spanishDict["Warning, obstacle at"]!
                                        print("aby")
                                        globalLanguage = "es-ES"
                                    case "french":
                                        warningCall = frenchDict["Warning, obstacle at"]!
                                        globalLanguage = "fr-FR"
                                    case "mandarin":
                                        warningCall = mandarinDict["Warning, obstacle at"]!
                                        globalLanguage = "zh-Hans"
                                    case "hindi":
                                        warningCall = hindiDict["Warning, obstacle at"]!
                                        globalLanguage = "hi-HI"
                                    case "arabic":
                                        warningCall = arabicDict["Warning, obstacle at"]!
                                        globalLanguage = "ar-SA"
                                    case "bengali":
                                        warningCall = bengaliDict["Warning, obstacle at"]!
                                        globalLanguage = "hi-IN"
                                   case "russian":
                                        warningCall = russianDict["Warning, obstacle at"]!
                                        globalLanguage = "ru-RU"
                                   case "portuguese":
                                        warningCall = portugueseDict["Warning, obstacle at"]!
                                        globalLanguage = "pt-BR"
                                   case "korean":
                                        warningCall = koreanDict["Warning, obstacle at"]!
                                        globalLanguage = "ko-KR"
                                   case "japanese":
                                        warningCall = japaneseDict["Warning, obstacle at"]!
                                        globalLanguage = "ja-JP"
                                   case "german":
                                        warningCall = germanDict["Warning, obstacle at"]!
                                        globalLanguage = "de-DE"
                                   case "hausa":
                                        warningCall = hausaDict["Warning, obstacle at"]!
                                        globalLanguage = "en-US"
                                   case "turkish":
                                        warningCall = turkishDict["Warning, obstacle at"]!
                                        globalLanguage = "tr-TR"
                                   case "dutch":
                                        warningCall = dutchDict["Warning, obstacle at"]!
                                        globalLanguage = "nl-NE"
                                   case "vietnamese":
                                        warningCall = vietnameseDict["Warning, obstacle at"]!
                                        globalLanguage = "en-US"
                                   case "indonesian":
                                        warningCall = indonesianDict["Warning, obstacle at"]!
                                        globalLanguage = "id-ID"
                                    default:
                                        globalLanguage = "en-US"
                                }
                                print("Warning object at " + newDistance + " " + globalSystemCall)
                                let utterance4 = AVSpeechUtterance(string: warningCall + " " + newDistance + " " + globalSystemCall)
                                utterance4.voice = AVSpeechSynthesisVoice(language: globalLanguage) // add languages audio function
                                let synthesizer4 = AVSpeechSynthesizer()
                                synthesizer4.speak(utterance4)
                                return
                            }
                            
                            return
                        }
                        
                        let precdence: [String] = ["people"] // list of important objects
                    
                
                        
                    var c = currentMLClassification.trimmingCharacters(in: .whitespaces)
                    var imageML = c.components(separatedBy: " ")
                    print(imageML[1])
//                    if imageML[1] == "people" {
//                        newDistance = String(100 + Int.random(in: -50..<50))
//                    }
                    
                    var appleCall: String = classification_apple.lowercased()
                    
                    var imageCall: String = imageML[1].lowercased()
                    print(globalLang)
                    switch globalLang {
                        case "spanish":
                            appleCall = spanishDict[appleCall]!
                            imageCall = spanishDict[imageCall]!
                            globalLanguage = "es-ES"
                        case "french":
                            appleCall = frenchDict[appleCall]!
                            imageCall = frenchDict[imageCall]!
                            globalLanguage = "fr-FR"
                        case "mandarin":
                            appleCall = mandarinDict[appleCall]!
                            imageCall = mandarinDict[imageCall]!
                            globalLanguage = "zh-Hans"
                        case "hindi":
                            appleCall = hindiDict[appleCall]!
                            imageCall = hindiDict[imageCall]!
                            globalLanguage = "hi-HI"
                        case "arabic":
                            appleCall = arabicDict[appleCall]!
                            imageCall = arabicDict[imageCall]!
                            globalLanguage = "ar-SA"
                        case "bengali":
                            appleCall = bengaliDict[appleCall]!
                            imageCall = bengaliDict[imageCall]!
                            globalLanguage = "hi-IN"
                       case "russian":
                            appleCall = russianDict[appleCall]!
                            imageCall = russianDict[imageCall]!
                            globalLanguage = "ru-RU"
                       case "portuguese":
                            appleCall = portugueseDict[appleCall]!
                            imageCall = portugueseDict[imageCall]!
                            globalLanguage = "pt-BR"
                       case "korean":
                            appleCall = koreanDict[appleCall]!
                            imageCall = koreanDict[imageCall]!
                            globalLanguage = "ko-KR"
                       case "japanese":
                            appleCall = japaneseDict[appleCall]!
                            imageCall = japaneseDict[imageCall]!
                            globalLanguage = "ja-JP"
                       case "german":
                            appleCall = germanDict[appleCall]!
                            imageCall = germanDict[imageCall]!
                            globalLanguage = "de-DE"
                       case "hausa":
                            appleCall = hausaDict[appleCall]!
                            imageCall = hausaDict[imageCall]!
                            globalLanguage = "en-US"
                       case "turkish":
                            appleCall = turkishDict[appleCall]!
                            imageCall = turkishDict[imageCall]!
                            globalLanguage = "tr-TR"
                       case "dutch":
                            appleCall = dutchDict[appleCall]!
                            imageCall = dutchDict[imageCall]!
                            globalLanguage = "nl-NE"
                       case "vietnamese":
                            appleCall = vietnameseDict[appleCall]!
                            imageCall = vietnameseDict[imageCall]!
                            globalLanguage = "en-US"
                       case "indonesian":
                            appleCall = indonesianDict[appleCall]!
                            imageCall = indonesianDict[imageCall]!
                            globalLanguage = "id-ID"
                        default:
                            appleCall = classification_apple.lowercased()
                            imageCall = imageML[1].lowercased()
                            if imageCall == "people" {
                                imageCall = "person"
                            }
                    }
                    
                    if globalSystem == "inches" {
                        var newDistanceTemp = currMinDistance / 2.54
                        newDistanceTemp.round()
                        newDistance = String(newDistanceTemp).replacingOccurrences(of: ".0", with: "")
                    }
                    if precdence.contains(imageML[1].lowercased()) {
                        let utterance2 = AVSpeechUtterance(string: imageCall +  "at " + newDistance + " " + globalSystemCall)
                        utterance2.voice = AVSpeechSynthesisVoice(language: globalLanguage) // add languages audio function
                        let synthesizer2 = AVSpeechSynthesizer()
                        synthesizer2.speak(utterance2)
                        return
                    } else {
                        print(classification_apple)
                        if classification_apple != "None" {

                            print(classification_apple + " after")
                            let utterance = AVSpeechUtterance(string: appleCall + " at " + newDistance + " " + globalSystemCall)
                            utterance.voice = AVSpeechSynthesisVoice(language: globalLanguage) // add languages audio function
                            let synthesizer = AVSpeechSynthesizer()
                            synthesizer.speak(utterance)
                            return
                        } else {
                            let utterance3 = AVSpeechUtterance(string: imageCall + " at " + newDistance + " " + globalSystemCall)
                            utterance3.voice = AVSpeechSynthesisVoice(language: globalLanguage) // add languages audio function
                            let synthesizer3 = AVSpeechSynthesizer()
                            synthesizer3.speak(utterance3)
                            return
                        }
                    }
                }
                
            })
            // print(points.count)
           //print(objects.count)
             
        }
       
        
        
        
    }
    
    
    
    func processClassifications(for request: VNRequest, error: Error?, completionHandler: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            guard let results = request.results else {
//                self.classificationLabel.text = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
        
            if classifications.isEmpty {
               // self.classificationLabel.text = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(2)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                   completionHandler(String(format: "  (%.2f) %@", classification.confidence, classification.identifier))
                }
//                self.classificationLabel.text = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
    
    
    
    func snapShotCamera() -> (CIImage, UIImage) {
       
            guard let pixelBuffer = arView.session.currentFrame?.capturedImage else {
                fatalError("ded")
            }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer),
           context = CIContext(options: nil),
           cgImage = context.createCGImage(ciImage, from: ciImage.extent),
           uiImage = UIImage(cgImage: cgImage!, scale: 1, orientation: .right)
//            UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(imageSaveHandler(image:didFinishSavingWithError:contextInfo:)), nil)
        return (ciImage, uiImage)
        }
        
        @objc func imageSaveHandler(image:UIImage,didFinishSavingWithError error:NSError?,contextInfo:AnyObject) {
            if error != nil {
                print("Error saving picture")
            } else {
                print("Image saved successfully")
            }
        }
    
    
    func proximityToCenter() {
        // find coordinates of the center and shoot a raycast. find the distance.
        // find distance from center, use magnitude to determine direction
    }
    
    // @objc
    func startDetection(coord: XYPoint, completionHandler: @escaping () -> Void) {
            // (168.0, 368.6666564941406) approx middle
        let location = CGPoint(x: coord.getX(), y: coord.getY())
            
        let result = arView.raycast(from: location, allowing: .existingPlaneInfinite, alignment: .any)
           
            if let result = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first {
                
                // ...
               
                // 2. Visualize the intersection point of the ray with the real-world surface.
                let resultAnchor = AnchorEntity(world: result.worldTransform)
                // resultAnchor.addChild(sphere(radius: 0.01, color: .lightGray))
                // arView.scene.addAnchor(resultAnchor, removeAfter: 3)
                // 3. Try to get a classification near the tap location.
                //    Classifications are available per face (in the geometric sense, not human faces).
                
                nearbyFaceWithClassification(to: result.worldTransform.position) { (centerOfFace, classification) in
                    // ...
                    DispatchQueue.main.async {
                    
                        // 4. Compute a position for the text which is near the result location, but offset 10 cm
                        // towards the camera (along the ray) to minimize unintentional occlusions of the text by the mesh.
                        let rayDirection = normalize(result.worldTransform.position - self.arView.cameraTransform.translation)
                        let textPositionInWorldCoordinates = result.worldTransform.position - (rayDirection * 0.1)
                        
                        // 5. Create a 3D text to visualize the classification result.
                        let result = self.model(for: classification)
                        let distanceAtXYPoint = result.0
                        let _classification = result.1
                        
                        if (distanceAtXYPoint < currMinDistance) {
                            currMinDistance = distanceAtXYPoint
                        }

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
                            // faceAnchor.addChild(self.sphere(radius: 0.01, color: classification.color))
                           // self.arView.scene.addAnchor(faceAnchor, removeAfter: 3)
                        }
                        
                        // construct classification object:
                        let obj = SectionClassificationObject(direction: "wip", coord: coord, distance: distanceAtXYPoint, classification: _classification)
                        objects.append(obj)
                       // print(objects.count)
                      //  print(obj.classification)
                        
                        
                        completionHandler()
                    }
                }
                
            } else {

            }
            
        }

    

    
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
//    @IBAction func togglePlaneDetectionButtonPressed(_ button: UIButton) { // start plane detection
//        guard let configuration = arView.session.configuration as? ARWorldTrackingConfiguration else {
//            return
//        }
//        if configuration.planeDetection == [] {
//            configuration.planeDetection = [.horizontal, .vertical]
//            button.setTitle("Stop Plane Detection", for: [])
//        } else {
//            configuration.planeDetection = []
//            button.setTitle("Start Plane Detection", for: [])
//        }
//        arView.session.run(configuration)
//    }
    
    func nearbyFaceWithClassification(to location: SIMD3<Float>, completionBlock: @escaping (SIMD3<Float>?, ARMeshClassification) -> Void) {
        guard let frame = arView.session.currentFrame else {
            completionBlock(nil, .none)
            return
        }
    
        var meshAnchors = frame.anchors.compactMap({ $0 as? ARMeshAnchor })
        
        // Sort the mesh anchors by distance to the given location and filter out
        // any anchors that are too far away (4 feet is a safe upper limit).
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

            // Convert the bacse address to a safe pointer of the appropriate type
            let floatBuffer = unsafeBitCast(CVPixelBufferGetBaseAddress(depthData), to: UnsafeMutablePointer<Float32>.self)

            // Read the data (returns value of type Float)
            // Accessible values : (width-1) * (height-1) = 767 * 575
//        let distanceAtXYPoint = round(floatBuffer[Int(128 * 96)] * 10) / 10.0 // x and y is x,y coordinate
        let width = CVPixelBufferGetWidth(depthData)
        let height = CVPixelBufferGetHeight(depthData)
        var points = [XYPoint]()
        points = GeneratePoints(widthParam: width, heightParam: height, a: 7, b: 7, array: &points)
        var currentMin = Float32(100000)
        var distance: Float32
        for i in 0...points.count-1 {
            distance = floatBuffer[Int(points[i].getY() * Double(width) + points[i].getX())]
            if distance < currentMin {
                currentMin = distance
            }
        }
            
                
        let distanceAtXYPoint = currentMin
        
        
        if let model = modelsForClassification[classification] {
            model.transform = .identity

            
            return (Double(distanceAtXYPoint), classification.description)
        }
        
        
        return (Double(distanceAtXYPoint), classification.description)
    }
    
    func sphere(radius: Float, color: UIColor) -> ModelEntity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        // Move sphere up by half its diameter so that it does not intersect with the mesh
        sphere.position.y = radius
        return sphere
    }
    
  @IBAction func didTapButton(){
    guard let vc = storyboard?.instantiateViewController(identifier: "settings") as? ViewController2 else {
        return
    }
    present(vc, animated: true)
   }
    
}

