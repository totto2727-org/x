///|
pub extend TomlValue with Eq::{equal, not_equal}

///|
pub extend TomlValue with Debug::{to_repr}

///|
pub extend TomlValue with @json.FromJson::{from_json}
