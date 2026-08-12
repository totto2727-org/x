///|
fn format_javascript_path_(segments : Array[PathSegment]) -> String {
  let output = StringBuilder()
  for index, segment in segments {
    match segment {
      Key(key) if is_identifier_(key) => {
        if index > 0 {
          output.write_char('.')
        }
        output.write_string(key)
      }
      Key(key) => {
        output.write_char('[')
        output.write_string(Json::string(key).stringify())
        output.write_char(']')
      }
      Index(array_index) => {
        output.write_char('[')
        output.write_object(array_index)
        output.write_char(']')
      }
    }
  }
  output.to_string()
}

///|
fn is_identifier_(key : String) -> Bool {
  let chars = key.iter().to_array()
  guard chars.length() > 0 else { return false }
  guard chars[0].is_ascii_alphabetic() || chars[0] == '_' || chars[0] == '$' else {
    return false
  }
  chars[1:].all(char => {
    char.is_ascii_alphabetic() ||
    char.is_ascii_digit() ||
    char == '_' ||
    char == '$'
  })
}

///|
fn parse_javascript_path_(
  path : String,
) -> Array[PathSegment] raise FlattenJsonError {
  if path == "" {
    return []
  }
  let chars = path.iter().to_array()
  let segments : Array[PathSegment] = []
  let mut index = 0
  let mut expects_segment = true
  let mut after_dot = false
  while index < chars.length() {
    match chars[index] {
      '.' if !expects_segment => {
        expects_segment = true
        after_dot = true
        index = index + 1
      }
      '[' if !after_dot => {
        let (segment, next_index) = parse_bracket_segment_(chars, index, path)
        segments.push(segment)
        expects_segment = false
        index = next_index
      }
      _ if expects_segment => {
        let start = index
        while index < chars.length() &&
              chars[index] != '.' &&
              chars[index] != '[' {
          index = index + 1
        }
        let key = chars_to_string_(chars[start:index])
        guard is_identifier_(key) else { raise InvalidPath(path) }
        segments.push(Key(key))
        expects_segment = false
        after_dot = false
      }
      _ => raise InvalidPath(path)
    }
  }
  guard !expects_segment else { raise InvalidPath(path) }
  segments
}

///|
fn parse_bracket_segment_(
  chars : Array[Char],
  start : Int,
  path : String,
) -> (PathSegment, Int) raise FlattenJsonError {
  let mut index = start + 1
  guard index < chars.length() else { raise InvalidPath(path) }
  if chars[index] == '"' {
    let literal = StringBuilder()
    literal.write_char('"')
    index = index + 1
    let mut escaped = false
    while index < chars.length() {
      let char = chars[index]
      literal.write_char(char)
      index = index + 1
      if escaped {
        escaped = false
      } else if char == '\\' {
        escaped = true
      } else if char == '"' {
        break
      }
    }
    guard index < chars.length() && chars[index] == ']' else {
      raise InvalidPath(path)
    }
    let parsed = try @core_json.parse(literal.to_string()) catch {
      _ => raise InvalidPath(path)
    } noraise {
      value => value
    }
    let key = match parsed {
      Json::String(key) => key
      _ => raise InvalidPath(path)
    }
    return (Key(key), index + 1)
  }
  let number = StringBuilder()
  while index < chars.length() && chars[index] != ']' {
    number.write_char(chars[index])
    index = index + 1
  }
  guard index < chars.length() && chars[index] == ']' else {
    raise InvalidPath(path)
  }
  let token = number.to_string()
  guard is_pointer_index_token_(token) else { raise InvalidPath(path) }
  let value = try @string.parse_int(token) catch {
    _ => raise InvalidPath(path)
  } noraise {
    value => value
  }
  guard value >= 0 else { raise InvalidPath(path) }
  (Index(value), index + 1)
}

///|
fn chars_to_string_(chars : ArrayView[Char]) -> String {
  let output = StringBuilder()
  for char in chars {
    output.write_char(char)
  }
  output.to_string()
}
