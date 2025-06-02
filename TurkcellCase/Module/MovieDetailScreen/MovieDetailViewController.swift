//
//  MovieDetailViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 28.05.2025.
//

import UIKit

protocol MovieDetailViewControllerProtocol: AnyObject {
    func updateMovieInfoUI(movie: Movie?)
    func reloadData()
    func setupCollectionView()
    func hideLoadingView()
    func showLoadingView()
    func showError(_ error: String)
}

class MovieDetailViewController: BaseViewController {
    
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
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
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


    private let overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Konu"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let castTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Actors"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
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
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemBlue
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //Burası tamamen tablet için oluşturuldu
    //Eğer sayfa yüklüyse yani tablette yandan detail sayfası açıldıysa overlay olarak MovieListViewControllerında başka celle basılması durumunda sayfanın güncellenmesinin sağlanması
    var movie: Movie? {
        didSet { guard isViewLoaded else { return };
            configureViews()
            presenter.fetchCredits(for: movie?.id ?? 0)
        }
    }
    
    var presenter: MovieDetailPresenterProtocol!
    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad(movie: movie)
        if let movieId = movie?.id {
            presenter.fetchCredits(for: movieId)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = backdropImageView.bounds
    }
    
    private func configureViews() {
        guard let movie = movie else { return }
        titleLabel.text = movie.title ?? "Unknown Title"

        if let releaseDate = movie.releaseDate, let year = releaseDate.split(separator: "-").first {
            yearLabel.text = String(year)
        } else {
            yearLabel.text = "Unknown Year"
        }

        if let rating = movie.voteAverage {
            print(rating)
            if rating == floor(rating) {
                ratingLabel.text = String(format: "%.0f", rating)
            } else {
                ratingLabel.text = String(format: "%.1f", rating)
            }
        } else {
            ratingLabel.text = "-"
        }


        if let genreIds = movie.genreIds {
            let genres = genreIds.compactMap { genreName(for: $0) }
            genreLabel.text = genres.joined(separator: " • ")
        } else {
            genreLabel.text = "There is no info about type"
        }

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
            28: "Action",
            12: "Adventure",
            16: "Animation",
            35: "Comedy",
            80: "Crime",
            99: "Documentary",
            18: "Drama",
            10751: "Family",
            14: "Fantasy",
            36: "History",
            27: "Horror",
            10402: "Music",
            9648: "Mystery",
            10749: "Romance",
            878: "Science Fiction",
            10770: "TV Movie",
            53: "Thriller",
            10752: "War",
            37: "Western"
        ]
        return genres[id]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupUI() {
        view.backgroundColor = UIColor.black
        view.addSubview(scrollView)
        navigationItem.backButtonDisplayMode = .minimal        
        navigationController?.navigationBar.tintColor = .white
        scrollView.addSubview(contentView)
        contentView.addSubview(backdropImageView)
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.cgColor
        ]
        gradientLayer.locations = [0.0, 0.7, 1.0]
        backdropImageView.layer.addSublayer(gradientLayer)
        contentView.addSubview(posterImageView)
        
        setupPlayButton()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(yearLabel)
        
        setupRatingView()

        contentView.addSubview(genreLabel)
        contentView.addSubview(overviewTitleLabel)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(castTitleLabel)
        contentView.addSubview(castCollectionView)
        
        setupActionButtons()
        setupConstraints()
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
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = UIColor.systemRed
        favoriteButton.backgroundColor = UIColor.systemGray6
        favoriteButton.layer.cornerRadius = 25
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        contentView.addSubview(favoriteButton)
        
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
            
            yearLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
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
            

            
            overviewTitleLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor, constant: 24),
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
    
    @objc private func playButtonTapped() {
        presenter.didSelectPlayMovie(movie: movie)
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteButton.isSelected.toggle()
        let message = favoriteButton.isSelected ? "Added to favorites" : "Removed from favorites"
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func shareButtonTapped() {
        guard let movie = movie else { return }
        
        let textToShare = "Watch This Movie: \(String(describing: movie.title))"
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
    
    func updateMovieInfoUI(movie: Movie?) {
        configureViews()
    }
    
    func setupCollectionView() {
        castCollectionView.delegate = self
        castCollectionView.dataSource = self
        castCollectionView.register(CastCell.self, forCellWithReuseIdentifier: "CastCell")
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.castCollectionView.reloadData()
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            self.hideLoading()
        }
    }
    
    func showLoadingView() {
        DispatchQueue.main.async {
            self.showLoading()
        }
    }
    
    func showError(_ error: String) {
        DispatchQueue.main.async {
            self.showAlert(with: "Alert", message: error)
        }
    }
    
}
