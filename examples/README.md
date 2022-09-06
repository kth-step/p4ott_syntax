Note that the definitions cannot be opened interactively as-is in HOL4 without `p4_coreTheory`, `p4_vssTheory` and some word-related definitions not in this repo. If it is not enough to just visually inspect them, you can cut out the RHS of the definitions and place it in double backticks, like so: ``` ``RHS`` ```, then open it interactively.

The definitions in the example have type annotations on top level: this is to avoid overgeneralizations (in particular for the `ext_map` in this example).
