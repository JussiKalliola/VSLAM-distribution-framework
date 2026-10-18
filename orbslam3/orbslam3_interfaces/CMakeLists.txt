cmake_minimum_required(VERSION 3.5)
project(orbslam3_interfaces)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE("${PROJECT_NAME}: Build type: " ${CMAKE_BUILD_TYPE})

# Default to C99
if(NOT CMAKE_C_STANDARD)
  set(CMAKE_C_STANDARD 99)
endif()

# Default to C++14
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic -O3 -w)
endif()

#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall   -O3 -w ${GCC_COVERAGE_COMPILE_FLAGS}")
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall   -O3 -w ${GCC_COVERAGE_COMPILE_FLAGS}")
#set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native -w")
#set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native -w")

# find dependencies
find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(std_msgs REQUIRED)
find_package(Eigen3 3.1.0 REQUIRED)
# uncomment the following section in order to fill in
# further dependencies manually.
# find_package(<dependency> REQUIRED)

# Add include directories for the helper file
include_directories(
  include
)


rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/Atlas.msg"
  "msg/Map.msg"
  "msg/Frame.msg"
  "msg/MapPoint.msg"
  "msg/MapPointUpdate.msg"
  "msg/KeyFrame.msg"
  "msg/KeyFrameUpdate.msg"
  "msg/KeyFrameDatabase.msg"
  "msg/IMUBias.msg"
  "msg/IMUPreintegrated.msg"
  "msg/Matrix.msg"
  "msg/IntTuple.msg"
  "msg/KeyValuePair.msg"
  "msg/BowVector.msg"
  "msg/BowFeatureVector.msg"
  "msg/Grid3D.msg"
  "msg/KeyPoint.msg"
  "msg/Int64.msg"
  "msg/Bool.msg"
  DEPENDENCIES geometry_msgs sensor_msgs std_msgs builtin_interfaces Eigen3
)

# Install headers
install(DIRECTORY include/
  DESTINATION include/orbslam3_interfaces/
)


if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  # the following line skips the linter which checks for copyrights
  # uncomment the line when a copyright and license is not present in all source files
  #set(ament_cmake_copyright_FOUND TRUE)
  # the following line skips cpplint (only works in a git repo)
  # uncomment the line when this package is not in a git repo
  #set(ament_cmake_cpplint_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
