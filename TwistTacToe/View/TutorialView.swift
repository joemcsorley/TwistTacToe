//
//  TutorialView.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

class TutorialView: UIView {
    private(set) var label = UILabel()
    private(set) var backButton = UIButton(type: .custom)
    private(set) var nextButton = UIButton(type: .custom)

    // MARK: - Init / Setup
    
    init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupLabel()
        setupBackButton()
        setupNextButton()
    }

    private func setupLabel() {
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.brown
        addSubviewWithAutoLayout(label)
    }
    
    private func setupBackButton() {
        backButton.setTitle(backButtonTitle, for: .normal)
        backButton.setTitleColor(UIColor.brown, for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        backButton.layer.cornerRadius = 3
        addSubviewWithAutoLayout(backButton)
    }

    private func setupNextButton() {
        nextButton.setTitle(nextButtonTitle, for: .normal)
        nextButton.setTitleColor(UIColor.brown, for: .normal)
        nextButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        nextButton.layer.cornerRadius = 3
        addSubviewWithAutoLayout(nextButton)
    }
    
    private func layout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            
            backButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            
            nextButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
        ])
    }
}

// MARK: - Localizable Strings

private let backButtonTitle = NSLocalizedString("Back", comment: "Back Button title")
private let nextButtonTitle = NSLocalizedString("Next", comment: "Next Button title")
