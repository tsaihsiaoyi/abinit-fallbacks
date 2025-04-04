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



# AFB_TRICKS_ELPA(FC_VENDOR,FC_VERSION)
# -------------------------------------
#
# Applies tricks and workarounds to have the ELPA library correctly
# linked to the binaries.
#
AC_DEFUN([AFB_TRICKS_ELPA],[
  dnl Do some sanity checking of the arguments
  m4_if([$1], [], [AC_FATAL([$0: missing argument 1])])dnl
  m4_if([$2], [], [AC_FATAL([$0: missing argument 2])])dnl

  dnl Init
  afb_elpa_tricks="no"
  afb_elpa_tricky_vars=""
  tmp_elpa_num_tricks=2
  tmp_elpa_cnt_tricks=0

  dnl Configure tricks
  if test "${afb_elpa_cfgflags_custom}" = "no"; then
    AC_MSG_NOTICE([applying ELPA tricks (vendor: $1, version: $2, flags: config)])
    
    dnl Basic configuration options
    CFGFLAGS_ELPA="--enable-static --disable-shared"
    
    dnl OpenMP support
    if test "${afb_elpa_enable_openmp}" = "yes"; then
      CFGFLAGS_ELPA="${CFGFLAGS_ELPA} --enable-openmp=yes"
    else
      CFGFLAGS_ELPA="${CFGFLAGS_ELPA} --enable-openmp=no"
    fi

    dnl Add standard flags
    tmpcfg_elpa="--disable-avx-kernels --disable-avx2-kernels --disable-avx512-kernels --disable-sse-kernels --disable-sse-assembly-kernels"
    CFGFLAGS_ELPA="${tmpcfg_elpa} ${CFGFLAGS_ELPA}"
    unset tmpcfg_elpa
    # TODO: add support for AVX kernels if available
    
    dnl Finish
    tmp_elpa_cnt_tricks=`expr ${tmp_elpa_cnt_tricks} \+ 1`
    afb_elpa_tricky_vars="${afb_elpa_tricky_vars} CFGFLAGS"
  else
    AC_MSG_NOTICE([CFGFLAGS_ELPA set => skipping ELPA arch tricks])
  fi

  dnl Linar algebra tricks
  if test "${afb_elpa_ldflag_custom}" = "no"; then
    AC_MSG_NOTICE([applying ELPA tricks (vendor: $1, version: $2, flags: linalg)])
    
    dnl Add standard flags
    tmplibs_elpa='$(afb_linalg_libs)'
    LDFLAGS_ELPA="${tmplibs_elpa} ${LDFLAGS_ELPA}"
    unset tmplibs_elpa
    
    dnl Finish
    tmp_elpa_cnt_tricks=`expr ${tmp_elpa_cnt_tricks} \+ 1`
    afb_elpa_tricky_vars="${afb_elpa_tricky_vars} LDFLAGS"
  else
    AC_MSG_NOTICE([LDFLAGS_ELPA set => skipping ELPA linalg tricks])
  fi

  dnl Count applied tricks
  case "${tmp_elpa_cnt_tricks}" in
    0)
      afb_elpa_tricks="no"
      ;;
    ${tmp_elpa_num_tricks})
      afb_elpa_tricks="yes"
      ;;
    *)
      afb_elpa_tricks="partial"
      ;;
  esac
  unset tmp_elpa_cnt_tricks
  unset tmp_elpa_num_tricks
]) # AFB_TRICKS_ELPA
