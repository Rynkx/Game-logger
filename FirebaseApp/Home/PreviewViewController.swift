//
//  PreviewViewController.swift
//  FirebaseApp
//
//  Created by Dimitar Dimitrov on 19.02.20.
//

import UIKit
import AVKit

class PreviewViewController: UIViewController {
    var controller:AVPlayerViewController!
    var matchLog:MatchLog!
    var boundaryObserverToken: Any?
    
    @IBOutlet weak var EventView: UITextView!
    @IBOutlet weak var NextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controller =  childViewControllers.first(where: { $0 is AVPlayerViewController}) as? AVPlayerViewController
        configureOverlay()
        
        // Tva tuka ako mi go napraish, puk i URL-a da raboti, perfe
        matchLog = getTest()
        
        self.title = matchLog.title
        
        var timestamps = [NSValue]()
        for event in matchLog.events {
            timestamps.append(NSValue(time:event.start))
            timestamps.append(NSValue(time:event.end))
        }
        
        controller.player = AVPlayer(url: matchLog.videoURL)
        
        self.boundaryObserverToken = controller.player!.addBoundaryTimeObserver(forTimes: timestamps, queue: .main) {
            [weak self] in
            self?.updateEventView()
        }
    }
    
    func configureOverlay() {
        self.EventView.isHidden = true
        self.EventView.layer.cornerRadius = 8
        self.NextButton.layer.cornerRadius = 8
        self.EventView.layer.masksToBounds = true
        self.NextButton.layer.masksToBounds = true
        self.EventView.textContainerInset =
            UIEdgeInsetsMake(15, 15, 15, 15)
        self.NextButton.contentEdgeInsets =
            UIEdgeInsetsMake(15, 25, 15, 25)
        self.EventView.layer.borderWidth = 2
        self.NextButton.layer.borderWidth = 2
    }
    
    @IBAction func goToNext(_ sender: Any) {
        let currentTime = controller.player!.currentTime()
        
        guard let nextTime = matchLog.events.first(where: {event in
            currentTime < event.start
            })?.start
            else {
                return
        }
        
        let offsetNextTime = nextTime -
            CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        controller.player!.play()
        controller.player!.seek(to: offsetNextTime)
    }
    
    func updateEventView () {
        let current = controller.player!.currentTime()
        
        guard let event = matchLog.events.first(where: {event in
            event.start < current && current < event.end })
        else {
            self.EventView.isHidden = true;
            return
        }
        
        self.EventView.text = event.type
        
        switch(event.type){
        case "GOAL!":
            self.EventView.backgroundColor = UIColor.green
            self.EventView.textColor = UIColor.black
        case "FOUL!":
            self.EventView.backgroundColor = UIColor.red
            self.EventView.textColor = UIColor.white
        case "COOL!":
            self.EventView.backgroundColor = UIColor.cyan
            self.EventView.textColor = UIColor.black
        default:
            self.EventView.isHidden = true
            return
        }
        
        self.EventView.isHidden = false
        return
    }
}
