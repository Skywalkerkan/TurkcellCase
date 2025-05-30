//
//  ViewController.swift
//  TurkcellCase
//
//  Created by Erkan on 26.05.2025.
//

import UIKit

protocol MovieListViewControllerProtocol: AnyObject {
    func setupCollectionView()
    func reloadData()
    func hideLoadingView()
    func showLoadingView()
    func showError(_ error: String)
}

final class MovieListViewController: BaseViewController {
    
    private let movieService: MovieServiceProtocol = TMDBService()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            let isTablet = UIDevice.current.userInterfaceIdiom == .pad
            
            let itemsPerRow: CGFloat = isTablet ? 4.0 : 3
            let itemHeight: CGFloat = isTablet ? 330 : 200
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / itemsPerRow),
                heightDimension: .absolute(itemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 16, trailing: 0)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(16)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    var presenter: MovieListPresenterProtocol!
    
    private var overlayDetailViewController: UIViewController?
    private var overlayLeadingConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        presenter.viewDidLoad()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    private func fetchMovies() async {
        let result = await movieService.fetchMovies(category: .upcoming, page: 1)
        
        switch result {
        case .success(let movieListResponse):
            print(" \(movieListResponse)")
            movieListResponse.results?.forEach { movie in
                print("🎬 \(movie.title ?? "title yok")")
            }
        case .failure(let error):
            print(" Hata: \(error.localizedDescription)")
        }
    }
}


extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getMovieCount(for: section) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movies = presenter.getMoviesForSection(indexPath.section)
        
        if indexPath.item == movies.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.identifier, for: indexPath) as? LoadingCell {
                cell.startLoading()
                return cell
            }
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        let movie = movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Film section\(indexPath.section), itemi \(indexPath.item)")
        let movies = presenter.getMoviesForSection(indexPath.section)
        let movie = movies[indexPath.item]
        print(movie.backdropPath)
        presenter.didSelectMovie(movie)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let movies = presenter.getMoviesForSection(indexPath.section)
        
        if indexPath.item == movies.count {
            presenter.loadMoreMoviesIfNeeded(for: indexPath.section)
        }
    }
    

    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.identifier,
                for: indexPath
              ) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let title = presenter.getSectionTitle(for: indexPath.section)
        header.configure(with: title)
        return header
    }
}


extension MovieListViewController: MovieListViewControllerProtocol {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.identifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func hideLoadingView() {
        
    }
    
    func showLoadingView() {
        
    }
    
    func showError(_ error: String) {
        
    }

    func showOverlayDetail(with movie: Movie) {
        if let detailVC = overlayDetailViewController as? MovieDetailViewController {
            detailVC.movie = movie
            return
        }

        let detailVC = MovieDetailRouter.createModule(with: movie)
        let detailNav = UINavigationController(rootViewController: detailVC)
        detailNav.view.translatesAutoresizingMaskIntoConstraints = false

        addChild(detailNav)
        view.addSubview(detailNav.view)
        detailNav.didMove(toParent: self)

        overlayDetailViewController = detailVC

        let close = UIBarButtonItem(title: "Kapat", style: .plain, target: self, action: #selector(closeOverlay))
        detailVC.navigationItem.leftBarButtonItem = close

        overlayLeadingConstraint = detailNav.view.leadingAnchor.constraint(equalTo: view.trailingAnchor)

        NSLayoutConstraint.activate([
            detailNav.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            overlayLeadingConstraint!,
            detailNav.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            detailNav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.layoutIfNeeded()

        overlayLeadingConstraint?.isActive = false
        overlayLeadingConstraint = detailNav.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: view.bounds.width * 0.55)
        overlayLeadingConstraint?.isActive = true

        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }


    @objc private func closeOverlay() {
        guard let detailNav = overlayDetailViewController?.navigationController else { return }

        overlayLeadingConstraint?.isActive = false
        overlayLeadingConstraint = detailNav.view.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        overlayLeadingConstraint?.isActive = true

        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            detailNav.willMove(toParent: nil)
            detailNav.view.removeFromSuperview()
            detailNav.removeFromParent()
            self.overlayDetailViewController = nil
            self.overlayLeadingConstraint = nil
        }
    }
}


