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
