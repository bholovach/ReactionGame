import UIKit
import SpriteKit
import WebKit

class GameViewController: UIViewController {
    
    var counter = 0;
    private let networking = Networking()
    var timer: Timer?
    var winnerUrl = ""
    var loserUrl = ""

    @IBOutlet var webView: WKWebView!
    
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
    }
    @objc func gameOver() {
        print(loserUrl, counter)
        showWebView(url: loserUrl)
        timer?.invalidate()
        
    }
    func showWebView(url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    @objc func tapAim() {
        if counter > 10 {
            return
        } else {
            counter += 1
        }
        if counter == 10 {
            print(winnerUrl, counter)
            showWebView(url: winnerUrl)
            timer?.invalidate()
        }
    }
    
    func renderAim() {
        let myLayer = CALayer()
        let myImage = UIImage(named: "aim")
        let myButton = UIButton(type: .custom)
        myButton.setImage(myImage, for: .normal)
//        myImage.image = UIImage(named: "aim")
//        let tapRec = UITapGestureRecognizer(target: self, action: #selector(tapAim))
//        myImage.isUserInteractionEnabled = true;
//        myImage.addGestureRecognizer(tapRec)
        myLayer.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        myLayer.contents = myButton
        self.view.layer.addSublayer(myLayer)
    }
}

