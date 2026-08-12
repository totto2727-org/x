///|
/// Owns an upstream TOML value so standard JSON traits can be implemented
/// without violating MoonBit's foreign-trait implementation rule.
pub struct TomlValue {
  value : @upstream_toml.TomlValue
} derive(Eq, Debug)

///|
/// Wraps an upstream TOML value for standard JSON conversion.
pub fn TomlValue::TomlValue(value : @upstream_toml.TomlValue) -> TomlValue {
  { value, }
}

///|
/// Converts a wrapped TOML value into its flat JSON representation.
///
/// Date-time variants become their stored date strings, so decoding that JSON
/// produces `TomlString` rather than restoring date-time type information.
/// TOML `inf` and `nan` floats abort conversion because JSON cannot represent
/// non-finite numbers.
pub impl ToJson for TomlValue with fn to_json(self) {
  match self.value {
    @upstream_toml.TomlString(value) => Json::string(value)
    @upstream_toml.TomlInteger(value) =>
      Json::number(value.to_double(), repr=value.to_string())
    @upstream_toml.TomlFloat(value) => {
      if value.is_nan() ||
        value == @double.infinity ||
        value == @double.neg_infinity {
        abort("non-finite TOML floats cannot be represented as JSON")
      }
      Json::number(value)
    }
    @upstream_toml.TomlBoolean(value) => Json::boolean(value)
    @upstream_toml.TomlArray(values) =>
      Json::array(values.map(value => TomlValue::TomlValue(value).to_json()))
    @upstream_toml.TomlTable(values) =>
      Json::object(
        values.map((_, value) => TomlValue::TomlValue(value).to_json()),
      )
    @upstream_toml.TomlDateTime(_) =>
      match self.value.datetime_info() {
        Some((_, value)) => Json::string(value)
        None => abort("TOML date-time value did not expose its stored string")
      }
  }
}

///|
/// Converts flat JSON values into wrapped TOML values.
///
/// JSON strings always become `TomlString`; date-time type information is not
/// inferred. JSON `null` and heterogeneous arrays are rejected because TOML
/// has no corresponding valid value.
pub impl @json.FromJson for TomlValue with fn from_json(json, path) {
  match json {
    Json::Null => raise @json.JsonDecodeError((path, "TOML has no null value"))
    Json::True => TomlValue::TomlValue(@upstream_toml.TomlBoolean(true))
    Json::False => TomlValue::TomlValue(@upstream_toml.TomlBoolean(false))
    Json::String(value) =>
      TomlValue::TomlValue(@upstream_toml.TomlString(value))
    Json::Number(value, repr~) => {
      let representation = match repr {
        Some(representation) => representation
        None => value.to_string()
      }
      try @string.parse_int64(representation) catch {
        _ => TomlValue::TomlValue(@upstream_toml.TomlFloat(value))
      } noraise {
        integer => TomlValue::TomlValue(@upstream_toml.TomlInteger(integer))
      }
    }
    Json::Array(_) => {
      let values : Array[TomlValue] = @json.from_json(json, path~)
      let inner_values = values.map(value => value.value)
      guard @upstream_toml.TomlValue::is_homogeneous_array(inner_values) else {
        raise @json.JsonDecodeError((path, "TOML arrays must be homogeneous"))
      }
      TomlValue::TomlValue(@upstream_toml.TomlArray(inner_values))
    }
    Json::Object(_) => {
      let values : Map[String, TomlValue] = @json.from_json(json, path~)
      TomlValue::TomlValue(
        @upstream_toml.TomlTable(values.map((_, value) => value.value)),
      )
    }
  }
}
