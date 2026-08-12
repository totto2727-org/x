///|
fn escape_pointer_key_(key : String) -> String {
  key.replace_all(old="~", new="~0").replace_all(old="/", new="~1")
}

///|
fn is_pointer_index_token_(value : String) -> Bool {
  let chars = value.iter().to_array()
  !chars.is_empty() &&
  chars.all(char => char.is_ascii_digit()) &&
  (chars.length() == 1 || chars[0] != '0')
}

///|
fn format_json_pointer_(segments : Array[PathSegment]) -> String {
  let output = StringBuilder()
  for segment in segments {
    output.write_char('/')
    match segment {
      Key(key) => output.write_string(escape_pointer_key_(key))
      Index(index) => output.write_object(index)
    }
  }
  output.to_string()
}

///|
fn parse_json_pointer_(
  path : String,
) -> Array[PathSegment] raise FlattenJsonError {
  if path == "" {
    return []
  }
  guard path.has_prefix("/") else { raise InvalidPath(path) }
  let segments : Array[PathSegment] = []
  for token in path[1:].split("/") {
    let value = unescape_pointer_key_(token.to_owned(), path)
    if is_pointer_index_token_(value) {
      let index = try @string.parse_int(value) catch {
        _ => raise InvalidPath(path)
      } noraise {
        value => value
      }
      segments.push(Index(index))
    } else {
      segments.push(Key(value))
    }
  }
  segments
}

///|
fn unescape_pointer_key_(
  token : String,
  path : String,
) -> String raise FlattenJsonError {
  let chars = token.iter().to_array()
  let output = StringBuilder()
  let mut index = 0
  while index < chars.length() {
    if chars[index] == '~' {
      guard index + 1 < chars.length() else { raise InvalidPath(path) }
      match chars[index + 1] {
        '0' => output.write_char('~')
        '1' => output.write_char('/')
        _ => raise InvalidPath(path)
      }
      index = index + 2
    } else {
      output.write_char(chars[index])
      index = index + 1
    }
  }
  output.to_string()
}
