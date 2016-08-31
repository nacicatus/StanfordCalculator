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
        case UnaryOperation(String, Double ->Double)
        case BinaryOperation(String, (Double, Double) ->Double)
        
        var description : String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                
                }
            }
        }
        
    }
    
    private var opStack = [Op]()
    private var knownOps = Dictionary<String, Op>()
    
    // initialize
    init() {
        knownOps["×"] = Op.BinaryOperation("×", *)
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["-"] = Op.BinaryOperation("-") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["sin"] = Op.UnaryOperation("sin") {sin($0)}
        knownOps["cos"] = Op.UnaryOperation("cos") {cos($0)}
    }
    
    private func evaluateStack(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops // we make a local variable, because ops is an immutable array, but if we make a var copy of it, it becomes mutable and we can work with it
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluateStack(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
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
    

}