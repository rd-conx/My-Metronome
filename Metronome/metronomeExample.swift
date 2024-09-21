import UIKit
import AVFoundation


class ViewController: UIViewController, MetronomeDelegate
{
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var barTextField: UITextField?
    @IBOutlet weak var beatTextField: UITextField?
   
    var metronome: Metronome!
   
    override func viewDidLoad () {
        super.viewDidLoad ()
       
        print ("Hello, Metronome!\n");
       
        let audioSession = AVAudioSession.sharedInstance ()
       
        do {
            try audioSession.setCategory (AVAudioSessionCategoryAmbient)
            try audioSession.setActive (true)
        }
        catch {
            print (error)
        }
       
        // if media services are reset, we need to rebuild our audio chain
       
        NotificationCenter.default.addObserver (self,
                                                selector: #selector (handleMediaServicesWereReset(_:)),
                                                name: NSNotification.Name.AVAudioSessionMediaServicesWereReset,
                                                object: audioSession)
       
        metronome = Metronome ()
        metronome.delegate = self
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    @IBAction func buttonPressed (sender: UIButton!) {
        // change the selected state thereby the button color and title
        // toggle between Start & Stop
        sender.isSelected = !sender.isSelected
       
        if metronome.isPlaying {
            metronome.stop ()
        }
        else {
            metronome.start ()
        }
    }
   
    @objc func metronomeTicking (_ metronome: Metronome, bar: Int32, beat: Int32) {
        DispatchQueue.main.async {
            self.barTextField!.text = String (format: "%d", bar)
            self.beatTextField!.text = String (format: "%d", beat)
        }
    }
   
    // see https://developer.apple.com/library/content/qa/qa1749/_index.html
   
    @objc func handleMediaServicesWereReset (_ notification: Notification) {
        print("Media services have reset...")
       
        // tear down
        metronome.delegate = nil
        metronome = nil
       
        button!.isSelected = false
       
        // re-create
        metronome = Metronome ()
        metronome.delegate = self
       
        do {
            try AVAudioSession.sharedInstance ().setActive (true)
        }
        catch {
            print (error)
        }
    }
}
