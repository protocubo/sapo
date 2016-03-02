# Compiler flags in use

Certain compiler flags are used to customize, at compile time, the build of
certain subsystems.

To use an hypothetical flag `foo`, add `-D foo` to the command line options or
`.hxml` file – or use the corresponding UI in your IDE – and check for it with
`#if foo #else #end`.

Note that hyphens in flag names automatically become underscores in Haxe code.

## Tracing and debug

**-D trace-sqlite**: trace all requests made to SQLite databases (SAPO only)

