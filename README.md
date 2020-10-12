# Titanic Overview

## Author

* **Maik Müller** *Applied Computer Science (M. Sc.)* - [LinkedIn](https://www.linkedin.com/in/maik-m-253357107), [Xing](https://www.xing.com/profile/Maik_Mueller215/cv)

#### Background

<p align="justify">I finished my studies in <a href="https://ai-master.htw-berlin.de">Applied Computer Science</a> (B.Sc and M.Sc.) at the HTW University of Applied Science Berlin in January 2020. During my studies, I worked on several projects that contained app prototypes in the areas of public health and professional environments. All apps were written in Swift (I started with Swift 2.2 in 2016). The present project, Titanic, based on a simple app exercise during the swift course: B53.1 Current Applications in Computing: Swift Programming for iOS¹.

¹Course was renamed to ["B53.1 Current Applications in Computing: iOS Programming with Swift, UIKit and SwiftUI"](https://lsf.htw-berlin.de/qisserver/rds?state=verpublish&status=init&vmfile=no&publishid=164482&moduleCall=webInfo&publishConfFile=webInfo&publishSubDir=veranstaltung&expand=0&noDBAction=y&init=y)

## Table of Contents

* [1. About the App](#1-about-the-app)
  * [1.1. Goals](#11-goals)
  * [1.2. What's the game about?](#12.what's-the-game-about?)
  * [1.3. Game Features](#13.game-features)
  * [1.4. Technical Infos](#14-technical-infos)
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

### 1.1. Goals

<p align="justify">The main goal of the project was to gain knowledge about Swift and iOS development. In order to learn more while practicing and improve my skills, I've tested different technologies e.g. several package managers. So, I used Cocoa Pods, Homebrew, and Swift Package Manager to implement third-party libraries.</p>

There were three subgoals:

* Implementing the MVP pattern ([chapter 2.1](#21-mvp-design-pattern))
* Readable code and clear project structure
* Adapting layout for different screen and text sizes ([chapter 2.3.1](#231-adapting-layout))

### 1.2. What's the Game About?

<p align="justify">Users move a boat horizontally by their thumb to avoid collisions with icebergs, which are moving vertically from top to bottom. Any collision will increase the crash count, and slow down the boat. The game is over when the user reaches 5 crashes or the time is up. After the end of the game, the driven sea miles will be checked. If they are in the top ten, a highscore entry is provided. The game state can be controlled with the action button in the upper right corner. Image 1 shows a game scene.</p> <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Game.jpg" align="center" width="400">
    <p align="center">Image 1: Game Scene; Source: Own Illustration
  </p>
</figure>
<br />

### 1.3. Game Features

The following game features haven been implemented:

* Countdown timer
* Score counter
* Game control options
* Vertically movable ship
* Horizontally moving icebergs
* Highscore list

### 1.4. Technical Infos

The following list contains the most important technical informations about the app:

* Development Environment: Xcode
* Language: Swift
* Deployment Info: iOS 14.0, iPhone
* 3pp Libraries: [SRCountdownTimer](https://github.com/rsrbk/SRCountdownTimer), [SwiftLint](https://github.com/realm/SwiftLint), [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)
* Dependency Manager: [CocoaPods²](https://cocoapods.org), [Homebrew](https://brew.sh), [SwiftPackageManager](https://swift.org/package-manager/)

<p align="justify">²CocoaPods was used to implement SRCountdownTimer from Github during the first phase of development. Later it was replaced with a customized class of SRCountdownTimer.</p>

---

## 2. Concept and Implementation

### 2.1. MVP Design Pattern

<p align="justify">MVP stands for Model-View-Presenter. Graphic 1 shows the theoretical concept of MVP.  In comparison to the common MVC (Model-View-Controller) pattern, MVP offers an additional entity, the presenter. Furthermore, view and view controller form together the view entity. There are two different versions of MVP: Supervising Controller and Passive View. In Titanic, the Passive View was implemented, so all data synchronization between view and model is organized by the presenter. The view should only implement view logic. There is no direct data binding between view and model or view and presenter. The view sends intents via public API to the presenter, it calls the public API of the model and communicates back to the view via delegate methods. The presenter is like a portal for the view to see and get relevant view-formatted model data to update their UI. It’s to be mentioned that only the game scene uses the MVP pattern. All other Scenes use MVC.</p>

A big benefit of MVP is to avoid a massive view controller ([chapter 2.2](#22-avoid-massive-viewcontroller)) and create a reusable view.  <br /> <br />

<figure>
  <p align="center">
     <img src="/Titanic/Resources/Images/MVP.jpg" align="center" width="450">
     <p align="center">Graphic 1: MVP Design Pattern; Source: Own Illustration
  </p>
</figure>
<br />

### 2.2. Avoid Massive View Controller

<p align="justify">In MVC the view controller implements UI logic and communicates to the model. Depending on the complexity, it can end up in many functions and properties. This makes the view controller less readable, reusable, and gains complexity. In MVC the view is "general" and the view controller is "special". In MVP both (view and view controller) are "general" and seen as one part. The presenter is "special" and communicates to the model. So, you can get rid of all model related code in the view controller. In order to reduce complexity further, a few more steps were done:</p>

* <p align="justify">Game view is used as the main view and implements the adding and handling of subviews and their layout</p>
*  <p align="justify">Game view adds observers to each iceberg that sends notifications when an iceberg and ship intersect or if an iceberg reaches the vertical end of the screen</p>
* <p align="justify">Lightweight view presenters are used to navigating to other view controllers or presenting alerts including the call back handling</p>
* <p align="justify">Child view controllers are used to encapsulate reusable UI logic which handles UI improvements for the user, e.g. the animated preparation view</p>

Graphic 2 shows the theoretical concept of implementations in Titanic to avoid a massive game view controller.  <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/AvoidMassiveVC.jpg" align="center" width="450">
    <p align="center">Graphic 2: Avoid Massive Game View Controller; Source: Own Illustration
  </p>
</figure>
<br />

### 2.3. Layout

#### 2.3.1. Adapting Layout

<p align="justify">Different technologies were used to create layouts in Titanic: game view and game view controller programmatically and all others in a storyboard via interface builder. Autolayout was mostly used. The layout of the game view was challenging. On one hand, the score and countdown label should be related to the text size chosen in iPhone settings. On the other hand icebergs and ship sizes should be related to the screen size. According to the game logic, it doesn’t make sense to have a relation between text and the size of the objects.</p>

<p align="justify">That means that always three icebergs fit side by side on a screen. If the screen width grows, icebergs and ship will grow as well. In order to achieve the described behaviors, the following three points were made: </p>

* Autolayout and geometry were mixed
* Constraints and object coordinates were defined programmatically in game view
* Iceberg image was created by myself, ship image was created and designed by myself

<p align="justify">A second challenge was the SRCountdownTimer, which was imported from Github. Originally the circle and the time label were created without any constraints or any consideration of implementing the content size category. The result was, that the font size didn’t change when the text size was changed by the user. This was resolved by implementing constraints and setting the „adjustsFontForContentSize Category" property of the time label to true. Additionally, dark mode was implemented to improve the UI. Image 2 illustrates the implementation of dark mode and the content size category of the font. An extra layout feature is the localization of texts. Titanic supports English as the default language and German as an additional language.</p> <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Layout.jpg" align="center" width="450">
     <p align="center">Image 2: Dark mode and font size related to content size; Source: Own Illustration
  </p>
</figure>
<br />

#### 2.3.2. Animation

<p align="justify">The goal of animations is to improve the user experience. So, two scenes were chosen to implement animations: welcome and game scene. After starting the app, the welcome view controller shows up and animates an iceberg in the middle of the view. At first, the iceberg is scaled to the left and right edge of the view. Afterwards, the iceberg scales down and becomes transparent. The animation is called when the view did load or the iOS environment changes e.g. the font size. The following GIF shows the animated iceberg after starting the app.</p> <br /> <br />

<figure>
  <p align="center">
    <img src="/Titanic/Resources/Images/Iceberg.gif" align="center" width="200">
    <p align="center">GIF 1: Animated iceberg in Welcome Scene; Source: Own Illustration
  </p>
</figure>
<br />

<p align="justify">When the user taps on the start button, the game view controller gets called.
There are two other animations before the game is starting. At first, a preparation view with a countdown for the user comes up in order to get ready for the game. The change of the alpha value of the view is animated. Additionally, during the preparation countdown, the slider moves from one side to the other to find a random position.</p>

### 2.4. Persistence

<p align="justify">Titanic uses the <a href="https://developer.apple.com/documentation/foundation/filemanager">FileManager</a> to save a JSON formatted file in the application support directory. The file contains the top ten players with names and ordered by their driven sea miles.</p>

### 2.5. Testing

<p align="justify">The testing part doesn’t focus on every unit and every feature. Rather the purpose was to implement different types of test strategies:</p>

* Unit tests
* UI tests
* Snapshot tests
* Tests with mocked objects

<p align="justify">Additionally to the project included UI and unit tests, a third-party library (<a href="https://github.com/pointfreeco/swift-snapshot-testing">SnapshotTesting</a>) was installed and used to verify the UI of the game view. Snapshots were very useful while playing around with the programmatical initialization of the game view controller. Of course, unit tests are quicker and don't need as much resources as UI tests, but it was possible to test the responsivity of the UI without the need for manual tests. To test edge cases, manual tests were mainly used.</p>

<p align="justify">In order to avoid and detect a retained memory cycle, three general points were important besides taking care when self is captured in a closure or during property initialization:</p>

* Using structs before classes
* Print statements when a class is deinitialized
* Check for memory leaks with Xcode Instruments

### 2.6. Followup

<p align="justify">Currently watching the Stanford Course <a href="https://www.youtube.com/playlist?list=PLpGHT1n4-mAtTj9oywMWoBx0dCGd51_yG">Developing Applications for iOS using SwiftUI</a>. So, the next goal is to implement a SwiftUI view in Titanic.</p>

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


