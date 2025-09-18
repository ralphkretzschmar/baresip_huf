# Find the system's GTK+ 3 includes and library
#
#  GTK3_CFLAGS(_OTHER) - where to find gtk.h
#  GTK3_LIBRARIES      - List of libraries when using GTK+ 3
#  GTK3_FOUND          - True if GTK+ 3 found

# First try pkg-config (also available via MSYS2/MinGW environments on
# Windows).  When pkg-config is not available we fall back to manual
# discovery based on common installation layouts and an optional
# GTK3_ROOT hint.

set(_GTK3_PKGCONFIG_FOUND FALSE)

find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(GTK3 QUIET gtk+-3.0)
  if(GTK3_FOUND)
    set(_GTK3_PKGCONFIG_FOUND TRUE)
  else()
    unset(GTK3_FOUND)
  endif()
endif()

if(WIN32 AND NOT _GTK3_PKGCONFIG_FOUND)
  # Manual search on Windows.  Honour a GTK3_ROOT variable or environment
  # variable to simplify discovery in MSYS2 or custom installations.
  set(_GTK3_ROOT_HINTS)
  if(GTK3_ROOT)
    list(APPEND _GTK3_ROOT_HINTS "${GTK3_ROOT}")
  endif()
  if(DEFINED ENV{GTK3_ROOT})
    list(APPEND _GTK3_ROOT_HINTS "$ENV{GTK3_ROOT}")
  endif()
  if(DEFINED ENV{GTK_DIR})
    list(APPEND _GTK3_ROOT_HINTS "$ENV{GTK_DIR}")
  endif()
  if(DEFINED ENV{MSYS2_ROOT})
    list(APPEND _GTK3_ROOT_HINTS
      "$ENV{MSYS2_ROOT}/mingw64" "$ENV{MSYS2_ROOT}/mingw32")
  endif()
  list(APPEND _GTK3_ROOT_HINTS ${CMAKE_PREFIX_PATH})
  list(REMOVE_DUPLICATES _GTK3_ROOT_HINTS)

  set(_GTK3_INCLUDE_SUFFIXES
    include
    include/gtk-3.0
  )

  find_path(GTK3_INCLUDE_DIR gtk/gtk.h
    HINTS ${_GTK3_ROOT_HINTS}
    PATH_SUFFIXES ${_GTK3_INCLUDE_SUFFIXES}
  )

  find_path(GTK3_GDK_INCLUDE_DIR gdk/gdk.h
    HINTS ${_GTK3_ROOT_HINTS}
    PATH_SUFFIXES include/gtk-3.0
  )

  find_path(GTK3_GLIB_INCLUDE_DIR glib.h
    HINTS ${_GTK3_ROOT_HINTS}
    PATH_SUFFIXES include/glib-2.0
  )

  find_path(GTK3_GLIBCONFIG_INCLUDE_DIR glibconfig.h
    HINTS ${_GTK3_ROOT_HINTS}
    PATH_SUFFIXES lib/glib-2.0/include lib64/glib-2.0/include
  )

  set(_GTK3_LIBRARY_SUFFIXES lib lib64)

  macro(_gtk3_find_library _var _name)
    if(NOT ${_var})
      find_library(${_var} NAMES ${_name}
        HINTS ${_GTK3_ROOT_HINTS}
        PATH_SUFFIXES ${_GTK3_LIBRARY_SUFFIXES}
      )
    endif()
  endmacro()

  _gtk3_find_library(GTK3_GTK_LIBRARY gtk-3 gtk-3.0)
  _gtk3_find_library(GTK3_GDK_LIBRARY gdk-3 gdk-3.0)
  _gtk3_find_library(GTK3_PANGOCARIO_LIBRARY pangocairo-1.0)
  _gtk3_find_library(GTK3_PANGO_LIBRARY pango-1.0)
  _gtk3_find_library(GTK3_ATK_LIBRARY atk-1.0)
  _gtk3_find_library(GTK3_CAIRO_GOBJECT_LIBRARY cairo-gobject)
  _gtk3_find_library(GTK3_CAIRO_LIBRARY cairo)
  _gtk3_find_library(GTK3_GDK_PIXBUF_LIBRARY gdk_pixbuf-2.0)
  _gtk3_find_library(GTK3_GIO_LIBRARY gio-2.0)
  _gtk3_find_library(GTK3_GOBJECT_LIBRARY gobject-2.0)
  _gtk3_find_library(GTK3_GLIB_LIBRARY glib-2.0)

  set(GTK3_INCLUDE_DIRS)
  foreach(_dir
      ${GTK3_INCLUDE_DIR}
      ${GTK3_GDK_INCLUDE_DIR}
      ${GTK3_GLIB_INCLUDE_DIR}
      ${GTK3_GLIBCONFIG_INCLUDE_DIR})
    if(_dir)
      list(APPEND GTK3_INCLUDE_DIRS "${_dir}")
    endif()
  endforeach()
  list(REMOVE_DUPLICATES GTK3_INCLUDE_DIRS)

  set(_GTK3_REQUIRED_LIBS
    GTK3_GTK_LIBRARY
    GTK3_GDK_LIBRARY
    GTK3_PANGOCARIO_LIBRARY
    GTK3_PANGO_LIBRARY
    GTK3_ATK_LIBRARY
    GTK3_CAIRO_GOBJECT_LIBRARY
    GTK3_CAIRO_LIBRARY
    GTK3_GDK_PIXBUF_LIBRARY
    GTK3_GIO_LIBRARY
    GTK3_GOBJECT_LIBRARY
    GTK3_GLIB_LIBRARY
  )

  set(_GTK3_LIB_MISSING FALSE)
  foreach(_lib ${_GTK3_REQUIRED_LIBS})
    if(NOT ${_lib})
      set(_GTK3_LIB_MISSING TRUE)
    endif()
  endforeach()

  if(NOT _GTK3_LIB_MISSING)
    set(GTK3_LIBRARIES
      ${GTK3_GTK_LIBRARY}
      ${GTK3_GDK_LIBRARY}
      ${GTK3_PANGOCARIO_LIBRARY}
      ${GTK3_PANGO_LIBRARY}
      ${GTK3_ATK_LIBRARY}
      ${GTK3_CAIRO_GOBJECT_LIBRARY}
      ${GTK3_CAIRO_LIBRARY}
      ${GTK3_GDK_PIXBUF_LIBRARY}
      ${GTK3_GIO_LIBRARY}
      ${GTK3_GOBJECT_LIBRARY}
      ${GTK3_GLIB_LIBRARY}
    )
    list(REMOVE_DUPLICATES GTK3_LIBRARIES)
  else()
    unset(GTK3_LIBRARIES)
  endif()

  set(GTK3_CFLAGS "")
  foreach(_dir IN LISTS GTK3_INCLUDE_DIRS)
    string(APPEND GTK3_CFLAGS " -I${_dir}")
  endforeach()
  string(STRIP "${GTK3_CFLAGS}" GTK3_CFLAGS)
  set(GTK3_CFLAGS_OTHER "")

  if(GTK3_INCLUDE_DIR AND EXISTS "${GTK3_INCLUDE_DIR}/gtk/gtkversion.h")
    file(READ "${GTK3_INCLUDE_DIR}/gtk/gtkversion.h" _GTK3_VERSION_CONTENT)
    string(REGEX MATCH "#define GTK_MAJOR_VERSION[ \t]+([0-9]+)" _GTK3_MAJOR "${_GTK3_VERSION_CONTENT}")
    set(_GTK3_MAJOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#define GTK_MINOR_VERSION[ \t]+([0-9]+)" _GTK3_MINOR "${_GTK3_VERSION_CONTENT}")
    set(_GTK3_MINOR "${CMAKE_MATCH_1}")
    string(REGEX MATCH "#define GTK_MICRO_VERSION[ \t]+([0-9]+)" _GTK3_MICRO "${_GTK3_VERSION_CONTENT}")
    set(_GTK3_MICRO "${CMAKE_MATCH_1}")
    if(_GTK3_MAJOR MATCHES "^[0-9]+$" AND _GTK3_MINOR MATCHES "^[0-9]+$" AND _GTK3_MICRO MATCHES "^[0-9]+$")
      set(GTK3_VERSION "${_GTK3_MAJOR}.${_GTK3_MINOR}.${_GTK3_MICRO}")
    endif()
    unset(_GTK3_VERSION_CONTENT)
    unset(_GTK3_MAJOR)
    unset(_GTK3_MINOR)
    unset(_GTK3_MICRO)
  endif()

  if(GTK3_INCLUDE_DIRS AND GTK3_LIBRARIES)
    set(GTK3_FOUND TRUE)
  endif()
endif()

if(NOT DEFINED GTK3_CFLAGS_OTHER)
  set(GTK3_CFLAGS_OTHER "")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GTK3 DEFAULT_MSG GTK3_LIBRARIES GTK3_CFLAGS)

mark_as_advanced(
  GTK3_LIBRARIES GTK3_CFLAGS GTK3_CFLAGS_OTHER
  GTK3_INCLUDE_DIR GTK3_GDK_INCLUDE_DIR GTK3_GLIB_INCLUDE_DIR
  GTK3_GLIBCONFIG_INCLUDE_DIR GTK3_GTK_LIBRARY GTK3_GDK_LIBRARY
  GTK3_PANGOCARIO_LIBRARY GTK3_PANGO_LIBRARY GTK3_ATK_LIBRARY
  GTK3_CAIRO_GOBJECT_LIBRARY GTK3_CAIRO_LIBRARY
  GTK3_GDK_PIXBUF_LIBRARY GTK3_GIO_LIBRARY GTK3_GOBJECT_LIBRARY
  GTK3_GLIB_LIBRARY
)
