//: Playground - noun: a place where people can play

import UIKit
import MRClient
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


DispatchQueue.main.async {
    for i in 0...10000{
        print("hi: ", i)
    }
}

DispatchQueue.main.async {
    for i in 0...100{
        print("bye", i)
    }
}
