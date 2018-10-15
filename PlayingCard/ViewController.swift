//
//  ViewController.swift
//  PlayingCard
//
//  Created by Betina Andersson on 2018-09-10.
//  Copyright © 2018 Betina Andersson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var deck = PlayingCardDeck()
    
    
    // MARK: Properties
   // @IBOutlet private var cardViews: [PlayingCardView]!
    @IBOutlet private var cardViews: [PlayingCardView]!
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in : animator)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count+1)/2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_ :)))) //target sent to action
            cardBehavior.addItem(cardView)
        }
        
    }
    
    private var faceUpCardViews : [PlayingCardView] {
        return cardViews.filter{$0.isFaceUp && !$0.isHidden && $0.transform != CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0) && $0.alpha == 1}
    }
    private var faceUpCardViewsMatch : Bool {
        return faceUpCardViews.count == 2 && faceUpCardViews[0].rank == faceUpCardViews[1].rank && faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    var lastChosenCardView : PlayingCardView?
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCardView = recognizer.view as? PlayingCardView {
                lastChosenCardView = chosenCardView
                cardBehavior.removeItem(chosenCardView)
                UIView.transition(with: chosenCardView,
                                  duration: 0.6, 
                                  options: [.transitionFlipFromLeft],
                                  animations: {
                                    chosenCardView.isFaceUp = !chosenCardView.isFaceUp},
                                  completion: { finished in
                                    let cardsToAnimate = self.faceUpCardViews
                                    if self.faceUpCardViewsMatch {
                                        UIViewPropertyAnimator.runningPropertyAnimator(
                                            withDuration: 0.6,
                                            delay: 0,
                                            options: [],
                                            animations: {
                                                cardsToAnimate.forEach {
                                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 3.0, y: 3.0)
                                                }
                                            },
                                            completion: { position in
                                                UIViewPropertyAnimator.runningPropertyAnimator(
                                                    withDuration: 0.75,
                                                    delay: 0,
                                                    options: [],
                                                    animations: {
                                                        cardsToAnimate.forEach {
                                                            $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                                            $0.alpha = 0
                                                        }
                                                    },
                                                    completion: { position in
                                                        cardsToAnimate.forEach {
                                                            $0.isHidden = true
                                                            $0.alpha = 1    //clean up
                                                            $0.transform = .identity    //clean up
                                                        }
                                                    }
                                                )
                                                                                        
                                            }
                                        )
                                    } else if cardsToAnimate.count == 2 && chosenCardView == self.lastChosenCardView {     //two cards dont match
                                        
                                        cardsToAnimate.forEach { cardView in
                                            UIView.transition(with: cardView,
                                                duration: 0.6,
                                                options: [.transitionFlipFromLeft],
                                                animations: {
                                                    cardView.isFaceUp = false
                                                },
                                                completion: {finished in
                                                    self.cardBehavior.addItem(cardView)
                                                }
                                            )
                                        }
                                    } else {
                                        if (!chosenCardView.isFaceUp) { //when fard faces down instead
                                            self.cardBehavior.addItem(chosenCardView)   //every time you add self, check if in memory cycle
                                        }
                                    }
                }
                )
                
            }
        default:
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

/*

 @IBOutlet weak var playingCardView: PlayingCardView! {
 didSet {
 let swipe = UISwipeGestureRecognizer(target: self, action: #selector(nextCard))
 swipe.direction = [.left, .right]
 playingCardView.addGestureRecognizer(swipe)
 
 let pinch = UIPinchGestureRecognizer(target:  playingCardView, action: #selector(PlayingCardView.adjustFaceCardScale(byHandlingGestureRecognizedBy:)))
 playingCardView.addGestureRecognizer(pinch)
 }
 }
 
 // MARK: Functions
 @objc func nextCard() {
 if let card = deck.draw() {
 playingCardView.rank = card.rank.order
 playingCardView.suit = card.suit.rawValue
 }
 }
 
 // MARK: Actions
 @IBAction func flipCard(_ sender: UITapGestureRecognizer) {
 switch sender.state {
 case .ended: playingCardView.isFaceUp = !playingCardView.isFaceUp
 default: break
 }
 }
 */

extension CGFloat {
    var arc4random : CGFloat {
        if self > 0 {
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else {
            return 0
        }
    }
}

