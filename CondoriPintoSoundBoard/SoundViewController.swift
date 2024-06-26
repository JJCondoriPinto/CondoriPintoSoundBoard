//
//  SoundViewController.swift
//  CondoriPintoSoundBoard
//
//  Created by Neals Paye Aguilar on 13/05/24.
//

import UIKit
import AVFoundation
import CoreData

class SoundViewController: UIViewController {
    
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var grabarButton: UIButton!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio: AVAudioPlayer?
    var audioURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
    }
    
    func configurarGrabacion() {
    do {
    
        let session = AVAudioSession.sharedInstance()
        try session.setCategory (AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
        try session.overrideOutputAudioPort(.speaker)
        try session.setActive(true)
        //creando direccion para el archivo de audio
        let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask,
        true).first!
        let pathComponents = [basePath, "audio.m4a"]
        audioURL = NSURL.fileURL (withPathComponents: pathComponents)!
        //impresion de ruta donde se guardan los archivos
        print("*********************")
        print(audioURL!)
        print("*********************")
        //crear opciones para el grabador de audio
        var settings: [String: AnyObject] = [:]
        settings [AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
        settings[AVSampleRateKey] = 44100.0 as AnyObject?
        settings[AVNumberOfChannelsKey] = 2 as AnyObject?
        //crear el objeto de grabacion de audio
        grabarAudio = try AVAudioRecorder (url: audioURL!, settings: settings)
        grabarAudio!.prepareToRecord()
    }catch let error as NSError{
        print(error)
    }
    }
    
    func getContext() -> NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func guardarContexto() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = getContext()
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.audio = NSData(contentsOf: audioURL!)! as Data
        guardarContexto()
        navigationController!.popViewController(animated: true)
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo...")
        } catch {}
    }
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
            grabarAudio?.stop()
            grabarButton?.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
        } else {
            grabarAudio?.record()
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
