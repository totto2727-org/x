///|
pub extend AbsolutePath with Eq::{equal, not_equal}

///|
pub extend AbsolutePath with Debug::{to_repr}

///|
pub extend AbsolutePath with @json.FromJson::{from_json}

///|
pub extend RelativePath with Eq::{equal, not_equal}

///|
pub extend RelativePath with Debug::{to_repr}

///|
pub extend RelativePath with @json.FromJson::{from_json}
