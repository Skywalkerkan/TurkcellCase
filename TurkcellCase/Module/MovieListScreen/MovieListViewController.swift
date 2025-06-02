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
            
            let itemWidth: CGFloat = isTablet ? 230 : 130
            let itemHeight: CGFloat = isTablet ? 350 : 190
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(itemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .estimated(itemWidth),
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

    //Bonus tablet için gerekli olan swinject factorysi
    var detailViewFactory: ((Movie) -> MovieDetailViewController?)?

    //Tablet için gerekli atamalar
    private var overlayDetailViewController: UIViewController?
    private var overlayLeadingConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        //presenterla bağlantının sağlanması
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Buraya girerken kısıtlamayı portrait yap
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restrictRotation = .portrait
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //Buradan çıkarken kısıtlamayı kaldırma yeri
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.restrictRotation = .all
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        // tablet için ekran yataya geçerkenki constraitin ayarlanması
        guard let overlay = overlayLeadingConstraint else { return }
        coordinator.animate(alongsideTransition: { _ in
            overlay.constant = size.width * 0.55
            self.view.layoutIfNeeded()
        })
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
    
}


extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.sectionCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //+1 burada collectionViewin sonuna loading cell eklenmesi
        return presenter.getMovieCount(for: section) + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movies = presenter.getMoviesForSection(indexPath.section)
        //2 tane cell türü var birisi sondaki loading cell yükleme esnasında listenin sonunda gözüküyor
        if indexPath.item == movies.count {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.identifier, for: indexPath) as? LoadingCell {
                cell.startLoading()
                return cell
            }
        }
        //Birisi bizim normal movie cellimiz
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as? MovieCell else {
            return UICollectionViewCell()
        }
        let movie = movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Loading Celle basılmaması için indexpathin kontrol edilmesi
        guard indexPath.item < presenter.getMovieCount(for: indexPath.section) else { return }
        let movies = presenter.getMoviesForSection(indexPath.section)
        let movie = movies[indexPath.item]
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
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.identifier)
        collectionView.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.identifier
        )
    }
    
    func reloadData() {
        //Movilerin gelmesi halinde ekranın güncellenmesi
        DispatchQueue.main.async {
            self.collectionView.reloadData()
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

    //Bonus Tablet ekranı için gerekli yerin sağlandığı yer
    //Viewcontrollerda bir cell seçilince presenterla router navigateden direk bağlantı sağlayıp buradan direk yandan sayfa açılmasını sağlayan bir protocol
    func showOverlayDetail(with movie: Movie) {
        if let detailVC = overlayDetailViewController as? MovieDetailViewController {
            detailVC.movie = movie
            return
        }
        
        guard let detailVC = detailViewFactory?(movie) else {
            assertionFailure("MovieDetailViewController resolve edilmedi")
            return
        }
        
        let detailNav = UINavigationController(rootViewController: detailVC)
        detailNav.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(detailNav)
        view.addSubview(detailNav.view)
        detailNav.didMove(toParent: self)
        overlayDetailViewController = detailVC
        
        detailVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward")?
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.white),
            style: .plain,
            target: self,
            action: #selector(closeOverlay)
        )
        
        overlayLeadingConstraint = detailNav.view.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            detailNav.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            overlayLeadingConstraint!,
            detailNav.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.45),
            detailNav.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.layoutIfNeeded()
        
        overlayLeadingConstraint?.isActive = false
        overlayLeadingConstraint = detailNav.view.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: view.bounds.width * 0.55
        )
        overlayLeadingConstraint?.isActive = true
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
    }

    //Tabletiçin detay ekranının kapandığı yer
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


