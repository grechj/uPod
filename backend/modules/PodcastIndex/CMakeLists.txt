# CMakeLists.txt for PodcastIndex backend module

set(PODCASTINDEX_SOURCES
    PodcastIndexAPI.cpp
)

set(PODCASTINDEX_HEADERS
    PodcastIndexAPI.h
)

add_library(podcastindex STATIC
    ${PODCASTINDEX_SOURCES}
    ${PODCASTINDEX_HEADERS}
)

target_link_libraries(podcastindex
    Qt5::Core
    Qt5::Network
)

target_include_directories(podcastindex PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
