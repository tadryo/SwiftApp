//
//  ViewController.swift
//  ClapPro
//
//  Created by 蓼沼諒也 on 2021/08/25.
//

import UIKit
import AVFoundation

let record_image = UIImage(named:"record_image")!
let play_image = UIImage(named:"play_image")!
let stop_image = UIImage(named:"stop_image")!

class DrawView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.backgroundColor = UIColor.clear;
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        let rectangle = UIBezierPath(rect: CGRect(x: 700, y: 500, width: 130, height: 100))
        // 内側の色
        UIColor(red: 1, green: 0.5, blue: 0, alpha: 1.0).setFill()
        // 内側を塗りつぶす
        rectangle.fill()
        // 線の色
        UIColor(red: 1, green: 0.5, blue: 0, alpha: 1.0).setStroke()
        // 線の太さ
        rectangle.lineWidth = 2.0
        // 線を塗りつぶす
        rectangle.stroke()
    }
}

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!

    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func record(){
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord)
        try! session.setActive(true)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        audioRecorder = try! AVAudioRecorder(url: getURL(), settings: settings)
        audioRecorder.delegate = self
        audioRecorder.record()
        recordButton.isEnabled = false
        playButton.isEnabled = false
//        let drawView = DrawView(frame: self.view.bounds)
//        self.view.addSubview(drawView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [self] in
            audioRecorder.stop()
            recordButton.setTitle("録音開始", for: .normal)
            recordButton.isEnabled = true
            playButton.isEnabled = true
        }
    }

    @IBAction func play(){
        if !isPlaying {
            audioPlayer = try! AVAudioPlayer(contentsOf: getURL())
            audioPlayer.delegate = self
            audioPlayer.play()
            isPlaying = true
            playButton.setTitle("停止", for: .normal)
            recordButton.isEnabled = false
        }else{
            audioPlayer.stop()
            isPlaying = false
            playButton.setTitle("再生", for: .normal)
            recordButton.isEnabled = true
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            
            audioPlayer.stop()
            isPlaying = false

            playButton.setTitle("再生", for: .normal)
            recordButton.isEnabled = true
            
        }
    }

    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirect = paths[0]
        let url = docsDirect.appendingPathComponent("recording.m4a")
        return url
    }
}
