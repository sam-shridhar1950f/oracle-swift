 //
//  ViewController2.swift
//  VisualizingSceneSemantics
//
//  Created by Sam Shridhar on 8/4/21.
//  Copyright © 2021 Apple. All rights reserved.
//
import SwiftUI

class ViewController2: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    // time slider
    @IBOutlet weak var textLabel:UILabel?
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var language: UILabel!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var switch_: UISwitch!
    @IBOutlet weak var menu: UIButton!
    @IBOutlet weak var hapticSwitch: UISwitch!
    @IBOutlet weak var langpicker: UIPickerView!
    //var pickerData = ["English", "Spanish", "French", "Mandarin", "Hindi", "Arabic", "Bengali", "Russian", "Portuguese", "Korean", "Japanese", "German", "Hausa", "Turkish", "Dutch", "Vietnamese", "Indonesian"]
    var pickerData = ["English", "Spanish", "French", "Mandarin", "Hindi", "Arabic", "Bengali", "Russian", "Portuguese", "Korean", "Japanese", "German", "Turkish", "Dutch", "Indonesian"]

    
    
    
    

    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        langpicker.delegate = self
        langpicker.dataSource = self
        label.text =  "Time Interval (" + String(globalInterval) + " sec)"
        langpicker.selectRow(pickerData.firstIndex(of: globalLang.capitalized)!, inComponent: 0, animated: false)

        textLabel?.text = "Click the button"
        switch_.setOn(globalSystem == " centimeters", animated: false)
        hapticSwitch.setOn(hapticBool == true, animated: false)
        

    }
        
    func numberOfComponents(in langpicker: UIPickerView) -> Int {
        return 1
    }
        
    func pickerView(_ langpicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ langpicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    func pickerView(_ langpicker: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        globalLang = pickerData[row].lowercased()
        switch globalLang {
            case "spanish":
                globalSystemCall = spanishDict[globalSystem]!
                globalLanguage = "es-ES"
            case "french":
                globalSystemCall = frenchDict[globalSystem]!
                globalLanguage = "fr-FR"
            case "mandarin":
                globalSystemCall = mandarinDict[globalSystem]!
                globalLanguage = "zh-Hans"
            case "hindi":
                globalSystemCall = hindiDict[globalSystem]!
                globalLanguage = "hi-HI"
            case "arabic":
                globalSystemCall = arabicDict[globalSystem]!
                globalLanguage = "ar-SA"
            case "bengali":
                globalSystemCall = bengaliDict[globalSystem]!
                globalLanguage = "hi-IN"
           case "russian":
                globalSystemCall = russianDict[globalSystem]!
                globalLanguage = "ru-RU"
           case "portuguese":
                globalSystemCall = portugueseDict[globalSystem]!
                globalLanguage = "pt-BR"
           case "korean":
                globalSystemCall = koreanDict[globalSystem]!
                globalLanguage = "ko-KR"
           case "japanese":
                globalSystemCall = japaneseDict[globalSystem]!
                globalLanguage = "ja-JP"
           case "german":
                globalSystemCall = germanDict[globalSystem]!
                globalLanguage = "de-DE"
           case "hausa":
                globalSystemCall = hausaDict[globalSystem]!
                globalLanguage = "en-US"
           case "turkish":
                globalSystemCall = turkishDict[globalSystem]!
                globalLanguage = "tr-TR"
           case "dutch":
                globalSystemCall = dutchDict[globalSystem]!
                globalLanguage = "nl-NE"
           case "vietnamese":
                globalSystemCall = vietnameseDict[globalSystem]!
                globalLanguage = "en-US"
           case "indonesian":
                globalSystemCall = indonesianDict[globalSystem]!
                globalLanguage = "id-ID"
            default:
                globalSystemCall = globalSystem
                globalLanguage = "en-US"
        }
        print(globalLang)
    }

//    @IBAction func menuValueChanged(_ sender: Any) {
//        globalLang = menu.menu?.selectedElements.description.lowercased() ?? "english"
//    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        globalInterval = Int(slider.value)
        label.text = "Time Interval  (" + String(globalInterval) + " sec)"
    }
    
    
    //    @IBAction func submitLanguage(_ send: Any) {
//        globalLanguage = String(textfield.text!)
//        print(globalLanguage)
//
//
//    }
    
    @IBAction func systemValueChanged(_ sender: Any) {
        if switch_.isOn != true {
            globalSystem = "inches"
        }
        else {
            globalSystem = "centimeters"
        }
    }
    
    @IBAction func hapticValueChanged(_ sender: Any) {
        hapticBool = hapticSwitch.isOn
    }
    
    // still need to add unit conversions, only unit names have changed

    
    
    
    
}
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


