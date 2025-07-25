/*

   upload.exe  --  Upload a file to a server using forms.


   DESCRIPTION

       This is a CGI program to upload one or more files to a WWW
       server, using standard HTML forms instead of FTP. It works with
       Netscape 3.0 and 4.0, and Internet Explorer 4.0.

       See the manpage for more information.

   AUTHOR

       Jeroen C. Kessels
       Internet Engineer
       mailto:jeroen@kessels.com       http://www.kessels.com/
       Tel: +31(0)654 744 702


   COPYRIGHT

       Jeroen C. Kessels
       9 december 2000


   VERSION 2.6

*/




#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#ifdef unix
#include <sys/stat.h>
#else
#include <io.h>
#ifdef _MSC_VER
#include <direct.h>
#else
#include <dir.h>
#endif
#endif
#include <time.h>




#ifdef unix
#define stricmp         strcasecmp
#define strnicmp        strncasecmp
#endif



#define COPYRIGHT  "<center><font size=6><b>Upload v2.6</b></font><br>&copy; 2000 <a href='http://www.kessels.com/'>Jeroen C. Kessels</a></center>\n<hr>"
#define NO   0
#define YES  1
#define MUST 2



/* Define DIRSEP, the character that will be used to separate directories. */
#ifdef unix
#define DIRSEP "/\\"
#else
#define DIRSEP "\\/"
#endif




/* Configuration parameters from the configuration file. */
char Root[BUFSIZ];
char FileMask[BUFSIZ];
int IgnoreSubdirs;
int OverWrite;
char LogFile[BUFSIZ];
char OkPage[BUFSIZ];
char OkUrl[BUFSIZ];
char BadPage[BUFSIZ];
char BadUrl[BUFSIZ];

char UpFileName[BUFSIZ];
int Debug;

long FileCount;
long ByteCount;
char LastFileName[BUFSIZ];




/* Translate character to lowercase. */
char clower(char c) {
  if ((c >= 'A') && (c <= 'Z')) return((c - 'A') + 'a');
  return(c);
  }




/* Compare a string with a mask, case-insensitive. If it matches then return
   YES, otherwise NO. The mask may contain wildcard characters '?' (any
   character) '*' (any characters). */
int MatchMask(char *String, char *Mask) {
  char *m;
  char *s;

  if (String == NULL) return NO;                /* Just to speed up things. */
  if (Mask == NULL) return NO;
  if (strcmp(Mask,"*") == 0) return YES;

  m = Mask;
  s = String;

  while ((*m != '\0') && (*s != '\0')) {
    if ((clower(*m) != clower(*s)) && (*m != '?')) {
      if (*m != '*') return NO;
      m++;
      if (*m == '\0') return YES;
      while (*s != '\0') {
        if (MatchMask(s,m) == YES) return YES;
        s++;
        }
      return NO;
      }
    m++;
    s++;
    }

  while (*m == '*') m++;
  if ((*s == '\0') && (*m == '\0')) return YES;
  return NO;
  }





/* Translate the URL separator '/' into the directory separator ('/' for
   UNIX, '\\' for DOS), making a proper pathname. */
void Url2Dir(char *Dir, char *Url) {
  char *p1;
  char *p2;

  p1 = Url;
  p2 = Dir;
  while (*p1 != '\0') {
    if (*p1 == '/') {
        *p2++ = *DIRSEP;
        p1++;
      } else {
        *p2++ = *p1++;
        }
    }
  *p2 = '\0';
  }




/* Return the last position in a string of any character from
   collection. The haystack string is scanned from end to begin until a
   character is found from the needle string. The pointer to the found
   character is returned, or NULL if not found. This subroutine is
   designed to find a directory separator in a path, where the directory
   separator can be '\\' (DOS) or '/' (UNIX). */
char *strrchrs(char *haystack,char *needle) {
  char *h_here;
  char *n_here;
  long h_length;

  if ((haystack == NULL) || (needle == NULL)) return(NULL);

  for (h_length = 0, h_here = haystack; *h_here != '\0'; h_here++, h_length++);
  while (h_length > 0) {
    h_here--;
    h_length--;
    n_here = needle;
    while (*n_here != '\0') {
      if (*n_here == *h_here) return(h_here);
      n_here++;
      }
    }

  return(NULL);
  }





/* Create all directories in the path. The permissions of the directory at
   From are used for the new directory, leave NULL for default permissions.
   If IsAdir=NO then the path points to a filename, otherwise it is a
   directoryname. */
void CreatePath(char *To, char *From, int IsAdir) {
#ifdef unix
  struct stat statbuf;
#endif
  char s1[BUFSIZ];
  char s2[BUFSIZ];
  char *p1;

  if (To == NULL) return;

  /* If the Path contains subdirectories, then strip the last directory and
     iterate. */
  strcpy(s1,To);
  if (From != NULL) {
      strcpy(s2,From);
    } else {
      *s2 ='\0';
      }
  p1 = strrchrs(s1,DIRSEP);
  if (p1 != NULL) {
    *p1 = '\0';
    p1 = strrchrs(s2,DIRSEP);
    if (p1 == NULL) p1 = s2;
    *p1 = '\0';
    CreatePath(s1,s2,YES);
    }

  /* Create the directory. */
  if (IsAdir == YES) {
#ifdef unix
    if ((From != NULL) && (*From != '\0') && (stat(From,&statbuf) == 0)) {
        mkdir(To,statbuf.st_mode & 0777);
      } else {
        mkdir(To,0755);
        }
#else
    if ((strlen(To) > 2) || (To[1] != ':')) mkdir(To);
#endif
    }
  }





/* Show the BadPage, with macro MESSAGE. */
void ShowBadPage(char *Message) {
  FILE *Fin;
  char Line[BUFSIZ];
  char s1[BUFSIZ];
  char *p1;

  if (*BadUrl != '\0') {
    fprintf(stdout,"Location: %s\n\n",BadUrl);
    return;
    }

  if (Debug == 0) fprintf(stdout,"Content-type: text/html\n\n");

  Fin = fopen(BadPage,"r");
  if (Fin == NULL) {
    fprintf(stdout,"<html>\n<body>\n",Message);
    if (*BadPage != '\0') {
      fprintf(stdout,"Error: could not open the BadPage: %s<p>\n",BadPage);
      fprintf(stdout,"The original error message was:<br>\n");
      }
    fprintf(stdout,"%s\n",Message);
    fprintf(stdout,"</body>\n</html>\n",Message);
    exit(0);
    }

  while (fgets(Line,BUFSIZ,Fin) != NULL) {
    p1 = Line;
    while (*p1 != '\0') {
      if (strnicmp(p1,"<insert message>",15) == 0) {
        *p1 = '\0';
        sprintf(s1,"%s%s%s",Line,Message,p1 + 16);
        strcpy(Line,s1);
        }
      p1++;
      }
    fprintf(stdout,"%s",Line);
    }

  exit(0);
  }




/* Write a line to the logging file. */
void WriteLogLine(char *Line) {
  FILE *Fout;
  char s1[BUFSIZ];
  time_t Now;

  if (*LogFile == '\0') return;

  Fout = fopen(LogFile,"a");
  if (Fout == NULL) {
    sprintf(s1,"I could not open the logfile: %s",LogFile);
    ShowBadPage(s1);
    }
  Now = time(NULL);
  strcpy(s1,ctime(&Now));
  s1[24] = '\0';
  fprintf(Fout,"%s %s\n",s1,Line);
  fclose(Fout);
  }




/* Show the OkPage, with statistics about the file. */
void ShowOkPage(void) {
  FILE *Fin;
  char Line[BUFSIZ];
  char s1[BUFSIZ];
  char *p1;

  if (*OkUrl != '\0') {
    fprintf(stdout,"Location: %s\n\n",OkUrl);
    return;
    }

  Fin = fopen(OkPage,"r");
  if (Fin == NULL) {
    sprintf(s1,"I could not open the OkPage: %s",OkPage);
    ShowBadPage(s1);
    }
  if (Debug == 0) fprintf(stdout,"Content-type: text/html\n\n");
  while (fgets(Line,BUFSIZ,Fin) != NULL) {
    p1 = Line;
    while (*p1 != '\0') {
      if (strnicmp(p1,"<insert filecount>",18) == 0) {
        *p1 = '\0';
        sprintf(s1,"%s%lu%s",Line,FileCount,p1 + 18);
        strcpy(Line,s1);
        }
      if (strnicmp(p1,"<insert bytecount>",18) == 0) {
        *p1 = '\0';
        sprintf(s1,"%s%lu%s",Line,ByteCount,p1 + 18);
        strcpy(Line,s1);
        }
      if (strnicmp(p1,"<insert lastfilename>",21) == 0) {
        *p1 = '\0';
        sprintf(s1,"%s%s%s",Line,LastFileName,p1 + 21);
        strcpy(Line,s1);
        }
      p1++;
      }
    fprintf(stdout,"%s",Line);
    }

  exit(0);
  }




/* Load the proper segment from the configuration file. */
void LoadConfig(char *ProgramPath, char *ConfigID) {
  FILE *Fin;
  char Path[BUFSIZ];
  char Line[BUFSIZ];
  char Name[BUFSIZ];
  char Value[BUFSIZ];
  int Accept;
  int NewDebug;
  char *p1;
  char *p2;

  strcpy(Path,ProgramPath);
  p1 = strrchrs(Path,"./\\");
  if (p1 != NULL) {
      strcpy(p1,".cfg");
    } else {
      strcat(Path,".cfg");
      }
  Fin = fopen(Path,"rt");
  if (Fin == NULL) {
    p1 = getenv("PATH");
    while ((p1 != NULL) && (*p1 != '\0')) {
      p2 = Value;
      while ((*p1 != '\0') && (*p1 != ';')) *p2++ = *p1++;
      *p2 = '\0';
      if (*p1 == ';') p1++;
      sprintf(Name,"%s%cupload.cfg",Value,*DIRSEP);
      Fin = fopen(Name,"rt");
      if (Fin != NULL) break;
      }
    }
  if (Fin == NULL) ShowBadPage("I could not open the configuration file.");

  if (Debug > 0) fprintf(stdout,"<center>\n");
  Accept = NO;
  NewDebug = Debug;
  while (fgets(Line,BUFSIZ,Fin) != NULL) {
    *Name = *Value = '\0';
    if (sscanf(Line,"%[^ \t=]%*[ \t=]%[^\n\r]",Name,Value) != 2) {
      sscanf(Line,"%*[ \t]%[^ \t=]%*[ \t=]%[^\n\r]",Name,Value);
      }
    if (stricmp(Name,"Config") == 0) {
      if (Accept == YES) {
        if (Debug > 0) fprintf(stdout,"</table>\n</center>\n<p>\n");
        if ((Debug == 0) && (NewDebug > 0)) {
          fprintf(stdout,"Content-type: text/html\n\n");
          fprintf(stdout,"<html>\n<head>\n");
          fprintf(stdout,"<meta http-equiv=expires content=\"0\">\n");
          fprintf(stdout,"</head>\n<body>\n");
          fprintf(stdout,"%s\n",COPYRIGHT);
          }
        Debug = NewDebug;
        return;
        }
      if ((ConfigID == NULL) || (*ConfigID == '\0')) {
          Accept = YES;
        } else {
          if (stricmp(ConfigID,Value) == 0) Accept = YES;
          }
      if (Debug > 0) {
        if (Accept == YES) {
          fprintf(stdout,"<h2>Loading configuration</h2>\"%s\"\n",Value);
          fprintf(stdout,"<table border=1>\n");
          }
        }
      continue;
      }
    if (Accept != NO) {
      if (Debug > 0) {
        fprintf(stdout,"<tr><td>%s</td><td>%s</td></tr>\n",Name,Value);
        }
      if (stricmp(Name,"Debug") == 0) NewDebug = atoi(Value);
      if (stricmp(Name,"Root") == 0) {
        Url2Dir(Root,Value);
        p1 = strchr(Root,'\0');
        if (p1 != Root) p1--;
        if ((p1 != Root) && (strchr(DIRSEP,*p1) == NULL)) {
          p1++;
          *p1++ = *DIRSEP;
          *p1 = '\0';
          }
        }
      if (stricmp(Name,"FileMask") == 0) strcpy(FileMask,Value);
      if (stricmp(Name,"LogFile") == 0) Url2Dir(LogFile,Value);
      if (stricmp(Name,"OkPage") == 0) Url2Dir(OkPage,Value);
      if (stricmp(Name,"OkUrl") == 0) strcpy(OkUrl,Value);
      if (stricmp(Name,"BadPage") == 0) Url2Dir(BadPage,Value);
      if (stricmp(Name,"BadUrl") == 0) strcpy(BadUrl,Value);
      if (stricmp(Name,"OverWrite") == 0) {
        if (stricmp(Value,"no") == 0) OverWrite = NO;
        if (stricmp(Value,"yes") == 0) OverWrite = YES;
        if (stricmp(Value,"must") == 0) OverWrite = MUST;
        }
      if (stricmp(Name,"IgnoreSubdirs") == 0) {
        if (stricmp(Value,"no") == 0) IgnoreSubdirs = NO;
        if (stricmp(Value,"yes") == 0) IgnoreSubdirs = YES;
        }
      }
    }
  if (Debug > 0) {
    if (Accept == YES) {
        fprintf(stdout,"</table>\n</center>\n<p>\n");
      } else {
        fprintf(stdout,
          "</center>\nConfiguration \"%s\" not found, using defaults instead.<p>\n",
          ConfigID);
        }
    }
  if ((Debug == 0) && (NewDebug > 0)) {
    fprintf(stdout,"Content-type: text/html\n\n");
    fprintf(stdout,"<html>\n<head>\n");
    fprintf(stdout,"<meta http-equiv=expires content=\"0\">\n");
    fprintf(stdout,"</head>\n<body>\n");
    fprintf(stdout,"%s\n",COPYRIGHT);
    }
  Debug = NewDebug;
  }





/* Skip a line in the input stream. */
void SkipLine(char **Input,            /* Pointer into the incoming stream. */
    long *InputLength) {              /* Bytes left in the incoming stream. */

  while ((**Input != '\0') && (**Input != '\r') && (**Input != '\n')) {
    *Input = *Input + 1;
    *InputLength = *InputLength - 1;
    }
  if (**Input == '\r') {
    *Input = *Input + 1;
    *InputLength = *InputLength - 1;
    }
  if (**Input == '\n') {
    *Input = *Input + 1;
    *InputLength = *InputLength - 1;
    }
  }





/* Accept a single segment from the incoming mime stream. Each field in the
   form will generate a mime segment. Return a pointer to the beginning of
   the Boundary, or NULL if the stream is exhausted. */
void AcceptSegment(char **Input,            /* Pointer into the incoming stream. */
    long *InputLength,                /* Bytes left in the incoming stream. */
    char *Boundary,             /* Character string that delimits segments. */
    char *ProgramPath) {
  char FieldName[BUFSIZ];            /* Name of the variable from the form. */
  char FileName[BUFSIZ];          /* The filename, as selected by the user. */
  char *ContentStart;                       /* Pointer to the file content. */
  char *ContentEnd;
  char ContentAsString[BUFSIZ];
  long ContentLength;                          /* Bytecount of the content. */
  char Key1[BUFSIZ];
  char Key2[BUFSIZ];
  char Path[BUFSIZ];
  FILE *Fout;
  long Result;
  char s1[BUFSIZ];
  char *p1;
  int i;

  /* The input stream should begin with a Boundary line. Error-exit if not
     found. */
  if (strncmp(*Input,Boundary,strlen(Boundary)) != 0) {
    sprintf(s1,"Missing boundary in input.");
    WriteLogLine(s1);
    ShowBadPage(s1);
    }

  /* Skip the Boundary line. */
  *Input = *Input + strlen(Boundary);
  *InputLength = *InputLength - strlen(Boundary);
  SkipLine(Input,InputLength);

  /* Return NULL if the stream is exhausted (no more segments). */
  if ((**Input == '\0') || (strncmp(*Input,"--",2) == 0)) {
    *InputLength = 0;
    return;
    }

  /* The first line of a segment must be a "Content-Disposition" line. It
     contains the fieldname, and optionally the original filename. Error-exit
     if the line is not recognised. */
  if (sscanf(*Input,"%[^:]: %[^;]; name=\"%[^\"]\"; filename=\"%[^\"]\"",
      Key1,Key2,FieldName,FileName) != 4) {
    *FileName = '\0';
    if (sscanf(*Input,"%[^:]: %[^;]; name=\"%[^\"]\"",Key1,Key2,
        FieldName) != 3) {
      *FieldName = '\0';
      if (sscanf(*Input,"%[^:]: %[^;]; filename=\"%[^\"]\"",Key1,Key2,
          FileName) != 3) {
        sscanf(*Input,"%[^\r\n]",Key1);
        sprintf(s1,"Disposition line not recognised: %s",Key1);
        WriteLogLine(s1);
        ShowBadPage(s1);
        }
      }
    }
  if (stricmp(Key1,"content-disposition") != 0) {
    sprintf(s1,"\"Content-Disposition\" expected, but I got \"%s\" instead.",
      Key1);
    WriteLogLine(s1);
    ShowBadPage(s1);
    }
  if (stricmp(Key2,"form-data") != 0) {
    sprintf(s1,"\"form-data\" expected, but I got \"%s\" instead.",Key2);
    WriteLogLine(s1);
    ShowBadPage(s1);
    }

  /* Skip the Disposition line and one or more mime lines, until an empty
     line is found. */
  SkipLine(Input,InputLength);
  while ((**Input != '\r') && (**Input != '\n')) SkipLine(Input,InputLength);
  SkipLine(Input,InputLength);

  /* The following data in the stream is binary. The Boundary string is the
     end of the data. There may be a CRLF just before the Boundary, which
     must be stripped. */
  ContentStart = *Input;
  ContentLength = 0;
  while ((*InputLength > 0) && (memcmp(*Input,Boundary,strlen(Boundary)) != 0)) {
    *Input = *Input + 1;
    *InputLength = *InputLength - 1;
    ContentLength = ContentLength + 1;
    }
  ContentEnd = *Input - 1;
  if ((ContentLength > 0) && (*ContentEnd == '\n')) {
    ContentEnd--;
    ContentLength = ContentLength - 1;
    }
  if ((ContentLength > 0) && (*ContentEnd == '\r')) {
    ContentEnd--;
    ContentLength = ContentLength - 1;
    }
  i = BUFSIZ - 1;
  if (ContentLength < i) i = ContentLength;
  strncpy(ContentAsString,ContentStart,i);
  ContentAsString[i] = '\0';

  if (ContentEnd) {};                                 /* Keep lint happy... */

  /* Show debugging information. */
  if (Debug > 0) {
    fprintf(stdout,"<tr>\n");
    fprintf(stdout,"  <td valign=top rowspan=2>");
    if (*FieldName != '\0') fprintf(stdout,"%s",FieldName);
    fprintf(stdout,"</td>\n");
    fprintf(stdout,"  <td valign=top>");
    if (*FileName != '\0') {
        fprintf(stdout,"%s",FileName);
      } else {
        fprintf(stdout,"%s",ContentAsString);
        }
    fprintf(stdout,"</td>\n");
    fprintf(stdout,"  <td valign=top>%ld</td>\n",ContentLength);
    fprintf(stdout,"  </tr>\n");
    }

  /* If this field is the "Config" field, then load the configuration and
     leave. */
  if ((stricmp(FieldName,"Config") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    if (Debug > 0) fprintf(stdout,"<tr><td colspan=2>");
    LoadConfig(ProgramPath,ContentAsString);
    if (Debug > 0) fprintf(stdout,"</td></tr>\n");
    return;
    }

  /* If this field is the "FileName" field, then store it and leave. */
  if ((stricmp(FieldName,"FileName") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    strcpy(UpFileName,ContentAsString);
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>New filename stored.</td></tr>\n");
      }
    return;
    }

  /* If this field is the "OkPage" field, then store it and leave. */
  if ((stricmp(FieldName,"OkPage") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    Url2Dir(OkPage,ContentAsString);
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>New OkPage stored.</td></tr>\n");
      }
    return;
    }

  /* If this field is the "OkUrl" field, then store it and leave. */
  if ((stricmp(FieldName,"OkUrl") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    strcpy(OkUrl,ContentAsString);
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>New OkUrl stored.</td></tr>\n");
      }
    return;
    }

  /* If this field is the "BadPage" field, then store it and leave. */
  if ((stricmp(FieldName,"BadPage") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    Url2Dir(BadPage,ContentAsString);
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>New BadPage stored.</td></tr>\n");
      }
    return;
    }

  /* If this field is the "BadUrl" field, then store it and leave. */
  if ((stricmp(FieldName,"BadUrl") == 0) &&
      (*FileName == '\0') &&
      (*ContentStart != '\0')) {
    strcpy(BadUrl,ContentAsString);
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>New BadUrl stored.</td></tr>\n");
      }
    return;
    }

  /* Do nothing if this is not a file, but some other kind of field. */
  if ((FileName == NULL) || (*FileName == '\0')) {
    if (Debug > 0) {
      fprintf(stdout,"<tr><td colspan=2>FieldName not recognised.</td></tr>\n");
      }
    return;
    }

  /* Determine the filename to store the file. If the UpFileName field was
     defined then use it, otherwise use the name of the incoming file. The
     ROOT is always prepended. */
  if (*UpFileName == '\0') strcpy(UpFileName,FileName);
  if (IgnoreSubdirs == YES) {
    p1 = strrchrs(UpFileName,DIRSEP);
    if (p1 != NULL) {
      p1++;
      strcpy(UpFileName,p1);
      }
    }
  sprintf(Path,"%s%s",Root,UpFileName);

  /* Test if the filename matches the mask. */
  if (MatchMask(Path,FileMask) == NO) {
    sprintf(s1,
      "The file is rejected because it does not match the mask.<br>Filename: %s<br>Mask: %s",
      Path,FileMask);
    WriteLogLine(s1);
    ShowBadPage(s1);
    }

  /* Test if the file already exists. */
  if (OverWrite != YES) {
    Fout = fopen(Path,"r");
    if ((OverWrite == NO) && (Fout != NULL)) {
      fclose(Fout);
      sprintf(s1,
        "The file could not be uploaded because it already exists.<br>Filename: %s",
        Path);
      WriteLogLine(s1);
      ShowBadPage(s1);
      }
    if ((OverWrite == MUST) && (Fout == NULL)) {
      sprintf(s1,
        "The file could not be uploaded because it does not exist already.<br>Filename: %s",
        Path);
      WriteLogLine(s1);
      ShowBadPage(s1);
      }
    if (Fout != NULL) fclose(Fout);
    }

  /* If needed then create directories for the file. */
  CreatePath(Path,NULL,NO);

  /* Open the file for writing. */
#ifndef unix
  Fout = fopen(Path,"w");
#else
  Fout = fopen(Path,"wb");
#endif
  if (Fout == NULL) {
    sprintf(s1,
      "The file could not be uploaded because write permission is denied.<br>Filename: %s",
      Path);
    WriteLogLine(s1);
    ShowBadPage(s1);
    }
#ifndef unix
  setmode(fileno(Fout),O_BINARY);
#endif

  /* Write the file to disk. */
  Result = fwrite(ContentStart,1,ContentLength,Fout);
  fclose(Fout);

  /* If the wrong number of bytes were written to disk, then show an error
     message. */
  if (Result != ContentLength) {
    sprintf(s1,
      "The wrong number of bytes were written.<br>Written: %ld<br>Bytes in input: %ld",
      Result,ContentLength);
    WriteLogLine(s1);
    ShowBadPage(s1);
    }

  /* Show debugging information. */
  if (Debug > 0) {
    fprintf(stdout,"<tr>\n");
    fprintf(stdout,"  <td colspan=2>File written: %s</td>\n",Path);
    fprintf(stdout,"  </tr>\n");
    }

  FileCount = FileCount + 1;
  ByteCount = ByteCount + ContentLength;
  strcpy(LastFileName,UpFileName);

  sprintf(s1,"File uploaded succesfully: %s (%lu bytes)",
    UpFileName,ContentLength);
  WriteLogLine(s1);

  /* Clear the filename. */
  *UpFileName = '\0';

  return;
  }





int main(int argc, char *argv[], char *environment[]) {
  char *Method;           /* Pointer to REQUEST_METHOD environment variable. */
  char *ContentLength;    /* Pointer to CONTENT_LENGTH environment variable. */
  char *ContentType;        /* Pointer to CONTENT_TYPE environment variable. */
  long InCount;                    /* The supposed number of incoming bytes. */
  long RealCount;                        /* Actual number of incoming bytes. */
  char *Content;                           /* Copy in memory of the Content. */
  char *Here;                                  /* Position into the Content. */
  char Boundary[BUFSIZ];            /* The boundary string between segments. */

  char Char;
  long MoreCount;
  char *p1;
  char s1[BUFSIZ];

  if (argc > 1) {
    fprintf(stdout,"Error: %s is a cgi program, and should not be ",argv[0]);
    fprintf(stdout,"started from the command line.\n");
    exit(1);
    }

  *Root = '\0';                                          /* Setup defaults. */
  strcpy(FileMask,"*");
  IgnoreSubdirs = YES;
  OverWrite = YES;
  *LogFile = '\0';
  *OkPage = '\0';
  *OkUrl = '\0';
  *BadPage = '\0';
  *BadUrl = '\0';
  Debug = 0;
  *UpFileName = '\0';
  FileCount = 0;
  ByteCount = 0;
  *LastFileName = '\0';

  if (environment) {};                                /* Keep lint() happy. */

  if (Debug > 0) {
    fprintf(stdout,"Content-type: text/html\n\n");
    fprintf(stdout,"<html>\n<head>\n");
    fprintf(stdout,"<meta http-equiv=expires content=\"0\">\n");
    fprintf(stdout,"</head>\n<body>\n");
    fprintf(stdout,"%s\n",COPYRIGHT);
    }

  LoadConfig(argv[0],"");                    /* Load default configuration. */

  /* Test if the program was started by a METHOD=POST form. */
  Method = getenv("REQUEST_METHOD");
  if ((Method == NULL) || (*Method == '\0') || (stricmp(Method,"post") != 0)) {
    ShowBadPage("Sorry, this program only supports METHOD=POST.");
    }
  if (Debug > 0) fprintf(stdout,"<center><h2>Loading input</h2></center>\n",Method);
  if (Debug > 0) fprintf(stdout,"Method = %s<br>\n",Method);

  /* Test if the program was started with ENCTYPE="multipart/form-data". */
  ContentType = getenv("CONTENT_TYPE");
  if ((ContentType == NULL) ||
      (strnicmp(ContentType,"multipart/form-data; boundary=",30) != 0)) {
    ShowBadPage("Sorry, this program only supports ENCTYPE=\"multipart/form-data\".");
    }
  if (Debug > 0) fprintf(stdout,"Enctype = %s<br>\n",ContentType);

  /* Determine the Boundary, the string that separates the segments in the
     stream. The boundary is available from the CONTENT_TYPE environment
     variable. */
  Here = strchr(ContentType,'=') + 1;
  sprintf(Boundary,"--%s",Here);
  if (Debug > 0) fprintf(stdout,"Boundary = %s<br>\n",Boundary);

  /* Get the total number of bytes in the input stream from the
     CONTENT_LENGTH environment variable. */
  ContentLength = getenv("CONTENT_LENGTH");
  if (ContentLength == NULL) {
    WriteLogLine("Error: no CONTENT_LENGTH found.");
    ShowBadPage("Error: no CONTENT_LENGTH found.");
    }
  InCount = atol(ContentLength);
  if (InCount == 0) {
    WriteLogLine("Error: CONTENT_LENGTH is zero.");
    ShowBadPage("Error: CONTENT_LENGTH is zero.");
    }
  if (Debug > 0) fprintf(stdout,"Content_Length = %d<br>\n",InCount);

  /* Allocate sufficient memory for the incoming data. */
  Content = (char *)malloc(InCount + 1);
  if (Content == NULL) {
    WriteLogLine("Error: malloc() returned NULL.");
    ShowBadPage("Error: malloc() returned NULL.");
    }

  /* Load the data from standard input into memory. */
#ifndef unix
  setmode(fileno(stdin),O_BINARY);      /* Make sure the input is binary... */
#endif
  p1 = Content;
  RealCount = 0;
  /* For some reason fread() of Borland C 4.52 barfs if the bytecount is
     bigger than 2.5Mb, so I have to do it like this. */
  while (fread(p1++,1,1,stdin) == 1) {
    RealCount++;
    if (RealCount >= InCount) break;
    }
  *p1 = '\0';
  /* Ignore any extra caracters. We have to read them, or the server
     will give an error message. */
  if (RealCount < InCount) {
    MoreCount = InCount - RealCount;
    while ((MoreCount > 0) && (fread(&Char,1,1,stdin) == 1)) MoreCount--;
    }
  if (RealCount != InCount) {
    free(Content);
    sprintf(s1,
      "Error: The number of bytes received (%ld) is not what the CONTENT_LENGTH environment variable says it sould be (%ld).",
      RealCount + MoreCount, InCount);
    WriteLogLine(s1);
    ShowBadPage(s1);
    return(0);
    }
  if (Debug > 0) fprintf(stdout,"Input succesfully loaded into memory.<br>\n");

  /* Handle all segments in the incoming data, that has been stored in
     memory. */
  Here = Content;
  if (Debug > 0) {
    fprintf(stdout,"<p>\n<center>\n<h2>Parsing input</h2>\n");
    fprintf(stdout,"<table border=1>\n");
    fprintf(stdout,"<tr>\n");
    fprintf(stdout,"  <th>Fieldname</th>\n");
    fprintf(stdout,"  <th>Contents</th>\n");
    fprintf(stdout,"  <th>Size</th>\n");
    fprintf(stdout,"  </tr>\n");
    }
  while (RealCount > 0) AcceptSegment(&Here,&RealCount,Boundary,argv[0]);
  if (Debug > 0) fprintf(stdout,"</table>\n</center>\n");

  /* Cleanup. */
  free(Content);

  if (*LastFileName == '\0') ShowBadPage("You have not specified a file, so nothing was uploaded.");

  /* Display the OkPage. */
  if (Debug > 0) {
    fprintf(stdout,"<p><center><h2>Finished</h2></center>\n");
    }
  ShowOkPage();
  return(0);
  }


/*
Ideeen:

- Multiple filemasks.
- Maximum directory size.
- Maximum and Minimum file size.
- Result-macros as parameters to OkUrl.

*/
