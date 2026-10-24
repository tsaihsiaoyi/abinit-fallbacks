# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_LIBXC(API_MAJOR, API_MINOR, API_MAX)
# --------------------------------------------------------
#
# Check whether the specified LibXC library is working.
#
# Only the C API is checked: Abinit and the fallbacks depending on LibXC
# do not use its Fortran modules, and the Fortran 90 API has been removed
# from LibXC 6. The results are not cached, since this macro may be called
# several times with different flags.
#
AC_DEFUN([AFB_CHECK_LIBXC],[
  dnl Init
  afb_libxc_default_libs="-lxc"
  afb_libxc_has_incs="unknown"
  afb_libxc_has_libs="unknown"
  afb_libxc_version="unknown"
  afb_libxc_ext_ok="no"

  dnl Prepare environment
  tmp_saved_CPPFLAGS="${CPPFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  CPPFLAGS="${CPPFLAGS} ${afb_libxc_incs}"
  if test "${afb_libxc_libs}" = ""; then
    AC_MSG_CHECKING([for LibXC libraries to try])
    LIBS="${afb_libxc_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_libxc_default_libs}])
  else
    LIBS="${afb_libxc_libs} ${LIBS}"
  fi
  AC_LANG_PUSH([C])

  dnl Look for C includes
  AC_MSG_CHECKING([for LibXC C headers])
  AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
    [[
#include <xc.h>
#include <xc_funcs.h>
#include <xc_version.h>
    ]], [])], [afb_libxc_has_incs="yes"], [afb_libxc_has_incs="no"])
  AC_MSG_RESULT([${afb_libxc_has_incs}])

  dnl Check whether the library works
  if test "${afb_libxc_has_incs}" = "yes"; then
    AC_MSG_CHECKING([whether LibXC works])
    AC_LINK_IFELSE([AC_LANG_PROGRAM(
      [[
#include <xc.h>
      ]],
      [[
        xc_func_type func;
        if ( xc_func_init(&func, 1, XC_UNPOLARIZED) == 0 ) {
          xc_func_end(&func); }
      ]])], [afb_libxc_has_libs="yes"], [afb_libxc_has_libs="no"])
    AC_MSG_RESULT([${afb_libxc_has_libs}])
  fi

  dnl Check that we have the correct LibXC version
  if test "${afb_libxc_has_libs}" = "yes"; then
    AC_MSG_CHECKING([whether this is LibXC version $1.$2])
    AC_COMPILE_IFELSE([AC_LANG_PROGRAM(
      [[
#include <xc_version.h>
#if (XC_MAJOR_VERSION != $1) || (XC_MINOR_VERSION < $2) || (XC_MINOR_VERSION > $3)
#error "unsupported LibXC version"
#endif
      ]], [])], [afb_libxc_version="yes"], [afb_libxc_version="no"])
    AC_MSG_RESULT([${afb_libxc_version}])
    if test "${afb_libxc_version}" = "no"; then
      AC_COMPUTE_INT([tmp_libxc_major], [XC_MAJOR_VERSION],
        [[#include <xc_version.h>]], [tmp_libxc_major="?"])
      AC_COMPUTE_INT([tmp_libxc_minor], [XC_MINOR_VERSION],
        [[#include <xc_version.h>]], [tmp_libxc_minor="?"])
      AC_MSG_WARN([found LibXC API version ${tmp_libxc_major}.${tmp_libxc_minor}])
      unset tmp_libxc_major tmp_libxc_minor
    fi
  fi
  AC_LANG_POP([C])

  dnl Final adjustments
  if test "${afb_libxc_has_incs}" = "yes" -a \
          "${afb_libxc_has_libs}" = "yes" -a \
          "${afb_libxc_version}" = "yes"; then
    afb_libxc_ext_ok="yes"
    if test "${afb_libxc_libs}" = ""; then
      afb_libxc_libs="${afb_libxc_default_libs}"
    fi
  fi

  dnl Restore environment
  CPPFLAGS="${tmp_saved_CPPFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_LIBXC
