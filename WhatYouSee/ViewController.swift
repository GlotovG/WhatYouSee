//
//  ViewController.swift
//  WhatYouSee
//
//  Created by Gennadiy Glotov on 29.07.2018.
//  Copyright © 2018 Gennadiy Glotov. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let synth = AVSpeechSynthesizer()
    var myUtterance = AVSpeechUtterance(string: "")
    var myString = ""
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
            
            //№1 создаем переменную с фото для нашего ML ядра
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Не получилось конвертировать полученное фото UIImage -> CIImage!")
            }
            
            detect(image: ciimage)
            
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    //№2 создаем функцию для работы модели с фото
    func detect (image: CIImage){
        //№3 загружаем ядро ML
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else{
            fatalError("Ошибка загрузки CoreML!")
        }
        
        //№4 создание запроса в загруженное CoreML
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Ошибка обработки запроса в CoreML")
            }
            //print(results)
            
            if let firstResult = results.first {
                print(firstResult.identifier)
                self.navigationItem.title = firstResult.identifier
                self.speachText (textToSpeach: "Мне кажется это")
                self.speachText (textToSpeach: firstResult.identifier)
            }
            
        }
        
        //№5 пробуем получить заголовок
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        //старт работы камеры
        present(imagePicker, animated: true, completion: nil)
    }
    
    func speachText (textToSpeach: String){
        myUtterance = AVSpeechUtterance(string: textToSpeach)
        myUtterance.rate = 0.5
        synth.speak(myUtterance)
    }
}

