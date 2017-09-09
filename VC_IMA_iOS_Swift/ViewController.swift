//
//  ViewController.swift
//  VC_IMA_iOS_Swift
//
//  Created by James Rainville on 9/8/17.
//  Copyright © 2017 James Rainville. All rights reserved.
//

import UIKit

let kViewControllerPlaybackServicePolicyKey = "BCpkADawqM3dCmAPU7-jl0hHWW8097dehsjhdHYeCZVO3HbClNSwbtBpZkhuDuab141BnGkFL_xvPCif9v6Sz5A27pFUo8-qFuq42J6vzrXnLkmeLzGkQ1HzNdow2rI0qmhyPaEEhSGTPpW9"
let kViewControllerAccountID = "4517911906001"
let kViewControllerVideoID = "5269117590001"
let kViewControllerPlaylistID = "5280100152001"

let kViewControllerIMAPublisherID = "ca-pub-4202951716165137"
let kViewControllerIMALanguage = "en"
let kViewControllerIMAVMAPResponseAdTag = "https://pubads.g.doubleclick.net/gampad/ads?sz=320x240&iu=/6390/BabyCenter&cust_params={mediainfo.ad_keys}&impl=s&gdfp_req=1&env=vp&output=vast&unviewed_position_start=1&url={document.referrer}&description_url={player.url}&correlator={timestamp}"

class ViewController: UIViewController, BCOVPlaybackControllerDelegate, IMAWebOpenerDelegate {
    var playbackService :BCOVPlaybackService? = nil
    var playbackController :BCOVPlaybackController? = nil
    var playerView :BCOVPUIPlayerView? = nil
    var notificationReceipt :NSObject? = nil

    
    @IBOutlet weak var videoContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createPlayerView() {
        if playerView == nil {
            let options = BCOVPUIPlayerViewOptions()
            options.presentingViewController = self
            let controlView = BCOVPUIBasicControlView()
            // Set playback controller later.
            playerView = BCOVPUIPlayerView(playbackController: nil, options: options, controlsView: controlView)
            playerView?.frame = videoContainer.bounds
            playerView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            videoContainer.addSubview(playerView!)
        }
        else {
            print("PlayerView already exists")
        }
    }
    
    func setup() {
        createPlayerView()
        let manager = BCOVPlayerSDKManager.shared()
        let imaSettings = IMASettings()
        imaSettings.ppid = kViewControllerIMAPublisherID
        imaSettings.language = kViewControllerIMALanguage
        let renderSettings = IMAAdsRenderingSettings()
        renderSettings.webOpenerPresentingController = self
        renderSettings.webOpenerDelegate = self as IMAWebOpenerDelegate
        // BCOVIMAAdsRequestPolicy provides methods to specify VAST or VMAP/Server Side Ad Rules. Select the appropriate method to select your ads policy.
        let adsRequestPolicy = BCOVIMAAdsRequestPolicy.videoPropertiesVMAPAdTagUrl()
        playbackController = manager?.createIMAPlaybackController(with: imaSettings, adsRenderingSettings: renderSettings, adsRequestPolicy: adsRequestPolicy, adContainer: videoContainer, companionSlots: nil, viewStrategy: nil)
        playbackController?.delegate = self
        playbackController?.isAutoAdvance = true
        playbackController?.isAutoPlay = true
        playerView?.playbackController = playbackController
        playbackService = BCOVPlaybackService(accountId: kViewControllerAccountID, policyKey: kViewControllerPlaybackServicePolicyKey)
        resumeAdAfterForeground()
    }
    
    func resumeAdAfterForeground() {
        // When the app goes to the background, the Google IMA library will pause
        // the ad. This code demonstrates how you would resume the ad when entering
        // the foreground.
        let weakSelf: ViewController? = self
        notificationReceipt = NotificationCenter.default.addObserver(forName: UIApplicationWillEnterForegroundNotification, object: nil, queue: nil, usingBlock: {(_ note: Notification) -> Void in
            let strongSelf: ViewController? = weakSelf
            if strongSelf?.adIsPlaying && !strongSelf?.isBrowserOpen {
                strongSelf?.playbackController?.resumeAd()
            }
        })
    }


}

