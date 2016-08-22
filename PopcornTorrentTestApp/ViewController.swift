

import UIKit
import PopcornTorrent

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        print("Initializing Stream...")
        PTTorrentStreamer.sharedStreamer().startStreamingFromFileOrMagnetLink("magnet:?xt=urn:btih:77ed6b3e37f16481adcf256faa4c16f618f7d728&dn=Game.Of.Thrones.S05E02.INTERNAL.HDTV.x264-BATV%5Brartv%5D&tr=http%3A%2F%2Ftracker.trackerfix.com%3A80%2Fannounce&tr=udp%3A%2F%2F9.rarbg.me%3A2710&tr=udp%3A%2F%2F9.rarbg.to%3A2710&tr=udp%3A%2F%2Fopen.demonii.com%3A1337%2Fannounce", progress: { progress in
            
        }, readyToPlay: { url in
            
        }) { error in
                
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

