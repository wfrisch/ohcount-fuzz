#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include "structs.h"
#include "sourcefile.h"


int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  char* filename = getenv("FUZZ_FILENAME");
  assert(filename);
  char* ext = strrchr(filename, '.');
  if (ext) {
    ext++;
  } else {
    ext = "";
  }

  SourceFile *sf = malloc(sizeof(SourceFile));
  sf->filepath = strdup(filename);
  sf->dirpath = 0;
  sf->filename = filename;
  sf->ext = ext;
  sf->diskpath = 0;

  sf->contents = malloc(Size + 1);
  assert(sf->contents);
  memcpy(sf->contents, Data, Size);
  sf->contents[Size] = '\0';
  sf->size = Size;

  sf->language = NULL;
  sf->language_detected = 0;
  sf->parsed_language_list = NULL;
  sf->license_list = NULL;
  sf->loc_list = NULL;
  sf->filenames = NULL;

  ohcount_sourcefile_parse(sf);
  ohcount_sourcefile_free(sf);

  return 0;
}

