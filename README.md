# p4ott Syntax
* `p4.ott` contains the language syntax written in Ott. Since externs may modify parts of the state directly, the file also contains parts of the state syntax in order to make it self-contained.
* `p4Script.sml` contains a snapshot of the HOL4 export of the Ott file.
* The `examples` directory contains a HOL4 representation of the VSS example P4 program, as a suggestion for HOL4 output of a `.p4` parser.

## Dependencies
No dependencies are needed in order to generate any files. The following can be used in order to study them interactively:
* [Ott 0.31](https://github.com/ott-lang/ott/tree/0.31) can be used to perform the export from Ott to HOL4. Install using `opam install ott` (other versions should likely be fine).
* The export can be played with in [HOL4 (kananaskis-14)](https://github.com/HOL-Theorem-Prover/HOL/tree/kananaskis-14) - installation instructions can be found in the HOL4 repo README.

## Notes
There are quite a few differences between the P4 language as formalized in `p4ott` and the P4 language as described in the official specification. Most notably, `p4ott` tries to simplify statically determined parts of the program to as large a degree as possible.

Differences from the representation in the P4 specification:
* `p4ott` doesn't represent parser and control blocks (and functions, externs, actions et.c.) as a part of the language that is reduced by the semantics: rather, an association list with the programmable blocks is part of the static context. As a consequence, the topmost-level language construct is the statement
* Declarations of global constants is not handled by the semantics, but rather they start out as part of a global variable scope (note: undergoing changes)
* `p4ott` doesn't represent type polymorphism in functions et.c.
* `p4ott` doesn't represent type abbreviations
* `p4ott` doesn't distinguish between actions and functions
* `p4ott` gathers the declarations of a block in a separate list, removing the declare statement 
* ...

Furthermore, many language features have not been added yet or are in flux:
* signed arithmetic (also representation of signed bitstrings as needed)
* variable-length bitstrings
* casts
* sub-parsers
* enumeration types, et.c.
  * match_kind is not treated as a base type (as in version 1.2.3 of the spec)
  * `error` is not treated as a proper enumeration type
* header stacks and header unions in any form
* tuples
* Currently, the modular architecture model works with only a single package per architecture
* ...
