//
//  AssemblyManager.swift
//  TurkcellCase
//
//  Created by Erkan on 1.06.2025.
//

import Swinject

final class AssemblyManager {
    
    static let shared = AssemblyManager()
    let assembler: Assembler
    
    private init() {
        assembler = Assembler([
            MovieListAssembly(),
            MovieDetailAssembly(),
            MoviePlayerAssembly()
        ])
    }
    
    var container: Container {
        return assembler.resolver as! Container
    }
}
