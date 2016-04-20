//
//  MessageManager.swift
//  SportCarClient
//
//  Created by 黄延 on 16/4/19.
//  Copyright © 2016年 WoodyHuang. All rights reserved.
//

import UIKit
import XMPPFramework

class MessageManager: NSObject, XMPPRosterDelegate, XMPPStreamDelegate {
    
    static let defaultManager = MessageManager()
    
    var xmppStream: XMPPStream!
    var xmppRoster: XMPPRoster!
    
    override init() {
        xmppStream = XMPPStream()
        xmppStream.hostName = kHostName
        let xmppRosterStorage = XMPPRosterCoreDataStorage()
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        
        super.init()
    }
    
    deinit {
        xmppStream.removeDelegate(self)
    }
    
    func setupStream() {
        xmppRoster.activate(xmppStream)
        xmppStream.addDelegate(self, delegateQueue: dispatch_get_main_queue())
        xmppRoster.addDelegate(self, delegateQueue: dispatch_get_main_queue())
    }
    
    func goOnline() {
        let presence = XMPPPresence()
        xmppStream.sendElement(presence)
    }
    
    func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        xmppStream.sendElement(presence)
    }
    
    func register() {
//        let password = "default_password"
//        guard let user = MainManager.sharedManager.hostUser else {
//            return
//        }
//        xmppStream.myJID = user.xmppID
//        do {
//            try xmppStream.registerWithPassword(password)
//        } catch (let e) {
//            print(e)
//        }
    }
    
    func connect() -> Bool {
        if !xmppStream.isConnected(), let user = MainManager.sharedManager.hostUser{
            let jabberID = user.xmppID
            print(jabberID)
            let myPassword = "default_password"
            if !xmppStream.isDisconnected() {
                return true
            }
            xmppStream.myJID = jabberID
            do {
                try xmppStream.connectWithTimeout(XMPPStreamTimeoutNone)
                print("xmppserver connection success")
                return true
            } catch {
                return false
            }
        }
        return false
    }
    
    func disconnect() {
        goOffline()
        xmppStream.disconnect()
    }
    
    func xmppStream(sender: XMPPStream!, socketDidConnect socket: GCDAsyncSocket!) {
        do {
            try xmppStream.authenticateWithPassword("default_password")
        } catch {
            print("xmpp: cannot authenticate")
        }
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        print("connected")
        do {
            try xmppStream.authenticateWithPassword("default_password")
        } catch {
            print("xmpp: cannot authenticate")
        }
    }
    
    func xmppStreamDidAuthenticate(sender: XMPPStream!) {
        goOnline()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("xmpp: did receive iq")
        print(iq)
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("xmpp: did send message")
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        let msg = message.elementForName("body")
        let from = message.attributeForName("from")
        
        let m = ["msg": msg, "sender": from]
        print(m)
    }
    
    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: NSError!) {
        print("xmpp: fail to send message:\n\(error)")
    }
    
    func xmppRoster(sender: XMPPRoster!, didReceiveRosterItem item: DDXMLElement!) {
        print("xmpp: did receive roster item")
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        let presenceType = presence.type()
        let myUserName = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != myUserName {
            print("did Receive presence from \(presenceFromUser)")
            print(presenceType)
        }
    }
}
