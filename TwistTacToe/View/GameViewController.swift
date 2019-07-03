//
//  GameViewController.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GameViewController: UIViewController {
    private let boardView = TappableBoardView(withFontSize: 64)
    private let rotationMapView = TappableBoardView(withFontSize: 32)
    private let tutorialView = TutorialView()
    private var undoButton: UIButton!
    private var redoButton: UIButton!

    private let radioButtonSize: CGFloat = 32
    
    private var game: GameController?
    private(set) var playerX: Player
    private(set) var playerO: Player
    private(set) var isTutorialMode = false
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle / Setup Methods
    
    init(playerX: Player, playerO: Player) {
        self.playerX = playerX
        self.playerO = playerO
        super.init(nibName: nil, bundle: nil)
    }

    convenience init(tutorialMode: Bool) {
        self.init(playerX: HumanPlayer(symbol: .X), playerO: HumanPlayer(symbol: .O))
        self.isTutorialMode = tutorialMode
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
        if isTutorialMode {
            startTutorial()
        }
        else {
            startNewGame()
        }
    }
    
    private func setup() {
        view.backgroundColor = UIColor("#FFD9AA")
        
        setupNavigationBar()
        setupBoard()
        setupTutorialView()
        setupRotationMap()
        setupUndoRedoButtons()
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = createBarButton(withTitle: endGameText, selector: #selector(handleEndGame))
        if !isTutorialMode {
            navigationItem.rightBarButtonItem = createBarButton(withTitle: resumeGameText, selector: #selector(handleResumeGame))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func createBarButton(withTitle title: String, selector: Selector) -> UIBarButtonItem {
        let barButtonTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .bold),
                                       NSAttributedString.Key.foregroundColor: UIColor.brown]
        let disabledBarButtonTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10, weight: .bold),
                                               NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        let barButton = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
        barButton.setTitleTextAttributes(barButtonTextAttributes, for: .normal)
        barButton.setTitleTextAttributes(barButtonTextAttributes, for: .focused)
        barButton.setTitleTextAttributes(barButtonTextAttributes, for: .selected)
        barButton.setTitleTextAttributes(disabledBarButtonTextAttributes, for: .disabled)
        return barButton
    }
    
    private func setupBoard() {
        view.addSubviewWithAutoLayout(boardView)
        boardView.tapHandler = handleTapped
    }

    private func setupTutorialView() {
        tutorialView.backgroundColor = UIColor.white
        tutorialView.layer.cornerRadius = 4
        tutorialView.layer.masksToBounds = false
        tutorialView.layer.shadowOffset = CGSize(width: 4, height: 4)
        tutorialView.layer.shadowColor = UIColor.brown.cgColor
        tutorialView.layer.shadowRadius = 4
        tutorialView.layer.shadowOpacity = 1
        tutorialView.alpha = isTutorialMode ? 1 : 0
        view.addSubviewWithAutoLayout(tutorialView)
    }

    private func setupRotationMap() {
        view.addSubviewWithAutoLayout(rotationMapView)
    }

    private func setupPlayerSelectorButton(_ button: UIButton, handler: Selector) {
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: handler, for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = radioButtonSize / 2
    }
    
    private func setupUndoRedoButtons() {
        undoButton = createUndoRedoButton(withTitle: undoButtonTitle, selector: #selector(handleUndo))
        view.addSubviewWithAutoLayout(undoButton)

        redoButton = createUndoRedoButton(withTitle: redoButtonTitle, selector: #selector(handleRedo))
        view.addSubviewWithAutoLayout(redoButton)
    }
    
    private func createUndoRedoButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor.brown, for: .normal)
        button.setTitleColor(UIColor("#FEAF7B"), for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.isEnabled = false
        button.alpha = isTutorialMode ? 0 : 1
        return button
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            undoButton.topAnchor.constraint(equalTo: view.normalizedLayoutGuide.topAnchor, constant: 15),
            undoButton.trailingAnchor.constraint(equalTo: redoButton.leadingAnchor, constant: -15),
            undoButton.heightAnchor.constraint(equalToConstant: 14),
            
            redoButton.topAnchor.constraint(equalTo: view.normalizedLayoutGuide.topAnchor, constant: 15),
            redoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            redoButton.heightAnchor.constraint(equalToConstant: 14),
            
            boardView.topAnchor.constraint(equalTo: undoButton.bottomAnchor, constant: 15),
            boardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            boardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            rotationMapView.topAnchor.constraint(greaterThanOrEqualTo: boardView.bottomAnchor, constant: 15),
            rotationMapView.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            rotationMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            rotationMapView.widthAnchor.constraint(equalTo: boardView.widthAnchor, multiplier: 0.4),
            
            tutorialView.topAnchor.constraint(equalTo: boardView.bottomAnchor, constant: 15),
            tutorialView.bottomAnchor.constraint(equalTo: view.normalizedLayoutGuide.bottomAnchor, constant: -15),
            tutorialView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tutorialView.trailingAnchor.constraint(equalTo: rotationMapView.leadingAnchor, constant: -15),
        ])
    }
    
    // MARK: - Button Handlers
    
    @objc
    private func handleResumeGame() {
        guard let game = game, game.isGamePaused else { return }
        if game.gameStateSnapshotValue.gameBoard.gameResult == .unfinished {
            boardView.isEnabled = true
        }
        game.resume()
    }

    @objc
    private func handleEndGame() {
        navigationController?.popViewController(animated: true)
    }

    @objc
    private func handleUndo() {
        game?.undo()
    }

    @objc
    private func handleRedo() {
        game?.redo()
    }

    private func handleTapped(_ boardLocation: BoardLocation) {
        game?.handleGameBoardTapped(atLocation: boardLocation)
    }

    // MARK: - Helper Methods
    
    private func startTutorial() {
        guard let rotationPattern = try? TutorialData.getRotationPattern() else { return }
        boardView.isEnabled = false
        game = newGame(withPlayerX: playerX, playerO: playerO, rotationPattern: rotationPattern)
        game?.play(withHistory: TutorialData.playHistory)
        updateRotationMapView()
    }
    
    private func startNewGame() {
        boardView.isEnabled = true
        game = newGame(withPlayerX: playerX, playerO: playerO)
        game?.play()
        updateRotationMapView()
    }
    
    private func newGame(withPlayerX playerX: Player, playerO: Player, rotationPattern: RotationPattern? = nil) -> GameController {
        var game: GameController!
        if let rotationPattern = rotationPattern {
            game = GameController(playerX: playerX, playerO: playerO, rotationPattern: rotationPattern)
        }
        else {
            game = GameController(playerX: playerX, playerO: playerO)
        }
        bindCurrentPlayerIndicatorToGameState(ofGame: game)
        observeBoardUpdates(ofGame: game)
        observeGameEnd(ofGame: game)
        observeTutorial()
        return game
    }
    
    private func observeTutorial() {
        guard isTutorialMode else { return }
        tutorialView.backButton.rx.tap.bind {
            self.handleUndo()
        }.disposed(by: disposeBag)
        tutorialView.nextButton.rx.tap.bind {
            self.handleRedo()
        }.disposed(by: disposeBag)
    }
    
    private func observeBoardUpdates(ofGame game: GameController) {
        game.gameStateSnapshot
            // Throttle board updates so the user can see them happen
            .throttle(0.4, scheduler: MainScheduler.instance)
            .subscribe(onNext: handleChanged(gameStateSnapshot:))
            .disposed(by: disposeBag)
    }
    
    private func observeGameEnd(ofGame game: GameController) {
        game.gameStateSnapshot.subscribe(
            onNext: handleGameOver(gameStateSnapshot:),
            onError: handleGameError(_:),
            onCompleted: nil,
            onDisposed: nil
        ).disposed(by: disposeBag)
    }

    private func bindCurrentPlayerIndicatorToGameState(ofGame game: GameController) {
        game.gameStateSnapshot.map { (gameStateSnapshot) -> String in
            switch gameStateSnapshot.gameState {
            case .initial: fallthrough
            case .xPlaysNext:
                return String(format: currentPlayerText, "X")
            case .oPlaysNext:
                return String(format: currentPlayerText, "O")
            case .boardNeedsRotation:
                return gamePiecesRotateText
            case.gameOver:
                return self.getGameResultText(forWinner: game.gameStateSnapshotValue.gameBoard.gameResult.winningSymbol)
            }
        }.bind(to: navigationItem.rx.title).disposed(by: disposeBag)
    }
    
    private func updateRotationMapView() {
        guard let rotationPattern = game?.rotationPattern else { return }
        var rotationBoardContent: [String] = []
        for i in boardRange {
            rotationBoardContent.append("\(rotationPattern.numberMap[i] + 1)")
        }
        rotationMapView.update(boardContent: rotationBoardContent)
    }
    
    private func getGameResultText(forWinner winner: GamePiece?) -> String {
        guard let winner = winner else { return tieText }
        return winner == .X ? xWinsText : oWinsText
    }

    // MARK: - Game Event Handlers

    private func handleChanged(gameStateSnapshot: GameStateSnapshot) {
        do {
            let boardContent = try boardRange.map { boardLocation -> String in
                guard let symbol = try gameStateSnapshot.gameBoard.gamePiece(atLocation: boardLocation) else { return "" }
                return symbol.rawValue
            }
            boardView.update(boardContent: boardContent)
            navigationItem.rightBarButtonItem?.isEnabled = game?.isGamePaused ?? false
            undoButton.isEnabled = game?.hasUndo ?? false
            redoButton.isEnabled = game?.hasRedo ?? false
            if isTutorialMode {
                tutorialView.label.text = TutorialData.tutorialText[gameStateSnapshot.playHistoryIndex]
            }
        } catch {}
    }
    
    private func handleGameOver(gameStateSnapshot: GameStateSnapshot) {
        guard gameStateSnapshot.gameState == .gameOver else { return }
        boardView.isEnabled = false
    }
    
    private func handleGameError(_ error: Error) {
        let errorAlert = UIAlertController(title: errorAlertTitle, message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: okButtonTitle, style: .default) { action in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(errorAlert, animated: true, completion: nil)
    }
}

// MARK: - Localizable Strings

private let humanIsPlayerXText = NSLocalizedString("You are X", comment: "Human is Player X label text")
private let humanIsPlayerOText = NSLocalizedString("You are O", comment: "Human is Player O label text")
private let currentPlayerText = NSLocalizedString("%@ Plays", comment: "Current Player Indicator text template")
private let gamePiecesRotateText = NSLocalizedString("Pieces move", comment: "Game pieces all rotate text")
private let resumeGameText = NSLocalizedString("Resume Game", comment: "Resume game button text")
private let endGameText = NSLocalizedString("End Game", comment: "End game button text")
private let xWinsText = NSLocalizedString("Player X Wins!", comment: "Player X Wins")
private let oWinsText = NSLocalizedString("Player O Wins!", comment: "Player O Wins")
private let tieText = NSLocalizedString("You Tied.", comment: "You tied")
private let gameErrorText = NSLocalizedString("Game Error", comment: "Game Error")
private let okButtonTitle = NSLocalizedString("Ok", comment: "Ok button title")
private let undoButtonTitle = NSLocalizedString("Undo", comment: "Undo button text")
private let redoButtonTitle = NSLocalizedString("Redo", comment: "Redo button text")
private let errorAlertTitle = NSLocalizedString("A fatal error occurred", comment: "error alert title")
