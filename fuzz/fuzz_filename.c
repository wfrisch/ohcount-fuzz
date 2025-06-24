#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include "structs.h"
#include "sourcefile.h"


int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  char* filepath = malloc(Size + 1);
  assert(filepath);
  strncpy(filepath, Data, Size);
  filepath[Size] = '\0';

  // reject unwanted input
  if (strlen(filepath) < 1) {
    return -1;
  }

  for (size_t i = 0; i < strlen(filepath); i++) {
    switch (filepath[i]) {
      case '\0':
      case '\n':
        return -1;
    }
  }

  printf("filepath: %s\n", filepath);

  SourceFile *sf = ohcount_sourcefile_new(filepath);
  sf->contents = strdup("<?php echo Hello ?>");
  sf->size = strlen(sf->contents);
  ohcount_sourcefile_parse(sf);
  ohcount_sourcefile_free(sf);

  free(filepath);

  return 0;
}

