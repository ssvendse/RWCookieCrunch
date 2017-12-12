//
//  Array2D.swift
//  RWCookieCrunch
//
//  Created by Skyler Svendsen on 11/21/17.
//  Copyright © 2017 Skyler Svendsen. All rights reserved.
//

struct Array2D<T> {
    
    let columns: Int
    let rows: Int
    fileprivate var array: Array<T?>
    
    init(columns: Int, rows: Int) {
        self.columns = columns
        self.rows = rows
        array = Array<T?>(repeating: nil, count: rows*columns)
    }
    
    subscript(column: Int, row: Int) -> T? {
        get {
            return array[row*columns + column]
        }
        set {
            array[row*columns + column] = newValue
        }
    }
}
