//
//  MemoDate.swift
//  KVOandDate
//
//  Created by 今橋浩樹 on 2022/06/06.
//

import Foundation
import RealmSwift

class MemoDate :Object {
    @Persisted var pageName = ""
    @Persisted var URL = ""
    @Persisted var watchDate = ""
}
