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
    func audioDidFinishRecording(audioURL: NSURL?)
    func audioDidCancelRecording()
    func audioFailToRecord(errorMessage: String)
}


class ChatAudioRecorder: NSObject, AVAudioRecorderDelegate {
    // 代理
    weak var delegate: ChatAudioRecordDelegate?
    /// An audio session to manage recording.
    private var recordingSession: AVAudioSession!
    /// An audio recorder to handle the actual reading and saving of data.
    private var audioRecorder: AVAudioRecorder!
    
    var audioURL: NSURL!
    
    var startTime: NSDate!
    
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
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.audioFailToRecord("Fail to get permisssion")
                    })
                }
            })
        } catch {
            // fail to record
            delegate.audioFailToRecord("")
        }
    }
    
    func startRecording(filename: String?) {
        UniversalAudioPlayer.sharedPlayer.stop()
        
        let cacheFilename = filename ?? (NSUUID().UUIDString + ".m4a")
        let cacheFilePath = (getCachedAudioDirectory() as AnyObject).stringByAppendingPathComponent(cacheFilename)
        let cacheFileURL = NSURL(fileURLWithPath: cacheFilePath)
        audioURL = cacheFileURL
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: cacheFileURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            startTime = NSDate()
        } catch {
            finishRecording(false)
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        do {
            try recordingSession.setActive(false)
        } catch {}
        if success {
            let now = NSDate()
            let interval = now.timeIntervalSinceDate(startTime)
            if interval < 1 {
                delegate?.audioDidFinishRecording(nil)
            }else{
                delegate?.audioDidFinishRecording(audioURL)
            }
        }else{
            // 失败时开始尝试删除已经创建的缓存文件
            let fileManager = NSFileManager.defaultManager()
            do{
                try fileManager.removeItemAtURL(audioURL)
            }catch {
            }
            delegate?.audioDidCancelRecording()
        }
    }
    
    func getCachedAudioDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
        let cacheDirectory: AnyObject = paths[0]
        let targetFolder = cacheDirectory.stringByAppendingPathComponent("record_audio_cache")
        do {
            if !NSFileManager.defaultManager().fileExistsAtPath(targetFolder) {
                try NSFileManager.defaultManager().createDirectoryAtPath(targetFolder, withIntermediateDirectories: false, attributes: nil)
            }
        }catch{
            return cacheDirectory as! String
        }
        return targetFolder
    }
    
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(false)
        }
    }
}
