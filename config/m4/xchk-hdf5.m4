# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_HDF5()
# ----------------
#
# Check whether the specified HDF5 library is working, including its
# high-level library, which NetCDF4 requires. Also tells whether it
# supports parallel I/O. The results are not cached, since this macro may
# be called several times with different flags.
#
AC_DEFUN([AFB_CHECK_HDF5],[
  dnl Init
  afb_hdf5_default_libs="-lhdf5_hl -lhdf5"
  afb_hdf5_has_incs="unknown"
  afb_hdf5_has_libs="unknown"
  afb_hdf5_has_par="unknown"
  afb_hdf5_ext_ok="no"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${afb_hdf5_incs}"
  if test "${afb_hdf5_libs}" = ""; then
    AC_MSG_CHECKING([for HDF5 libraries to try])
    LIBS="${afb_hdf5_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_hdf5_default_libs}])
  else
    LIBS="${afb_hdf5_libs} ${LIBS}"
  fi
  AC_LANG_PUSH([C])

  dnl Look for C includes
  AC_MSG_CHECKING([for HDF5 C headers])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
    [[
#include <hdf5.h>
#include <hdf5_hl.h>
    ]], [])], [afb_hdf5_has_incs="yes"], [afb_hdf5_has_incs="no"])
  AC_MSG_RESULT([${afb_hdf5_has_incs}])

  dnl Check whether the libraries work
  if test "${afb_hdf5_has_incs}" = "yes"; then
    AC_MSG_CHECKING([whether HDF5 works])
    AC_LINK_IFELSE([AC_LANG_PROGRAM(
      [[
#include <hdf5.h>
#include <hdf5_hl.h>
      ]],
      [[
        H5open();
        H5DSis_scale(0);
        H5close();
      ]])], [afb_hdf5_has_libs="yes"], [afb_hdf5_has_libs="no"])
    AC_MSG_RESULT([${afb_hdf5_has_libs}])
  fi

  dnl Check for parallel I/O support
  if test "${afb_hdf5_has_libs}" = "yes"; then
    AC_MSG_CHECKING([whether HDF5 supports parallel I/O])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
      [[
#include <hdf5.h>
#ifndef H5_HAVE_PARALLEL
#error "serial HDF5"
#endif
      ]], [])], [afb_hdf5_has_par="yes"], [afb_hdf5_has_par="no"])
    AC_MSG_RESULT([${afb_hdf5_has_par}])
  fi
  AC_LANG_POP([C])

  dnl Final adjustments
  if test "${afb_hdf5_has_libs}" = "yes"; then
    afb_hdf5_ext_ok="yes"
    if test "${afb_hdf5_libs}" = ""; then
      afb_hdf5_libs="${afb_hdf5_default_libs}"
    fi
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_HDF5
