# -*- Autoconf -*-
#
# Copyright (C) 2026 ABINIT Group
#
# This file is part of the ABINIT software package. For license information,
# please see the COPYING file in the top-level directory of the ABINIT source
# distribution.
#

#
# Support for the detection of external packages
#
# The AFB_FIND_<PKG> macros look for a package already available in the
# build environment, e.g. through an environment module, so that the
# corresponding fallback does not have to be built. They are called by
# the _AFB_SETUP_<PKG> macros when the package has not been configured
# explicitly, i.e. without --enable-<pkg>, --disable-<pkg> nor
# --with-<pkg>-*. They register candidate build flags from pkg-config with
# the _AFB_FIND_ADD* macros below, then let _AFB_FIND_TRY run the
# AFB_CHECK_<PKG> macro of the package on them until one of them works.
#
# Packages are not looked for in the default search paths of the compilers
# (e.g. through CPATH and LIBRARY_PATH), which would give empty include
# flags: some fallbacks depending on them do not support it (e.g. AtomPAW
# stops, and BigDFT builds its own LibXC).
#



# _AFB_FIND_INIT(PKG_NAME)
# ------------------------
#
# Starts looking for an external package.
#
AC_DEFUN([_AFB_FIND_INIT],[
  AC_REQUIRE([_AFB_FIND_PKG_CONFIG])
  AC_MSG_NOTICE([looking for an external $1])
  tmp_find_num=0
]) # _AFB_FIND_INIT



# _AFB_FIND_PKG_CONFIG()
# ----------------------
#
# Looks for pkg-config, and sets afb_find_pkg_config to the command to run
# it. This command keeps the flags of the directories that pkg-config
# considers as system ones, e.g. the ones listed in CPATH or LIBRARY_PATH
# for pkgconf: Fortran compilers do not look for modules there, and the
# packages depending on the selected ones need these flags as well.
#
AC_DEFUN([_AFB_FIND_PKG_CONFIG],[
  AC_CHECK_PROG([PKG_CONFIG], [pkg-config], [pkg-config], [no])
  if test "${PKG_CONFIG}" = "" -o "${PKG_CONFIG}" = "no"; then
    afb_find_pkg_config=""
    AC_MSG_WARN([pkg-config not found: the fallbacks will be built even for
                  the packages already available, except linear algebra])
  else
    afb_find_pkg_config="env PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1 PKG_CONFIG_ALLOW_SYSTEM_LIBS=1 ${PKG_CONFIG}"
  fi
]) # _AFB_FIND_PKG_CONFIG



# _AFB_FIND_ADD(ORIGIN, INCS, LIBS)
# ---------------------------------
#
# Registers candidate include and library flags, found through ORIGIN.
#
AC_DEFUN([_AFB_FIND_ADD],[
  tmp_find_num=`expr ${tmp_find_num} \+ 1`
  tmp_find_val="$1"
  eval "tmp_find_from_${tmp_find_num}=\${tmp_find_val}"
  tmp_find_val="$2"
  eval "tmp_find_incs_${tmp_find_num}=\${tmp_find_val}"
  tmp_find_val="$3"
  eval "tmp_find_libs_${tmp_find_num}=\${tmp_find_val}"
]) # _AFB_FIND_ADD



# _AFB_FIND_ADD_PKGCONFIG(MODULE, [INCS], [LIBS])
# -----------------------------------------------
#
# Registers the flags that pkg-config provides for MODULE, if it knows it.
# INCS and LIBS default to the output of "pkg-config --cflags MODULE" and
# "pkg-config --libs MODULE", and must use ${afb_find_pkg_config} to run
# pkg-config otherwise.
#
AC_DEFUN([_AFB_FIND_ADD_PKGCONFIG],[
  if test "${afb_find_pkg_config}" != ""; then
    if ${afb_find_pkg_config} --exists $1 >/dev/null 2>&1; then
      _AFB_FIND_ADD([pkg-config $1],
        [m4_default([$2], [`${afb_find_pkg_config} --cflags $1`])],
        [m4_default([$3], [`${afb_find_pkg_config} --libs $1`])])
    fi
  fi
]) # _AFB_FIND_ADD_PKGCONFIG



# _AFB_FIND_TRY(PKG, CHECK, [CONDITION])
# --------------------------------------
#
# Runs CHECK, which sets afb_PKG_ext_ok, on the registered candidates
# until it succeeds and the optional shell CONDITION holds as well. Sets
# afb_PKG_found to "yes" in this case, with the selected flags in
# afb_PKG_incs and afb_PKG_libs.
#
AC_DEFUN([_AFB_FIND_TRY],[
  afb_$1_found="no"
  tmp_find_idx=1
  while test ${tmp_find_idx} -le ${tmp_find_num}; do
    eval "tmp_find_from=\${tmp_find_from_${tmp_find_idx}}"
    eval "afb_$1_incs=\${tmp_find_incs_${tmp_find_idx}}"
    eval "afb_$1_libs=\${tmp_find_libs_${tmp_find_idx}}"
    AC_MSG_NOTICE([trying $1 from ${tmp_find_from}])
    $2
    if test "${afb_$1_ext_ok}" = "yes"; then
      if m4_default([$3], [true]); then
        afb_$1_found="yes"
        break
      fi
    fi
    tmp_find_idx=`expr ${tmp_find_idx} \+ 1`
  done

  if test "${afb_$1_found}" = "yes"; then
    AC_MSG_NOTICE([using $1 from ${tmp_find_from} instead of the fallback])
    AC_MSG_NOTICE([$1 include flags: ${afb_$1_incs:-none}])
    AC_MSG_NOTICE([$1 libraries: ${afb_$1_libs:-none}])
  else
    afb_$1_incs=""
    afb_$1_libs=""
    AC_MSG_NOTICE([no usable external $1 found => building the fallback])
  fi
  unset tmp_find_from tmp_find_idx tmp_find_num tmp_find_val
]) # _AFB_FIND_TRY
