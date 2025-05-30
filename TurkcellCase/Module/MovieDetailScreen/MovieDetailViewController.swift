//
//  MovieDetailViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 28.05.2025.
//

import UIKit

protocol MovieDetailViewControllerProtocol: AnyObject {
    func reloadData()
    func setupCollectionView()
    func hideLoadingView()
    func showLoadingView()
    func showError(_ error: String)
}

class MovieDetailViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.backgroundColor = .systemGray4
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowRadius = 8
        imageView.layer.shadowOpacity = 0.3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("▶ Oynat", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.systemRed.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.3
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let ratingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemYellow.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let starImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        imageView.tintColor = .systemYellow
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .systemYellow
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemBlue
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let durationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Konu"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let castTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Oyuncular"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var castCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = .systemRed
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

   /* var movie: Movie? {
        didSet {
            updateUI()
        }
    }*/
    
    var movie: Movie?

    
    private let castMembers = [
        ("Leonardo DiCaprio", "Actor", "https://example.com/leo.jpg"),
        ("Kate Winslet", "Actress", "https://example.com/kate.jpg"),
        ("James Cameron", "Director", "https://example.com/james.jpg"),
        ("Celine Dion", "Singer", "https://example.com/celine.jpg"),
        ("Celine Dion", "Singer", "https://example.com/celine.jpg")
    ]
    
    var presenter: MovieDetailPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        registerCollectionViewCells()
        if let movieId = movie?.id {
            presenter.fetchCredits(for: movieId)
        }
        configureViews()
        
        if UIDevice.current.userInterfaceIdiom == .pad,
           let split = splitViewController as? UISplitViewController {
            setupBackButton()
        }
        
    }
    
    private func configureViews() {
        guard let movie = movie else { return }

        titleLabel.text = movie.title ?? "Bilinmeyen Başlık"

        if let releaseDate = movie.releaseDate, let year = releaseDate.split(separator: "-").first {
            yearLabel.text = String(year)
        } else {
            yearLabel.text = "Yıl Bilinmiyor"
        }

        if let rating = movie.voteAverage {
            ratingLabel.text = String(format: "%.1f", rating)
        } else {
            ratingLabel.text = "-"
        }

        if let genreIds = movie.genreIds {
            let genres = genreIds.compactMap { genreName(for: $0) }
            genreLabel.text = genres.joined(separator: " • ")
        } else {
            genreLabel.text = "Tür bilgisi yok"
        }

        durationLabel.text = "2 saat 28 dk"

        overviewLabel.text = movie.overview ?? "Açıklama bulunmuyor."

        if let backdropPath = movie.backdropPath {
            let url = "https://image.tmdb.org/t/p/w780\(backdropPath)"
            ImageLoaderManager.shared.loadImage(from: url, into: backdropImageView, placeholder: UIImage(named: "placeholder"))
        }

        if let posterPath = movie.posterPath {
            let url = "https://image.tmdb.org/t/p/w500\(posterPath)"
            ImageLoaderManager.shared.loadImage(from: url, into: posterImageView, placeholder: UIImage(named: "placeholder"))
        }

    }

    private func genreName(for id: Int) -> String? {
        let genres: [Int: String] = [
            28: "Aksiyon",
            12: "Macera",
            16: "Animasyon",
            35: "Komedi",
            80: "Suç",
            99: "Belgesel",
            18: "Dram",
            10751: "Aile",
            14: "Fantastik",
            36: "Tarih",
            27: "Korku",
            10402: "Müzik",
            9648: "Gizem",
            10749: "Romantik",
            878: "Bilim Kurgu",
            10770: "TV Filmi",
            53: "Gerilim",
            10752: "Savaş",
            37: "Western"
        ]
        return genres[id]
    }

    
    private func setupBackButton() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        guard let split = splitViewController as? UISplitViewController,
              let window = view.window else { return }
        
        guard let primaryNav = split.viewController(for: .primary) as? UINavigationController,
              let listVC = primaryNav.viewControllers.first else { return }
        
        let singleNav = UINavigationController(rootViewController: listVC)
        
        UIView.transition(with: window, duration: 0.35, options: [.curveEaseInOut], animations: {
            self.view.transform = CGAffineTransform(translationX: window.bounds.width, y: 0)
        }) { _ in
            window.rootViewController = singleNav
            self.view.transform = .identity
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        contentView.addSubview(backdropImageView)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.systemBackground.withAlphaComponent(0.8).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradientLayer.locations = [0.0, 0.7, 1.0]
        backdropImageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(posterImageView)
        
        setupPlayButton()
        
        contentView.addSubview(titleLabel)

        contentView.addSubview(yearLabel)
        
        setupRatingView()

        contentView.addSubview(genreLabel)
        
        contentView.addSubview(durationLabel)

        contentView.addSubview(overviewTitleLabel)
        

        contentView.addSubview(overviewLabel)
        
        contentView.addSubview(castTitleLabel)
        
        castCollectionView.translatesAutoresizingMaskIntoConstraints = false
        castCollectionView.backgroundColor = UIColor.clear
        castCollectionView.showsHorizontalScrollIndicator = false
        castCollectionView.dataSource = self
        castCollectionView.delegate = self
        contentView.addSubview(castCollectionView)
        
        setupActionButtons()
    }
    
    private func setupPlayButton() {
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.backgroundColor = UIColor.systemRed
        playButton.setTitle("▶ Oynat", for: .normal)
        playButton.setTitleColor(.white, for: .normal)
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        playButton.layer.cornerRadius = 25
        playButton.layer.shadowColor = UIColor.systemRed.cgColor
        playButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        playButton.layer.shadowRadius = 4
        playButton.layer.shadowOpacity = 0.3
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        contentView.addSubview(playButton)
    }
    
    private func setupRatingView() {
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        ratingView.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.1)
        ratingView.layer.cornerRadius = 8
        ratingView.layer.borderWidth = 1
        ratingView.layer.borderColor = UIColor.systemYellow.cgColor
        contentView.addSubview(ratingView)
        
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.image = UIImage(systemName: "star.fill")
        starImageView.tintColor = UIColor.systemYellow
        ratingView.addSubview(starImageView)
        
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        ratingLabel.textColor = UIColor.systemYellow
        ratingView.addSubview(ratingLabel)
    }
    
    private func setupActionButtons() {
        // Favorite Button
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = UIColor.systemRed
        favoriteButton.backgroundColor = UIColor.systemGray6
        favoriteButton.layer.cornerRadius = 25
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
        // Share Button
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = UIColor.systemBlue
        shareButton.backgroundColor = UIColor.systemGray6
        shareButton.layer.cornerRadius = 25
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        contentView.addSubview(shareButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            backdropImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backdropImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backdropImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backdropImageView.heightAnchor.constraint(equalToConstant: 250),
            
            posterImageView.topAnchor.constraint(equalTo: backdropImageView.bottomAnchor, constant: -80),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            posterImageView.widthAnchor.constraint(equalToConstant: 120),
            posterImageView.heightAnchor.constraint(equalToConstant: 180),
            
            playButton.centerYAnchor.constraint(equalTo: posterImageView.centerYAnchor),
            playButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            playButton.widthAnchor.constraint(equalToConstant: 120),
            playButton.heightAnchor.constraint(equalToConstant: 50),
            
            titleLabel.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            yearLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            ratingView.centerYAnchor.constraint(equalTo: yearLabel.centerYAnchor),
            ratingView.leadingAnchor.constraint(equalTo: yearLabel.trailingAnchor, constant: 12),
            ratingView.widthAnchor.constraint(equalToConstant: 60),
            ratingView.heightAnchor.constraint(equalToConstant: 30),
            
            starImageView.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            starImageView.leadingAnchor.constraint(equalTo: ratingView.leadingAnchor, constant: 8),
            starImageView.widthAnchor.constraint(equalToConstant: 16),
            starImageView.heightAnchor.constraint(equalToConstant: 16),
            
            ratingLabel.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 4),
            ratingLabel.trailingAnchor.constraint(equalTo: ratingView.trailingAnchor, constant: -4),
            
            favoriteButton.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: shareButton.leadingAnchor, constant: -12),
            favoriteButton.widthAnchor.constraint(equalToConstant: 50),
            favoriteButton.heightAnchor.constraint(equalToConstant: 50),
            
            shareButton.centerYAnchor.constraint(equalTo: ratingView.centerYAnchor),
            shareButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),
            
            genreLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 12),
            genreLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            durationLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 4),
            durationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            overviewTitleLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 24),
            overviewTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            overviewLabel.topAnchor.constraint(equalTo: overviewTitleLabel.bottomAnchor, constant: 8),
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            castTitleLabel.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 24),
            castTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            castCollectionView.topAnchor.constraint(equalTo: castTitleLabel.bottomAnchor, constant: 12),
            castCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            castCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            castCollectionView.heightAnchor.constraint(equalToConstant: 120),
            castCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        DispatchQueue.main.async {
            if let gradientLayer = self.backdropImageView.layer.sublayers?.first as? CAGradientLayer {
                gradientLayer.frame = self.backdropImageView.bounds
            }
        }
    }
    

    
    private func registerCollectionViewCells() {
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: "CastCell")
    }
    
    private func updateUI() {
        guard let movie = movie else { return }
        
        titleLabel.text = movie.title
        yearLabel.text = "2024" 
        ratingLabel.text = String(format: "%.1f", movie.voteAverage ?? 5.0)
        genreLabel.text = "Aksiyon, Dram, Romantik"
        durationLabel.text = "194 dakika"
        overviewLabel.text = movie.overview
        
    }
    
    @objc private func playButtonTapped() {
        presenter.didSelectPlayMovie(movie: movie)
        let alert = UIAlertController(title: "Film Oynatılıyor", message: "Film oynatma özelliği yakında eklenecek.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteButton.isSelected.toggle()
        let message = favoriteButton.isSelected ? "Favorilere eklendi" : "Favorilerden çıkarıldı"
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func shareButtonTapped() {
        guard let movie = movie else { return }
        
        let textToShare = "Bu filmi izle: \(movie.title)"
        let activityViewController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = shareButton
            popover.sourceRect = shareButton.bounds
        }
        
        present(activityViewController, animated: true)
    }
    
}

extension MovieDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.castCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CastCell", for: indexPath) as! CastCell
        if let castMember = presenter.getCastMember(at: indexPath.item) {
            cell.configure(castMember)
        }
        return cell
    }
}

extension MovieDetailViewController: MovieDetailViewControllerProtocol {
    func setupCollectionView() {
        
    }
    
    func reloadData() {
        print("reloadlandı")
        DispatchQueue.main.async {
            self.castCollectionView.reloadData()
        }
    }
    
    func hideLoadingView() {
        
    }
    
    func showLoadingView() {
        
    }
    
    func showError(_ error: String) {
        
    }
    
}
