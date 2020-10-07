# Titanic Overview

## Author

* **Maik Müller** *Applied Computer Science (M. Sc.)* - [LinkedIn](https://www.linkedin.com/in/maik-m-253357107), [Xing](https://www.xing.com/profile/Maik_Mueller215/cv)


## Table of Contents

* [1. About the App](#1-about-the-app)
  * [1.1. Background](#11-introduction)
  * [1.2. Goals](#12-goals)
  * [1.3. What's the game about?](#13.what's-the-game-about?)
  * [1.4. Game Features](#14.game-features)
  * [1.5. Technical Infos](#15-technical-infos)
* [2. Concept and Implementation](#2-concept-and-implmentation)
  * [2.1. MVP Design Pattern](#21-mvp-design-pattern)
  * [2.2. Avoid Massive ViewController](#22-avoid-massive-viewcontroller)
  * [2.3. Layout](#23-layout)
    * [2.3.1. Adapting Layout](#231-adapting-layout)
    * [2.3.2. Animation](#232-animation)
  * [2.4. Persistence](#24-persistence)
  * [2.5. Testing](#25-testing)
  * [2.6 Follow Up](#26-follow-up)

## 1. About the App

### 1.1. Background

Titanic is a simple game where the development started in Spring 2020 after I finished my studies in Applied Computer Science at the HTW University of Applied Science Berlin. During my studies, I worked on several projects that contained app prototypes in the areas of public health and professional environments. All apps were written in Swift (I started with Swift 2.2 in 2016) and I used the MVC Pattern. The idea of Titanic is based on a simple app exercise during a swift course.

### 1.2. Goals

The main goal of the project was to gain knowledge about Swift and iOS development. In order to learn more while practicing and improve my skills, I've tested different technologies e.g. several package managers. So, I used Cocoa Pods, Homebrew, and Swift Package Manager to implement third-party libraries.

There were three subgoals:

* implementing the MVP pattern ([chapter 2.1](#21-mvp-design-pattern))
* readable code and clear project structure
* adapting layout for different screen and text sizes ([chapter 2.3.1](#231-adapting-layout))

### 1.3. What's the game about?

Users move a ship horizontally by their thumb to avoid intersections with icebergs, which are moving vertically from top to bottom. If the time is up or the maximum crashes are reached, the game is over. Immediately after the game finished, driven sea miles will be verified. If the user is in the top ten, an alert with a text field shows up in order to enter the name of the user. Image 1 shows a game scene. <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Game.jpg" align="center" width="400">
    <p align="center">Image 1: Game Scene
  </p>
</figure>

### 1.4. Game Features

* countdown timer
* score counter
* game control options
* moving ship to avoid intersections with icebergs
* high score list

### 1.5. Technical Infos

* Development Environment: Xcode
* Language: Swift
* Deployment Info: iOS 14.0, iPhone
* 3pp Libraries: [SRCountdownTimer](https://github.com/rsrbk/SRCountdownTimer), [SwiftLint](https://github.com/realm/SwiftLint), [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)
* Dependency Manager: [CocoaPods¹](https://cocoapods.org), [Homebrew](https://brew.sh), [SwiftPackageManager](https://swift.org/package-manager/)

¹CocoaPods was used to implement SRCountdownTimer from Github during the first phase of development. Later it was replaced with a customized class of SRCountdownTimer.

---

## 2. Concept and Implementation

### 2.1. MVP Design Pattern

MVP stands for Model-View-Presenter. Graphic 1 shows the theoretical concept of MVP.  In comparison to the common MVC (Model-View-Controller) pattern, MVP offers an additional entity, the Presenter. Furthermore View and ViewController form together the View entity. There are two different versions of MVP: Supervising Controller and Passive View. In Titanic, the Passive View was implemented, so all data synchronization between View and Model is organized by the Presenter. The view is "dumb" as possible. There is no direct data binding between View and Model or View and Presenter. The View sends Intents via public API to the Presenter, it calls the public API of the Model and communicates back to the view via delegate methods. The Presenter is like a portal for the View to see and get relevant view-formatted Model data to update their UI. It can be seen as a front door with a glass hole in the middle. It’s to be mentioned that only the Game Scene uses the MVP pattern. All other Scenes use MVC.

A big benefit of MVP is to avoid a massive ViewController ([chapter 2.2](#22-avoid-massive-viewcontroller)) and create a reusable View and ViewController.  <br /> <br />

<figure>
  <p align="center">
     <img src="/Titanic/Resources/Images/MVP.jpg" align="center" width="450">
     <p align="center">Graphic 1: MVP Design Pattern
  </p>
</figure>

### 2.2. Avoid Massive ViewController

In MVC the ViewController implements UI logic and communicates to the model. Depending on the complexity, it can end up in many functions and properties. This makes the ViewController less readable, reusable, and gains complexity. In MVC the View is "general" and the ViewController is "special". In MVP both (View and ViewController) are "general" and seen as one part. The presenter is "special" and communicates to the model. So, you can get rid of all model related code in the ViewController. In order to reduce complexity further, a few more steps were done:

* GameView itself is used as the main view and implements the adding and handling of subviews and their layout
* GameView adds observers to each iceberg that sends notifications when an iceberg and ship intersect or if an iceberg reaches the vertical end of the screen
* Lightweight view presenters are used to navigating to other view controllers or presenting alerts including the call back handling
* ChildViewController is used to encapsulate reusable UI logic which handles UI improvements for the user, for example the animated preparation view

Graphic 2 shows the theoretical concept of implementations in Titanic to avoid a massive GameViewController.  <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/AvoidMassiveVC.jpg" align="center" width="450">
    <p align="center">Graphic 2: Avoid Massive ViewController
  </p>
</figure>

### 2.3. Layout

#### 2.3.1. Adapting Layout

Different technologies were used to create layouts in Titanic: GameView and Game ViewController programmatically and all others in a storyboard via interface builder. Autolayout was mostly used. The layout of the GameView was challenging. On one hand, the score and countdown label should be related to the text size chosen in iPhone settings. On the other hand icebergs and ship sizes should be related to the screen size. According to the game logic, it doesn’t make sense to have a relation between text and the size of the objects.

That means that always three icebergs fit side by side on a screen. If the screen width grows, icebergs and ship will grow as well. In order to achieve the described behaviors the following three points were made:

* Autolayout and geometry were mixed
* constraints and object coordinates were defined programmatically in GameView
* iceberg image was created by myself, ship image was created and designed by myself

A second challenge was the SRCountdownTimer, which was imported from Github. Originally the circle and the time label were created without any constraints or any consideration of implementing the content size category. The result was that the font size didn’t change when the text size was changed by the user. This was resolved by implementing constraints and setting the „adjustsFontForContentSize Category" property of the time label to true. Additionally, dark mode was implemented to improve the UI. Image 2 illustrates the implementation of dark mode and the content size category of the font. An extra layout feature is the localization of texts. Titanic supports English as the default language and German as an additional language. <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Layout.jpg" align="center" width="450">
     <p align="center">Image 2: Dark mode and font size related to content size category
  </p>
</figure>
<br />

#### 2.3.2. Animation

The goal of animations is to improve the user experience. So, two scenes were chosen to implement animations: welcome and game scene. After starting the app, the WelcomeViewController shows up and animates an iceberg in the middle of the view. At first, the iceberg is scaled to the left and right edge of the view. Afterwards the iceberg scales down and becomes transparent. The animation is called when the view did load or the iOS environment changes e.g. the font size. The following GIF shows the animated iceberg after starting the app. <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Iceberg.gif" align="center" width="200">
    <p align="center">GIF 1: Animated iceberg in Welcome Scene
  </p>
</figure>
<br />

When the user taps on the start button, the GameViewController gets called.
There are two other animations before the game is starting. At first, a preparation view with a countdown for the user comes up in order to get ready for the game. The change of the alpha value of the view is animated. Additionally, during the preparation countdown, the slider moves from one side to the other to find a random position.

### 2.4. Persistence

Titanic uses the default FileManager to save a JSON formatted file in the Application Support Directory. The file contains the top ten players with names and ordered by their driven sea miles.

### 2.5. Testing

The testing part doesn’t focus on every unit and every feature. Rather the purpose was to implement different types of test strategies:

* UnitTesting
* UI-Testing
* SnapshotTesting
* testing with mocked objects

Additionally to the pre-installed UI- and Unit tests possibilities, a third-party library, SnapshotTesting, was installed and used to verify the UI of the Game View. Snapshots were very useful while playing around with the programmatical initialization of the Game ViewController. Of course, unit tests are quicker and don't need as much resources as UI tests, but it was possible to test the responsivity of the UI without the need for manual tests. To test edge cases, manual tests were mainly used.

In order to avoid and detect a retained memory cycle, three general points were important besides taking care when self is captured in a closure or during property initialization:

* using structs before classes
* print statements when class is deinitialized
* check for memory leaks with Xcode Instruments

### 2.6. Followup

Currently watching the Stanford Course „Developing Applications for iOS using SwiftUI". The next goal is to implement a SwiftUI View in Titanic.

---

#### Main Sources

##### Documentations, Blogs and Tutorial Providers

* [App Coda](https://www.appcoda.com)
* [Apple Developer Documentation](https://developer.apple.com/documentation/technologies)
* [Hacking With Swift](https://www.hackingwithswift.com)
* [Learn App Making](https://learnappmaking.com)
* [Medium](https://medium.com)
* [NSHipster](https://nshipster.com)
* [Ray Wenderlich](https://www.raywenderlich.com)
* [Swift](https://swift.org)
* [Swift Book](https://docs.swift.org/swift-book/index.html)
* [Swift by Sundell](https://www.swiftbysundell.com)
* [Swift Lee](https://www.avanderlee.com)
* [Swift Standard Library](https://developer.apple.com/documentation/swift/swift_standard_library)

##### Podcasts and Videos

* [Stanford, CS193p, Developing Applications for iOS using SwiftUI](https://www.youtube.com/playlist?list=PLpGHT1n4-mAtTj9oywMWoBx0dCGd51_yG)
* [Stanford, CS193p, Developing iOS11 Apps with Swift](https://podcasts.apple.com/de/podcast/developing-ios-11-apps-with-swift/id1315130780?l=en)
* [Hallo Swift](https://podcasts.apple.com/de/podcast/hallo-swift/id1225721421?l=en)
