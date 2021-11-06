import UIKit
import SpriteKit
import Foundation

class GameViewController: UIViewController {
    
    var counter = 0;
    private let networking = Networking()
    var timer: Timer?
    var winnerUrl = ""
    var loserUrl = ""
    let imageData = UIPasteboard.general.data(forPasteboardType: "aim")

    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var startGameLabel: UIButton!
  
    @IBAction func startGameButton(_ sender: Any) {
        startGameLabel.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(gameOver), userInfo: nil, repeats: false)
        renderAim()
        networking.getGameOverUrl { result in
            switch result {
            case .success(let response):
                self.winnerUrl = response.winner
                self.loserUrl = response.loser
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let userDefaults = UserDefaults.standard
        let isRulesAccepted = userDefaults.object(forKey: "isRulesAccepted")
        if isRulesAccepted == nil {
            let alert = UIAlertController(title: "Rules of the game", message: "Game finishes when you press the aim 10 times. You win if you do it faster than 7 seconds. You lose if you are slower.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: onRulesAccept))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    func onRulesAccept(alert: UIAlertAction!) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "isRulesAccepted")
    }
    @objc func gameOver() {
        showWebView(url: loserUrl)
        resetGameValues()
    }
    func resetGameValues() {
        startGameLabel.isHidden = false
        removeAim()
        counter = 0
        timer?.invalidate()
    }
    func showWebView(url: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: "WebViewController") as! WebViewController
        viewController.url = url
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func tapAim() {
        if counter > 10 {
            return
        } else if counter == 10 {
            showWebView(url: winnerUrl)
            resetGameValues()
        } else {
            counter += 1
            removeAim()
            renderAim()
        }
    }
    func renderAim() {
        let image = UIImage(named: "aim")
        imageView = UIImageView(image: image!)
        let imageWidth = 64
        let imageHeight = 64
        let bounds = UIScreen.main.bounds
        let width = Int(bounds.size.width) - imageWidth
        let height = Int(bounds.size.height) - imageHeight
        imageView.frame = CGRect(x: Int.random(in: 0..<width), y: Int.random(in: 0..<height), width: 64, height: 64)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapAim))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)
        view.addSubview(imageView)
    }
    func removeAim() {
        imageView.removeFromSuperview()
    }
}
