//
//  APIConstants.swift
//  Flickrsight
//
//  Created by Glen Yi on 2015-11-07.
//  Copyright © 2015 On The Pursuit Inc. All rights reserved.
//


// MARK: Authentication

let FlickrAPIKey = "1ca511884538073ab81225b018981457"
let FlickrAPISecret = "cfb9f3bf61bdb176"


// MARK: Paths

let FlickrAPIBaseURL = "https://api.flickr.com/services/rest"


// MARK: HTTP Methods

let HTTPMethodGet = "GET"


// MARK: Methods

let FlickrAPIMethodSearch = "flickr.photos.search"


// MARK: Params

let FlickrAPIParamApiKey = "api_key"
let FlickrAPIParamFormat = "format"
let FlickrAPIParamNoCallback = "nojsoncallback"
let FlickrAPIParamMethod = "method"
let FlickrAPIParamText = "text"
let FlickrAPIParamTags = "tags"
let FlickrAPIParamPerPage = "per_page"
let FlickrAPIParamSort = "sort"


// MARK: Data Keys

let FlickrAPIDataKeyPhotos = "photos"
let FlickrAPIDataKeyPhoto = "photo"


// MARK: Sort Params

enum FlickrAPISortParam: String {
    case DatePostedAsc = "date-posted-asc"
    case DatePostedDesc = "date-posted-desc"
    case DateTakenAsc = "date-taken-asc"
    case DateTakenDesc = "date-taken-desc"
    case InterestingnessAsc = "interestingness-asc"
    case InterestingnessDesc = "interestingness-desc"
    case Relevance = "relevance"
}


