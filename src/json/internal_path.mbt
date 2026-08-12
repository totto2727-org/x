///|
priv enum PathSegment {
  Key(String)
  Index(Int)
}

///|
fn format_path_(segments : Array[PathSegment], format : PathFormat) -> String {
  match format {
    JsonPointer => format_json_pointer_(segments)
    JavaScript => format_javascript_path_(segments)
  }
}

///|
fn parse_path_(
  path : String,
  format : PathFormat,
) -> Array[PathSegment] raise FlattenJsonError {
  match format {
    JsonPointer => parse_json_pointer_(path)
    JavaScript => parse_javascript_path_(path)
  }
}

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
  while index < chars.length() {
    match chars[index] {
      '.' if !expects_segment => {
        expects_segment = true
        index = index + 1
      }
      '[' => {
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
  let value = try @string.parse_int(number.to_string()) catch {
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
