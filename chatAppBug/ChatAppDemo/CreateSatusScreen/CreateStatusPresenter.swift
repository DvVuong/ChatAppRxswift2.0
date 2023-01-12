//
//  CreateStatusPresenter.swift
//  ChatAppDemo
//
//  Created by BeeTech on 28/12/2022.
//

import Foundation

protocol CreateStatusPresenterViewDelegate: NSObject {
    
}

class CreateStatusPresenter {
    private weak var view: CreateStatusPresenterViewDelegate?
    private var user: User?
    
    init(with view: CreateStatusPresenterViewDelegate, user: User? ) {
        self.view = view
        self.user = user
    }
   
}
