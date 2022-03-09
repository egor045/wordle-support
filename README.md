# wordle-support
Wordle helper shell script

## Usage
```
wordle-support.sh [-i characters_to_include] [-x characters_to_exclude] [-f dictionary_file] [-d] pattern
  pattern:       Placed characters (green). Use '.' for unknown characters
  -i characters: Unplaced characters that appear in the solution (yellow)
  -x characters: Characters that must not appear in the solution
  -f file:       Dictionary file (default: /usr/share/dict/words)
  -d:            Debug mode
```
