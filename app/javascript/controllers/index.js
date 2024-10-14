// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

// import HelloController from "./hello_controller"
// application.register("hello", HelloController)

// import MobileNavController from "./mobile_nav_controller"
// application.register("mobileNav", MobileNavController)

import MobileMenuController from "./mobile_menu_controller"
application.register("mobileMenu", MobileMenuController)

import MobileMarkAsReadController from "./mobile_mark_as_read_controller"
application.register("mobileMarkAsRead", MobileMarkAsReadController)

import DesktopMarkAsReadController from "./desktop_mark_as_read_controller"
application.register("desktopMarkAsRead", DesktopMarkAsReadController)

import SearchController from "./search_controller"
application.register("search", SearchController)

import ScrollerController from "./scroller_controller"
application.register("scroller", ScrollerController)

import AlertsController from "./alerts_controller"
application.register("alerts", AlertsController)

import NotificationsController from "./notifications_controller"
application.register("notifications", NotificationsController)

import BookmarksController from "./bookmarks_controller"
application.register("bookmarks", BookmarksController)

import SendToDownloaderController from "./send_to_downloader_controller"
application.register("sendToDownloader", SendToDownloaderController)

