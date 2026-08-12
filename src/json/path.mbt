///|
priv enum PathSegment {
  Key(String)
  Index(Int)
}

///|
let max_path_length = 16384

///|
let max_path_segments = 256

///|
fn format_path(segments : Array[PathSegment], format : PathFormat) -> String {
  match format {
    JsonPointer => format_json_pointer(segments)
    JavaScript => format_javascript_path(segments)
  }
}

///|
fn checked_path(
  segments : Array[PathSegment],
  format : PathFormat,
) -> String raise FlattenJsonError {
  guard segments.length() <= max_path_segments else {
    raise PathDepthExceeded(segments.length())
  }
  let mut raw_length = 0
  for segment in segments {
    match segment {
      Key(key) => {
        raw_length = raw_length + key.length()
        guard raw_length <= max_path_length else {
          raise PathLengthExceeded(raw_length)
        }
      }
      Index(_) => ()
    }
  }
  let path = format_path(segments, format)
  guard path.length() <= max_path_length else {
    raise PathLengthExceeded(path.length())
  }
  path
}

///|
fn parse_path(
  path : String,
  format : PathFormat,
) -> Array[PathSegment] raise FlattenJsonError {
  guard path.length() <= max_path_length else {
    raise PathLengthExceeded(path.length())
  }
  let segments = match format {
    JsonPointer => parse_json_pointer(path)
    JavaScript => parse_javascript_path(path)
  }
  guard segments.length() <= max_path_segments else {
    raise PathDepthExceeded(segments.length())
  }
  segments
}

///|
fn is_array_index_token(value : String) -> Bool {
  let chars = value.iter().to_array()
  !chars.is_empty() &&
  chars.all(char => char.is_ascii_digit()) &&
  (chars.length() == 1 || chars[0] != '0')
}
