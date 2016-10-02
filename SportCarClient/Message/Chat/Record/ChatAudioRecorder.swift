//
//  ChatAudioRecorder.swift
//  SportCarClient
//
//  Created by 黄延 on 16/2/2.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import Foundation
import AVFoundation

protocol ChatAudioRecordDelegate: class {
    func audioWillStartRecording()
    func audioDidFinishRecording(_ audioURL: URL?)
    func audioDidCancelRecording()
    func audioFailToRecord(_ errorMessage: String)
}


class ChatAudioRecorder: NSObject, AVAudioRecorderDelegate {
    // 代理
    weak var delegate: ChatAudioRecordDelegate?
    /// An audio session to manage recording.
    fileprivate var recordingSession: AVAudioSession!
    /// An audio recorder to handle the actual reading and saving of data.
    fileprivate var audioRecorder: AVAudioRecorder!
    
    var audioURL: URL!
    
    var startTime: Date!
    
    var isRecording: Bool {
        return audioRecorder == nil
    }
    
    init(delegate: ChatAudioRecordDelegate) {
        super.init()
        recordingSession = AVAudioSession.sharedInstance()
        self.delegate = delegate
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission({ (allowed: Bool) -> Void in
                if !allowed {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.delegate?.audioFailToRecord("Fail to get permisssion")
                    })
                }
            })
        } catch {
            // fail to record
            delegate.audioFailToRecord("")
        }
    }
    
    func startRecording(_ filename: String?) {
        UniversalAudioPlayer.sharedPlayer.stop()
        
        let cacheFilename = filename ?? (UUID().uuidString + ".m4a")
//        let cacheFilePath = (getCachedAudioDirectory() as AnyObject).appendingPathComponent(cacheFilename)
        let cacheFilePath = (getCachedAudioDirectory() as NSString).appendingPathComponent(cacheFilename) as String
        let cacheFileURL = URL(fileURLWithPath: cacheFilePath)
        audioURL = cacheFileURL
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: cacheFileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            startTime = Date()
        } catch {
            finishRecording(false)
        }
    }
    
    func finishRecording(_ success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        do {
            try recordingSession.setActive(false)
        } catch {}
        if success {
            let now = Date()
            let interval = now.timeIntervalSince(startTime)
            if interval < 1 {
                delegate?.audioDidFinishRecording(nil)
            }else{
                delegate?.audioDidFinishRecording(audioURL)
            }
        }else{
            // 失败时开始尝试删除已经创建的缓存文件
            let fileManager = FileManager.default
            do{
                try fileManager.removeItem(at: audioURL)
            }catch {
            }
            delegate?.audioDidCancelRecording()
        }
    }
    
    func getCachedAudioDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let cacheDirectory: AnyObject = paths[0] as AnyObject
        let targetFolder = cacheDirectory.appendingPathComponent("record_audio_cache")
        do {
            if !FileManager.default.fileExists(atPath: targetFolder) {
                try FileManager.default.createDirectory(atPath: targetFolder, withIntermediateDirectories: false, attributes: nil)
            }
        }catch{
            return cacheDirectory as! String
        }
        return targetFolder
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(false)
        }
    }
}
