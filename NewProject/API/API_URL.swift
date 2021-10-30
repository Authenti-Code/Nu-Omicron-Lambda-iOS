//
//  API_URL.swift
//  NewProject
//
//  Created by osx on 19/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import Foundation

enum API_URLS : String {
    //case BASE_URL = ""
    //3.219.184.206 https://ikl.apa1906.app/public/
    //case BASE_URL = "https://ikl.apa1906.app/public/api/"
    
    case BASE_URL = "https://nu-omicron-lambda.apa1906.app/public/api/"
    case BASE_URL_DOCUMENTS = "https://nu-omicron-lambda.apa1906.app/public/document/"
    case BASE_URL_IMAGES_EVENTS = "https://nu-omicron-lambda.apa1906.app/public/uploads/events/"
    case BASE_URL_IMAGES_NEWS = "https://nu-omicron-lambda.apa1906.app/public/uploads/news/"
    case BASE_URL_IMAGES_MESSAGE = "https://nu-omicron-lambda.apa1906.app/public/uploads/message/"
    case BASE_URL_IMAGES_GUEST_MESSAGE = "https://nu-omicron-lambda.apa1906.app/public/uploads/guest-message/"
    
    case BASE_URL_IMAGES_USER = "https://nu-omicron-lambda.apa1906.app/public/uploads/user/profile_image/"
    case BASE_URL_IMAGES = "https://nu-omicron-lambda.apa1906.app/public/"
    case BASE_URL_DIRECTORY = "https://nu-omicron-lambda.apa1906.app/public/uploads/directory/"
    case BASE_URL_GUEST_IMAGE = "https://nu-omicron-lambda.apa1906.app/public/uploads/guest-user/"
    case BASE_URL_MEDIA = "https://nu-omicron-lambda.apa1906.app/public/uploads/user/chat/media/"
    case BASE_URL_NEWS_PDF = "https://nu-omicron-lambda.apa1906.app/public/event-pdf/"
    
    case BASE_URL_SOCIAL_LINK = "https://nu-omicron-lambda.apa1906.app/public/uploads/social/"
    case BASE_URL_VIP_PARTNER = "https://apa1906.app/uploads/partner/"
    /// kil
}

enum API_ENDPOINTS : String {
    case CREATE_ACCOUNT = "register"
    case CREATE_GUEST_ACCOUNT = "register-guest"
    case CONFIRM_OTP = "comfirmOtp"
    case LOGIN = "login"
    case LOGOUT = "logout"
    case GET_PARTNER = "partner/list"
    case CHARGE_DONATION = "charge-donation"
    case GET_DIRECTORY = "getDirectories"
    case GET_PAYMENT_METHODS = "donations"
    case GET_PAYMENT_LINKS_METHODS = "donation-links"
    
    case GET_ALPHA_LINKS = "getAlphaLinks"
    case GET_DOCUMENT_CATEGORIES = "document/categories"
    case GET_DOCUMENTS = "documents"
    case GET_DOCUMENT_DETAIL = "document"
    case GET_EVENTS = "events"
    case GET_NEWS_DETAILS = "news"
    case GET_NEWS = "news/list"
    case GET_MESSAGE =  "message/list"
    case GET_MESSAGE_DETAILS = "message"
    case RESET_PASSWORD = "user/update/password"
    case UPDATE_USER = "user/update"
    case UPLOAD_CHAT_MEDIA = "user/chat/upload-media"
    case EVENT_ATTEND = "event/attend"
    case EVENT_ATTEND_LIST = "event/attendies"
    case EVENT_ATTENDED = "event/attended"
    case EVENT_DETAILS = "event"
    case FORGOT_PASSWORD = "forget-password"
    case GET_META = "getMeta"
    case GET_CHAT_LIST = "user/chat"
    case GET_CHAT_REPLY_LIST = "user/chat/reply"
    case GET_CONFIGURATION = "configuration"
    case GET_NOTIFICATION = "notify"
    case GET_SOCIAL = "social"
    case GET_USER_DETAILS = "user/get"
    case GET_USER_CHAT = "user/chat/receiver/reply"
    case GET_RECENT_CHAT = "user/chat/receiver/reply/list"
    case READ_REPLY = "user/chat/reply/read"
    case GET_GUEST_LINKS = "guest-users/list"
    case GET_GUEST_MESSAGE =  "guest-message/list"
    case GET_GUEST_MESSAGE_DETAILS = "guest-message"
    case CONTACT_STORE = "contact/store"
    case USER_CONTACT_STORE = "user-contact/store"
    
}
