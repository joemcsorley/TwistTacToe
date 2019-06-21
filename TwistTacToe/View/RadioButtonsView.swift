//
//  RadioButtonsView.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RadioButtonsView: UIView {
    private var numberOfButtons = 1
    private(set) var selectedButton: Int?
    private(set) var buttons: [RadioButtonView] = []
    private let disposeBag = DisposeBag()

    // MARK: - Init / Setup

    init(numberOfButtons: Int) {
        super.init(frame: .zero)
        self.numberOfButtons = numberOfButtons
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        for i in 0..<numberOfButtons {
            let radioButtonView = RadioButtonView(buttonId: i)
            radioButtonView.tapPublisher.subscribe(onNext: setSelectedButton(_:)).disposed(by: disposeBag)
            addSubviewWithAutoLayout(radioButtonView)
            buttons.append(radioButtonView)
        }
    }
    
    private func layout() {
        guard let lastRadioButtonView = buttons.last else { return }
        var currentTopAnchor: NSLayoutYAxisAnchor = topAnchor
        var currentTopOffset: CGFloat = 0
        buttons.forEach { radioButtonView in
            NSLayoutConstraint.activate([
                radioButtonView.topAnchor.constraint(equalTo: currentTopAnchor, constant: currentTopOffset),
                radioButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
                radioButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
            ])
            currentTopAnchor = radioButtonView.bottomAnchor
            currentTopOffset = 8
        }
        NSLayoutConstraint.activate([
            lastRadioButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    // MARK: - Public interface methods
    
    func setSelectedButton(_ i: Int) {
        guard i >= 0 && i < numberOfButtons else { return }
        buttons.forEach {
            $0.button.setTitle(" ", for: .normal)
        }
        buttons[i].button.setTitle("✓", for: .normal)
        selectedButton = i
    }
}

class RadioButtonView: UIView {
    let button = UIButton(type: .custom)
    let label = UILabel()
    let buttonId: Int
    let tapPublisher = PublishSubject<Int>()
    let disposeBag = DisposeBag()

    private let radioButtonSize: CGFloat = 32

    // MARK: - Init / Setup
    
    init(buttonId: Int) {
        self.buttonId = buttonId
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        setupButton()
        setupLabel()
    }

    private func setupButton() {
        addSubviewWithAutoLayout(button)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = radioButtonSize / 2
    }
    
    private func setupLabel() {
        addSubviewWithAutoLayout(label)
        label.backgroundColor = UIColor.clear
        label.font = UIFont.systemFont(ofSize: 16)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.widthAnchor.constraint(equalToConstant: radioButtonSize),
            button.heightAnchor.constraint(equalTo: button.widthAnchor),

            label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 15),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
        ])
    }
    
    @objc
    private func handleButtonTapped() {
        tapPublisher.onNext(buttonId)
    }
}
