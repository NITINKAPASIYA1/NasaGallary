//
//  HomeViewModel.swift
//  NasaGallary
//
//  Created by Nitin Kapasiya on 30/12/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var apodData: NasaStuffModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let networkService = NetworkService()
    private var cancellables = Set<AnyCancellable>()
    private var lastRequestedDate: Date?
    
    func fetchAPOD(for date: Date? = nil) {
        isLoading = true
        errorMessage = nil
        lastRequestedDate = date
        
        networkService.fetchAPOD(for: date) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let apod):
                    self?.apodData = apod
                    self?.errorMessage = nil
                case .failure(let error):
                    self?.errorMessage = self?.getErrorMessage(for: error)
                }
            }
        }
    }
    
    func retryFetch() {
        fetchAPOD(for: lastRequestedDate)
    }
    
    private func getErrorMessage(for error: NetworkError) -> String {
        switch error {
        case .invalidURL:
            return "Something went wrong. Please try again."

        case .requestFailed:
            return "Network request failed. Please check your internet connection."

        case .noData:
            return "No data received from the server."

        case .decodingFailed:
            return "Unable to process the data. Please try again later."

        case .serverError(let statusCode):
            switch statusCode {
            case 404:
                return "No data available for the selected date."
            case 429:
                return "Too many requests. Please try again later."
            default:
                return "Server error (\(statusCode)). Please try again."
            }
        }
    }

}
