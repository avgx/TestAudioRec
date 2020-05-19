//
//  RecordAudioViewController.swift
//  TestAudioRec
//
//  Created by Alexey Govorovsky on 19.05.2020.
//  Copyright © 2020 ITV/Axxonsoft. All rights reserved.
//
// https://gist.github.com/vikaskore/e5d9fc91feac455d6b4778b3d768a6e8

import UIKit
import AVFoundation
import SnapKit

class RecordAudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    lazy var recordButton: UIButton = {
        return UIButton(frame: .zero)
    }()
    lazy var playButton: UIButton = {
           return UIButton(frame: .zero)
   }()
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup Recorder
        self.setupView()
    }
    
    func setupView() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record
                    }
                }
            }
        } catch {
            // failed to record
        }
    }
    
    func loadRecordingUI() {
        recordButton.isEnabled = true
        playButton.isEnabled = false
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.addTarget(self, action: #selector(recordAudioButtonTapped), for: .touchUpInside)
        playButton.setTitle("Play", for: .normal)
        playButton.addTarget(self, action: #selector(playAudioButtonTapped), for: .touchUpInside)
        
        view.addSubview(recordButton)
        view.addSubview(playButton)
        self.view.backgroundColor = .white
        
        recordButton.snp.makeConstraints{
            $0.width.equalTo(200)
            $0.height.equalTo(40)
            $0.center.equalToSuperview()
        }
        playButton.snp.makeConstraints{
            $0.top.equalTo(recordButton.snp.bottom)
            $0.width.equalTo(200)
            $0.height.equalTo(40)
            $0.centerX.equalToSuperview()
        }
        
        recordButton.backgroundColor = .green
        playButton.backgroundColor = .yellow
    }
    
    @objc func recordAudioButtonTapped(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func startRecording() {
        let audioFilename = getFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("Tap to Stop", for: .normal)
            playButton.isEnabled = false
        } catch {
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
        
        playButton.isEnabled = true
        recordButton.isEnabled = true
    }
    
    @objc func playAudioButtonTapped(_ sender: UIButton) {
        if (sender.titleLabel?.text == "Play"){
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
            preparePlayer()
            audioPlayer.play()
        } else {
            audioPlayer.stop()
            sender.setTitle("Play", for: .normal)
        }
    }
    
    func preparePlayer() {
        var error: NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: getFileURL() as URL)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("AVAudioPlayer error: \(err.localizedDescription)")
        } else {
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 10.0
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileURL() -> URL {
        let path = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return path as URL
    }
    
    //MARK: Delegates
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.isEnabled = true
        playButton.setTitle("Play", for: .normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    //MARK: To upload video on server
    
    func uploadAudioToServer() {
        /*Alamofire.upload(
         multipartFormData: { multipartFormData in
         multipartFormData.append(getFileURL(), withName: "audio.m4a")
         },
         to: "https://yourServerLink",
         encodingCompletion: { encodingResult in
         switch encodingResult {
         case .success(let upload, _, _):
         upload.responseJSON { response in
         Print(response)
         }
         case .failure(let encodingError):
         print(encodingError)
         }
         })*/
    }
    
    
}
