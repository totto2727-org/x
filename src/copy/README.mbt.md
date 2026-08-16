# totto2727/x

Focused MoonBit utility packages for independent copying, typed filesystem paths, JSON flattening, and JSON conversion for upstream YAML and TOML values.

This document is canonical `README.mbt.md`; maintain `README.md` as the relative symlink `README.md -> README.mbt.md`.

## Usage

Use the package that owns the required utility. For example, `Copy::copy` produces an independent logical value:

```mbt check
///|
test {
  let source = [1, 2]
  let copied = Copy::copy(source)
  copied[0] = 3
  debug_inspect((source, copied), content="([1, 2], [3, 2])")
}
```

## Key features

- Explicit `Copy` semantics for scalars, collections, options, results, maps, and tuples
- Validated absolute and relative filesystem path value types
- Bounded JSON flattening and reconstruction with JSON Pointer or JavaScript-style paths
- Owned YAML and TOML wrappers with standard JSON conversion traits
- Checked examples and tests across each public package

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with the package version.

## Setup

Add the module to a MoonBit project:

```bash
moon add totto2727/x
```

Import the required package, such as `totto2727/x/copy`, `totto2727/x/path`, `totto2727/x/json`, `totto2727/x/yaml`, or `totto2727/x/toml`.

## API

The canonical API reference is the [`totto2727/x` documentation on Mooncakes](https://mooncakes.io/docs/totto2727/x). It covers the public declarations, implementations, constraints, errors, and examples for every published package.

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
