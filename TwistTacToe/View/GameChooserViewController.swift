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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        view.backgroundColor = UIColor("#FFD9AA")
        setupOnePlayerButton()
        setupTwoPlayerButton()
        setupPlayerChooserButtons()
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
        playerChooserButtons.setSelectedButton(humanPlayerIsXButtonId)
        view.addSubviewWithAutoLayout(playerChooserButtons)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            onePlayerButton.topAnchor.constraint(equalTo: view.normalizedLayoutGuide.topAnchor, constant: 50),
            onePlayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            onePlayerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            playerChooserButtons.topAnchor.constraint(equalTo: onePlayerButton.bottomAnchor, constant: 15),
            playerChooserButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
            playerChooserButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
            twoPlayerButton.topAnchor.constraint(equalTo: playerChooserButtons.bottomAnchor, constant: 30),
            twoPlayerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            twoPlayerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
        ])
    }
    
    // MARK: - Button Handlers
    
    @objc
    private func handleOnePlayerTapped() {
        if playerChooserButtons.selectedButton == humanPlayerIsXButtonId {
            present(GameViewController(playerX: HumanPlayer(symbol: .X), playerO: AutomatedRandomPlayer(symbol: .O)), animated: true, completion: nil)
        }
        else {
            present(GameViewController(playerX: AutomatedRandomPlayer(symbol: .X), playerO: HumanPlayer(symbol: .O)), animated: true, completion: nil)
        }
    }
    
    @objc
    private func handleTwoPlayerTapped() {
        present(GameViewController(playerX: HumanPlayer(symbol: .X), playerO: HumanPlayer(symbol: .O)), animated: true, completion: nil)
    }
}

// MARK: - Localizable Strings

private let onePlayerButtonTitle = NSLocalizedString("One Player", comment: "One Player button title")
private let twoPlayerButtonTitle = NSLocalizedString("Two Player", comment: "Two Player button title")
private let humanIsPlayerXText = NSLocalizedString("You are X", comment: "Human is Player X label text")
private let humanIsPlayerOText = NSLocalizedString("You are O", comment: "Human is Player O label text")
