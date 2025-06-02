//
//  MoviePlayerViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import UIKit
import AVFoundation

protocol MoviePlayerViewControllerProtocol: AnyObject {
    func updatePlayPauseButton(isPlaying: Bool)
    func updateVolumeIcon(isMuted: Bool, volume: Float)
    func updateProgress(currentTime: String, progress: Float)
    func updateTotalTime(_ totalTime: String)
    func setupPlayerLayer(with player: AVPlayer)
    func updateMovieInfo(title: String, description: String)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showControls()
    func hideControls()
}

final class MoviePlayerViewController: BaseViewController {
    
    var presenter: MoviePlayerPresenterProtocol!
    private var playerLayer: AVPlayerLayer?
    private var isFullscreen = false
        
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.alpha = 0
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var fullscreenButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        button.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(fullscreenButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var volumeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "speaker.2.fill", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(volumeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.value = 1.0
        slider.addTarget(self, action: #selector(volumeSliderChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var progressSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = .systemBlue
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.3)
        slider.thumbTintColor = .white
        slider.addTarget(self, action: #selector(progressSliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(progressSliderTouchBegan), for: .touchDown)
        slider.addTarget(self, action: #selector(progressSliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var movieTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "No title for this movie."
        return label
    }()
    
    private lazy var movieDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.text = "There is no decription for this movie"
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
                
    private var playerHeightConstraint: NSLayoutConstraint!
    private var contentViewBottomConstraint: NSLayoutConstraint!
    private var fullscreenConstraints: [NSLayoutConstraint] = []
    private var normalConstraints: [NSLayoutConstraint] = []
        
    var movie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad(movie: movie)
        listenOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    private func listenOrientation(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deviceOrientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func deviceOrientationDidChange() {
        let orientation = UIDevice.current.orientation

        switch orientation {
        case .landscapeLeft, .landscapeRight:
            if !isFullscreen {
                enterFullscreen()
            }
        case .portrait:
            if isFullscreen {
                exitFullscreen()
            }
        default:
            break
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    
    private func setupUI() {
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(backButton)
        view.addSubview(playerContainerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(movieTitleLabel)
        contentView.addSubview(movieDescriptionLabel)
        
        playerContainerView.addSubview(controlsContainerView)
        playerContainerView.addSubview(loadingIndicator)
        controlsContainerView.addSubview(playPauseButton)
        controlsContainerView.addSubview(fullscreenButton)
        controlsContainerView.addSubview(volumeButton)
        controlsContainerView.addSubview(volumeSlider)
        controlsContainerView.addSubview(progressSlider)
        controlsContainerView.addSubview(currentTimeLabel)
        controlsContainerView.addSubview(totalTimeLabel)
        
        setupConstraints()
        setupGestures()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        playerHeightConstraint = playerContainerView.heightAnchor.constraint(equalTo: playerContainerView.widthAnchor, multiplier: 9.0/16.0)
        normalConstraints = [
            playerContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            playerHeightConstraint
        ]
        NSLayoutConstraint.activate(normalConstraints)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(equalTo: movieDescriptionLabel.bottomAnchor, constant: 32)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentViewBottomConstraint
        ])
        
        NSLayoutConstraint.activate([
            controlsContainerView.leadingAnchor.constraint(equalTo: playerContainerView.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: playerContainerView.trailingAnchor),
            controlsContainerView.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 60),
            playPauseButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            volumeButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 12),
            volumeButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16),
            volumeButton.widthAnchor.constraint(equalToConstant: 32),
            volumeButton.heightAnchor.constraint(equalToConstant: 32),
            
            volumeSlider.centerYAnchor.constraint(equalTo: volumeButton.centerYAnchor),
            volumeSlider.trailingAnchor.constraint(equalTo: volumeButton.leadingAnchor, constant: -8),
            volumeSlider.widthAnchor.constraint(equalToConstant: 70),
            volumeSlider.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -24),
            
            totalTimeLabel.trailingAnchor.constraint(equalTo: fullscreenButton.leadingAnchor, constant: -12),
            totalTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -24),
            
            fullscreenButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16),
            fullscreenButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -20),
            fullscreenButton.widthAnchor.constraint(equalToConstant: 24),
            fullscreenButton.heightAnchor.constraint(equalToConstant: 24),
            
            progressSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 12),
            progressSlider.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor, constant: -12),
            progressSlider.centerYAnchor.constraint(equalTo: currentTimeLabel.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: playerContainerView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            movieTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            movieTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            movieDescriptionLabel.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 12),
            movieDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            movieDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped))
        //Ekrana tıklanma gestureı kontrolcüyü açıp kapama yeri
        playerContainerView.addGestureRecognizer(tapGesture)
    }
        
    @objc private func playPauseButtonTapped() {
        presenter.playPauseTapped()
    }
    
    @objc private func fullscreenButtonTapped() {
        //Ekran full ekransa ekrandan çıkma yatay hizadan düz hizaya geçme ya da tam tersi
        if isFullscreen {
            exitFullscreen()
        } else {
            enterFullscreen()
        }
    }
    
    private func enterFullscreen() {
        isFullscreen = true
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.deactivate(normalConstraints)
        
        fullscreenConstraints = [
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(fullscreenConstraints)
        
        playerContainerView.layer.cornerRadius = 0
        
        scrollView.isHidden = true
        backButton.isHidden = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        fullscreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: config), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if #available(iOS 16.0, *) {
                guard let windowScene = self.view.window?.windowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        }
    }
    
    private func exitFullscreen() {
        isFullscreen = false
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.deactivate(fullscreenConstraints)
        
        NSLayoutConstraint.activate(normalConstraints)
        
        playerContainerView.layer.cornerRadius = 12
        
        scrollView.isHidden = false
        backButton.isHidden = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: config), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if #available(iOS 16.0, *) {
                guard let windowScene = self.view.window?.windowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    @objc private func volumeButtonTapped() {
        presenter.volumeButtonTapped()
    }
    
    @objc private func volumeSliderChanged() {
        presenter.volumeSliderChanged(to: volumeSlider.value)
    }
    
    @objc private func progressSliderValueChanged() {
        presenter.progressSliderChanged(to: progressSlider.value)
    }
    
    @objc private func progressSliderTouchBegan() {
        presenter.progressSliderTouchBegan()
    }
    
    @objc private func progressSliderTouchEnded() {
        presenter.progressSliderTouchEnded()
    }
    
    @objc private func playerTapped() {
        presenter.playerTapped()
    }
    
    @objc private func backButtonTapped() {
        presenter.backButtonTapped()
    }
        
    func enterFullscreenLayout() {
        isFullscreen = true
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.deactivate(normalConstraints)
        
        fullscreenConstraints = [
            playerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(fullscreenConstraints)
        
        playerContainerView.layer.cornerRadius = 0
        
        scrollView.isHidden = true
        backButton.isHidden = true
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        fullscreenButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: config), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if #available(iOS 16.0, *) {
                guard let windowScene = self.view.window?.windowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }
        }
    }
    
    func exitFullscreenLayout() {
        isFullscreen = false
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        NSLayoutConstraint.deactivate(fullscreenConstraints)
        
        NSLayoutConstraint.activate(normalConstraints)
        
        playerContainerView.layer.cornerRadius = 12
        
        scrollView.isHidden = false
        backButton.isHidden = false
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        fullscreenButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: config), for: .normal)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            if #available(iOS 16.0, *) {
                guard let windowScene = self.view.window?.windowScene else { return }
                windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
}

extension MoviePlayerViewController: MoviePlayerViewControllerProtocol {
    
    func updateMovieInfo(title: String, description: String) {
        movieTitleLabel.text = title
        movieDescriptionLabel.text = description
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        let imageName = isPlaying ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
    }
    
    func updateVolumeIcon(isMuted: Bool, volume: Float) {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let imageName: String
        if isMuted || volume == 0 {
            imageName = "speaker.slash.fill"
        } else if volume < 0.3 {
            imageName = "speaker.1.fill"
        } else if volume < 0.7 {
            imageName = "speaker.2.fill"
        } else {
            imageName = "speaker.3.fill"
        }
        volumeButton.setImage(UIImage(systemName: imageName, withConfiguration: config), for: .normal)
        volumeSlider.value = volume
    }
    
    func updateProgress(currentTime: String, progress: Float) {
        currentTimeLabel.text = currentTime
        progressSlider.value = progress
    }
    
    func updateTotalTime(_ totalTime: String) {
        totalTimeLabel.text = totalTime
    }
    
    func setupPlayerLayer(with player: AVPlayer) {
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer = playerLayer {
            playerContainerView.layer.insertSublayer(playerLayer, at: 0)
            playerLayer.frame = playerContainerView.bounds
        }
    }
    
    func showLoadingIndicator() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        loadingIndicator.stopAnimating()
    }
    
    func showControls() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 1
        }
    }
    
    func hideControls() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 0
        }
    }
}
