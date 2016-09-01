//
//  ViewController.swift
//  StanfordCalculator
//
//  Created by Saurabh Sikka on 28/08/16.
//  Copyright (c) 2016 Saurabh Sikka. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userIsInTheMiddleOfTypingANumber = false

    @IBOutlet weak var calculatorDisplay: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var brain = CalculatorBrain()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateHistory()
    }
    
    @IBAction func appendDecimal(sender: UIButton) {
        let decimalSymbol = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if calculatorDisplay.text?.rangeOfString(decimalSymbol) == nil {
                calculatorDisplay.text = calculatorDisplay.text! + decimalSymbol
            }
        } else {
            userIsInTheMiddleOfTypingANumber = true
            calculatorDisplay.text = "0" + decimalSymbol
        }
    }
    
    @IBAction func enter() {
        if displayValue == nil {
            return
        }
        userIsInTheMiddleOfTypingANumber = false
        displayValue = brain.pushOperand(displayValue!)
        updateHistory()
    }
    
    @IBAction func operate(sender: UIButton) {
        if let operation = sender.currentTitle {
            if userIsInTheMiddleOfTypingANumber {
                if operation == "±" {
                    if let oldDisplayValue = displayValue {
                        if oldDisplayValue.isSignMinus {
                            calculatorDisplay.text = dropFirst(calculatorDisplay.text!)
                        }
                        if !oldDisplayValue.isZero {
                            calculatorDisplay.text = "-" + calculatorDisplay.text!
                        }
                    }
                    return
                } else {
                    enter()
                }
            }
            displayValue = brain.performOperation(operation)
            updateHistory()
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear()
        brain.variableValues.removeAll(keepCapacity: false)
        resetDisplayText()
        updateHistory()
    }
    
    
    @IBAction func backspace() {
        if (!userIsInTheMiddleOfTypingANumber) {
            displayValue = brain.undoOp()
            updateHistory()
            return
        }
        if count(calculatorDisplay.text!) > 1 {
            calculatorDisplay.text = dropLast(calculatorDisplay.text!)
        } else {
            resetDisplayText()
        }
    }
    
    private let memoryVariableName = "M"
    
    @IBAction func setMemoryValue(sender: UIButton) {
        if let newMemoryValue = displayValue {
            userIsInTheMiddleOfTypingANumber = false
            brain.variableValues.updateValue(newMemoryValue, forKey: memoryVariableName)
            displayValue = brain.evaluate()
            updateHistory()
        }
    }
    
    private func updateHistory() {
        history.text = brain.description
    }
    
    private func resetDisplayText() {
        calculatorDisplay.text = "0"
        userIsInTheMiddleOfTypingANumber = false
    }
    
    var displayValue: Double? {
        get {
            if let displayText = calculatorDisplay.text {
                return NSNumberFormatter().numberFromString(displayText)?.doubleValue
            }
            return nil
            
        }
        set {
            if let newNumber = newValue {
                calculatorDisplay.text = "\(newNumber)"
            } else {
                calculatorDisplay.text = nil
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
   

    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTypingANumber {
            calculatorDisplay.text = calculatorDisplay.text! + digit
        } else {
            calculatorDisplay.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }

}

