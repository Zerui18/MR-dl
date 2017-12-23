//
//  URLRequest+MRClient.swift
//  MRClient
//
//  Created by Chen Changheng on 19/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation


let resultDecoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .secondsSince1970
    return d
}()

extension URLRequest{
    
    /**
     Fetch and decode a Codable object using the receiver.
     - parameters:
        - completion: closure to be run when the fetch completes
        - error: Optional error raised during the fetch
        - object: Optional fetched object which might be nil due to errors during the process
     */
    func fetch<T: Codable>(completion:@escaping (_ error: Error?, _ object: T?)-> Void){
        URLSession.shared.dataTask(with: self) { (data, _, error) in
            if error != nil{
                completion(error, nil)
            }
            else{
                do{
                    completion(nil, try resultDecoder.decode(T.self, from: data!))
                }
                catch let decodeError{
                    completion(decodeError, nil)
                }
            }
        }.resume()
    }
    
}
