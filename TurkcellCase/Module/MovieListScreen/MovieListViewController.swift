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
            let itemHeight: CGFloat = isTablet ? 330 : 185
            
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
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    var presenter: MovieListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()

        presenter.viewDidLoad()

    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
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
            print("❌ Hata: \(error.localizedDescription)")
        }
    }
}


extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getMovieCount(for: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        let movies = presenter.getMoviesForSection(indexPath.section)
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
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
    }
    
    func reloadData() {
        print(presenter.getMovieCount(for: 0))
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
    
    
}
