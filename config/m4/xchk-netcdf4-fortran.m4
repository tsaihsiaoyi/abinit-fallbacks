# -*- Autoconf -*-
#
# Copyright (C) 2014 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_NETCDF4_FORTRAN()
# ---------------------------
#
# Check whether the specified NetCDF4-Fortran library is working with the
# current Fortran compiler. The results are not cached, since this macro
# may be called several times with different flags.
#
AC_DEFUN([AFB_CHECK_NETCDF4_FORTRAN],[
  dnl Init
  afb_netcdf4_fortran_default_libs="-lnetcdff"
  afb_netcdf4_fortran_ext_ok="no"

  dnl Prepare environment
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  FCFLAGS="${FCFLAGS} ${afb_netcdf4_fortran_incs}"
  if test "${afb_netcdf4_fortran_libs}" = ""; then
    AC_MSG_CHECKING([for NetCDF4-Fortran libraries to try])
    LIBS="${afb_netcdf4_fortran_default_libs} ${LIBS}"
    AC_MSG_RESULT([${afb_netcdf4_fortran_default_libs}])
  else
    LIBS="${afb_netcdf4_fortran_libs} ${LIBS}"
  fi

  dnl Check whether the Fortran module and library work
  AC_MSG_CHECKING([whether NetCDF4-Fortran works])
  AC_LANG_PUSH([Fortran])
  AC_LINK_IFELSE([AC_LANG_PROGRAM([],
    [[
      use netcdf
      character(len=*), parameter :: path = "dummy"
      integer :: mode, ncerr, ncid
      ncerr = nf90_open(path,mode,ncid)
    ]])], [afb_netcdf4_fortran_ext_ok="yes"],
    [afb_netcdf4_fortran_ext_ok="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_netcdf4_fortran_ext_ok}])

  dnl Set internal variables if successful
  if test "${afb_netcdf4_fortran_ext_ok}" = "yes"; then
    if test "${afb_netcdf4_fortran_libs}" = ""; then
      afb_netcdf4_fortran_libs="${afb_netcdf4_fortran_default_libs}"
    fi
  fi

  dnl Restore environment
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_NETCDF4_FORTRAN



# AFB_FIND_NETCDF4_FORTRAN()
# --------------------------
#
# Looks for a working NetCDF4-Fortran in the build environment (see
# xchk-find.m4). It is only used with an external NetCDF4, which it has
# presumably been built with.
#
AC_DEFUN([AFB_FIND_NETCDF4_FORTRAN],[
  if test "${enable_netcdf4_fortran}" = ""; then
    if test "${enable_netcdf4}" = "no" -a "${afb_netcdf4_ok}" = "yes"; then
      _AFB_FIND_INIT([NetCDF4-Fortran])
      _AFB_FIND_ADD_PKGCONFIG([netcdf-fortran])
      _AFB_FIND_TRY([netcdf4_fortran], [AFB_CHECK_NETCDF4_FORTRAN])
      if test "${afb_netcdf4_fortran_found}" = "yes"; then
        enable_netcdf4_fortran="no"
        with_netcdf4_fortran_incs="${afb_netcdf4_fortran_incs}"
        with_netcdf4_fortran_libs="${afb_netcdf4_fortran_libs}"
      fi
    else
      AC_MSG_NOTICE([NetCDF4 is built as a fallback => building the NetCDF4-Fortran fallback as well])
    fi
  fi
]) # AFB_FIND_NETCDF4_FORTRAN
