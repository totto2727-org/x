///|
priv enum PathSegment {
  Key(String)
  Index(Int)
}

///|
let max_path_length_ = 16384

///|
let max_path_segments_ = 256

///|
fn format_path_(segments : Array[PathSegment], format : PathFormat) -> String {
  match format {
    JsonPointer => format_json_pointer_(segments)
    JavaScript => format_javascript_path_(segments)
  }
}

///|
fn checked_path_(
  segments : Array[PathSegment],
  format : PathFormat,
) -> String raise FlattenJsonError {
  guard segments.length() <= max_path_segments_ else { raise InvalidPath("") }
  let mut raw_length = 0
  for segment in segments {
    match segment {
      Key(key) => {
        raw_length = raw_length + key.length()
        guard raw_length <= max_path_length_ else { raise InvalidPath(key) }
      }
      Index(_) => ()
    }
  }
  let path = format_path_(segments, format)
  guard path.length() <= max_path_length_ else { raise InvalidPath(path) }
  path
}

///|
fn parse_path_(
  path : String,
  format : PathFormat,
) -> Array[PathSegment] raise FlattenJsonError {
  guard path.length() <= max_path_length_ else { raise InvalidPath(path) }
  let segments = match format {
    JsonPointer => parse_json_pointer_(path)
    JavaScript => parse_javascript_path_(path)
  }
  guard segments.length() <= max_path_segments_ else { raise InvalidPath(path) }
  segments
}
