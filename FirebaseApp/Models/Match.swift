//
//  Event.swift
//  FirebaseApp
//
//  Created by Dimitar Dimitrov on 20.02.20.
//

import Foundation
import CoreMedia

class Event {
    var type:String // trqq da e enum, ama ba li go.
                    // GOAL!, FOUL!, COOL!, kakto dolu.
    var start:CMTime
    var end:CMTime
    
    init(type:String, start:CMTime, end:CMTime){
        self.type = type;
        self.start = start;
        self.end = end
    }
}


class MatchLog {
    var title:String
    var createdAt:Date
    
    var videoURL:URL
    var events: [Event]
    
    init(title:String, createdAt: Date, events:[Event], videoURL:URL){
        self.title = title
        self.createdAt = createdAt
        self.events = events
        self.videoURL = videoURL
    }
}


func getTest () -> MatchLog {
    var testevents = [Event]()
    
    testevents.append(Event(type: "GOAL!", start: time(seconds: 5), end: time(seconds: 10)))

    testevents.append(Event(type: "COOL!", start: time(seconds: 15), end: time(seconds: 20)))
    
    testevents.append(Event(type: "FOUL!", start: time(seconds: 25), end: time(seconds: 30)))
    return MatchLog(title: "First Match EVER!", createdAt: Date(timeIntervalSinceNow: 5), events: testevents, videoURL: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8")!)
}

func time (seconds:Int) -> CMTime {
    return CMTime(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
}
