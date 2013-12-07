/*
 * bmp2c64
 *
 * This is a little tool for converting BMP bitmaps to something useful for
 * C64 coders.
 *
 * Author: Felix Palmen <felix@palmen-it.de>
 *
 * [0.1] - {unfinished}
 *   - understands 1bpp input files in 320x200 (full-screen hires),
 *     256x64 (font for 40 columns mode) 128x64 (font for 80 columns mode)
 *     and 24x21 (a sprite).
 *   - only available output format so far is assembler code (.byte lines)
 */

#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#ifdef WIN32
#include "getopt.h"
#else
#include <getopt.h>
#endif
#include <libgen.h>

enum gfxtype
{
    GFX_UNKNOWN,
    GFX_IMAGE,
    GFX_SPRITE,
    GFX_FONT_40,
    GFX_FONT_80
};

#pragma pack(push)
#pragma pack(1)
struct bmphdr
{
    uint16_t    bfType;
    uint32_t    bfSize;
    uint32_t    bfReserved;
    uint32_t    bfOffBits;
    uint32_t    biSize;
    uint32_t    biWidth;
    int32_t     biHeight;
    uint16_t    biPlanes;
    uint16_t    biBitCount;
    uint32_t    biCompression;
    uint32_t    biSizeImage;
    int32_t     biXPelsPerMeter;
    int32_t     biYPelsPerMeter;
    uint32_t    biClrUsed;
    uint32_t    biClrImportant;
};
#pragma pack(pop)

static struct bmphdr hdr;
static enum gfxtype type;
static int bottomup;
static int height;

static size_t rowsize;
static size_t bitmapsize;
static char *bitmap;
static char *c64bitmap;
static char *segment=0;

static int readhdr(int fd)
{
    size_t n = sizeof(struct bmphdr);
    void *p = &hdr;

    while (n != 0)
    {
        ssize_t r = read(fd, p, n);
        if (!r) return -1;
        n -= r;
        p += r;
    }
    return 0;
}

static void checkbmp()
{
    type = GFX_UNKNOWN;
    if (hdr.bfType != 0x4D42) return;
    if (hdr.biBitCount != 1) return;        // only hires for now

    height = hdr.biHeight;
    if (height > 0)
    {
        bottomup = 1;
    }
    else
    {
        bottomup = 0;
        height = -height;
    }
    switch (hdr.biWidth)
    {
        case 320:
            if (height == 200) type = GFX_IMAGE;
            break;
        case 256:
            if (height == 64) type = GFX_FONT_40;
            break;
        case 128:
            if (height == 64) type = GFX_FONT_80;
            break;
        case 24:
            if (height == 21) type = GFX_SPRITE;
            break;
    }
    rowsize = hdr.biWidth;
    int padding = rowsize % 32;
    if (padding) rowsize = rowsize - padding + 32;
    bitmapsize = rowsize / 8 * height;
}

static void readbmp(int fd)
{
    bitmap = 0;
    if (lseek(fd, hdr.bfOffBits, SEEK_SET) < 0) return;
    void *p = malloc(bitmapsize);
    if (!p) return;
    bitmap = p;

    size_t n = bitmapsize;
    while (n != 0)
    {
        ssize_t r = read(fd, p, n);
        if (!r)
        {
            free(bitmap);
            bitmap = 0;
            return;
        }
        n -= r;
        p += r;
    }
}

static void converttosprite()
{
    int l,c;
    char *p;

    char *q = c64bitmap;
    int inverted = bottomup ? *(bitmap+80) & 1<<7 : *bitmap & 1<<7;

    for (l = 0; l < 21; ++l)
    {
        p = bottomup ? bitmap + 4 * (20 - l) : bitmap + 4 * l;
        for (c = 0; c<3; ++c)
        {
            if (inverted)
                *q++ = ~*p++;
            else
                *q++ = *p++;
        }
    }
}

static void converttoblocks()
{
    int linestep;
    int rowstep;
    char *p;

    char *q = c64bitmap;
    int rows = height / 8;
    int cols = hdr.biWidth / 8;

    if (bottomup)
    {
        linestep = -(rowsize / 8);
        rowstep = -rowsize;
        p = bitmap + bitmapsize + linestep;
    }
    else
    {
        linestep = rowsize / 8;
        rowstep = rowsize;
        p = bitmap;
    }

    int inverted = (*p & 1<<7);

    int i,j,k;
    for (i = rows; i > 0; --i)
    {
        char *pl = p;
        for (j = cols; j > 0; --j)
        {
            char *pc = pl;
            for (k = 8; k > 0; --k)
            {
                if (inverted)
                    *q++ = ~*pc;
                else
                    *q++ = *pc;

                pc += linestep;
            }
            ++pl;
        }
        p += rowstep;
    }
}

static void convertbmp()
{
    c64bitmap = 0;
    char *p = malloc(bitmapsize);
    if (!p) return;
    c64bitmap = p;
    if (type == GFX_SPRITE)
    {
        converttosprite();
    }
    else
    {
        converttoblocks();
    }
    free(bitmap);
    bitmap = 0;
}

static void tobinstring(char *buf, char val)
{
    char *p = buf;
    *p++ = (val & 1<<7) ? '1' : '0';
    *p++ = (val & 1<<6) ? '1' : '0';
    *p++ = (val & 1<<5) ? '1' : '0';
    *p++ = (val & 1<<4) ? '1' : '0';
    *p++ = (val & 1<<3) ? '1' : '0';
    *p++ = (val & 1<<2) ? '1' : '0';
    *p++ = (val & 1<<1) ? '1' : '0';
    *p++ = (val & 1<<0) ? '1' : '0';
    *p = '\0';
}

static void formatsprite(const char *name)
{
    char bin0[9];
    char bin1[9];
    char bin2[9];
    char *p = c64bitmap;
    int l;

    printf(".export %s\n\n", name);
    if (segment) printf(".segment \"%s\"\n\n", segment);
    printf("%s:\n", name);

    for (l = 0; l < 21; ++l)
    {
        tobinstring(bin0, *p++);
        tobinstring(bin1, *p++);
        tobinstring(bin2, *p++);
        printf("                .byte   %%%s,%%%s,%%%s\n",
                bin0, bin1, bin2);
    }
    printf("                .byte   0\n\n");
}

static void formatfont(const char *name)
{
    int c = 8;
    char bin[9];
    char *p = c64bitmap;
    int i;

    printf(".export %s\n\n", name);
    if (segment) printf(".segment \"%s\"\n\n", segment);
    printf("%s:\n", name);

    for (i = 0; i < bitmapsize; ++i)
    {
        tobinstring(bin, *p++);
        printf("                .byte   %%%s\n", bin);
        if (!--c)
        {
            c = 8;
            printf("\n");
        }
    }
    printf("; vim: et:si:ts=8:sts=8:sw=8");
}

int main(int argc, char **argv)
{
    int fd, i;

    optind=opterr=0;
    
    while ((i = getopt(argc, argv, "s:"))!= -1)
    {
        segment=optarg;
    }
    
    if (optind != argc-1)
    {
        fprintf(stderr, "Usage: %s [-s segment] <file.bmp>.\n", argv[0]);
        return -1;
    }
    if ((fd = open(argv[optind], O_RDONLY)) < 0)
    {
        fprintf(stderr, "Error opening `%s'.\n", argv[optind]);
        return -1;
    }
    if (readhdr(fd) < 0)
    {
        fprintf(stderr, "`%s' is not a BMP file.\n", argv[optind]);
        close(fd);
        return -1;
    }
    checkbmp();
    if (type == GFX_UNKNOWN)
    {
        fprintf(stderr, "`%s' is not a BMP file or\n does not contain a known C64 gfx type.\n"
                "Supported types:\n"
                "  hires bitmap (320x200x1)\n"
                "  40 char font (256x64x1)\n"
                "  80 char font (128x64x1)\n"
                "  hires sprite (24x21x1)\n", argv[1]);
        close(fd);
        return -1;
    }
    readbmp(fd);
    close(fd);

    if (!bitmap)
    {
        fprintf(stderr, "Error reading `%s' -- corrupted file.\n",
                argv[optind]);
        return -1;
    }

    char *name = basename(argv[optind]);
    char *ext = name + strlen(name) - 4;
    if (*ext == '.')
    {
        *ext = '\0';
    }

    convertbmp();
#ifdef WIN32
    setmode(fileno(stdout), O_BINARY);
#endif
    switch (type)
    {
        case GFX_IMAGE:
            break;
        case GFX_FONT_40:
        case GFX_FONT_80:
            formatfont(name);
            break;
        case GFX_SPRITE:
            formatsprite(name);
            break;
    }

    free(c64bitmap);
    return 0;
}

/* vim: et:si:ts=8:sts=4:sw=4
*/
