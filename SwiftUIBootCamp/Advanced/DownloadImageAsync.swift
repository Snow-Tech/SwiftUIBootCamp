//
//  DoCatchTryThrowsBootCamp.swift
//  SwiftUIBootCamp
//
//  Created by Brian Michael on 24/07/2022.
//

import SwiftUI
import Combine

class DownloadAsyncImageLoader {
    
    let url = URL(string: "https://pbs.twimg.com/profile_images/1264183802315902977/WRMYPLJI_400x400.jpg")!
    
    private func handleResponse(data: Data?, response: URLResponse?) -> UIImage? {
        guard let data = data, let image = UIImage(data: data), let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }
    
    func downloadImage(completion: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data), let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
                completion(nil, error)
                return
            }
            completion(image, nil)
        }
        .resume()
    }
    
    //COMBINE
    func downloadImageWithCombine() -> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }
    
    //ASYNC AWAIT
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
            return handleResponse(data: data, response: response)
        } catch {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject {
    
    @Published var image: UIImage? = nil
    private let loader = DownloadAsyncImageLoader()
    private var cancellable = Set<AnyCancellable>()
    
    func fetchImage() async {
        //        loader.downloadImage(completion: { [weak self] image, error in
        //            if let _ = error {
        //                return
        //            }
        //
        //            if let image = image {
        //                DispatchQueue.main.async {
        //                    self?.image = image
        //                }
        //            }
        //        })
        
        //COMBINE
        //        loader.downloadImageWithCombine()
        //            .receive(on: DispatchQueue.main)
        //            .sink { _ in
        //
        //            } receiveValue: { [weak self] image in
        //                self?.image = image
        //            }
        //            .store(in: &cancellable)

        //ASYNC/AWAIT
        self.image = try? await loader.downloadWithAsync()
    }
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel ()
    
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .clipShape(Circle())
            }
        }
        .task { @MainActor in
            await viewModel.fetchImage()
        }
    }
}

struct DoCatchTryThrowsBootCamp_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
