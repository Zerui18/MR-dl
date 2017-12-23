//: Playground - noun: a place where people can play

import MRClient
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true


let data = try! Data(contentsOf: URL(string: "")!)

let decrpted = MRImageDataDecryptor.decrypt(data: data)



