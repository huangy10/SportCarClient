//
//  ChatAudioPlayer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AVFoundation
import Dollar

let kUniversalAudioPlayerStopNotification = "universal_audio_player_stop"

protocol UniversalAudioPlayerDelegate: class {
    // 即将播放另一段音频
    func willPlayAnotherAudioFile()
    // 即将开始播放
    func willStartPlaying()
    
    func playProcessUpdate(_ process: Double)
    
    func playDidFinished()
    
    func getIdentifier() -> String
    
    func failToPlay()
}


class UniversalAudioPlayer: NSObject, AVAudioPlayerDelegate {
    
    static let sharedPlayer = UniversalAudioPlayer()
    
    weak var delegate: UniversalAudioPlayerDelegate? {
        willSet {
            if self.delegate != nil && self.delegate?.getIdentifier() != newValue?.getIdentifier() {
                self.delegate?.willPlayAnotherAudioFile()
            }
        }
    }
    // 正在播放的音频的url
    var audioURL: URL?
    
    var player: AVAudioPlayer?
    
    var playing: Bool? {
        get {
            return player?.isPlaying
        }
    }
    
    var playProccessListener: Timer?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        // TODO: Add observer to monitor the audio interruption
    }
    
    func play(_ audioURL: URL, newDelegate: UniversalAudioPlayerDelegate) {
        self.audioURL = audioURL
        delegate = newDelegate
        guard let soundData = try? Data(contentsOf: audioURL) else {
            delegate?.failToPlay()
            return
        }
        do {
            player?.stop()
            
            player = try AVAudioPlayer(data: soundData)
            
            player?.delegate = self
            playProccessListener = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(UniversalAudioPlayer.audioPlayerProcessUpdate), userInfo: nil, repeats: true)
            delegate?.willStartPlaying()
            player?.prepareToPlay()
            player?.play()
        }catch _ {
            delegate?.failToPlay()
        }
    }
    
    func stop() {
        playProccessListener?.invalidate()
        player?.stop()
    }
    
    func isPlayingURLStr(_ audioURLStr: String) -> Bool{
        if player != nil && player!.isPlaying && audioURL?.absoluteString == audioURLStr {
            return true
        }else {
            return false
        }
    }
    
//    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
//        // 当播放被打断时视为播放成功
//        self.player?.pause()
//    }
//    
//    func audioPlayerEndInterruption(_ player: AVAudioPlayer) {
//        self.player?.play()
//    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playProccessListener?.invalidate()
        self.player = nil
        self.delegate?.playDidFinished()
    }
    
    func audioPlayerProcessUpdate() {
        if player == nil {
            return
        }
        delegate?.playProcessUpdate(player!.currentTime / player!.duration)
    }
    
    func configAudioSession() {
        
    }
    
    func isOnSpeaker() -> Bool {
        let session = AVAudioSession.sharedInstance()
        let outputs = session.currentRoute.outputs
        let result = $.find(outputs, callback: { $0.portType == AVAudioSessionPortBuiltInSpeaker})
        return result != nil
    }
    
    func setPlayFromSpeaker() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(.speaker)
    }
    
    func setToUseDefaultOutputType() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try session.overrideOutputAudioPort(.none)
    }
}
