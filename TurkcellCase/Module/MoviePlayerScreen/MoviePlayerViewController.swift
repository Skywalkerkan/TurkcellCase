//
//  DenemeViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 29.05.2025.
//

import UIKit
import AVFoundation
import AVKit

class MoviePlayerViewController: UIViewController {
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var timeObserver: Any?
    private var isPlaying = false
    private var isFullscreen = false
    private var isMuted = false
    private var originalOrientation: UIInterfaceOrientationMask = .portrait
    
    var movieTitle: String = "Örnek Dizi"
    var movieDescription: String = "Örnek film açıklamasııııı "
    var movieURL = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
    
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
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchBegan), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchEnded), for: [.touchUpInside, .touchUpOutside])
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
        label.textColor = .label
        label.numberOfLines = 0
        label.text = movieTitle
        return label
    }()
    
    private lazy var movieDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = movieDescription
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Constraints
    private var playerHeightConstraint: NSLayoutConstraint!
    private var contentViewBottomConstraint: NSLayoutConstraint!
    private var fullscreenConstraints: [NSLayoutConstraint] = []
    private var normalConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPlayer()
        setupGestures()
        setupNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = playerContainerView.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pausePlayer()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isFullscreen ? .landscape : .portrait
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    deinit {
        cleanup()
    }
    
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        view.addSubview(backButton)
        view.addSubview(playerContainerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(movieTitleLabel)
        contentView.addSubview(movieDescriptionLabel)
        
        // Player controls
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
            scrollView.topAnchor.constraint(equalTo: playerContainerView.bottomAnchor, constant: 0),
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
    
    private func setupPlayer() {
        guard let url = URL(string: movieURL) else { return }
        
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        
        if let playerLayer = playerLayer {
            playerContainerView.layer.insertSublayer(playerLayer, at: 0)
        }
        
        setupTimeObserver()
        observePlayerStatus()
        setupAudioSession()
        loadingIndicator.startAnimating()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.updateProgress()
        }
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playerTapped))
        playerContainerView.addGestureRecognizer(tapGesture)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationDidChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
        
    private func observePlayerStatus() {
        player?.currentItem?.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if player?.currentItem?.status == .readyToPlay {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                    self.updateTotalTime()
                    self.controlsContainerView.alpha = 1
                }
            }
        } else if keyPath == "duration" {
            DispatchQueue.main.async {
                self.updateTotalTime()
            }
        }
    }
    
    private func updateProgress() {
        guard let currentTime = player?.currentTime(),
              let duration = player?.currentItem?.duration,
              !duration.seconds.isNaN,
              duration.seconds > 0 else { return }
        
        let currentSeconds = currentTime.seconds
        let totalSeconds = duration.seconds
        
        progressSlider.value = Float(currentSeconds / totalSeconds)
        currentTimeLabel.text = formatTime(currentSeconds)
    }
    
    private func updateTotalTime() {
        guard let duration = player?.currentItem?.duration,
              !duration.seconds.isNaN else { return }
        
        totalTimeLabel.text = formatTime(duration.seconds)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let totalSeconds = Int(seconds)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func toggleControlsVisibility() {
        let shouldShow = controlsContainerView.alpha == 0

        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = shouldShow ? 1 : 0
        }

        if shouldShow && isPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                if self.controlsContainerView.alpha > 0 && self.isPlaying {
                    UIView.animate(withDuration: 0.3) {
                        self.controlsContainerView.alpha = 0
                    }
                }
            }
        }

        if !isPlaying {
            UIView.animate(withDuration: 0.3) {
                self.controlsContainerView.alpha = 1
            }
        }
    }
    
    private func playPlayer() {
        player?.play()
        isPlaying = true
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: config), for: .normal)
    }
    
    private func pausePlayer() {
        player?.pause()
        isPlaying = false
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .semibold)
        playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: config), for: .normal)
    }
    
    private func updateVolumeUI() {
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        if isMuted || volumeSlider.value == 0 {
            volumeButton.setImage(UIImage(systemName: "speaker.slash.fill", withConfiguration: config), for: .normal)
        } else if volumeSlider.value < 0.3 {
            volumeButton.setImage(UIImage(systemName: "speaker.1.fill", withConfiguration: config), for: .normal)
        } else if volumeSlider.value < 0.7 {
            volumeButton.setImage(UIImage(systemName: "speaker.2.fill", withConfiguration: config), for: .normal)
        } else {
            volumeButton.setImage(UIImage(systemName: "speaker.3.fill", withConfiguration: config), for: .normal)
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
        
    @objc private func playPauseButtonTapped() {
        if isPlaying {
            pausePlayer()
        } else {
            playPlayer()
            toggleControlsVisibility()
        }
    }
    
    @objc private func fullscreenButtonTapped() {
        if isFullscreen {
            exitFullscreen()
        } else {
            enterFullscreen()
        }
    }
    
    @objc private func volumeButtonTapped() {
        isMuted.toggle()
        player?.isMuted = isMuted
        updateVolumeUI()
    }
    
    @objc private func volumeSliderChanged() {
        player?.volume = volumeSlider.value
        isMuted = false
        player?.isMuted = false
        updateVolumeUI()
    }
    
    @objc private func sliderValueChanged() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = duration.seconds
        let seekTime = Double(progressSlider.value) * totalSeconds
        let seekCMTime = CMTime(seconds: seekTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: seekCMTime)
    }
    
    @objc private func sliderTouchBegan() {
        player?.pause()
    }
    
    @objc private func sliderTouchEnded() {
        if isPlaying {
            player?.play()
        }
    }
    
    @objc private func playerTapped() {
        toggleControlsVisibility()
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func playerDidFinishPlaying() {
        pausePlayer()
        player?.seek(to: .zero)
        progressSlider.value = 0
        currentTimeLabel.text = "00:00"
    }
    
    @objc private func orientationDidChange() {
        DispatchQueue.main.async {
            self.playerLayer?.frame = self.playerContainerView.bounds
        }
    }
        
    private func cleanup() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
        
        player?.currentItem?.removeObserver(self, forKeyPath: "status")
        player?.currentItem?.removeObserver(self, forKeyPath: "duration")
        
        NotificationCenter.default.removeObserver(self)
        
        player?.pause()
        player = nil
        playerLayer = nil
    }
}
