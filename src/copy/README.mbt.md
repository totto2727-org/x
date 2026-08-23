# totto2727/x/copy

Defines explicit logical-copy behavior for built-in MoonBit values and downstream types that need an independent mutable result. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## Usage

Copy a mutable collection before changing it so the original value remains available for comparison or reuse.

```mbt check
///|
test {
  let source = [1, 2]
  let copied = Copy::copy(source)
  copied[0] = 3
  debug_inspect((source, copied), content="([1, 2], [3, 2])")
}
```

## Package behavior

- Built-in implementations for scalars, collections, options, results, maps, and tuples
- Recursive copying for composite values
- An open trait for downstream value types to define their own semantics

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/copy)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
