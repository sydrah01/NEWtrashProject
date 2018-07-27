//
//  ScoreViewController.swift
//  TrashProject
//
//  Created by Jacqueline Palevich on 7/25/18.
//  Copyright © 2018 Sydrah Al-saegh. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highScoreLabel: UILabel!
    
    var highScore: Int = UserDefaults.standard.integer(forKey: "highScore") {
        didSet {
            if oldValue != highScore {
                UserDefaults.standard.set(highScore, forKey: "highScore")
                highScoreLabel.text = "High Score: \(highScore)"
            }
        }
    }
    var score: Int = 0

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scoreLabel.text = "Score: \(score)"
        
        highScore = max(highScore, score)
        highScoreLabel.text = "High Score: \(highScore)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
