//
//  MemeManager.swift
//  MemeMeV1
//
//  Created by Steven O'Toole on 3/20/15.
//  Copyright (c) 2015 Steven O'Toole. All rights reserved.
//

import Foundation


class MemeManager {


    var memeList = [Meme]()



    init() {
        let m1 = ["memetop1", "memetop2", "memetop3", "memetop4"]
        let m2 = ["memebot1", "memebot2", "memebot3", "memebot4"]
        for (i, m) in enumerate(m1) {
            let ms = Meme(top: m, bottom: m2[i])
            memeList.append(ms)
        }
    }


    func numberOfMemes() -> Int { return memeList.count }

    func memeAtIndex(row: Int) -> Meme { return memeList[row] }

    func appendMeme(meme: Meme) { memeList.append(meme) }
    func removeMemeAtIndex(row: Int) { memeList.removeAtIndex(row) }

}