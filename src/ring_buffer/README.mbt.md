# totto2727/x/ring_buffer

Provides a fixed-capacity FIFO collection that retains the newest values without growing after construction. See the [module README](../../README.mbt.md#setup) for consumer setup and package imports.

## Usage

Retain the three most recent measurements while consuming them in insertion order.

```mbt check
///|
test {
  let measurements : RingBuffer[Int] = RingBuffer::RingBuffer(3)
  for value in [10, 20, 30, 40] {
    measurements.push(value)
  }
  debug_inspect(measurements.peek(), content="Some(20)")
  debug_inspect(measurements.to_array(), content="[20, 30, 40]")
}
```

## Package behavior

- Fixed positive capacity established at construction
- FIFO `push`, `pop`, and `peek` operations without directional terminology
- Oldest-value overwrite when a full buffer receives a new value
- Logical-order iterators, indexing, array copies, and zero-copy split views
- No arbitrary position-based insertion or removal, reordering, capacity changes, or multi-buffer operations that would weaken FIFO ring-buffer semantics
- Order-preserving predicate-based `retain` and `retain_map` transformations
- No nested collection or `FromJson` operations whose resulting fixed capacity would be ambiguous

## API

[Mooncakes API reference](https://mooncakes.io/docs/totto2727/x/ring_buffer)

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
