# -*- Autoconf -*-
#
# Copyright (C) 2006-2017 ABINIT Group (Yann Pouillon)
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

#
# Tricks for external packages
#



# AFB_TRICKS_NETCDF4_FORTRAN(FC_VENDOR,FC_VERSION)
# ----------------------------------------
#
# Applies tricks and workarounds to have the NetCDF4 Fortran
# C libraries correctly linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_NETCDF4_FORTRAN],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_netcdf4_fortran_tricks="no"
  afb_netcdf4_fortran_tricky_vars=""
  tmp_netcdf4_fortran_num_tricks=2
  tmp_netcdf4_fortran_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_netcdf4_fortran_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF4 Fortran tricks (vendor: $1, version: $2, flags: config)])

    dnl Internal NetCDF4 Fortran parameters
    CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN} --enable-large-file-tests --disable-shared"

    if test "${afb_hdf5_ok}" = "yes"; then
      if test "${afb_hdf5_build_par}" != "no"; then
          CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN} --enable-parallel-tests"
      else
          CFGFLAGS_NETCDF4_FORTRAN="${CFGFLAGS_NETCDF4_FORTRAN}"
      fi
    fi

    dnl Finish
    tmp_netcdf4_fortran_cnt_tricks=`expr ${tmp_netcdf4_fortran_cnt_tricks} \+ 1`
    afb_netcdf4_fortran_tricky_vars="${afb_netcdf4_fortran_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_NETCDF4_FORTRAN set => skipping NetCDF4 Fortran config tricks])
  fi

  dnl LIBS tricks
  if test "${afb_netcdf4_fortran_libs_custom}" = "no"; then
    AC_MSG_NOTICE([applying NetCDF4 Fortran tricks (vendor: $1, version: $2, flags: LIBS)])

    dnl Look for HDF5 wrapper (h5cc or h5pcc) in afb_hdf5_bins and extract extra libs
    tmp_netcdf4_fortran_h5cc=""
    AC_PATH_PROGS([tmp_netcdf4_fortran_h5cc],
                   [h5cc h5pcc],
                   [],
                   [${prefix}/${hdf5_pkg_inst}/bin])

    if test "${tmp_netcdf4_fortran_h5cc}" != ""; then
      tmp_netcdf4_fortran_extra_libs=`${tmp_netcdf4_fortran_h5cc} -showconfig 2>/dev/null | sed -n 's/^ *Extra libraries: *//p'`
      for arg in ${tmp_netcdf4_fortran_extra_libs}; do
        case "${arg}" in
          -l*) LIBS_NETCDF4_FORTRAN="${LIBS_NETCDF4_FORTRAN} ${arg}" ;;
        esac
      done
    fi

    dnl Finish
    unset tmp_netcdf4_fortran_h5cc
    unset tmp_netcdf4_fortran_extra_libs
    tmp_netcdf4_fortran_cnt_tricks=`expr ${tmp_netcdf4_fortran_cnt_tricks} \+ 1`
    afb_netcdf4_fortran_tricky_vars="${afb_netcdf4_fortran_tricky_vars} LIBS"
  else
    AC_MSG_NOTICE([LIBS_NETCDF4_FORTRAN set => skipping NetCDF4 Fortran libs tricks])
  fi

  dnl Count applied tricks
  case "${tmp_netcdf4_fortran_cnt_tricks}" in
    0)
      afb_netcdf4_fortran_tricks="no"
      ;;
    ${tmp_netcdf4_fortran_num_tricks})
      afb_netcdf4_fortran_tricks="yes"
      ;;
    *)
      afb_netcdf4_fortran_tricks="partial"
      ;;
  esac
  unset tmp_netcdf4_fortran_cnt_tricks
  unset tmp_netcdf4_fortran_num_tricks
]) # AFB_TRICKS_NETCDF4_FORTRAN
