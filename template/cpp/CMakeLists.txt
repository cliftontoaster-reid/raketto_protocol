cmake_minimum_required(VERSION 3.10)
project(raketto_protocol VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INSTALL_RPATH "$ORIGIN/../lib")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_NAME "raketto_protocol")
set(CPACK_PACKAGE_CONTACT "Archprotogens <info@archprotogens.com>")
set(CPACK_PACKAGE_VENDOR "Archprotogens")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Raketto protocol C++ bindings")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/LICENCE.md")
set(CPACK_SET_DESTDIR ON)
set(CPACK_GENERATOR "DEB;RPM;TGZ")

# Find required packages
find_package(Protobuf REQUIRED)

# Include protobuf headers
include_directories(${Protobuf_INCLUDE_DIRS})

# Add library with generated protobuf files
file(GLOB_RECURSE PROTO_SOURCES "org/**/*.pb.cc")
add_library(raketto_protocol ${PROTO_SOURCES})
target_include_directories(raketto_protocol PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${Protobuf_INCLUDE_DIRS}
)
target_link_libraries(raketto_protocol PUBLIC ${Protobuf_LIBRARIES})

# Install
install(TARGETS raketto_protocol
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
install(DIRECTORY org DESTINATION include)
