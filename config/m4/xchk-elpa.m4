# -*- Autoconf -*-
#
# Copyright (C) 2026 ABINIT Group
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#



# AFB_CHECK_ELPA()
# ----------------
#
# Check whether the specified ELPA library is working with the current
# Fortran compiler and linear algebra libraries. The results are not
# cached, since this macro may be called several times with different
# flags.
#
AC_DEFUN([AFB_CHECK_ELPA],[
  dnl Init
  afb_elpa_ext_ok="no"

  dnl Prepare environment
  tmp_saved_FCFLAGS="${FCFLAGS}"
  tmp_saved_LIBS="${LIBS}"
  FCFLAGS="${FCFLAGS} ${afb_elpa_incs}"
  LIBS="${afb_elpa_libs} ${with_linalg_libs} ${LIBS}"

  dnl Check whether the Fortran module and library work (with the API
  dnl Abinit requires)
  AC_MSG_CHECKING([whether ELPA works])
  AC_LANG_PUSH([Fortran])
  AC_LINK_IFELSE([AC_LANG_PROGRAM([],
    [[
      use elpa
      class(elpa_t), pointer :: e
      if (elpa_init(20170403) /= ELPA_OK) stop
      e => elpa_allocate()
      call elpa_deallocate(e)
      call elpa_uninit()
    ]])], [afb_elpa_ext_ok="yes"], [afb_elpa_ext_ok="no"])
  AC_LANG_POP([Fortran])
  AC_MSG_RESULT([${afb_elpa_ext_ok}])

  dnl Restore environment
  FCFLAGS="${tmp_saved_FCFLAGS}"
  LIBS="${tmp_saved_LIBS}"
]) # AFB_CHECK_ELPA



# AFB_FIND_ELPA()
# ---------------
#
# Looks for a working ELPA in the build environment (see xchk-find.m4).
# Since no other fallback depends on ELPA, the fallback is simply not
# built when one is found.
#
AC_DEFUN([AFB_FIND_ELPA],[
  if test "${enable_elpa}" = ""; then
    _AFB_FIND_INIT([ELPA])
    dnl The include flags for the Fortran modules of ELPA, which are
    dnl installed in include/elpa-<version>/modules, are in the fcflags
    dnl variable of its pkg-config file
    _AFB_FIND_ADD_PKGCONFIG([elpa],
      [`${afb_find_pkg_config} --variable=fcflags elpa`])
    _AFB_FIND_TRY([elpa], [AFB_CHECK_ELPA])
    if test "${afb_elpa_found}" = "yes"; then
      enable_elpa="no"
      afb_elpa_ok="yes"
    fi
  fi
]) # AFB_FIND_ELPA
