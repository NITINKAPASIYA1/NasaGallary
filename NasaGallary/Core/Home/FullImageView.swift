//
//  FullImageView.swift
//  NasaGallary
//
//  Created by Nitin Kapasiya on 30/12/25.
//

import SwiftUI

struct FullImageView: View {
    let imageURL: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity,alignment: .center)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        if scale < 1 {
                                            withAnimation {
                                                scale = 1
                                                lastScale = 1
                                            }
                                        } else if scale > 5 {
                                            withAnimation {
                                                scale = 5
                                                lastScale = 5
                                            }
                                        }
                                    }
                            )
                            .onTapGesture(count: 2) {
                                withAnimation {
                                    if scale > 1 {
                                        scale = 1
                                        lastScale = 1
                                    } else {
                                        scale = 2
                                        lastScale = 2
                                    }
                                }
                            }
                    case .failure:
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        }
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            }.foregroundColor(.white))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    let onDateSelected: (Date) -> Void
    
    private let minDate: Date = {
        let components = DateComponents(year: 1995, month: 6, day: 16)
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    private let maxDate: Date = {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select a Date")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Choose any date from June 16, 1995 onwards")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: minDate...maxDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Button(action: {
                    onDateSelected(selectedDate)
                }) {
                    Text("Fetch APOD")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Gradient(colors: [Color.yellow.opacity(0.8),Color.red.opacity(0.6),Color.green.opacity(0.4)]))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
}
