//
//  MoviePlayerPresenter.swift
//  TurkcellCase
//
//  Created by Erkan on 31.05.2025.
//

import Foundation
import AVFoundation

protocol MoviePlayerPresenterProtocol {
    func viewDidLoad(movie: Movie?)
    func playPauseTapped()
    func volumeButtonTapped()
    func volumeSliderChanged(to value: Float)
    func progressSliderChanged(to value: Float)
    func progressSliderTouchBegan()
    func progressSliderTouchEnded()
    func playerTapped()
    func backButtonTapped()
}

final class MoviePlayerPresenter {
    
    unowned var view: MoviePlayerViewControllerProtocol
    private let interactor: MoviePlayerInteractorProtocol
    private let router: MoviePlayerRouterProtocol
    
    private var movie: Movie?
    private var isPlaying = false
    private var isMuted = false
    
    init(view: MoviePlayerViewControllerProtocol,
         interactor: MoviePlayerInteractorProtocol,
         router: MoviePlayerRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
}

extension MoviePlayerPresenter: MoviePlayerPresenterProtocol {
    
    func viewDidLoad(movie: Movie?) {
        self.movie = movie
        let title = movie?.title ?? "No title for this movie."
        let description = movie?.overview ?? "There is no description for this movie"
        view.updateMovieInfo(title: title, description: description)
        
        // loading indicatorunu aç ve oynatıcıyı hazırlama yeri
        view.showLoadingIndicator()
        interactor.setupPlayer()
    }
    
    func playPauseTapped() {
        if isPlaying {
            interactor.pause()
            isPlaying = false
            view.updatePlayPauseButton(isPlaying: false)
            view.showControls()
        } else {
            interactor.play()
            isPlaying = true
            view.updatePlayPauseButton(isPlaying: true)
            view.hideControls()
        }
    }
    
    // Ses kıs/aç butonu
    func volumeButtonTapped() {
        isMuted.toggle()
        interactor.setMuted(isMuted)
        view.updateVolumeIcon(isMuted: isMuted, volume: interactor.getVolume())
    }
    
    func volumeSliderChanged(to value: Float) {
        interactor.setVolume(value)
        isMuted = false
        interactor.setMuted(false)
        view.updateVolumeIcon(isMuted: false, volume: value)
    }
    
    func progressSliderChanged(to value: Float) {
        interactor.seek(to: value)
    }
    
    func progressSliderTouchBegan() {
        interactor.pause()
    }
    
    func progressSliderTouchEnded() {
        if isPlaying {
            interactor.play()
        }
    }
    
    // Oynatıcı yüzeyine dokunmada kontrolleri göster/gizlemeyeri
    //3 saniyede içinde kontrolün kapatılması eğer oynatılıyorsa
    func playerTapped() {
        if isPlaying {
            view.showControls()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                if self.isPlaying {
                    self.view.hideControls()
                }
            }
        } else {
            view.showControls()
        }
    }
    
    func backButtonTapped() {
        router.navigateBack()
    }
    
}

extension MoviePlayerPresenter: MoviePlayerInteractorOutputProtocol {
    
    func playerReady(totalTime: String) {
        view.hideLoadingIndicator()
        view.updateTotalTime(totalTime)
        view.showControls()
    }
    
    func playerProgressUpdated(currentTime: String, progress: Float) {
        view.updateProgress(currentTime: currentTime, progress: progress)
    }
    
    func playerCreated(player: AVPlayer) {
        view.setupPlayerLayer(with: player)
    }
    
    func playerDidFinish() {
        isPlaying = false
        view.updatePlayPauseButton(isPlaying: false)
    }
    
    func playerLoading() {
        view.showLoadingIndicator()
    }
}
