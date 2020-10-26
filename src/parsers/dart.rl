/************************* Required for every parser *************************/
#ifndef OHCOUNT_DART_PARSER_H
#define OHCOUNT_DART_PARSER_H

#include "../parser_macros.h"

// the name of the language
const char *DART_LANG = LANG_DART;

// the languages entities
const char *dart_entities[] = {
  "space", "comment", "any"
};

// constants associated with the entities
enum {
  DART_SPACE = 0, DART_COMMENT, DART_ANY
};

/*****************************************************************************/

%%{
  machine dart;
  write data;
  include common "common.rl";

  # Line counting machine

  action dart_ccallback {
    switch(entity) {
    case DART_SPACE:
      ls
      break;
    case DART_ANY:
      code
      break;
    case INTERNAL_NL:
      std_internal_newline(DART_LANG)
      break;
    case NEWLINE:
      std_newline(DART_LANG)
    }
  }

  dart_line_comment =
    '//' @comment (
      escaped_newline %{ entity = INTERNAL_NL; } %dart_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )*;
  dart_block_comment =
    '/*' @comment (
      newline %{ entity = INTERNAL_NL; } %dart_ccallback
      |
      ws
      |
      (nonnewline - ws) @comment
    )* :>> '*/';
  dart_comment = dart_line_comment | dart_block_comment;

  dart_line := |*
    spaces    ${ entity = DART_SPACE; } => dart_ccallback;
    dart_comment;
    newline   ${ entity = NEWLINE; } => dart_ccallback;
    ^space    ${ entity = DART_ANY;   } => dart_ccallback;
  *|;

  # Entity machine
  # TODO: This is a placeholder and most entities are missing.

  action dart_ecallback {
    callback(DART_LANG, dart_entities[entity], cint(ts), cint(te), userdata);
  }

  dart_line_comment_entity = '//' (escaped_newline | nonnewline)*;
  dart_block_comment_entity = '/*' any* :>> '*/';
  dart_comment_entity = dart_line_comment_entity | dart_block_comment_entity;

  dart_entity := |*
    space+                 ${ entity = DART_SPACE;      } => dart_ecallback;
    dart_comment_entity    ${ entity = DART_COMMENT;    } => dart_ecallback;
    ^space;
  *|;
}%%

/************************* Required for every parser *************************/

/* Parses a string buffer with Dart code.
 *
 * @param *buffer The string to parse.
 * @param length The length of the string to parse.
 * @param count Integer flag specifying whether or not to count lines. If yes,
 *   uses the Ragel machine optimized for counting. Otherwise uses the Ragel
 *   machine optimized for returning entity positions.
 * @param *callback Callback function. If count is set, callback is called for
 *   every line of code, comment, or blank with 'lcode', 'lcomment', and
 *   'lblank' respectively. Otherwise callback is called for each entity found.
 */
void parse_dart(char *buffer, int length, int count,
             void (*callback) (const char *lang, const char *entity, int s,
                               int e, void *udata),
             void *userdata
  ) {
  init

  %% write init;
  cs = (count) ? dart_en_dart_line : dart_en_dart_entity;
  %% write exec;

  // if no newline at EOF; callback contents of last line
  if (count) { process_last_line(DART_LANG) }
}

#endif

/*****************************************************************************/