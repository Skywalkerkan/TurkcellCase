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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )

        
        Task {
            await fetchMovies()
        }
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
        return 3
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Film section\(indexPath.section), itemi \(indexPath.item)")
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
        
        let title: String
        switch indexPath.section {
            case 0: title = "Top Rated"
            case 1: title = "Upcoming"
            case 2: title = "Now Playing"
        default: title = ""
        }
        
        header.configure(with: title)
        return header
    }

}


extension MovieListViewController: MovieListViewControllerProtocol {
    func setupCollectionView() {
        
    }
    
    func reloadData() {
        
    }
    
    func hideLoadingView() {
        
    }
    
    func showLoadingView() {
        
    }
    
    func showError(_ error: String) {
        
    }
    
    
}
