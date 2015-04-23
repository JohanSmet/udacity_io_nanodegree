//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Johan Smet on 14/04/15.
//  Copyright (c) 2015 JustCode. All rights reserved.
//

import UIKit
import AVFoundation


class PlaySoundsViewController: UIViewController {

    var avPlayer: AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    
    var receivedAudio : RecordedAudio!
 
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // events
    //
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize the audio player
        avPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        avPlayer.prepareToPlay()
        avPlayer.enableRate = true;
        
        // initialize the audio engine
        audioEngine = AVAudioEngine()
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    ///////////////////////////////////////////////////////////////////////////////////
    //
    // actions
    //
    
    @IBAction func playbackSlow(sender: UIButton) {
        playbackSoundVariableRate(0.5)
    }
    
    @IBAction func playbackFast(sender: UIButton) {
        playbackSoundVariableRate(1.5)
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        playbackSoundVariablePitch(1000)
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        playbackSoundVariablePitch(-1000)
    }
    
    @IBAction func stopPlayback(sender: UIButton) {
        playbackStop()
    }

    ///////////////////////////////////////////////////////////////////////////////////
    //
    // utility functions
    //
    
    private func playbackStop() {
        avPlayer.stop()
        audioEngine.stop()
    }
    
    func playbackSoundVariableRate(rate : Float)  {
        playbackStop()
        avPlayer.rate = rate
        avPlayer.currentTime = 0.0
        avPlayer.play()
    }
    
    func playbackSoundVariablePitch(pitch : Float)  {
        playbackStop()
        audioEngine.reset()
        
        // create an audio player node
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // create the pitch effect
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // connect the nodes
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: audioFile.processingFormat)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: audioFile.processingFormat)
        
        // start playing audio
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
}
