//
//  StringExtension.swift
//  geosniffit
//
//  Created by cgmckeever on 11/1/14.
//  Copyright (c) 2014 cgmckeever. All rights reserved.
//

extension String {
    func doubleValue() -> Double
    {
        let minusAscii: UInt8 = 45
        let dotAscii: UInt8 = 46
        let zeroAscii: UInt8 = 48
        
        var res = 0.0
        let ascii = self.utf8
        
        var whole = [Double]()
        var current = ascii.startIndex
        
        let negative = current != ascii.endIndex && ascii[current] == minusAscii
        if (negative)
        {
            current = current.successor()
        }
        
        while current != ascii.endIndex && ascii[current] != dotAscii
        {
            whole.append(Double(ascii[current] - zeroAscii))
            current = current.successor()
        }
        
        //whole number
        var factor: Double = 1
        for var i = countElements(whole) - 1; i >= 0; i--
        {
            res += Double(whole[i]) * factor
            factor *= 10
        }
        
        //mantissa
        if current != ascii.endIndex
        {
            factor = 0.1
            current = current.successor()
            while current != ascii.endIndex
            {
                res += Double(ascii[current] - zeroAscii) * factor
                factor *= 0.1
                current = current.successor()
            }
        }
        
        if (negative)
        {
            res *= -1;
        }
        
        return res
    }
}