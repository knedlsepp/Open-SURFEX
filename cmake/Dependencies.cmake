
include(ExternalProject)

if(${USE_LOCAL_NETCDF})
    ExternalProject_add(HDF5
        URL ${CMAKE_CURRENT_SOURCE_DIR}/libs/hdf5-1.8.19.tar.bz2
        INSTALL_DIR ${CMAKE_BINARY_DIR}/libs
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DHDF5_BUILD_FORTRAN=ON
            -DBUILD_TESTING=OFF
            -DHDF5_BUILD_TOOLS=OFF
            -DHDF5_BUILD_EXAMPLES=OFF
            -DHDF5_BUILD_CPP_LIB=OFF
        )

    ExternalProject_add(NetCDF_C
        DEPENDS HDF5
        URL ${CMAKE_CURRENT_SOURCE_DIR}/libs/netcdf-4.4.1.1.tar.gz
        INSTALL_DIR ${CMAKE_BINARY_DIR}/libs
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DENABLE_DAP=OFF
            -DBUILD_UTILITIES=OFF
            -DENABLE_EXAMPLES=OFF
            -DENABLE_TESTS=OFF
        )

    ExternalProject_add(NetCDF_Fortran
        DEPENDS NetCDF_C
        URL ${CMAKE_CURRENT_SOURCE_DIR}/libs/netcdf-fortran-4.4.4.tar.gz
        INSTALL_DIR ${CMAKE_BINARY_DIR}/libs
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DENABLE_TESTS=OFF
        )

    ExternalProject_get_property(NetCDF_Fortran install_dir)

    set(LOCAL_NETCDF NetCDF_Fortran)

    # Hack to suppress error in INTERFACE_INCLUDE_DIRECTORIES
    file(MAKE_DIRECTORY "${install_dir}/include")

    add_library(NetCDF::NetCDF SHARED IMPORTED)
    set_property(TARGET NetCDF::NetCDF PROPERTY
        IMPORTED_LOCATION "${install_dir}/lib/libnetcdf.so")

    add_library(NetCDF::NetCDF_Fortran SHARED IMPORTED)
    set_property(TARGET NetCDF::NetCDF_Fortran PROPERTY
        IMPORTED_LOCATION "${install_dir}/lib/libnetcdff.so")
    set_property(TARGET NetCDF::NetCDF_Fortran PROPERTY
        INTERFACE_INCLUDE_DIRECTORIES "${install_dir}/include")
    target_link_libraries(NetCDF::NetCDF_Fortran INTERFACE NetCDF::NetCDF)

else(${USE_LOCAL_NETCDF})
    find_package(NetCDF REQUIRED COMPONENTS F90)
endif(${USE_LOCAL_NETCDF})

if(${USE_LOCAL_GRIB_API})
    ExternalProject_add(grib_api
        URL ${CMAKE_CURRENT_SOURCE_DIR}/libs/grib_api-1.23.0-Source.tar.gz
        INSTALL_DIR ${CMAKE_BINARY_DIR}/libs
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR>
            -DENABLE_FORTRAN=ON
            -DENABLE_NETCDF=OFF
            -DENABLE_PYTHON=OFF
            -DENABLE_EXAMPLES=OFF
            -DENABLE_TESTS=OFF
        )

    ExternalProject_get_property(grib_api install_dir)

    set(LOCAL_GRIB_API grib_api)

    # Hack to suppress error in INTERFACE_INCLUDE_DIRECTORIES
    file(MAKE_DIRECTORY "${install_dir}/include")

    add_library(grib_api::grib_api SHARED IMPORTED)
    set_property(TARGET grib_api::grib_api PROPERTY
        IMPORTED_LOCATION "${install_dir}/lib/libgrib_api.so")

    add_library(grib_api::grib_api_Fortran SHARED IMPORTED)
    set_property(TARGET grib_api::grib_api_Fortran PROPERTY
        IMPORTED_LOCATION "${install_dir}/lib/libgrib_api_f90.so")
    set_property(TARGET grib_api::grib_api_Fortran PROPERTY
        INTERFACE_INCLUDE_DIRECTORIES "${install_dir}/include")
    target_link_libraries(grib_api::grib_api_Fortran INTERFACE grib_api::grib_api)
else(${USE_LOCAL_GRIB_API})
    find_package(grib_api REQUIRED)
endif(${USE_LOCAL_GRIB_API})

if(${ENABLE_MPI})
    find_package(MPI REQUIRED COMPONENTS Fortran)
endif(${ENABLE_MPI})

if(${ENABLE_OMP})
    find_package(OpenMP REQUIRED)
endif(${ENABLE_OMP})