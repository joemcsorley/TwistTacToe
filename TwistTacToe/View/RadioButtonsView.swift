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
    private var numberOfButtons: Int = 1
    private var buttons: [UIButton] = []
    
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
        
    }
    
    private func layout() {
        
    }
}

private class RadioButtonView: UIView {
    let button = UIButton(type: .custom)
    let label = UILabel()
    let buttonId: Int
    let tapPublisher = PublishRelay<Int>()
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
            
            label.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    @objc
    private func handleButtonTapped() {
        tapPublisher.accept(buttonId)
    }
}
