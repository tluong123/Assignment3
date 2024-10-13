//
//  RewardRedepmtionView.swift
//  Assignment3
//
//  Created by thomas on 10/10/2024.
//
//
import SwiftUI

struct RewardRedemptionView: View {
    @State private var rewards: [RewardItem] = []
    @State private var selectedReward: RewardItem?
    @State private var userPoints = 1000 // Example user points
    @State private var showSuccessMessage = false
    @State private var errorMessage: String? = nil // Optional String for error message
    @State private var showErrorAlert = false // Boolean for showing error alerts

    var body: some View {
        NavigationStack {
            List(rewards, id: \.rewardID) { reward in
                HStack {
                    VStack(alignment: .leading) {
                        Text(reward.rewardName)
                            .font(.headline)
                        Text("Points Required: \(reward.pointsRequired)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button("Redeem") {
                        redeemReward(reward: reward)
                    }
                    .disabled(reward.pointsRequired > userPoints)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Available Rewards")
            .onAppear {
                fetchRewards()
            }
            .alert(isPresented: $showSuccessMessage) {
                Alert(title: Text("Success"), message: Text("Reward redeemed successfully!"), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func fetchRewards() {
        RewardAPIManager.shared.fetchAvailableRewards { rewards, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            }
            self.rewards = rewards ?? []
        }
    }

    private func redeemReward(reward: RewardItem) {
        RewardAPIManager.shared.redeemReward(rewardID: reward.rewardID, userID: "USER_ID", points: reward.pointsRequired) { response, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showErrorAlert = true
                return
            }
            if response?.success == true {
                userPoints -= reward.pointsRequired
                showSuccessMessage = true
            } else {
                errorMessage = response?.message ?? "Failed to redeem reward."
                showErrorAlert = true
            }
        }
    }
}
