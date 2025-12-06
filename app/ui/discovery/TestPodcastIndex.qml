// TestPodcastIndex.qml
// Test page to verify Podcast Index API integration

import QtQuick 2.9
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItem
import PodcastIndex 1.0

Page {
    id: testPage
    
    header: PageHeader {
        title: i18n.tr("Discover Podcasts")
    }
    
    PodcastIndexAPI {
        id: api
        
        onSearchResultsReceived: {
            console.log("Search results received:", feeds.length, 
"podcasts")
            searchResultsModel.clear()
            for (var i = 0; i < feeds.length; i++) {
                var feed = feeds[i]
                searchResultsModel.append({
                    title: feed.title,
                    author: feed.author || "Unknown",
                    description: feed.description || "",
                    artwork: feed.artwork || feed.image || "",
                    feedUrl: feed.url
                })
            }
            statusLabel.text = "Found " + feeds.length + " podcasts"
        }
        
        onTrendingReceived: {
            console.log("Trending received:", feeds.length, "podcasts")
            trendingModel.clear()
            for (var i = 0; i < feeds.length; i++) {
                var feed = feeds[i]
                trendingModel.append({
                    title: feed.title,
                    author: feed.author || "Unknown",
                    trendScore: feed.trendScore || 0
                })
            }
            statusLabel.text = "Loaded " + feeds.length + " trending 
podcasts"
        }
        
        onErrorOccurred: {
            console.log("API Error:", errorMessage, errorType)
            statusLabel.text = "Error: " + errorMessage
        }
        
        Component.onCompleted: {
            if (isConfigured) {
                statusLabel.text = "API Ready"
            } else {
                statusLabel.text = "Please configure API credentials in 
Settings"
            }
        }
    }
    
    ListModel { id: searchResultsModel }
    ListModel { id: trendingModel }
    
    Flickable {
        anchors {
            fill: parent
            topMargin: testPage.header.height
        }
        contentHeight: contentColumn.height + units.gu(4)
        
        Column {
            id: contentColumn
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: units.gu(2)
            }
            spacing: units.gu(2)
            
            Rectangle {
                width: parent.width
                height: units.gu(6)
                color: api.isConfigured ? UbuntuColors.green : 
UbuntuColors.red
                opacity: 0.2
                radius: units.gu(1)
                
                Label {
                    anchors.centerIn: parent
                    text: api.isConfigured ? i18n.tr("✓ API Configured") 
: i18n.tr("⚠ Not Configured")
                    fontSize: "medium"
                }
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                
                Label {
                    text: i18n.tr("Search Podcasts")
                    fontSize: "large"
                    font.bold: true
                }
                
                Row {
                    width: parent.width
                    spacing: units.gu(1)
                    
                    TextField {
                        id: searchField
                        width: parent.width - searchButton.width - 
units.gu(1)
                        placeholderText: i18n.tr("Enter search term...")
                        text: "technology"
                        
                        onAccepted: searchButton.clicked()
                    }
                    
                    Button {
                        id: searchButton
                        text: i18n.tr("Search")
                        color: UbuntuColors.blue
                        enabled: api.isConfigured && 
searchField.text.length > 0
                        
                        onClicked: {
                            statusLabel.text = "Searching..."
                            api.searchPodcasts(searchField.text, 10)
                        }
                    }
                }
            }
            
            Row {
                width: parent.width
                spacing: units.gu(1)
                
                Button {
                    text: i18n.tr("Get Trending")
                    color: UbuntuColors.orange
                    enabled: api.isConfigured
                    
                    onClicked: {
                        statusLabel.text = "Loading trending..."
                        api.getTrending(10)
                    }
                }
                
                Button {
                    text: i18n.tr("Recent Episodes")
                    color: UbuntuColors.purple
                    enabled: api.isConfigured
                    
                    onClicked: {
                        statusLabel.text = "Loading recent episodes..."
                        api.getRecentEpisodes(10)
                    }
                }
            }
            
            Label {
                id: statusLabel
                width: parent.width
                wrapMode: Text.WordWrap
                text: "Ready"
                color: UbuntuColors.darkGrey
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                visible: searchResultsModel.count > 0
                
                Label {
                    text: i18n.tr("Search Results")
                    fontSize: "large"
                    font.bold: true
                }
                
                ListView {
                    width: parent.width
                    height: units.gu(40)
                    clip: true
                    model: searchResultsModel
                    
                    delegate: ListItem.Standard {
                        width: parent.width
                        height: units.gu(10)
                        
                        Row {
                            anchors {
                                fill: parent
                                margins: units.gu(1)
                            }
                            spacing: units.gu(1)
                            
                            Image {
                                width: units.gu(8)
                                height: units.gu(8)
                                source: model.artwork
                                fillMode: Image.PreserveAspectCrop
                                
                                Rectangle {
                                    anchors.fill: parent
                                    color: UbuntuColors.slate
                                    visible: parent.status !== Image.Ready
                                    
                                    Label {
                                        anchors.centerIn: parent
                                        text: "📻"
                                        fontSize: "large"
                                    }
                                }
                            }
                            
                            Column {
                                width: parent.width - units.gu(9)
                                spacing: units.gu(0.5)
                                
                                Label {
                                    width: parent.width
                                    text: model.title
                                    fontSize: "medium"
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                
                                Label {
                                    width: parent.width
                                    text: model.author
                                    fontSize: "small"
                                    color: UbuntuColors.darkGrey
                                    elide: Text.ElideRight
                                }
                                
                                Label {
                                    width: parent.width
                                    text: model.description
                                    fontSize: "x-small"
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                }
                            }
                        }
                        
                        onClicked: {
                            console.log("Clicked:", model.title, "Feed 
URL:", model.feedUrl)
                        }
                    }
                }
            }
        }
    }
}
