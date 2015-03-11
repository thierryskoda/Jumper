//
//  Bloc.swift
//  jumper
//
//  Created by Thierry Skoda on 2015-03-05.
//  Copyright (c) 2015 thierry skoda. All rights reserved.
//

import Foundation

class Bloc : NSObject {
    var length : Float;
    var width : Float;
    var height : Float;
    var speed : Float;
    
    init(length: Float, width: Float, height: Float, speed: Float) {
        
        self.length = 0.0
        self.width = 30
        self.height = 30
        self.speed = 5
    }
    
}