# 📰 News Client

A desktop news aggregator designed with a focus on speed, minimal system resource consumption, and absolute user privacy. The application allows users to comfortably read, filter, and save news articles to a local database without intrusive ads or forced cloud synchronization.

This project was developed as a coursework assignment for the "Cross-Platform Programming" course (NURE).

## ✨ Key Features

* **Real-time News Feed:** Asynchronous loading of up-to-date articles via a remote REST API (NewsAPI).
* **Built-in Browser (WebView):** Read original publications directly within the application window without invoking heavy external browsers.
* **Local Archive (SQLite):** Save metadata of selected articles into a private database with built-in protection against SQL injections. 
* **Smart Filtering & Search:** Instant local filtering by sources, date, and full-text search without triggering additional network requests.
* **Data Export:** Ability to export saved articles into a `.csv` format (UTF-8) for external use.
* **Adaptive UI/UX:** Seamless layout switching (vertical list or grid) and light/dark theme support with persistent settings.

## 🛠 Tech Stack

* **Backend (Application Logic):** C++, Qt 6 (Qt Core, Qt Network, Qt Sql)
* **Frontend (UI):** QML, Qt Quick, Qt WebView
* **Database:** SQLite
* **Architecture:** Model-View-Delegate (Qt's adaptation of MVC)

## 🚀 Getting Started

### Prerequisites:
* Installed **Qt 6** framework (ensure `QtWebView` and `QtQml` modules are included).
* A compiler supporting C++17 or higher.
* A developer API key from [NewsAPI](https://newsapi.org/).

## Contact

Author: Petro Luchaninov
Email: luchaninovp5@gmail.com

## Preview

<img width="1277" height="824" alt="image" src="https://github.com/user-attachments/assets/ebbc0500-cb30-4834-a05e-13b67bfcb95e" />
<img width="1274" height="825" alt="image" src="https://github.com/user-attachments/assets/e7c7b49e-1f60-4f40-be4c-33b06f663d93" />
