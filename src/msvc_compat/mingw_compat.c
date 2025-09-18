#include <stdarg.h>
#include <stdio.h>

#if defined(_MSC_VER)
#if defined(_WIN64)
void __cdecl __chkstk(void);
#  pragma intrinsic(__chkstk)
#else
void __cdecl _chkstk(void);
#  pragma intrinsic(_chkstk)
#endif

void __cdecl __chkstk_ms(void)
{
#if defined(_WIN64)
    __chkstk();
#else
    _chkstk();
#endif
}

int __cdecl __mingw_fprintf(FILE *stream, const char *format, ...)
{
    va_list args;
    int ret;

    va_start(args, format);
    ret = vfprintf(stream, format, args);
    va_end(args);

    return ret;
}

int __cdecl __mingw_sscanf(const char *buffer, const char *format, ...)
{
    va_list args;
    int ret;

    va_start(args, format);
    ret = vsscanf(buffer, format, args);
    va_end(args);

    return ret;
}
#endif /* _MSC_VER */
