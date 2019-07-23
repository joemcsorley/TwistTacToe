//
//  GameChooserViewController.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class GameChooserViewController: UIViewController {
    private let onePlayerButton = UIButton()
    private let twoPlayerButton = UIButton()
    
    private let playerChooserButtons = RadioButtonsView(numberOfButtons: 2)
    private let humanPlayerIsXButtonId = 0
    private let humanPlayerIsOButtonId = 1
    
    private let difficultyChooserButtons = RadioButtonsView(numberOfButtons: 2)
    private let difficultyEasyButtonId = 0
    private let difficultyImpossibleButtonId = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        view.backgroundColor = UIColor("#FFD9AA")
        setupNavigationBar()
        setupOnePlayerButton()
        setupTwoPlayerButton()
        setupPlayerChooserButtons()
        setupDifficultyChooserButtons()
    }

    private func setupNavigationBar() {
        navigationItem.title = screenTitle
        
        let howToPlayButton = UIBarButtonItem(title: helpButtonTitle, style: .plain, target: self, action: #selector(handleHowToPlay))
        let titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .bold),
                                   NSAttributedString.Key.foregroundColor: UIColor.brown]
        howToPlayButton.setTitleTextAttributes(titleTextAttributes, for: .normal)
        howToPlayButton.setTitleTextAttributes(titleTextAttributes, for: .focused)
        howToPlayButton.setTitleTextAttributes(titleTextAttributes, for: .selected)
        howToPlayButton.setTitleTextAttributes(titleTextAttributes, for: .disabled)
        navigationItem.leftBarButtonItem = howToPlayButton
    }
    
    private func setupOnePlayerButton() {
        onePlayerButton.setTitle(onePlayerButtonTitle, for: .normal)
        onePlayerButton.setTitleColor(UIColor.black, for: .normal)
        onePlayerButton.addTarget(self, action: #selector(handleOnePlayerTapped), for: .touchUpInside)
        onePlayerButton.backgroundColor = UIColor.green
        onePlayerButton.layer.cornerRadius = 4
        view.addSubviewWithAutoLayout(onePlayerButton)
    }

    private func setupTwoPlayerButton() {
        twoPlayerButton.setTitle(twoPlayerButtonTitle, for: .normal)
        twoPlayerButton.setTitleColor(UIColor.black, for: .normal)
        twoPlayerButton.addTarget(self, action: #selector(handleTwoPlayerTapped), for: .touchUpInside)
        twoPlayerButton.backgroundColor = UIColor.green
        twoPlayerButton.layer.cornerRadius = 4
        view.addSubviewWithAutoLayout(twoPlayerButton)
    }

    private func setupPlayerChooserButtons() {
        playerChooserButtons.buttons[humanPlayerIsXButtonId].label.text = humanIsPlayerXText
        playerChooserButtons.buttons[humanPlayerIsOButtonId].label.text = humanIsPlayerOText
        playerChooserButtons.setSelectedButtonId(humanPlayerIsXButtonId)
        view.addSubviewWithAutoLayout(playerChooserButtons)
    }

    private func setupDifficultyChooserButtons() {
        difficultyChooserButtons.buttons[difficultyEasyButtonId].label.text = easyDifficultyText
        difficultyChooserButtons.buttons[difficultyImpossibleButtonId].label.text = impossibleDifficultyText
        difficultyChooserButtons.setSelectedButtonId(difficultyEasyButtonId)
        view.addSubviewWithAutoLayout(difficultyChooserButtons)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            onePlayerButton.topAnchor.constraint(equalTo: view.normalizedLayoutGuide.topAnchor, constant: 50),
            onePlayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            onePlayerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            playerChooserButtons.topAnchor.constraint(equalTo: onePlayerButton.bottomAnchor, constant: 15),
            playerChooserButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            playerChooserButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            difficultyChooserButtons.topAnchor.constraint(equalTo: playerChooserButtons.bottomAnchor, constant: 20),
            difficultyChooserButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            difficultyChooserButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            twoPlayerButton.topAnchor.constraint(equalTo: difficultyChooserButtons.bottomAnchor, constant: 30),
            twoPlayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            twoPlayerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }

    // MARK: - Helpers

    private func getPlayerForChosenDifficulty(withSymbol symbol: GamePiece) -> Player {
        return difficultyChooserButtons.selectedButtonId == difficultyImpossibleButtonId ? AutomatedImpossiblePlayer(symbol: symbol) : AutomatedRandomPlayer(symbol: symbol)
    }
    
    private func addDropShadow(toView v: UIView) {
        v.layer.masksToBounds = false
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 4.0
        v.layer.shadowOffset = CGSize(width: 2, height: 2)
        v.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor
    }
    
    // MARK: - Button Handlers
    
    @objc
    private func handleOnePlayerTapped() {
        if playerChooserButtons.selectedButtonId == humanPlayerIsXButtonId {
            let gameViewController = GameViewController(playerX: HumanPlayer(symbol: .X), playerO: getPlayerForChosenDifficulty(withSymbol: .O))
            navigationController?.pushViewController(gameViewController, animated: true)
        }
        else {
            let gameViewController = GameViewController(playerX: getPlayerForChosenDifficulty(withSymbol: .X), playerO: HumanPlayer(symbol: .O))
            navigationController?.pushViewController(gameViewController, animated: true)
        }
    }
    
    @objc
    private func handleTwoPlayerTapped() {
        let gameViewController = GameViewController(playerX: HumanPlayer(symbol: .X), playerO: HumanPlayer(symbol: .O))
        navigationController?.pushViewController(gameViewController, animated: true)
    }

    @objc
    private func handleHowToPlay() {
        let gameViewController = GameViewController(tutorialMode: true)
        navigationController?.pushViewController(gameViewController, animated: true)
    }
}

// MARK: - Localizable Strings

private let screenTitle = NSLocalizedString("Twist-Tac-Toe", comment: "Screen title")
private let helpButtonTitle = NSLocalizedString("Help", comment: "Help button text")
private let onePlayerButtonTitle = NSLocalizedString("One Player", comment: "One Player button title")
private let twoPlayerButtonTitle = NSLocalizedString("Two Player", comment: "Two Player button title")
private let humanIsPlayerXText = NSLocalizedString("You are X", comment: "Human is Player X label text")
private let humanIsPlayerOText = NSLocalizedString("You are O", comment: "Human is Player O label text")
private let easyDifficultyText = NSLocalizedString("Easy", comment: "Easy difficulty level label text")
private let impossibleDifficultyText = NSLocalizedString("Impossible", comment: "Impossible difficulty level label text")
