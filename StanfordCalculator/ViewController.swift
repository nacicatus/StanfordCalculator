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
    
    var operandStack = [Double]()
    
    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        operandStack.append(displayValue)
        stackDisplay.text! = "\(operandStack)\n"
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        switch operation {
        case "×": performOperation {$0 * $1}
        case "÷": performOperation {$1 / $0}
        case "+": performOperation {$0 + $1}
        case "-": performOperation {$1 - $0}
        case "√": performOperation2 {sqrt($0)}
        case "sin": performOperation2 {sin($0)}
        case "cos":performOperation2 {cos($0)}
        default: break
        }
    }
    
    func performOperation (operation: (Double, Double) ->Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast())
            enter()
        }
    }
    
    func performOperation2 (operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast())
            enter()
        }
    }
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(calculatorDisplay.text!)!.doubleValue
        }
        set {
            calculatorDisplay.text = "\(newValue)"
            userIsInTheMiddleOfTypingANumber = false
        }
    }
   
    @IBAction func clear(sender: UIButton) {
        do {
            operandStack.removeLast()
        } while operandStack.count >  0
        calculatorDisplay.text = "\(0)"
        userIsInTheMiddleOfTypingANumber = false
        print(operandStack)
        
    }
    
    
    @IBAction func appendPi(sender: UIButton) {
      displayValue = M_PI
        enter()
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

