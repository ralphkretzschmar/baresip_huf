#pragma once

#ifdef _MSC_VER

#include <BaseTsd.h>
#include <direct.h>
#include <io.h>
#include <process.h>
#include <stdlib.h>
#include <windows.h>

#ifndef ssize_t
typedef SSIZE_T ssize_t;
#endif

#ifndef pid_t
typedef int pid_t;
#endif

#ifndef uid_t
typedef int uid_t;
#endif

#ifndef gid_t
typedef int gid_t;
#endif

#ifndef F_OK
#define F_OK 0
#endif
#ifndef X_OK
#define X_OK 1
#endif
#ifndef W_OK
#define W_OK 2
#endif
#ifndef R_OK
#define R_OK 4
#endif

#ifndef STDIN_FILENO
#define STDIN_FILENO 0
#endif
#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif
#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

#ifndef access
#define access _access
#endif
#ifndef dup2
#define dup2 _dup2
#endif
#ifndef fileno
#define fileno _fileno
#endif
#ifndef getpid
#define getpid _getpid
#endif
#ifndef isatty
#define isatty _isatty
#endif
#ifndef lseek
#define lseek _lseek
#endif
#ifndef read
#define read _read
#endif
#ifndef write
#define write _write
#endif
#ifndef close
#define close _close
#endif
#ifndef unlink
#define unlink _unlink
#endif

#ifndef usleep
static inline int usleep(unsigned int usec)
{
    Sleep((usec + 999) / 1000);
    return 0;
}
#endif

#ifndef sleep
static inline unsigned int sleep(unsigned int seconds)
{
    Sleep(seconds * 1000);
    return 0;
}
#endif

#ifndef pipe
#define pipe _pipe
#endif

#else
#include_next <unistd.h>
#endif

