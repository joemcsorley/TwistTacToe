//
//  TappableBoardView.swift
//  TwistTacToe
//
//  Copyright 2019, Joe McSorley, All rights reserved.
//

import UIKit

class TappableBoardView: UIView {
    private var boardPositions: [UIButton] = []
    private var leadingMarginGuide = UILayoutGuide()
    private var vertical1MarginGuide = UILayoutGuide()
    private var vertical2MarginGuide = UILayoutGuide()
    private var trailingMarginGuide = UILayoutGuide()
    private var topMarginGuide = UILayoutGuide()
    private var horizontal1MarginGuide = UILayoutGuide()
    private var horizontal2MarginGuide = UILayoutGuide()
    private var bottomMarginGuide = UILayoutGuide()

    private var boardContent: [String] = []
    private let fontSize: CGFloat
    var tapHandler: (_ boardLocation: BoardLocation) -> Void = { _ in }
    
    private let separatorThicknessPercentage: CGFloat = 0.1

    init(withFontSize fontSize: CGFloat, boardContent: [String] = []) {
        self.fontSize = fontSize
        super.init(frame: .zero)
        self.boardContent = boardContent
        setup()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        for i in boardRange {
            let boardPosition = UIButton()
            boardPosition.setTitleColor(UIColor.brown, for: .normal)
            boardPosition.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            boardPosition.backgroundColor = UIColor.white
            addSubviewWithAutoLayout(boardPosition)
            boardPosition.tag = i
            boardPosition.addTarget(self, action: #selector(handleTapped(boardPosition:)), for: .touchUpInside)
            boardPositions.append(boardPosition)
        }
        addLayoutGuide(leadingMarginGuide)
        addLayoutGuide(vertical1MarginGuide)
        addLayoutGuide(vertical2MarginGuide)
        addLayoutGuide(trailingMarginGuide)
        addLayoutGuide(topMarginGuide)
        addLayoutGuide(horizontal1MarginGuide)
        addLayoutGuide(horizontal2MarginGuide)
        addLayoutGuide(bottomMarginGuide)
    }

    private func layout() {
        NSLayoutConstraint.activate([
            topMarginGuide.topAnchor.constraint(equalTo: topAnchor),
            
            bottomMarginGuide.heightAnchor.constraint(equalTo: boardPositions[0].heightAnchor, multiplier: separatorThicknessPercentage),
            bottomMarginGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomMarginGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomMarginGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            leadingMarginGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            trailingMarginGuide.widthAnchor.constraint(equalTo: boardPositions[0].widthAnchor, multiplier: separatorThicknessPercentage),
            trailingMarginGuide.topAnchor.constraint(equalTo: topAnchor),
            trailingMarginGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            trailingMarginGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            boardPositions[0].heightAnchor.constraint(equalTo: boardPositions[0].widthAnchor)
        ])
        
        layoutHorizontals(rowAtIndex: 0, topHorizontalGuide: topMarginGuide, bottomHorizontalGuide: horizontal1MarginGuide)
        layoutHorizontals(rowAtIndex: 3, topHorizontalGuide: horizontal1MarginGuide, bottomHorizontalGuide: horizontal2MarginGuide)
        layoutHorizontals(rowAtIndex: 6, topHorizontalGuide: horizontal2MarginGuide, bottomHorizontalGuide: bottomMarginGuide)

        layoutVerticals(columnAtIndex: 0, leadingVerticalGuide: leadingMarginGuide, trailingVerticalGuide: vertical1MarginGuide)
        layoutVerticals(columnAtIndex: 1, leadingVerticalGuide: vertical1MarginGuide, trailingVerticalGuide: vertical2MarginGuide)
        layoutVerticals(columnAtIndex: 2, leadingVerticalGuide: vertical2MarginGuide, trailingVerticalGuide: trailingMarginGuide)
    }
    
    private func layoutHorizontals(rowAtIndex rowStartIndex: Int, topHorizontalGuide: UILayoutGuide, bottomHorizontalGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            topHorizontalGuide.heightAnchor.constraint(equalTo: boardPositions[rowStartIndex].heightAnchor, multiplier: separatorThicknessPercentage),
            topHorizontalGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
            topHorizontalGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            boardPositions[rowStartIndex].topAnchor.constraint(equalTo: topHorizontalGuide.bottomAnchor),
            boardPositions[rowStartIndex].bottomAnchor.constraint(equalTo: bottomHorizontalGuide.topAnchor),

            boardPositions[rowStartIndex+1].topAnchor.constraint(equalTo: topHorizontalGuide.bottomAnchor),
            boardPositions[rowStartIndex+1].bottomAnchor.constraint(equalTo: bottomHorizontalGuide.topAnchor),
            boardPositions[rowStartIndex+1].widthAnchor.constraint(equalTo: boardPositions[rowStartIndex].widthAnchor),
            boardPositions[rowStartIndex+1].heightAnchor.constraint(equalTo: boardPositions[rowStartIndex].heightAnchor),

            boardPositions[rowStartIndex+2].topAnchor.constraint(equalTo: topHorizontalGuide.bottomAnchor),
            boardPositions[rowStartIndex+2].bottomAnchor.constraint(equalTo: bottomHorizontalGuide.topAnchor),
            boardPositions[rowStartIndex+2].widthAnchor.constraint(equalTo: boardPositions[rowStartIndex].widthAnchor),
            boardPositions[rowStartIndex+2].heightAnchor.constraint(equalTo: boardPositions[rowStartIndex].heightAnchor),
        ])
    }

    private func layoutVerticals(columnAtIndex columnStartIndex: Int, leadingVerticalGuide: UILayoutGuide, trailingVerticalGuide: UILayoutGuide) {
        NSLayoutConstraint.activate([
            leadingVerticalGuide.widthAnchor.constraint(equalTo: boardPositions[columnStartIndex].widthAnchor, multiplier: separatorThicknessPercentage),
            leadingVerticalGuide.topAnchor.constraint(equalTo: topAnchor),
            leadingVerticalGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            boardPositions[columnStartIndex].leadingAnchor.constraint(equalTo: leadingVerticalGuide.trailingAnchor),
            boardPositions[columnStartIndex].trailingAnchor.constraint(equalTo: trailingVerticalGuide.leadingAnchor),

            boardPositions[columnStartIndex+3].leadingAnchor.constraint(equalTo: leadingVerticalGuide.trailingAnchor),
            boardPositions[columnStartIndex+3].trailingAnchor.constraint(equalTo: trailingVerticalGuide.leadingAnchor),
            boardPositions[columnStartIndex+3].widthAnchor.constraint(equalTo: boardPositions[columnStartIndex].widthAnchor),
            boardPositions[columnStartIndex+3].heightAnchor.constraint(equalTo: boardPositions[columnStartIndex].heightAnchor),
            
            boardPositions[columnStartIndex+6].leadingAnchor.constraint(equalTo: leadingVerticalGuide.trailingAnchor),
            boardPositions[columnStartIndex+6].trailingAnchor.constraint(equalTo: trailingVerticalGuide.leadingAnchor),
            boardPositions[columnStartIndex+6].widthAnchor.constraint(equalTo: boardPositions[columnStartIndex].widthAnchor),
            boardPositions[columnStartIndex+6].heightAnchor.constraint(equalTo: boardPositions[columnStartIndex].heightAnchor),
        ])
    }

    @objc
    private func handleTapped(boardPosition: UIButton) {
        tapHandler(boardPosition.tag)
    }

    // MARK: - Public Interface Methods
    
    var isEnabled: Bool {
        get {
            return boardPositions[0].isEnabled
        }
        set {
            boardPositions.forEach { $0.isEnabled = newValue }
        }
    }
    
    func update(boardContent: [String]) {
        for i in boardRange {
            let newContent = i < boardContent.count ? boardContent[i] : ""
            boardPositions[i].setTitle(newContent, for: .normal)
        }
    }
    
    func set(locationContent: String, atBoardLocation boardLocation: BoardLocation) {
        boardPositions[boardLocation].setTitle(locationContent, for: .normal)
    }
    
    func reset() {
        for i in boardRange {
            boardPositions[i].setTitle("", for: .normal)
        }
    }
}
