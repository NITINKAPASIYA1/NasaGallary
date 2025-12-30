//
//  HomeView.swift
//  NasaGallary
//
//  Created by Nitin Kapasiya on 30/12/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var showFullImage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .scaleEffect(1)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(message: errorMessage) {
                        viewModel.retryFetch()
                    }
                } else if let apod = viewModel.apodData {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            // Image Section
                            if apod.isImage {
                                AsyncImage(url: URL(string: apod.url)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(height: 300)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                            .onTapGesture {
                                                showFullImage = true
                                            }
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .padding(.horizontal, 10)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 300)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                VideoPlaceholderView(url: apod.url)
                            }
                            
                            // Title
                            Text(apod.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            HStack(spacing: 10) {
                                Text(apod.date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                
                                // Copyright
                                if let copyright = apod.copyright {
                                    HStack {
                                        Image(systemName: "c.circle")
                                            .font(.caption)
                                        Text(copyright)
                                            .font(.caption)
                                    }
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Explanation
                            Text(apod.explanation)
                                .font(.body)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    }
                    .sheet(isPresented: $showFullImage) {
                        FullImageView(imageURL: apod.displayMediaURL)
                    }
                }
            }
            .navigationTitle("NASA GALLARY")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showDatePicker.toggle()
                    }) {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerView(selectedDate: $selectedDate) { date in
                    viewModel.fetchAPOD(for: date)
                    showDatePicker = false
                }
            }
        }
        .onAppear {
            if viewModel.apodData == nil {
                viewModel.fetchAPOD()
            }
        }
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Oops!")
                .font(.title)
                .fontWeight(.bold)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Retry")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}
    
struct VideoPlaceholderView: View {
    let url: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "play.rectangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Video Content")
                .font(.headline)
            
            Text("This APOD contains a video. Tap to view in browser.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let videoURL = URL(string: url) {
                Link("Open Video", destination: videoURL)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
}
