#include <stdlib.h>
#include <stdio.h>
#include <netpbm.h>


static void usage(char *name)
{
  fprintf(stderr,"Usage: %s infile outfile\n",name);
  fprintf(stderr,"infile and outfile cannot be the same file.\n");
  exit(3);
}

int main(int argc, char **argv)
{
  rgbimage *color;
  grayimage *gray;
  //printf("%s\n", argv[1]);
  //printf("%s\n", argv[2]);
  color=read_color_image(argv[1]);
  gray=color_to_gray(color);
  write_grayscale_image(argv[2],gray);

  return 0;
}
