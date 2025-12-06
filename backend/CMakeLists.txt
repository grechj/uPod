add_subdirectory(modules/uPod)
add_subdirectory(modules/PodcastIndex)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
)

set(
    uPodbackend_SRCS
    modules/uPod/backend.cpp
    modules/uPod/filemanager.cpp
)

add_library(uPodbackend MODULE
    ${uPodbackend_SRCS}
)
# Add PodcastIndex module
add_subdirectory(modules/PodcastIndex)
add_subdirectory(modules/uPod)

set_target_properties(uPodbackend PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY uPod)

# qt5_use_modules(uPodbackend Gui Qml Quick)
# Link libraries
target_link_libraries(uPodbackend 
    Qt5::Qml 
    Qt5::Gui 
    Qt5::Quick 
    podcastindex
)

# Copy qmldir file to build dir for running in QtCreator
add_custom_target(uPodbackend-qmldir ALL
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/modules/uPod/qmldir ${CMAKE_CURRENT_BINARY_DIR}/uPod
    DEPENDS ${QMLFILES}
)

# Install plugin file
install(TARGETS uPodbackend DESTINATION ${QT_IMPORTS_DIR}/uPod/)
install(FILES   modules/uPod/qmldir DESTINATION ${QT_IMPORTS_DIR}/uPod/)
