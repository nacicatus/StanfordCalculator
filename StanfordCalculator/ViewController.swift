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
    
    @IBOutlet weak var stackDisplay: UILabel!
    
    var brain = CalculatorBrain()
    
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
            calculatorDisplay.text = "\(result)"
        } else {
            displayValue = 0
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        }
        
    }
    
    @IBAction func clear(sender: UIButton) {
        displayValue = 0
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(calculatorDisplay.text!)!.doubleValue
        }
        set {
            calculatorDisplay.text = "\(newValue)"
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

