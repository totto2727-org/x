# totto2727/x/copy

Defines explicit logical-copy behavior for built-in MoonBit values and downstream types that need an independent mutable result.

## Usage

`Copy::copy` produces an independent logical value according to its implementation's copy policy:

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

- Built-in implementations for scalars, collections, options, results, maps, and tuples
- Recursive copying for composite values
- An open trait for downstream value types to define their own semantics

## Prerequisites

- **MoonBit**: Use a current stable toolchain compatible with the package version.

## Setup

1. Add the module to a MoonBit project.

```bash
moon add totto2727/x
```

2. Import `totto2727/x/copy` and call `Copy::copy` for a type with a `Copy` implementation.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/copy)

## Development

For repository structure and development commands, see [AGENTS.md](../../AGENTS.md). For the complete module overview, see [the root README](../../README.mbt.md).

## License

[MIT](../../LICENSE)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
