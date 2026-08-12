# totto2727/x

Focused utility traits and value types for MoonBit.

Copy is provided by the `totto2727/x/copy` package.

Typed absolute and relative filesystem paths are provided by the `totto2727/x/path` package.

JSON conversion for `moonbit-community/yaml` is provided by the `totto2727/x/yaml` package. MoonBit does not allow a foreign trait to be implemented for a foreign type, so the package exposes an owned `Yaml` wrapper with standard `FromJson` and `ToJson` implementations. Construct `@x_yaml.Yaml(upstream_value)` before encoding and use the wrapper's public `value` field to recover the upstream value after decoding. JSON values are converted to equivalent flat YAML values; integer JSON number syntax becomes `Yaml::Integer`, while other numbers become `Yaml::Real`. YAML `inf` and `nan` reals abort `ToJson` conversion, and non-finite JSON numbers fail `FromJson`, because JSON cannot represent non-finite numbers.

JSON conversion for `bobzhang/toml` is provided by the `totto2727/x/toml` package through the same owned-wrapper pattern. Its `TomlValue` wrapper implements standard `FromJson` and `ToJson` and represents tables, arrays, strings, finite numbers, and booleans as their natural JSON equivalents. Construct `@x_toml.TomlValue(upstream_value)` before encoding and use the wrapper's public `value` field after decoding. TOML date-time variants are flattened to their stored date strings. Converting those strings back from JSON produces `TomlString`, so date-time type information is intentionally not restored. JSON `null` and heterogeneous arrays are rejected because TOML has no corresponding valid value. TOML `inf` and `nan` floats abort `ToJson` conversion, and non-finite JSON numbers fail `FromJson`, because JSON cannot represent non-finite numbers.

MoonBit does not move values when they are passed to a function, so this package is not a marker for Rust-style move semantics. `Copy::copy` instead creates an independent logical copy. Composite implementations recursively copy their contents, while immutable storage may be shared when it cannot expose mutation.

`Copy` has no blanket or default implementation. Every custom type must explicitly define how its independent logical copy is constructed so mutable fields and collections cannot be shared accidentally.

## Generic copying

Use a `Copy` bound when an operation must produce a logically independent value:

```mbt check
fn[T : Copy] duplicate(value : T) -> (T, T) {
  (Copy::copy(value), Copy::copy(value))
}

test {
  debug_inspect(duplicate(42), content="(42, 42)")
}
```

The package implements `Copy` for primitive and immutable scalar values, `Option`, `Result`, `Array`, `FixedArray`, `ReadOnlyArray`, `Map`, and two- and three-element tuples. Composite implementations require their contained values to implement `Copy`; map keys must also implement `Hash` and `Eq`.

## Custom mutable values

Mutable types define their own copy policy:

```mbt check
struct Counter {
  mut value : Int
}

impl Copy for Counter with fn copy(self) {
  Counter::{ value: self.value }
}

test {
  let source = Counter::{ value: 1 }
  let copied = Copy::copy(source)
  copied.value = 2
  debug_inspect((source.value, copied.value), content="(1, 2)")
}
```

MoonBit's trait syntax and generic trait bounds are documented in the [official Method and Trait reference](https://docs.moonbitlang.com/en/latest/language/methods.html).

## Typed paths

`AbsolutePath` and `RelativePath` normalize `moonbitlang/x/path.Path` values and validate their path form at construction. Their inner `Path` remains available through the public readonly `path` field.

```mbt check
let root = @typed_path.AbsolutePath(@path.Path("/workspace/./project"))
let source = @typed_path.RelativePath(@path.Path("src/../README.md"))
let readme = @typed_path.Path::join(root, source)
println(@typed_path.Path::to_string(readme))
```

Both types encode to a JSON string and decode through their validating constructors.
