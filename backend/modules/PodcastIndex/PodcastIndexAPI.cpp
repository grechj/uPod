// PodcastIndexAPI.cpp
// Podcast Index API implementation with SHA-1 authentication

#include "PodcastIndexAPI.h"
#include <QNetworkRequest>
#include <QUrlQuery>
#include <QDebug>
#include <QSettings>

PodcastIndexAPI::PodcastIndexAPI(QObject *parent)
    : QObject(parent)
    , m_networkManager(new QNetworkAccessManager(this))
    , m_baseUrl("https://api.podcastindex.org/api/1.0")
    , m_userAgent("uPod/0.2.0")
{
    connect(m_networkManager, &QNetworkAccessManager::finished,
            this, &PodcastIndexAPI::handleNetworkReply);
    
    loadConfiguration();
}

PodcastIndexAPI::~PodcastIndexAPI()
{
    for (QNetworkReply *reply : m_pendingRequests.keys()) {
        reply->abort();
        reply->deleteLater();
    }
}

void PodcastIndexAPI::setApiKey(const QString &key)
{
    if (m_apiKey != key) {
        m_apiKey = key;
        emit apiKeyChanged();
        emit isConfiguredChanged();
    }
}

void PodcastIndexAPI::setApiSecret(const QString &secret)
{
    if (m_apiSecret != secret) {
        m_apiSecret = secret;
        emit apiSecretChanged();
        emit isConfiguredChanged();
    }
}

QString PodcastIndexAPI::generateAuthHash(const QString &authDate)
{
    QString dataToHash = m_apiKey + m_apiSecret + authDate;
    QByteArray hash = QCryptographicHash::hash(
        dataToHash.toUtf8(),
        QCryptographicHash::Sha1
    );
    return hash.toHex();
}

QNetworkRequest PodcastIndexAPI::buildAuthenticatedRequest(const QString 
&url)
{
    QNetworkRequest request(url);
    
    QString authDate = 
QString::number(QDateTime::currentSecsSinceEpoch());
    QString authHash = generateAuthHash(authDate);
    
    request.setRawHeader("X-Auth-Key", m_apiKey.toUtf8());
    request.setRawHeader("X-Auth-Date", authDate.toUtf8());
    request.setRawHeader("Authorization", authHash.toUtf8());
    request.setRawHeader("User-Agent", m_userAgent.toUtf8());
    
    return request;
}

void PodcastIndexAPI::makeRequest(const QString &endpoint, const QUrlQuery 
&params)
{
    if (!isConfigured()) {
        emit errorOccurred("API not configured. Please set API key and 
secret.", "CONFIG_ERROR");
        return;
    }
    
    QString url = m_baseUrl + endpoint;
    if (!params.isEmpty()) {
        url += "?" + params.toString();
    }
    
    QNetworkRequest request = buildAuthenticatedRequest(url);
    QNetworkReply *reply = m_networkManager->get(request);
    
    m_pendingRequests[reply] = endpoint;
    emit requestStarted(endpoint);
    
    qDebug() << "Making request to:" << url;
}

void PodcastIndexAPI::handleNetworkReply(QNetworkReply *reply)
{
    QString endpoint = m_pendingRequests.take(reply);
    
    if (reply->error() != QNetworkReply::NoError) {
        QString errorMsg = QString("Network error: 
%1").arg(reply->errorString());
        qWarning() << errorMsg;
        emit errorOccurred(errorMsg, "NETWORK_ERROR");
        emit requestFinished(endpoint);
        reply->deleteLater();
        return;
    }
    
    processResponse(reply, endpoint);
    emit requestFinished(endpoint);
    reply->deleteLater();
}

void PodcastIndexAPI::processResponse(QNetworkReply *reply, const QString 
&endpoint)
{
    QByteArray responseData = reply->readAll();
    QJsonDocument doc = QJsonDocument::fromJson(responseData);
    
    if (!doc.isObject()) {
        emit errorOccurred("Invalid JSON response", "PARSE_ERROR");
        return;
    }
    
    QJsonObject response = doc.object();
    QString status = response["status"].toString();
    
    if (status != "true") {
        QString errorMsg = response["description"].toString("Unknown 
error");
        emit errorOccurred(errorMsg, "API_ERROR");
        return;
    }
    
    if (endpoint.contains("/search/byterm")) {
        QJsonArray feeds = response["feeds"].toArray();
        emit searchResultsReceived(feeds);
    }
    else if (endpoint.contains("/podcasts/trending")) {
        QJsonArray feeds = response["feeds"].toArray();
        emit trendingReceived(feeds);
    }
    else if (endpoint.contains("/recent/episodes")) {
        QJsonArray episodes = response["items"].toArray();
        emit recentEpisodesReceived(episodes);
    }
    else if (endpoint.contains("/podcasts/byfeedid") || 
             endpoint.contains("/podcasts/byfeedurl")) {
        QJsonObject feed = response["feed"].toObject();
        emit podcastDetailsReceived(feed);
    }
    else if (endpoint.contains("/episodes/byfeedid")) {
        QJsonArray episodes = response["items"].toArray();
        emit episodesReceived(episodes);
    }
    else if (endpoint.contains("/categories/list")) {
        QJsonArray categories = response["feeds"].toArray();
        emit categoriesReceived(categories);
    }
    else if (endpoint.contains("/podcasts/bycategory")) {
        QJsonArray feeds = response["feeds"].toArray();
        emit podcastsByCategoryReceived(feeds);
    }
}

void PodcastIndexAPI::searchPodcasts(const QString &query, int maxResults)
{
    QUrlQuery params;
    params.addQueryItem("q", query);
    params.addQueryItem("max", QString::number(maxResults));
    params.addQueryItem("fulltext", "true");
    
    makeRequest("/search/byterm", params);
}

void PodcastIndexAPI::getTrending(int maxResults, const QString &language)
{
    QUrlQuery params;
    params.addQueryItem("max", QString::number(maxResults));
    if (!language.isEmpty()) {
        params.addQueryItem("lang", language);
    }
    
    makeRequest("/podcasts/trending", params);
}

void PodcastIndexAPI::getRecentEpisodes(int maxResults, const QString 
&language)
{
    QUrlQuery params;
    params.addQueryItem("max", QString::number(maxResults));
    if (!language.isEmpty()) {
        params.addQueryItem("lang", language);
    }
    
    makeRequest("/recent/episodes", params);
}

void PodcastIndexAPI::getPodcastByFeedId(int feedId)
{
    QUrlQuery params;
    params.addQueryItem("id", QString::number(feedId));
    makeRequest("/podcasts/byfeedid", params);
}

void PodcastIndexAPI::getPodcastByFeedUrl(const QString &feedUrl)
{
    QUrlQuery params;
    params.addQueryItem("url", feedUrl);
    makeRequest("/podcasts/byfeedurl", params);
}

void PodcastIndexAPI::getEpisodesByFeedId(int feedId, int maxResults)
{
    QUrlQuery params;
    params.addQueryItem("id", QString::number(feedId));
    params.addQueryItem("max", QString::number(maxResults));
    makeRequest("/episodes/byfeedid", params);
}

void PodcastIndexAPI::getCategories()
{
    makeRequest("/categories/list");
}

void PodcastIndexAPI::getPodcastsByCategory(int categoryId, int 
maxResults)
{
    QUrlQuery params;
    params.addQueryItem("id", QString::number(categoryId));
    params.addQueryItem("max", QString::number(maxResults));
    makeRequest("/podcasts/bycategory", params);
}

void PodcastIndexAPI::loadConfiguration()
{
    QSettings settings;
    settings.beginGroup("PodcastIndex");
    
    m_apiKey = settings.value("apiKey", "").toString();
    m_apiSecret = settings.value("apiSecret", "").toString();
    
    settings.endGroup();
    
    if (isConfigured()) {
        qDebug() << "Podcast Index API credentials loaded";
    }
}

void PodcastIndexAPI::saveConfiguration()
{
    QSettings settings;
    settings.beginGroup("PodcastIndex");
    
    settings.setValue("apiKey", m_apiKey);
    settings.setValue("apiSecret", m_apiSecret);
    
    settings.endGroup();
    settings.sync();
    
    qDebug() << "Podcast Index API credentials saved";
}

void PodcastIndexAPI::clearConfiguration()
{
    QSettings settings;
    settings.beginGroup("PodcastIndex");
    settings.remove("");
    settings.endGroup();
    
    m_apiKey.clear();
    m_apiSecret.clear();
    
    emit apiKeyChanged();
    emit apiSecretChanged();
    emit isConfiguredChanged();
    
    qDebug() << "Podcast Index API credentials cleared";
}

bool PodcastIndexAPI::testConnection()
{
    if (!isConfigured()) {
        emit connectionTestResult(false, "API credentials not 
configured");
        return false;
    }
    
    QString url = m_baseUrl + "/categories/list";
    QNetworkRequest request = buildAuthenticatedRequest(url);
    
    QNetworkReply *reply = m_networkManager->get(request);
    
    QEventLoop loop;
    QTimer timer;
    timer.setSingleShot(true);
    
    connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    connect(&timer, &QTimer::timeout, &loop, &QEventLoop::quit);
    
    timer.start(5000);
    loop.exec();
    
    bool success = false;
    QString message;
    
    if (timer.isActive()) {
        timer.stop();
        
        if (reply->error() == QNetworkReply::NoError) {
            QJsonDocument doc = QJsonDocument::fromJson(reply->readAll());
            QJsonObject response = doc.object();
            
            if (response["status"].toString() == "true") {
                success = true;
                message = "Connection successful!";
            } else {
                message = "Authentication failed: " + 
response["description"].toString();
            }
        } else {
            message = "Network error: " + reply->errorString();
        }
    } else {
        message = "Connection timeout";
        reply->abort();
    }
    
    reply->deleteLater();
    emit connectionTestResult(success, message);
    
    return success;
}
