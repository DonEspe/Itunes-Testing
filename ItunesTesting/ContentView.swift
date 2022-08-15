//
//  ContentView.swift
//  NetworkTesting
//
//  Created by Don Espe on 7/23/22.
//

import SwiftUI
import Foundation

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
    var trackTimeMillis: Int
    var artworkUrl30, artworkUrl60, artworkUrl100: String
}



struct ContentView: View {
    @State private var results = [Result]()
    @State var imageCache = [String: Image]()

    var body: some View {
        Text("Testing Network")
        List(results, id:\.trackId) { item in
            HStack {
                if imageCache[item.artworkUrl60] == nil {
                    AsyncImage(url: URL(string: item.artworkUrl60)) { phase in
                        if let image = phase.image {
                            addToCache(image: image, url: item.artworkUrl60)
                            image
                                .resizable()
                                .scaledToFit()
                        } else if phase.error != nil {
                            Text("There was an error loading the image.")
                        } else {
                            ProgressView()
                        }
                    }
                } else {
                    if let image = imageCache[item.artworkUrl60] {
                        image
                            .resizable()
                            .scaledToFit()
                    }
                }


                //                .frame(width: 30, height: 30)
                //                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading) {
                    Text(item.trackName)
                        .font(.headline)
                    Text(item.collectionName)
                    Text("length (minutes): \(item.trackTimeMillis.msToSeconds.minuteSecondRounded)")
                        .font(.subheadline)
                }


            }
            .frame(height: 60)
        }
        .task {
            await loadData()
        }

    }

    //Create an array of Images?
    func loadData() async {
        print("loading data")
        guard let url = URL(string: "https://itunes.apple.com/search?term=john+williams&entity=song") else {
            print("Invalid URL")
            return
        }

        print("url ok")

        do {
            let(data, _) = try await URLSession.shared.data(from: url)

            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodedResponse.results
                print(String(decoding: data, as: UTF8.self))  //Convert data to string.
            }


        } catch {
            print("Invalid data")
        }
    }

    func addToCache(image: Image, url: String) -> Image {
        imageCache[url] = image
        return image
    }
}

extension TimeInterval {
    var hourMinuteSecondMS: String {
        String(format:"%d:%02d:%02d.%03d", hour, minute, second, millisecond)
    }
    var minuteSecondMS: String {
        String(format:"%d:%02d.%03d", minute, second, millisecond)
    }
    var minuteSecondRounded: String {
        String(format:"%d:%02d", minute, second)
    }
    var hour: Int {
        Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        Int(truncatingRemainder(dividingBy: 60))
    }
    var millisecond: Int {
        Int((self*1000).truncatingRemainder(dividingBy: 1000))
    }
}

extension Int {
    var msToSeconds: Double { Double(self) / 1000 }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
