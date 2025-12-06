// PodcastIndexAPI.h
// Podcast Index API authentication and request handler for PodPhoenix
// Place this file in: backend/modules/PodcastIndex/

#ifndef PODCASTINDEXAPI_H
#define PODCASTINDEXAPI_H

#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCryptographicHash>
#include <QDateTime>
#include <QUrlQuery>

class PodcastIndexAPI : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString apiKey READ apiKey WRITE setApiKey NOTIFY 
apiKeyChanged)
    Q_PROPERTY(QString apiSecret READ apiSecret WRITE setApiSecret NOTIFY 
apiSecretChanged)
    Q_PROPERTY(bool isConfigured READ isConfigured NOTIFY 
isConfiguredChanged)

public:
    explicit PodcastIndexAPI(QObject *parent = nullptr);
    ~PodcastIndexAPI();

    // Property getters
    QString apiKey() const { return m_apiKey; }
    QString apiSecret() const { return m_apiSecret; }
    bool isConfigured() const { return !m_apiKey.isEmpty() && 
!m_apiSecret.isEmpty(); }

    // Property setters
    void setApiKey(const QString &key);
    void setApiSecret(const QString &secret);

    // API Methods - exposed to QML via Q_INVOKABLE
    Q_INVOKABLE void searchPodcasts(const QString &query, int maxResults = 
25);
    Q_INVOKABLE void getTrending(int maxResults = 10, const QString 
&language = "");
    Q_INVOKABLE void getRecentEpisodes(int maxResults = 10, const QString 
&language = "");
    Q_INVOKABLE void getPodcastByFeedId(int feedId);
    Q_INVOKABLE void getPodcastByFeedUrl(const QString &feedUrl);
    Q_INVOKABLE void getEpisodesByFeedId(int feedId, int maxResults = 10);
    Q_INVOKABLE void getCategories();
    Q_INVOKABLE void getPodcastsByCategory(int categoryId, int maxResults 
= 25);

    // Configuration management
    Q_INVOKABLE void loadConfiguration();
    Q_INVOKABLE void saveConfiguration();
    Q_INVOKABLE void clearConfiguration();
    Q_INVOKABLE bool testConnection();

signals:
    // Property change signals
    void apiKeyChanged();
    void apiSecretChanged();
    void isConfiguredChanged();

    // API response signals
    void searchResultsReceived(const QJsonArray &feeds);
    void trendingReceived(const QJsonArray &feeds);
    void recentEpisodesReceived(const QJsonArray &episodes);
    void podcastDetailsReceived(const QJsonObject &feed);
    void episodesReceived(const QJsonArray &episodes);
    void categoriesReceived(const QJsonArray &categories);
    void podcastsByCategoryReceived(const QJsonArray &feeds);

    // Error and status signals
    void errorOccurred(const QString &errorMessage, const QString 
&errorType);
    void requestStarted(const QString &endpoint);
    void requestFinished(const QString &endpoint);
    void connectionTestResult(bool success, const QString &message);

private slots:
    void handleNetworkReply(QNetworkReply *reply);

private:
    // Core functionality
    void makeRequest(const QString &endpoint, const QUrlQuery &params = 
QUrlQuery());
    QNetworkRequest buildAuthenticatedRequest(const QString &url);
    QString generateAuthHash(const QString &authDate);
    void processResponse(QNetworkReply *reply, const QString &endpoint);

    // Member variables
    QNetworkAccessManager *m_networkManager;
    QString m_apiKey;
    QString m_apiSecret;
    QString m_baseUrl;
    QString m_userAgent;
    
    // Request tracking
    QMap<QNetworkReply*, QString> m_pendingRequests;
};

#endif // PODCASTINDEXAPI_H
