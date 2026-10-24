# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_NETCDF4()
# -------------------
#
# Check whether the specified NetCDF4 library is working and supports the
# NetCDF-4 (HDF5) format. Also tells whether it supports parallel I/O. The
# results are not cached, since this macro may be called several times
# with different flags.
#
AC_DEFUN([AFB_CHECK_NETCDF4],[
  dnl Init
  afb_netcdf4_default_libs="-lnetcdf"
  afb_netcdf4_has_incs="unknown"
  afb_netcdf4_has_nc4="unknown"
  afb_netcdf4_has_libs="unknown"
  afb_netcdf4_has_par="unknown"
  afb_netcdf4_ext_ok="no"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${afb_netcdf4_incs}"
  if test "${afb_netcdf4_libs}" = ""; then
    AC_MSG_CHECKING([for NetCDF4 libraries to try])
    LIBS="${afb_netcdf4_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_netcdf4_default_libs}])
  else
    LIBS="${afb_netcdf4_libs} ${LIBS}"
  fi
  AC_LANG_PUSH([C])

  dnl Look for C includes
  AC_MSG_CHECKING([for NetCDF4 C headers])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
    [[
#include <netcdf.h>
#include <netcdf_meta.h>
    ]], [])], [afb_netcdf4_has_incs="yes"], [afb_netcdf4_has_incs="no"])
  AC_MSG_RESULT([${afb_netcdf4_has_incs}])

  dnl Check for NetCDF-4 format and parallel I/O support
  if test "${afb_netcdf4_has_incs}" = "yes"; then
    AC_MSG_CHECKING([whether NetCDF4 supports the NetCDF-4 format])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
      [[
#include <netcdf_meta.h>
#if !(NC_HAS_HDF5 || NC_HAS_NC4)
#error "no NetCDF-4 support"
#endif
      ]], [])], [afb_netcdf4_has_nc4="yes"], [afb_netcdf4_has_nc4="no"])
    AC_MSG_RESULT([${afb_netcdf4_has_nc4}])

    AC_MSG_CHECKING([whether NetCDF4 supports parallel I/O])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
      [[
#include <netcdf_meta.h>
#if !(defined(NC_HAS_PARALLEL4) ? NC_HAS_PARALLEL4 : NC_HAS_PARALLEL)
#error "serial NetCDF4"
#endif
      ]], [])], [afb_netcdf4_has_par="yes"], [afb_netcdf4_has_par="no"])
    AC_MSG_RESULT([${afb_netcdf4_has_par}])
  fi

  dnl Check whether the library works
  if test "${afb_netcdf4_has_nc4}" = "yes"; then
    AC_MSG_CHECKING([whether NetCDF4 works])
    AC_LINK_IFELSE([AC_LANG_PROGRAM(
      [[
#include <netcdf.h>
      ]],
      [[
        const char *version;
        version = nc_inq_libvers();
      ]])], [afb_netcdf4_has_libs="yes"], [afb_netcdf4_has_libs="no"])
    AC_MSG_RESULT([${afb_netcdf4_has_libs}])
  fi
  AC_LANG_POP([C])

  dnl Final adjustments
  if test "${afb_netcdf4_has_libs}" = "yes"; then
    afb_netcdf4_ext_ok="yes"
    if test "${afb_netcdf4_libs}" = ""; then
      afb_netcdf4_libs="${afb_netcdf4_default_libs}"
    fi
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_NETCDF4
