//
//  GameViewController.swift
//  RWCookieCrunch
//
//  Created by Skyler Svendsen on 11/21/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    var scene: GameScene!
    var level: Level!
    var movesLeft = 0
    var score = 0
    var currentLevelNum = 1
    var moveDecd = false

    @IBOutlet weak var gameOverPanel: UIImageView!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!

    @IBAction func shuffleButtonPressed(_: Any) {
        shuffle()
        decrementMoves()
    }

    var tapGestureRecognizer: UITapGestureRecognizer!

    lazy var backgroundMusic: AVAudioPlayer? = {
        guard let url = Bundle.main.url(forResource: "Mining by Moonlight", withExtension: "mp3") else { return nil }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            return player
        } catch {
            return nil
        }
    }()

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLevel(currentLevelNum)

        backgroundMusic?.play()
    }

    func setupLevel(_ levelNum: Int) {
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false

        scene = GameScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill

        level = Level(filename: "Level_\(levelNum)")
        scene.level = level

        scene.addTiles()
        scene.swipeHandler = handleSwipe

        gameOverPanel.isHidden = true
        shuffleButton.isHidden = true

        skView.presentScene(scene)

        beginGame()
    }

    func beginGame() {
        movesLeft = level.maximumMoves
        score = 0
        updateLabels() //added
        level.resetComboMultiplier()
        scene.animateBeginGame {
            self.shuffleButton.isHidden = false
        }
        shuffle()
    }

    func shuffle() {
        scene.removeAllCookieSprites()

        let newCookies = level.shuffle()
        scene.addSprites(for: newCookies)
    }

    func handleSwipe(_ swap: Swap) {
        view.isUserInteractionEnabled = false

        if level.isPossibleSwap(swap) {
            level.performSwap(swap)
            moveDecd = false
            scene.animate(swap, completion: handleMatches)
        } else {
            scene.animateInvalidSwap(swap) {
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    func handleMatches() {
        let chains = level.removeMatches()
        if chains.count == 0 {
            if !moveDecd {
                decrementMoves()
                moveDecd = true
            }
            
            beginNextTurn()
            
            return
        }
        scene.animateMatchedCookies(for: chains) {
            for chain in chains {
                self.score += chain.score
            }
            self.updateLabels()

            let columns = self.level.fillHoles()
            self.scene.animateFallingCookies(columns: columns) {
                let columns = self.level.topUpCookies()
                self.scene.animateNewCookies(columns){
                    self.handleMatches()
                }
            }
        }
    }

    func beginNextTurn() {
        level.resetComboMultiplier()
        level.detectPossibleSwaps()
        view.isUserInteractionEnabled = true
        //decrementMoves()
    }

    func updateLabels() {
        targetLabel.text = String(format: "%ld", level.targetScore)
        movesLabel.text = String(format: "%ld", movesLeft)
        scoreLabel.text = String(format: "%ld", score)
    }

    func decrementMoves() {
        movesLeft -= 1
        updateLabels()

        if score >= level.targetScore {
            gameOverPanel.image = UIImage(named: "LevelComplete")
            currentLevelNum = currentLevelNum < NumLevels ? currentLevelNum+1 : 1
            showGameOver()
        } else if movesLeft == 0 {
            gameOverPanel.image = UIImage(named: "GameOver")
            showGameOver()
        }
    }

    func showGameOver() {
        gameOverPanel.isHidden = false
        shuffleButton.isHidden = true
        scene.isUserInteractionEnabled = false

        scene.animateGameOver() {
            self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.hideGameOver))
            self.view.addGestureRecognizer(self.tapGestureRecognizer)
        }
    }

    @objc func hideGameOver() {
        view.removeGestureRecognizer(tapGestureRecognizer)
        tapGestureRecognizer = nil

        gameOverPanel.isHidden = true
        scene.isUserInteractionEnabled = true

        setupLevel(currentLevelNum)
    }



}




















