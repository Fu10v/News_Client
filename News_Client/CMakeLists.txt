cmake_minimum_required(VERSION 3.16)

project(News_Client VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Network Sql WebView WebViewQuick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appNews_Client
    main.cpp
)

qt_add_qml_module(appNews_Client
    URI News_Client
    QML_FILES
        Main.qml
        QML_FILES NewsCard.qml
        QML_FILES FullArticleView.qml
        SOURCES networkmanager.h networkmanager.cpp
        SOURCES newsmodel.h newsmodel.cpp
        SOURCES databasemanager.h databasemanager.cpp
        SOURCES settingsmanager.h settingsmanager.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appNews_Client PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appNews_Client
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appNews_Client
    PRIVATE Qt6::Core Qt6::Gui Qt6::Qml Qt6::Quick Qt6::QuickControls2 Qt6::Network Qt6::Sql Qt6::WebView Qt6::WebViewQuick
)

include(GNUInstallDirs)
install(TARGETS appNews_Client
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
