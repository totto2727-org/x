///|
test "panic_RingBuffer::RingBuffer - rejects zero capacity" {
  try! ((@ring_buffer.RingBuffer::RingBuffer(0) : @ring_buffer.RingBuffer[Int])
  |> ignore)
}

///|
test "panic_RingBuffer::RingBuffer - rejects negative capacity" {
  try! ((@ring_buffer.RingBuffer::RingBuffer(-1) : @ring_buffer.RingBuffer[Int])
  |> ignore)
}

///|
test "RingBuffer state - reports an empty fixed-capacity buffer" {
  let buffer : @ring_buffer.RingBuffer[Int] = @ring_buffer.RingBuffer(3)
  debug_inspect(
    (
      buffer.capacity(),
      buffer.length(),
      buffer.is_empty(),
      buffer.is_full(),
      buffer.peek(),
      buffer.peek_latest(),
      buffer.pop(),
    ),
    content="(3, 0, true, false, None, None, None)",
  )
}

///|
test "RingBuffer push - preserves insertion order before reaching capacity" {
  let buffer : @ring_buffer.RingBuffer[Int] = @ring_buffer.RingBuffer(3)
  buffer.push(1)
  buffer.push(2)
  debug_inspect(buffer.to_array(), content="[1, 2]")
}

///|
test "RingBuffer push - overwrites the oldest value when full" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=3)
  buffer.push(4)
  debug_inspect(
    (buffer.to_array(), buffer.length(), buffer.capacity(), buffer.is_full()),
    content="([2, 3, 4], 3, 3, true)",
  )
}

///|
test "RingBuffer push - keeps fixed capacity across repeated overwrites" {
  let buffer : @ring_buffer.RingBuffer[Int] = @ring_buffer.RingBuffer(3)
  for value in 0..<1000 {
    buffer.push(value)
  }
  debug_inspect(
    (buffer.to_array(), buffer.length(), buffer.capacity()),
    content="([997, 998, 999], 3, 3)",
  )
}

///|
test "RingBuffer pop - removes the oldest value" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=3)
  debug_inspect(buffer.pop(), content="Some(1)")
  debug_inspect(buffer.to_array(), content="[2, 3]")
}

///|
test "RingBuffer peek - observes oldest and newest values" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  debug_inspect(
    (buffer.peek(), buffer.peek_latest()),
    content="(Some(2), Some(4))",
  )
}

///|
test "RingBuffer from_iter - retains the newest values" {
  let buffer = @ring_buffer.RingBuffer::from_iter(
    [1, 2, 3, 4].iter(),
    capacity=2,
  )
  debug_inspect(buffer.to_array(), content="[3, 4]")
}

///|
test "RingBuffer get - uses logical insertion-order indices" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  debug_inspect(
    (buffer.get(-1), buffer.get(0), buffer.get(2), buffer.get(3)),
    content="(None, Some(2), Some(4), None)",
  )
}

///|
test "RingBuffer at and set - access logical insertion-order indices" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  inspect(buffer.at(0), content="2")
  buffer.set(1, 30)
  debug_inspect(buffer.to_array(), content="[2, 30, 4]")
}

///|
test "RingBuffer indexed operators - access logical insertion-order indices" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  inspect(buffer[0], content="2")
  buffer[1] = 30
  debug_inspect(buffer.to_array(), content="[2, 30, 4]")
}

///|
test "panic_RingBuffer at - rejects an out-of-range index" {
  let buffer = @ring_buffer.RingBuffer::from_array([1], capacity=1)
  buffer.at(1) |> ignore
}

///|
test "RingBuffer as_views - exposes wrapped storage in logical order" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=3)
  buffer.push(4)
  buffer.push(5)
  let (first, second) = buffer.as_views()
  debug_inspect(
    (first, second),
    content="(<ArrayView: [3]>, <ArrayView: [4, 5]>)",
  )
}

///|
test "RingBuffer iter - traverses values from oldest to newest" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  debug_inspect(buffer.iter().collect(), content="[2, 3, 4]")
}

///|
test "RingBuffer iter2 - traverses logical indices from oldest to newest" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  let entries : Array[(Int, Int)] = []
  buffer.eachi((index, value) => entries.push((index, value)))
  debug_inspect(entries, content="[(0, 2), (1, 3), (2, 4)]")
}

///|
test "RingBuffer reverse traversal - visits newest values first" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  debug_inspect(buffer.rev_iter().collect(), content="[4, 3, 2]")
}

///|
test "RingBuffer clear - removes values without changing capacity" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2], capacity=3)
  buffer.clear()
  debug_inspect(
    (buffer.to_array(), buffer.length(), buffer.capacity()),
    content="([], 0, 3)",
  )
}

///|
test "RingBuffer search - returns logical indices" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  debug_inspect(
    (buffer.contains(3), buffer.search(3), buffer.search(1)),
    content="(true, Some(1), None)",
  )
}

///|
test "RingBuffer binary_search - searches the logical value order" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 3, 5], capacity=3)
  debug_inspect(
    (
      buffer.binary_search(3),
      buffer.binary_search_by(value => value.compare(4)),
    ),
    content="(Ok(1), Err(2))",
  )
}

///|
test "RingBuffer copy - preserves capacity and detaches later mutations" {
  let source = @ring_buffer.RingBuffer::from_array([1, 2], capacity=3)
  let copied = source.copy()
  copied.push(3)
  debug_inspect(
    (source.to_array(), copied.to_array(), copied.capacity()),
    content="([1, 2], [1, 2, 3], 3)",
  )
}

///|
test "RingBuffer map - preserves capacity and logical order" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2], capacity=3)
  let mapped = buffer.map(value => value * 2)
  debug_inspect((mapped.to_array(), mapped.capacity()), content="([2, 4], 3)")
}

///|
test "RingBuffer mapi - maps logical indices and values" {
  let buffer = @ring_buffer.RingBuffer::from_array([2, 3], capacity=3)
  debug_inspect(
    buffer.mapi((index, value) => index + value).to_array(),
    content="[2, 4]",
  )
}

///|
test "RingBuffer filter - preserves matching values and capacity" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=4)
  let filtered = buffer.filter(value => value % 2 == 1)
  debug_inspect(
    (filtered.to_array(), filtered.capacity()),
    content="([1, 3], 4)",
  )
}

///|
test "RingBuffer retain - preserves matching values in order" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=4)
  buffer.retain(value => value >= 2)
  debug_inspect(buffer.to_array(), content="[2, 3]")
}

///|
test "RingBuffer retain_map - replaces and removes values in order" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3], capacity=4)
  buffer.retain_map(value => if value == 2 { None } else { Some(value * 10) })
  debug_inspect(buffer.to_array(), content="[10, 30]")
}

///|
test "RingBuffer join - joins strings in logical order" {
  let buffer = @ring_buffer.RingBuffer::from_array(["a", "b", "c"], capacity=3)
  inspect(buffer.join(","), content="a,b,c")
}

///|
test "RingBuffer traits - compare and hash the logical value sequence" {
  let first = @ring_buffer.RingBuffer::from_array([1, 2], capacity=2)
  let second = @ring_buffer.RingBuffer::from_array([1, 2], capacity=4)
  let later = @ring_buffer.RingBuffer::from_array([1, 3], capacity=2)
  debug_inspect(
    (first == second, first.compare(later), first.hash() == second.hash()),
    content="(true, -1, true)",
  )
}

///|
test "RingBuffer Compare::compare - orders different lengths before values" {
  let shorter = @ring_buffer.RingBuffer::from_array([2], capacity=2)
  let longer = @ring_buffer.RingBuffer::from_array([1, 0], capacity=2)
  inspect(shorter.compare(longer), content="-1")
}

///|
test "RingBuffer ToJson - serializes the logical value sequence" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2, 3, 4], capacity=3)
  inspect(buffer.to_json().stringify(), content="[2,3,4]")
}

///|
test "RingBuffer Debug - formats the logical value sequence" {
  let buffer = @ring_buffer.RingBuffer::from_array([1, 2], capacity=3)
  debug_inspect(buffer, content="<RingBuffer: [1, 2]>")
}
