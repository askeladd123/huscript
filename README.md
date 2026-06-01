
A script that does calculations and investigates *buying vs. renting* in the Norwegian housing market.

This project serves two purposes:
- personal utility: helps me understand the housing market and make good decisions
- cli design: I use this as an opportunity to experiment with different command line interface methods

## run
If using `nix` with flakes, simply run:

```sh
nix develop -c nu -c '"general.years = 7" | nu --stdin run.nu crunch -c | from csv'
```

If not, you can find required dependencies in at `buildInputs` in `flake.nix`, and run `nu run.nu --help`.

## cli design
I am interested in how computer programs interoperate. Especially Command Line Interfaces (CLI), because these are simple to make, and have great potential.

**Background**
Many of the GNU/Linux *coreutils* work together with the help of piping. [Nushell](https://www.nushell.sh/) takes this a step further by:
- structured output: writing many *coreutils*-like and utility functions with structured output
- known format: makes it really easy to import, edit, pipe and export known formats like `json`, `yaml`, `toml` and `csv`

While *nushell* makes *input/output* formats stricter, the types and structures are still ambiguous. To enforce this, [json schema](https://json-schema.org/) can be used.

**Vision**
I am interested in multipe things:
- abstract configuration:
  - make it even easier to write *cli*s by unifying config files, cli flags, piped data and env vars into one abstraction
  - automatically merge this by some layering rules
- explicit input/output
  - a way for other programs to know structure and data types before calling

I hope to one day make my own schema language and cli library, but for now, I am just experimenting with what exists.

