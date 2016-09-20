//
//  ChatAudioController.swift
//  SportCarClient
//
//  Created by 黄延 on 16/1/23.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import Accelerate
import AudioToolbox


class AudioWaveDrawEngine: NSObject {
    
    var loading: Bool = true
    
    var preferredSampleNum: UInt32
    var maxMagnitude: Float = 1
    var normalizeCoeff: Float = 0
    var sampledata: [Float] = []
    var loadedSamples: Int = 0
    /// 指向音频文件reference
    var extAFRef: ExtAudioFileRef? = nil
    let defaultSampleRate: Float64 = 44100
    var extAFRateRatio: Float64 = 1 // 音频码率，默认44.1k
    let extAFNumChannels: Int = 2   // 音频文件的channel数量，这里默认是2
    var extAFReachedEOF = false
    var binSize: UInt32 = 1500      // 采样间隔
    var lengthInFrames: UInt32 = 0  // 音频文件的长度（帧）
    var lengthInSec: Double = 0

    
    /// 音频文件的URL
    var audioFileURL: URL
    var onFinished: (_ engine: AudioWaveDrawEngine)->()
    /**
     创建一个音频文件分析器
     
     - parameter audioFileURL: 文件URL
     - parameter onFinished:   完成后执行的closure，这个closure会放在主线程执行
     
     - returns: -
     */
    init(audioFileURL: URL, preferredSampleNum: UInt32, onFinished: @escaping (_ engine: AudioWaveDrawEngine)->(), async: Bool = true) {
        self.audioFileURL = audioFileURL
        self.onFinished = onFinished
        self.preferredSampleNum = preferredSampleNum
        super.init()
        if async{
            self.performSelector(inBackground: #selector(AudioWaveDrawEngine.startSampling), with: nil)
        }else{
            startSampling()
        }
    }
    
    func startSampling() {
        // 读取文件
        var err: OSStatus
        let audioFileURLRef: CFURL = self.audioFileURL as CFURL
        err = ExtAudioFileOpenURL(audioFileURLRef, &extAFRef)
        if err != noErr {
            assertionFailure("Can not Read Audio File")
        }
        // 提取音频文件的format信息
        var infoSize: UInt32 = 0
        err = ExtAudioFileGetPropertyInfo(extAFRef!, kExtAudioFileProperty_FileDataFormat, &infoSize, nil)
        if err != noErr {
            assertionFailure("Can not Extract File Info")
        }
        var fileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
        memset(&fileFormat, 0, MemoryLayout<AudioStreamBasicDescription>.size)
        // 读取音频文件的格式
        err = ExtAudioFileGetProperty(extAFRef!, kExtAudioFileProperty_FileDataFormat, &infoSize, &fileFormat)
        if err != noErr {
            assertionFailure("")
        }
        //
        extAFRateRatio = defaultSampleRate / fileFormat.mSampleRate
        // 读取文件的长度并且换算成时间
        var framesNum: UInt32 = 0
        var writable: DarwinBoolean = false
        err = ExtAudioFileGetPropertyInfo(extAFRef!, kExtAudioFileProperty_FileLengthFrames, &infoSize, &writable)
        if err != noErr {
            assertionFailure()
        }
        //
        err = ExtAudioFileGetProperty(extAFRef!, kExtAudioFileProperty_FileLengthFrames, &infoSize, &framesNum)
        if err != noErr {
            assertionFailure()
        }
        lengthInFrames = framesNum
        lengthInSec = Double(framesNum) / fileFormat.mSampleRate
        // 计算计算采样间隔
        binSize = lengthInFrames / preferredSampleNum
        
        loadAudioData()
    }
    
    func loadAudioData() {
        extAFReachedEOF = false
        //
        var clientFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
        memset(&clientFormat, 0, MemoryLayout<AudioStreamBasicDescription>.size)
        clientFormat.mFormatID = kAudioFormatLinearPCM
        clientFormat.mSampleRate = defaultSampleRate
        clientFormat.mFormatFlags = kAudioFormatFlagIsFloat
        clientFormat.mChannelsPerFrame = UInt32(extAFNumChannels)
        clientFormat.mBitsPerChannel = UInt32(MemoryLayout<Float>.size * 8)
        clientFormat.mFramesPerPacket = 1
        clientFormat.mBytesPerFrame = UInt32(extAFNumChannels * MemoryLayout<Float>.size)
        clientFormat.mBytesPerPacket = UInt32(extAFNumChannels * MemoryLayout<Float>.size)
        let err: OSStatus = ExtAudioFileSetProperty(extAFRef!, kExtAudioFileProperty_ClientDataFormat, UInt32(MemoryLayout<AudioStreamBasicDescription>.size), &clientFormat)
        if err != noErr {
            assertionFailure()
        }
        //
        let NUMBER_PER_READ = binSize
        var audio: [[Float]] = []
        for _ in 0..<extAFNumChannels {
            audio.append([Float](repeating: 0, count: Int(NUMBER_PER_READ)))
        }
        sampledata = [Float](repeating: 0, count: Int(preferredSampleNum))
        
        var packetsRead: Int = 0
        while !extAFReachedEOF {
            let k = readConsecutive(NUMBER_PER_READ, audio: &audio)
            if k < 0 {
                assertionFailure()
                break
            }
            packetsRead += k
            caculateSampleFromCache(audio, length: k)
        }
        normalizeSampleData(maxMagnitude)
        ExtAudioFileDispose(extAFRef!)
        
        loading = false
        DispatchQueue.main.async { () -> Void in
            self.onFinished(self)
        }
    }
    
    func readConsecutive(_ numFrames: UInt32,audio: inout [[Float]]) -> Int{
        var err: OSStatus = noErr
        if extAFRef == nil{
            return -1
        }
        
        var kSegmentSize = 0
        if extAFRateRatio < 1.0 {
            kSegmentSize = Int(Float64(numFrames * UInt32(extAFNumChannels)) / extAFRateRatio + 0.5)
        }else{
            kSegmentSize = Int(Float64(numFrames * UInt32(extAFNumChannels)) * extAFRateRatio + 0.5)
        }
        var data: [Float] = [Float](repeating: 0, count: kSegmentSize * MemoryLayout<Float>.size)
        // 创建容纳取出数据的缓冲buffer
        var bufList: AudioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(
            mNumberChannels: UInt32(extAFNumChannels), mDataByteSize: numFrames * UInt32(extAFNumChannels * MemoryLayout<Float>.size), mData: &data
            ))
        var loadedPackets: UInt32 = numFrames
        err = ExtAudioFileRead(extAFRef!, &loadedPackets, &bufList)
        if err == noErr {
//             let data = bufList.mBuffers.mData
            for c in 0..<Int(extAFNumChannels) {
                for v in 0..<Int(numFrames) {
                    let index = v * extAFNumChannels + c
                    if v < Int(loadedPackets){
                        audio[c][v] = data[index]
                    }else{
                        audio[c][v] = 0
                    }
                }
            }
        }
        if loadedPackets < numFrames {
            extAFReachedEOF = true
        }
        return Int(loadedPackets)
    }
    
    /**
     从读取的缓存中提取采样
     
     - parameter audioCache: 音频缓存
     - parameter length:     缓存的长度
     */
    func caculateSampleFromCache(_ audioCache: [[Float]], length: Int) {
        var index: Int = 0
        let sampleInterval = Int(binSize)
        for v in stride(from: 0, to: length, by: sampleInterval) {
//        for var v: Int = 0; v < length; v += sampleInterval {
            var maxVal: Float = 0
            for c in 0..<extAFNumChannels {
                for p in 0..<sampleInterval {
                    index = v + p
                    if index < length {
                        if maxVal < audioCache[c][index] {
                            maxVal = audioCache[c][index]
                            if maxVal > normalizeCoeff {
                                normalizeCoeff = maxVal
                            }
                        }else if maxVal < -audioCache[c][index] {
                            maxVal = -audioCache[c][index]
                            if maxVal > normalizeCoeff {
                                normalizeCoeff = maxVal
                            }
                        }
                    }else {
                        break
                    }
                }
            }
            if loadedSamples < Int(preferredSampleNum){
                sampledata[loadedSamples] = maxVal
                loadedSamples += 1
            }else {
                break
            }
        }
    }
    
    /**
     将采样数据归一化，并将幅度设置为制定的值
     */
    func normalizeSampleData(_ magnitude: Float) {
        var coeff = 1 / normalizeCoeff * magnitude
        vDSP_vsmul(&sampledata, 1, &coeff, &sampledata, 1, UInt(preferredSampleNum))
    }
    
    class func getAudioLengthInSec(_ audioURL: URL) -> Double {
        var err: OSStatus
        let audioURLRef: CFURL = audioURL as CFURL
        var extAFRef: ExtAudioFileRef? = nil
        err = ExtAudioFileOpenURL(audioURLRef, &extAFRef)
        if err != noErr{
            return -1
        }
        var infoSize: UInt32 = 0
        err = ExtAudioFileGetPropertyInfo(extAFRef!, kExtAudioFileProperty_FileDataFormat, &infoSize, nil)
        if err != noErr{
            return -1
        }
        var fileFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
        memset(&fileFormat, 0, MemoryLayout<AudioStreamBasicDescription>.size)
        err = ExtAudioFileGetProperty(extAFRef!, kExtAudioFileProperty_FileDataFormat, &infoSize, &fileFormat)
        if err != noErr {
            return -1
        }
        let sampleRate = fileFormat.mSampleRate
        var frameNum: UInt32 = 0
        var writable: DarwinBoolean = false
        err = ExtAudioFileGetPropertyInfo(extAFRef!, kExtAudioFileProperty_FileLengthFrames, &infoSize, &writable)
        if err != noErr{
            return -1
        }
        err = ExtAudioFileGetProperty(extAFRef!, kExtAudioFileProperty_FileLengthFrames, &infoSize, &frameNum)
        if err != noErr {
            return -1
        }
        return Double(frameNum) / Double(sampleRate)
    }
    
}
