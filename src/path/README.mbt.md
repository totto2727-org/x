# totto2727/x/path

Provides normalized absolute and relative filesystem path value types that preserve their form through parsing, joining, and JSON conversion. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## Usage

Resolve a relative source path against a workspace while normalizing parent-directory segments.

```mbt check
///|
test {
  let base = @path.AbsolutePath::from_string("/workspace/project")
  let child = @path.RelativePath::from_string("src/../README.md")
  assert_eq(
    @path.Path::join(base, child).to_string(),
    "/workspace/project/README.md",
  )
}
```

## Package behavior

- Separates normalized absolute and relative path forms at construction.
- Permits joins only with validated `RelativePath` values.
- Encodes values as normalized JSON strings and rejects mismatched forms on decoding.

## Migrate from 0.10

In version 0.11, the `AbsolutePath` and `RelativePath` constructors accept `moonbitlang/core/path.Path` instead of `moonbitlang/x/path.Path`.
The public `.path` fields return the standard-library type as well.
Update the import in `moon.pkg` if you use the underlying `Path` directly.
Calls to `from_string`, `join`, and the JSON conversion traits do not change.

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/path)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
