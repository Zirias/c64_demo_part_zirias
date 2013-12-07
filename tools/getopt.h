#ifndef GETOPT_H
#define GETOPT_H

extern int opterr;
extern int optind;
extern char *optarg;

int getopt(int nargc, char * const nargv[], const char *ostr);
 
#endif

/* vim: et:si:ts=8:sts=4:sw=4
*/
