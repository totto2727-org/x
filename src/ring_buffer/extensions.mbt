///|
pub extend RingBufferError with Eq::{equal, not_equal}

///|
pub extend RingBufferError with @debug.Debug::{to_repr}

///|
pub extend RingBuffer with Eq::{equal, not_equal}

///|
pub extend RingBuffer with Compare::{compare, op_lt, op_le, op_gt, op_ge}

///|
pub extend RingBuffer with Hash::{hash, hash_combine}

///|
pub extend RingBuffer with ToJson::{to_json}

///|
pub extend RingBuffer with @debug.Debug::{to_repr}
