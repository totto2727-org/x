///|
/// A failure raised while constructing a fixed-capacity ring buffer.
pub(all) suberror RingBufferError {
  /// The requested capacity was zero or negative.
  InvalidCapacity(Int)
} derive(Eq, Debug)

///|
/// A fixed-capacity FIFO collection that overwrites its oldest value when full.
///
/// The representation is private so callers cannot bypass the fixed-capacity
/// and insertion-order invariants through directional deque operations.
/// Arbitrary position-based insertion or removal, reordering, capacity changes,
/// and multi-buffer operations are intentionally excluded from the public API.
/// Predicate-based retain operations remain available because they preserve
/// the relative insertion order of every retained value.
/// Nested collection operations and `FromJson` are also excluded because a
/// fixed capacity cannot be inferred for their resulting buffers.
pub struct RingBuffer[A] {
  priv deque : @deque.Deque[A]
}

///|
fn[A] empty_ring_buffer(capacity : Int) -> RingBuffer[A] {
  let deque : @deque.Deque[A] = @deque.Deque([], capacity~)
  RingBuffer::{ deque, }
}

///|
/// Constructs an empty ring buffer with a positive fixed capacity.
pub fn[A] RingBuffer::RingBuffer(
  capacity : Int,
) -> RingBuffer[A] raise RingBufferError {
  guard capacity > 0 else { raise RingBufferError::InvalidCapacity(capacity) }
  empty_ring_buffer(capacity)
}

///|
/// Constructs a ring buffer by pushing values in order.
///
/// When `values` contains more elements than `capacity`, only the newest
/// `capacity` elements are retained.
pub fn[A] RingBuffer::from_array(
  values : ArrayView[A],
  capacity~ : Int,
) -> RingBuffer[A] raise RingBufferError {
  let buffer = RingBuffer::RingBuffer(capacity)
  for value in values {
    buffer.push(value)
  }
  buffer
}

///|
/// Constructs a ring buffer by consuming values in order.
///
/// When the iterator yields more elements than `capacity`, only the newest
/// `capacity` elements are retained.
pub fn[A] RingBuffer::from_iter(
  values : Iter[A],
  capacity~ : Int,
) -> RingBuffer[A] raise RingBufferError {
  let buffer = RingBuffer::RingBuffer(capacity)
  for value in values {
    buffer.push(value)
  }
  buffer
}

///|
/// Adds the newest value, overwriting the oldest value when the buffer is full.
pub fn[A] RingBuffer::push(self : RingBuffer[A], value : A) -> Unit {
  if self.is_full() {
    self.deque.pop_front() |> ignore
  }
  self.deque.push_back(value)
}

///|
/// Removes and returns the oldest value, or returns `None` when empty.
pub fn[A] RingBuffer::pop(self : RingBuffer[A]) -> A? {
  self.deque.pop_front()
}

///|
/// Returns the oldest value without removing it, or returns `None` when empty.
pub fn[A] RingBuffer::peek(self : RingBuffer[A]) -> A? {
  self.deque.front()
}

///|
/// Returns the newest value without removing it, or returns `None` when empty.
pub fn[A] RingBuffer::peek_latest(self : RingBuffer[A]) -> A? {
  self.deque.back()
}

///|
/// Returns the fixed maximum number of values held by the buffer.
pub fn[A] RingBuffer::capacity(self : RingBuffer[A]) -> Int {
  self.deque.capacity()
}

///|
/// Returns the current number of values.
pub fn[A] RingBuffer::length(self : RingBuffer[A]) -> Int {
  self.deque.length()
}

///|
/// Returns whether the buffer contains no values.
pub fn[A] RingBuffer::is_empty(self : RingBuffer[A]) -> Bool {
  self.deque.is_empty()
}

///|
/// Returns whether the current length has reached the fixed capacity.
pub fn[A] RingBuffer::is_full(self : RingBuffer[A]) -> Bool {
  self.length() == self.capacity()
}

///|
/// Removes every value without changing the fixed capacity.
pub fn[A] RingBuffer::clear(self : RingBuffer[A]) -> Unit {
  self.deque.clear()
}

///|
/// Returns the value at a logical insertion-order index, or `None` when out of bounds.
pub fn[A] RingBuffer::get(self : RingBuffer[A], index : Int) -> A? {
  self.deque.get(index)
}

///|
/// Returns the value at a logical insertion-order index.
///
/// Panics when `index` is negative or not less than `length()`.
pub fn[A] RingBuffer::at(self : RingBuffer[A], index : Int) -> A {
  self.deque[index]
}

///|
/// Provides indexed access in logical insertion order.
#alias("_[_]")
pub fn[A] RingBuffer::indexed_get(self : RingBuffer[A], index : Int) -> A {
  self.at(index)
}

///|
/// Replaces the value at a logical insertion-order index without changing order.
///
/// Panics when `index` is negative or not less than `length()`.
pub fn[A] RingBuffer::set(self : RingBuffer[A], index : Int, value : A) -> Unit {
  self.deque[index] = value
}

///|
/// Provides indexed replacement in logical insertion order.
#alias("_[_]=_")
pub fn[A] RingBuffer::indexed_set(
  self : RingBuffer[A],
  index : Int,
  value : A,
) -> Unit {
  self.set(index, value)
}

///|
/// Returns an iterator from the oldest value to the newest value.
pub fn[A] RingBuffer::iter(self : RingBuffer[A]) -> Iter[A] {
  self.deque.iter()
}

///|
/// Returns an iterator of logical indices and values from oldest to newest.
pub fn[A] RingBuffer::iter2(self : RingBuffer[A]) -> Iter2[Int, A] {
  self.deque.iter2()
}

///|
/// Calls `action` for each value from oldest to newest.
pub fn[A] RingBuffer::each(self : RingBuffer[A], action : (A) -> Unit) -> Unit {
  self.deque.each(action)
}

///|
/// Calls `action` for each logical index and value from oldest to newest.
pub fn[A] RingBuffer::eachi(
  self : RingBuffer[A],
  action : (Int, A) -> Unit,
) -> Unit {
  self.deque.eachi(action)
}

///|
/// Returns an iterator from the newest value to the oldest value.
pub fn[A] RingBuffer::rev_iter(self : RingBuffer[A]) -> Iter[A] {
  self.deque.rev_iter()
}

///|
/// Returns an iterator of logical indices and values from newest to oldest.
pub fn[A] RingBuffer::rev_iter2(self : RingBuffer[A]) -> Iter2[Int, A] {
  self.deque.rev_iter2()
}

///|
/// Calls `action` for each value from newest to oldest.
pub fn[A] RingBuffer::rev_each(
  self : RingBuffer[A],
  action : (A) -> Unit,
) -> Unit {
  self.deque.rev_each(action)
}

///|
/// Calls `action` for each logical index and value from newest to oldest.
pub fn[A] RingBuffer::rev_eachi(
  self : RingBuffer[A],
  action : (Int, A) -> Unit,
) -> Unit {
  self.deque.rev_eachi(action)
}

///|
/// Returns two borrowed views that together contain values from oldest to newest.
///
/// The first view starts at the physical head. The second view contains any
/// wrapped values from the physical start. Mutating the buffer may invalidate
/// either view.
pub fn[A] RingBuffer::as_views(
  self : RingBuffer[A],
) -> (ArrayView[A], ArrayView[A]) {
  self.deque.as_views()
}

///|
/// Copies the current values into an array ordered from oldest to newest.
pub fn[A] RingBuffer::to_array(self : RingBuffer[A]) -> Array[A] {
  self.deque.to_array()
}

///|
/// Returns whether any current value equals `value`.
pub fn[A : Eq] RingBuffer::contains(self : RingBuffer[A], value : A) -> Bool {
  self.deque.contains(value)
}

///|
/// Returns the logical index of the first matching value, or `None` when absent.
pub fn[A : Eq] RingBuffer::search(self : RingBuffer[A], value : A) -> Int? {
  self.deque.search(value)
}

///|
/// Searches logically ordered values and returns a matching index or insertion index.
///
/// The values must already be sorted according to `Compare`.
pub fn[A : Compare] RingBuffer::binary_search(
  self : RingBuffer[A],
  value : A,
) -> Result[Int, Int] {
  self.deque.binary_search(value)
}

///|
/// Searches logically ordered values with a caller-provided comparison.
///
/// The callback must describe a sequence sorted around the requested value.
pub fn[A] RingBuffer::binary_search_by(
  self : RingBuffer[A],
  compare : (A) -> Int,
) -> Result[Int, Int] {
  self.deque.binary_search_by(compare)
}

///|
/// Creates a shallow copy with the same fixed capacity and logical order.
pub fn[A] RingBuffer::copy(self : RingBuffer[A]) -> RingBuffer[A] {
  let copied = empty_ring_buffer(self.capacity())
  for value in self.iter() {
    copied.push(value)
  }
  copied
}

///|
/// Maps every value in logical order into a buffer with the same fixed capacity.
pub fn[A, B] RingBuffer::map(
  self : RingBuffer[A],
  transform : (A) -> B,
) -> RingBuffer[B] {
  let mapped = empty_ring_buffer(self.capacity())
  for value in self.iter() {
    mapped.push(transform(value))
  }
  mapped
}

///|
/// Maps every logical index and value into a buffer with the same fixed capacity.
pub fn[A, B] RingBuffer::mapi(
  self : RingBuffer[A],
  transform : (Int, A) -> B,
) -> RingBuffer[B] {
  let mapped = empty_ring_buffer(self.capacity())
  self.eachi((index, value) => mapped.push(transform(index, value)))
  mapped
}

///|
/// Copies matching values in logical order into a buffer with the same capacity.
pub fn[A] RingBuffer::filter(
  self : RingBuffer[A],
  predicate : (A) -> Bool raise?,
) -> RingBuffer[A] raise? {
  let filtered = empty_ring_buffer(self.capacity())
  for value in self.iter() {
    if predicate(value) {
      filtered.push(value)
    }
  }
  filtered
}

///|
/// Keeps only matching values while preserving their logical order and capacity.
pub fn[A] RingBuffer::retain(
  self : RingBuffer[A],
  predicate : (A) -> Bool,
) -> Unit {
  self.deque.retain(predicate)
}

///|
/// Replaces or removes values while preserving logical order and capacity.
pub fn[A] RingBuffer::retain_map(
  self : RingBuffer[A],
  transform : (A) -> A?,
) -> Unit {
  self.deque.retain_map(transform)
}

///|
/// Joins the current strings from oldest to newest with `separator`.
pub fn RingBuffer::join(
  self : RingBuffer[String],
  separator : StringView,
) -> String {
  self.deque.join(separator)
}

///|
/// Compares ring buffers by their logical value sequence, excluding capacity.
pub impl[A : Eq] Eq for RingBuffer[A] with fn equal(self, other) {
  self.deque == other.deque
}

///|
/// Orders ring buffers by length, then compares equal-length logical sequences element by element.
pub impl[A : Compare] Compare for RingBuffer[A] with fn compare(self, other) {
  self.deque.compare(other.deque)
}

///|
/// Hashes the logical value sequence without including capacity.
pub impl[A : Hash] Hash for RingBuffer[A] with fn hash_combine(self, hasher) {
  Hash::hash_combine(self.deque, hasher)
}

///|
/// Converts the logical value sequence to a JSON array.
pub impl[A : ToJson] ToJson for RingBuffer[A] with fn to_json(self) {
  ToJson::to_json(self.deque)
}

///|
/// Formats the logical value sequence for debugging.
pub impl[A : @debug.Debug] @debug.Debug for RingBuffer[A] with fn to_repr(self) {
  @debug.Repr::opaque_(
    "RingBuffer",
    @debug.Repr::array(self.to_array().map(value => @debug.Repr(value))),
  )
}
