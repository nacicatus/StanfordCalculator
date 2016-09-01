//
//  CalculatorBrain.swift
//  StanfordCalculator
//
//  Created by Saurabh Sikka on 31/08/16.
//  Copyright (c) 2016 Saurabh Sikka. All rights reserved.
//

import Foundation // It's a model, there should never be an import UIKit here

class CalculatorBrain {
    
    private enum Op : Printable {           //implements a protocol called Printable
        case Operand(Double)
        case Variable(String)
        case ConstantOperation(String, () -> Double) // this is for the pi!
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, Int, (Double, Double) ->Double)
        
        var description : String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variableName):
                    return variableName
                case .ConstantOperation(let constantName, _):
                    return constantName
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _, _):
                    return symbol
                
                }
            }
        }
        
    // In order to create a human readable display in the History section we need to create a variable to determine precedence
    var precedence: Int {
        get {
            switch self {
            case .BinaryOperation(_, let precedence, _):
                return precedence
            default:
                return Op.defaultPrecedence()
            }
        }
    }
        
    static func defaultPrecedence() -> Int {
            return Int.max
        }

} // end of the enum
    
    
    // The stack of operations and operands
    private var opStack = [Op]()
    
    // a Dictionary of known operations, used to translate the symbol into an operation
    private var knownOps = Dictionary<String, Op>()
  
    
    // initialize
    init() {
        
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", 2, *))
        learnOp(Op.BinaryOperation("÷", 2, {$1 / $0}))
        learnOp(Op.BinaryOperation("+", 1, +))
        learnOp(Op.BinaryOperation("-", 1, {$1 - $0}))
        learnOp(Op.UnaryOperation("√", sqrt))
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±", { -$0 }))
        learnOp(Op.ConstantOperation("π", {M_PI}))
        
    }
    
    
    // We're going to report back a PropertyList
    typealias PropertyList = AnyObject
    var program: PropertyList {
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? [String] {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        newOpStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    
    // Evaluates the opStack recursively and returns "result" and "remainder"
    private func evaluateStack(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops // we make a local variable, because ops is an immutable array, but if we make a var copy of it, it becomes mutable and we can work with it
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variableName):
                if let variableValue = variableValues[variableName] {
                    return (variableValue, remainingOps)
                }
                return (nil, remainingOps)
            case .ConstantOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluateStack(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, _, let operation):
                let op1Evaluation = evaluateStack(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateStack(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
            
        }
        
        return(nil, ops)
    }
    
    
    // Evaluates the whole brain and returns the result of that operation
    func evaluate() -> Double? {
        let (result, remainder) = evaluateStack(opStack)
        print("\(opStack) = \(result) with \(remainder) left over")
        return result
        
    }
    
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    // Pushes a variable operand to the opStack
    func pushOperand(operandVariable: String) -> Double? {
        opStack.append(Op.Variable(operandVariable))
        return evaluate()
    }
    
    // Removes the last operation from the opStack and recalculates
    func undoOp() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
    
    // Sets or gets values of variable operands in the stack
    var variableValues: Dictionary<String, Double> = Dictionary<String, Double>()
    
    // clears the opStack
    func clear() {
        opStack.removeAll(keepCapacity: false)
    }
    
    // Returns a human readable stack
    var description: String {
        get {
            if opStack.isEmpty {
                return "Empty"
            }
            var humanReadable = ""
            var (result, _, remainingOps) = history(opStack)
            humanReadable += result
            while !remainingOps.isEmpty {
                (result, _, remainingOps) = history(remainingOps)
                humanReadable = result + " , " + humanReadable
            }
            
            switch opStack.last! {
            case Op.ConstantOperation(_, _):
                fallthrough
            case Op.Operand(_):
                break;
            default:
                humanReadable += "="
            }
            return humanReadable
        }
    }
    
    private func history(ops: [Op]) -> (result: String, opPrecedence: Int, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            let currentOpPrecedence = op.precedence
            switch op {
            case .Operand(let operand):
                return ("\(operand)", currentOpPrecedence, remainingOps)
            case .Variable(let variableName):
                return (variableName, currentOpPrecedence, remainingOps)
            case .ConstantOperation(let operationName, _):
                return (operationName, currentOpPrecedence, remainingOps)
            case .UnaryOperation(let operationName, _):
                let operandEvaluation = history(remainingOps)
                let result = operationName + "(" + operandEvaluation.result + ")"
                return (result, currentOpPrecedence, operandEvaluation.remainingOps)
            case .BinaryOperation(let operationName, _, _):
                let op1Evaluation = history(remainingOps)
                let op2Evaluation = history(op1Evaluation.remainingOps)
                var result = ""
                
                if op2Evaluation.opPrecedence < currentOpPrecedence {
                    result += "(" + op2Evaluation.result + ")"
                } else {
                    result += op2Evaluation.result
                }
                result += operationName
                
                if op1Evaluation.opPrecedence < currentOpPrecedence {
                    result += "(" + op1Evaluation.result + ")"
                } else {
                    result += op1Evaluation.result
                }
                return (result, currentOpPrecedence, op2Evaluation.remainingOps)
            }
        }
        return ("?", Op.defaultPrecedence(), ops)
    }
    

}