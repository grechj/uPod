// PodcastIndexSettings.qml
// Settings page for configuring Podcast Index API credentials

import QtQuick 2.9
import Ubuntu.Components 1.3
import PodcastIndex 1.0

Page {
    id: podcastIndexSettingsPage
    
    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Podcast Index Settings")
        
        trailingActionBar.actions: [
            Action {
                iconName: "help"
                text: i18n.tr("Get API Key")
                onTriggered: 
Qt.openUrlExternally("https://api.podcastindex.org/signup")
            }
        ]
    }
    
    PodcastIndexAPI {
        id: podcastIndexApi
        
        onConnectionTestResult: {
            testButton.enabled = true
            if (success) {
                testResultLabel.text = message
                testResultLabel.color = UbuntuColors.green
            } else {
                testResultLabel.text = message
                testResultLabel.color = UbuntuColors.red
            }
        }
        
        onErrorOccurred: {
            console.log("Error:", errorMessage, errorType)
        }
    }
    
    Flickable {
        anchors {
            fill: parent
            topMargin: pageHeader.height
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
            
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                text: i18n.tr("Podcast Index provides podcast discovery, 
trending podcasts, and search capabilities. Get your free API key at 
api.podcastindex.org")
                fontSize: "small"
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                
                Label {
                    text: i18n.tr("API Key")
                    fontSize: "medium"
                }
                
                TextField {
                    id: apiKeyField
                    width: parent.width
                    placeholderText: i18n.tr("Enter your API key")
                    text: podcastIndexApi.apiKey
                    inputMethodHints: Qt.ImhNoPredictiveText
                    
                    onTextChanged: {
                        testResultLabel.text = ""
                    }
                }
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                
                Label {
                    text: i18n.tr("API Secret")
                    fontSize: "medium"
                }
                
                TextField {
                    id: apiSecretField
                    width: parent.width
                    placeholderText: i18n.tr("Enter your API secret")
                    text: podcastIndexApi.apiSecret
                    echoMode: showSecretCheckbox.checked ? 
TextInput.Normal : TextInput.Password
                    inputMethodHints: Qt.ImhNoPredictiveText
                    
                    onTextChanged: {
                        testResultLabel.text = ""
                    }
                }
                
                CheckBox {
                    id: showSecretCheckbox
                    text: i18n.tr("Show secret")
                }
            }
            
            Row {
                width: parent.width
                spacing: units.gu(2)
                
                Button {
                    id: testButton
                    text: i18n.tr("Test Connection")
                    color: UbuntuColors.blue
                    
                    onClicked: {
                        testResultLabel.text = i18n.tr("Testing 
connection...")
                        testResultLabel.color = UbuntuColors.darkGrey
                        testButton.enabled = false
                        
                        podcastIndexApi.apiKey = apiKeyField.text
                        podcastIndexApi.apiSecret = apiSecretField.text
                        podcastIndexApi.testConnection()
                    }
                }
                
                Button {
                    text: i18n.tr("Save")
                    color: UbuntuColors.green
                    enabled: apiKeyField.text.length > 0 && 
apiSecretField.text.length > 0
                    
                    onClicked: {
                        podcastIndexApi.apiKey = apiKeyField.text
                        podcastIndexApi.apiSecret = apiSecretField.text
                        podcastIndexApi.saveConfiguration()
                        
                        testResultLabel.text = i18n.tr("Settings saved!")
                        testResultLabel.color = UbuntuColors.green
                    }
                }
                
                Button {
                    text: i18n.tr("Clear")
                    color: UbuntuColors.red
                    
                    onClicked: {
                        apiKeyField.text = ""
                        apiSecretField.text = ""
                        testResultLabel.text = ""
                        podcastIndexApi.clearConfiguration()
                    }
                }
            }
            
            Label {
                id: testResultLabel
                width: parent.width
                wrapMode: Text.WordWrap
                fontSize: "small"
            }
            
            Row {
                width: parent.width
                spacing: units.gu(1)
                visible: podcastIndexApi.isConfigured
                
                Icon {
                    name: "tick"
                    width: units.gu(2)
                    height: units.gu(2)
                    color: UbuntuColors.green
                }
                
                Label {
                    text: i18n.tr("API Configured")
                    color: UbuntuColors.green
                    fontSize: "small"
                }
            }
            
            Rectangle {
                width: parent.width
                height: units.dp(1)
                color: UbuntuColors.silk
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                
                Label {
                    text: i18n.tr("How to get your API key:")
                    fontSize: "medium"
                    font.bold: true
                }
                
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    text: i18n.tr("1. Visit 
api.podcastindex.org/signup\n2. Create a free account\n3. Copy your API 
Key and Secret\n4. Paste them above and save")
                    fontSize: "small"
                }
            }
            
            Column {
                width: parent.width
                spacing: units.gu(1)
                
                Label {
                    text: i18n.tr("What you'll get:")
                    fontSize: "medium"
                    font.bold: true
                }
                
                Repeater {
                    model: [
                        i18n.tr("• Search millions of podcasts"),
                        i18n.tr("• Discover trending podcasts"),
                        i18n.tr("• Browse by categories"),
                        i18n.tr("• Get personalized recommendations"),
                        i18n.tr("• Find recent episodes across all 
podcasts")
                    ]
                    
                    Label {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: modelData
                        fontSize: "small"
                    }
                }
            }
        }
    }
}
