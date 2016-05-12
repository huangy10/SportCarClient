//
//  ChatAudioPlayer.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/25.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AVFoundation

let kUniversalAudioPlayerStopNotification = "universal_audio_player_stop"

protocol UniversalAudioPlayerDelegate: class {
    // 即将播放另一段音频
    func willPlayAnotherAudioFile()
    // 即将开始播放
    func willStartPlaying()
    
    func playProcessUpdate(process: Double)
    
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
    var audioURL: NSURL?
    
    var player: AVAudioPlayer?
    
    var playing: Bool? {
        get {
            return player?.playing
        }
    }
    
    var playProccessListener: NSTimer?
    
    func play(audioURL: NSURL, newDelegate: UniversalAudioPlayerDelegate) {
        self.audioURL = audioURL
        delegate = newDelegate
        guard let soundData = NSData(contentsOfURL: audioURL) else {
            delegate?.failToPlay()
            return
        }
        do {
            player?.stop()
            
            player = try AVAudioPlayer(data: soundData)
            player?.delegate = self
            playProccessListener = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(UniversalAudioPlayer.audioPlayerProcessUpdate), userInfo: nil, repeats: true)
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
    
    func isPlayingURLStr(audioURLStr: String) -> Bool{
        if player != nil && player!.playing && audioURL?.absoluteString == audioURLStr {
            return true
        }else {
            return false
        }
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        // 当播放被打断时视为播放成功
        self.player?.pause()
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer) {
        self.player?.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
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
}