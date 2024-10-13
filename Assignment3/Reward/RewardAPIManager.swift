//
//  RewardAPIManager.swift
//  Assignment3
//
//  Created by thomas on 12/10/2024.
//

import Foundation

class RewardAPIManager {
    
    static let shared = RewardAPIManager() // Singleton instance
    private let baseURL = "https://api.tangocard.com/raas/v2/"
    private let apiKey = "YOUR_API_KEY"
    
    // Function to fetch available rewards
    func fetchAvailableRewards(completion: @escaping ([RewardItem]?, Error?) -> Void) {
        let urlString = "\(baseURL)catalogs"
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkError.noData)
                return
            }
            
            do {
                let rewardResponse = try JSONDecoder().decode(RewardCatalogResponse.self, from: data)
                completion(rewardResponse.rewards, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    // Function to redeem points for rewards
    func redeemReward(rewardID: String, userID: String, points: Int, completion: @escaping (RedeemResponse?, Error?) -> Void) {
        let urlString = "\(baseURL)orders"
        guard let url = URL(string: urlString) else {
            completion(nil, NetworkError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "reward_id": rewardID,
            "user_id": userID,
            "points": points
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(nil, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NetworkError.noData)
                return
            }
            
            do {
                let redeemResponse = try JSONDecoder().decode(RedeemResponse.self, from: data)
                completion(redeemResponse, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}

// Error types for networking
enum NetworkError: Error {
    case invalidURL
    case noData
}

// Data models for rewards
struct RewardCatalogResponse: Codable {
    let rewards: [RewardItem]
}

struct RewardItem: Codable {
    let rewardID: String
    let rewardName: String
    let pointsRequired: Int
}

struct RedeemResponse: Codable {
    let success: Bool
    let message: String
}
