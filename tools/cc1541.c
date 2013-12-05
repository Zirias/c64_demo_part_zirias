/**
 * cc1541 -- flexible tool for creating d64 disk images
 *
 *
 * This is taken from http://csdb.dk/release/?id=69964 2013-12-04
 * Original Author: JackAsser (http://csdb.dk/scener/?id=4320)
 *
 * Modifications to original version:
 *
 * - make it plain C, so there's no C++ compiler needed (in fact, it was just
 *   plain C using a tiny bit of C++ syntax)
 * - fix potential memory leak when giving 2 filenames before writing file
 *   to disk
 * - add options to control filetype (PRG, USR, SEQ, REL, DEL) and
 *   write protection
 * - generally create write-protected disks for now (DOS-Version 0x40 in BAM)
 * - start writing files at track 17, better loading speed for first files
 *
 * Modified by Felix Palmen <felix@palmen-it.de>
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <getopt.h>
#include <unistd.h>

#define min(a,b) (((a)<(b))?(a):(b))
#define _true 1
#define _false 0

typedef int _bool;

enum filetype
{
    FT_DEL = 0x80,
    FT_SEQ = 0x81,
    FT_PRG = 0x82,
    FT_USR = 0x83,
    FT_REL = 0x84,

    FT_PROT = 0x40
};

struct d64file
{
    char *localname;
    char *filename;
    enum filetype type;
    int sectorInterleave;
    int track;
    int sector;
    int nrSectors;
};

char *name="default";
char *id="lodis";
char *image;
int nrFiles=0;
struct d64file files[100];
_bool track18split=_true;
_bool usetrack18=_false;

int extraTracksBamOffset = 0xc0;	// c0=speed dos, ac=dolphin dos
int nrTracks = 35;

void usage()
{
    printf("Usage: cc1541 -niSsfw image.d64\n\n");
    printf("-n diskname   Disk name, default='default'\n");
    printf("-i id         Disk ID, default='lodis'\n");
    printf("-S value      Default sector interleave, default=10\n");
    printf("-s value      Next file sector interleave, after each file\n");
    printf("              the interleave value falls back to the default value set by -S\n");
    printf("-f filename   Use filename as name when writing next file\n");
    printf("-u            Next file is USR (default: PRG)\n");
    printf("-q            Next file is SEQ (default: PRG)\n");
    printf("-r            Next file is REL (default: PRG)\n");
    printf("-d            Next file is DEL [not a real file, written immediately without");
    printf("              -w option])\n");
    printf("-p            Next file is write-protected\n");
    printf("-w localname  Write local file to disk, if filename is not set then the\n");
    printf("              local name is used. After file written filename is unset\n");
    printf("-x            Don't split files over track 18 hole (default split files)\n");
    printf("-t            Use track 18 to also store files (makes -x useless) (default no)\n");
    printf("-4            Use tracks 35-40 with SPEED DOS formatting\n");
    printf("-5            Use tracks 35-40 with DOLPHIN DOS formatting\n");
    printf("\n");
    exit(1);
}

static int sectorsPerTrack[]={
    21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,21,
    19,19,19,19,19,19,19,
    18,18,18,18,18,18,
    17,17,17,17,17,
    17,17,17,17,17 };

int linearSector(int track, int sector)
{
    if ((track<1) || (track>nrTracks))
    {
	fprintf(stderr, "Illegal track %d\n", track);
	exit(-1);
    }

    if ((sector<0) || (sector>=sectorsPerTrack[track-1]))
    {
	fprintf(stderr, "Illegal sector %d for track %d (max is %d)\n", sector, track, sectorsPerTrack[track-1]);
	exit(-1);
    }

    int i;
    int linearSector=0;
    for (i=0;i<track-1;i++)
	linearSector+=sectorsPerTrack[i];
    linearSector+=sector;

    return linearSector;
}

_bool isSectorFree(unsigned char* d64image, int track, int sector)
{
    int bam=linearSector(18,0)*256;

    if (track>35)
    {
	track-=35;
	bam=linearSector(18,0)*256+extraTracksBamOffset;
    }

    unsigned char *bitmap=d64image+bam+track*4+1;
    int byte=sector/8;
    int bit=7-(sector&7);

    return (bitmap[byte]&(1<<bit))!=0;
}

void markSector(unsigned char* d64image, int track, int sector, _bool free)
{
    int bam=linearSector(18,0)*256;

    if (free!=isSectorFree(d64image,track,sector))
    {
	if (track>35)
	{
	    track-=35;
	    bam=linearSector(18,0)*256+extraTracksBamOffset;
	}

	if (free)
	    d64image[bam+track*4+0]++;
	else
	    d64image[bam+track*4+0]--;

	unsigned char *bitmap=d64image+bam+track*4+1;
	int byte=sector/8;
	int bit=7-(sector&7);

	if (free)
	    bitmap[byte]|=1<<bit;
	else
	    bitmap[byte]&=~(1<<bit);
    }
}

int main(int argc, char** argv)
{
    struct stat st;

    int defaultSectorInterleave=10;
    int sectorInterleave=10;
    enum filetype type=FT_PRG;
    char *filename=NULL;

    //printf("(%d,%d)=%x\n",0x1f,0x04, 256*linearSector(31,4));
    optind=opterr=0;
    while(1)
    {
	int i=getopt(argc,argv,"n:i:S:s:f:w:uqrdpxt45");
	if (i==-1)
	    break;

	switch(i)
	{
	    case '4':
		nrTracks=40;
		extraTracksBamOffset=0xac;
		break;
	    case '5':
		nrTracks=40;
		extraTracksBamOffset=0xc0;
		break;
	    case 'n':
		name=strdup(optarg);
		break;
	    case 'i':
		id=strdup(optarg);
		break;
	    case 'S':
		defaultSectorInterleave=atoi(optarg);
		sectorInterleave=defaultSectorInterleave;
		break;
	    case 's':
		sectorInterleave=atoi(optarg);
		break;
	    case 'f':
		if (filename) free(filename);
		filename=strdup(optarg);
		break;
	    case 'u':
		type = (type & FT_PROT) | FT_USR;
		break;
	    case 'q':
		type = (type & FT_PROT) | FT_SEQ;
		break;
	    case 'r':
		type = (type & FT_PROT) | FT_REL;
		break;
	    case 'p':
		type |= FT_PROT;
		break;
	    case 'd':
		files[nrFiles].filename = filename ?
		    filename : "----------------";
		files[nrFiles].localname = NULL;
		type = (type & FT_PROT) | FT_DEL;
		goto filedone_common;
	    case 'w':
		if (stat(optarg, &st)==0)
		{
		    files[nrFiles].localname=strdup(optarg);
		}
		else
		{
		    fprintf(stderr, "File '%s' not found, skipping...\n", optarg);
		}
		if (filename==NULL)
		    files[nrFiles].filename=files[nrFiles].localname;
		else
		files[nrFiles].filename=filename;

filedone_common:
		files[nrFiles].sectorInterleave=sectorInterleave;
		files[nrFiles].nrSectors=0;
		files[nrFiles].type=type;

		nrFiles++;

		filename=NULL;
		sectorInterleave=defaultSectorInterleave;
		type=FT_PRG;
		break;
	    case 'x':
		track18split=_false;
		break;
	    case 't':
		usetrack18=_true;
		break;
	    default:
		usage();
	}
    }

    if (optind!=argc-1)
	usage();
    else
	image=strdup(argv[optind]);


    // Clear image
    int diskSize = 174848;
    if (nrTracks>35)
	diskSize+=5*17*256;

    unsigned char *d64image = malloc(diskSize);
    memset(d64image,0,diskSize);

    // Write initial BAM
    int bam=linearSector(18,0)*256;
    d64image[bam+0x00]=18;
    d64image[bam+0x01]=1;
    d64image[bam+0x02]=0x40; /* write protection, default 0x41 */

    int t;
    for (t=1;t<=nrTracks;t++)
    {
	int s;
	for (s=0;s<sectorsPerTrack[t-1];s++)
	{
	    markSector(d64image, t, s, _true);
	}
    }

    int i;
    for (i=0;i<16;i++)
    {
	if (i<strlen(name))
	    d64image[bam+0x90+i]=name[i];
	else
	    d64image[bam+0x90+i]=0xa0;
    }

    d64image[bam+0xa0]=0xa0;
    d64image[bam+0xa1]=0xa0;

    for (i=0;i<5;i++)
    {
	if (i<strlen(id))
	    d64image[bam+0xa2+i]=id[i];
	else
	    d64image[bam+0xa2+i]=0xa0;
    }

    d64image[bam+0xa7]=0xa0;
    d64image[bam+0xa8]=0xa0;
    d64image[bam+0xa9]=0xa0;
    d64image[bam+0xaa]=0xa0;

    // Reserve space for BAM+directory
    markSector(d64image, 18, 0, _false);
    if (usetrack18)
    {
	printf("Tagging %d blocks on track 18 for directory structure\n", nrFiles/8+1);
	for (i=0; i<nrFiles/8+1; i++)
	    markSector(d64image, 18, i+1, _false);
    }

    // Write files and mark sectors in BAM
    int track=17;
    int sector=0;
    int bytes2write=0;
    int lastTrack=track;
    int lastSector=sector;
    int lastOffset=linearSector(lastTrack,lastSector)*256;

    for (i=0;i<nrFiles;i++)
    {
	if (files[i].localname == NULL) continue;

	struct stat st;
	stat(files[i].localname, &st);

	int fileSize=st.st_size;

	unsigned char *data=malloc(fileSize);
	FILE *f=fopen(files[i].localname, "rb");
	fread(data, fileSize, 1, f);
	fclose(f);

	int byteOffset=0;
	int bytesLeft=fileSize;
	while(bytesLeft>0)
	{
	    // Find free track&sector, starting from current T/S forward one revolution, then the next track etc... skip T18
	    // If the file didn't fit before track 18 then restart on track 19 and try again.
	    // If the file didn't fit before track 36 then the disk is full.

	    _bool found=_false;
	    int findSector=0;

	    while(!found)
	    {
		int s;
		for (s=sector;s<sector+sectorsPerTrack[track-1];s++)
		{
		    findSector=s%sectorsPerTrack[track-1];
		    if (isSectorFree(d64image, track, findSector))
		    {
			found=_true;
			break;
		    }
		}

		if (!found)
		{
		    if (track == 1) track = 19;
		    else if (track < 18) track--; else track++;
		    sector=0;
		    if (!usetrack18)
		    {
			if (track==18)
			{
			    // Delete old fragments and restart file
			    if (!track18split)
			    {
				if (files[i].nrSectors>0)
				{
				    int deltrack=files[i].track;
				    int delsector=files[i].sector;
				    while(deltrack!=0)
				    {
					markSector(d64image, deltrack, delsector, _true);
					int offset=linearSector(deltrack, delsector)*256;
					deltrack=d64image[offset+0];
					delsector=d64image[offset+1];
					memset(d64image+offset,0,256);
				    }
				}

				bytesLeft=fileSize;
				byteOffset=0;
				files[i].nrSectors=0;
			    }
			    track=19;
			}
		    }

		    if (track==nrTracks+1)
		    {
			fprintf(stderr, "Disk full!\n");
			exit(-1);
		    }
		}
	    }
	    sector=findSector;
	    int offset=linearSector(track,sector)*256;

	    if (bytesLeft==fileSize)
	    {
		files[i].track=track;
		files[i].sector=sector;
		lastTrack=track;
		lastSector=sector;
		lastOffset=offset;
	    }
	    else
	    {
		d64image[lastOffset+0]=track;
		d64image[lastOffset+1]=sector;
	    }

	    // Write sector
	    bytes2write=min(254, bytesLeft);
	    int j;
	    for (j=0;j<bytes2write;j++)
		d64image[offset+2+j]=data[j+byteOffset];

	    bytesLeft-=bytes2write;
	    byteOffset+=bytes2write;

	    lastTrack=track;
	    lastSector=sector;
	    lastOffset=offset;

	    markSector(d64image, track, sector, _false);
	    //lastByteOnSector[track-1][sector]=bytes2write+1;

	    sector+=files[i].sectorInterleave;
	    files[i].nrSectors++;
	}

	d64image[lastOffset+0]=0x00;
	d64image[lastOffset+1]=bytes2write+1;

	free(data);
    }

    // Create directory entries
    int curFile=0;
    int filesLeft=nrFiles;
    sector=1;
    int entryOnSector=0;
    while(filesLeft>0)
    {
	int entryOffset=linearSector(18,sector)*256 + entryOnSector*32;

	markSector(d64image, 18, sector, _false);

	if ((entryOnSector==0) && (filesLeft>8))
	{
	    d64image[entryOffset+0]=18;
	    d64image[entryOffset+1]=sector+1;
	}
	else
	{
	    d64image[entryOffset+0]=0;
	    d64image[entryOffset+1]=0;
	}

	d64image[entryOffset+2]=files[curFile].type;
	d64image[entryOffset+3]=files[curFile].track;	//Track
	d64image[entryOffset+4]=files[curFile].sector;	//Sector

	for (i=0;i<16;i++)
	{
	    if (i<strlen(files[curFile].filename))
		d64image[entryOffset+5+i]=files[curFile].filename[i];
	    else
		d64image[entryOffset+5+i]=0xa0;
	}

	d64image[entryOffset+0x1e]=files[curFile].nrSectors&255;	// lo size
	d64image[entryOffset+0x1f]=files[curFile].nrSectors>>8;	// hi size

	filesLeft--;
	curFile++;
	entryOnSector++;
	if (entryOnSector==8)
	{
	    sector++;
	    entryOnSector=0;
	}
    }

    printf("%s (%s,%s):\n", image, name,id);
    for (i=0;i<nrFiles;i++)
    {
	if (files[i].localname)
	    printf("%3d \"%s\" => \"%s\" (SL:%d)", files[i].nrSectors, files[i].localname, files[i].filename, files[i].sectorInterleave);
	else
	    printf("%3d [NO FILE] => \"%s\"", files[i].nrSectors, files[i].filename);
	int track=files[i].track;
	int sector=files[i].sector;
	int j=0;
	while(track!=0)
	{
	    if (j==0)
		printf("\n    ");
	    printf("%02d/%02d ",track,sector);
	    int offset=linearSector(track,sector)*256;
	    track=d64image[offset+0];
	    sector=d64image[offset+1];
	    j++;
	    if (j==10)
		j=0;
	}
	printf("\n");
    }

    int sectorsFree=0;
    int sectorsFreeOnTrack18=0;
    for (t=1;t<=nrTracks;t++)
    {
	int s;
	printf("%2d: ",t);
	for (s=0;s<sectorsPerTrack[t-1];s++)
	{
	    if (isSectorFree(d64image, t, s))
	    {
		printf("0");
		if (t!=18)
		    sectorsFree++;
		else
		    sectorsFreeOnTrack18++;
	    }
	    else
		printf("1");
	}
	printf("\n");
    }
    printf("%3d (%d) BLOCKS FREE\n", sectorsFree, sectorsFree+sectorsFreeOnTrack18);

    // Save image
    FILE *f=fopen(image, "wb");
    fwrite(d64image, diskSize, 1, f);
    fclose(f);

    free(d64image);

    return 0;
}

/* vim: et:si:ts=8:sts=4:sw=4
*/

