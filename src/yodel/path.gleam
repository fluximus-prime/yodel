import gleam/int
import gleam/list

pub opaque type PathSegment {
  Key(String)
  Index(Int)
}

pub type Path =
  List(PathSegment)

pub fn new() -> Path {
  []
}

pub fn segment(path: Path, segment: String) -> Path {
  [Key(segment), ..path]
}

pub fn index(path: Path, index: Int) -> Path {
  [Index(index), ..path]
}

pub fn format(segments: Path) -> String {
  segments
  |> list.fold_right("", fn(acc, segment) {
    case segment {
      Key(key) -> {
        case acc {
          "" -> key
          _ -> acc <> "." <> key
        }
      }
      Index(index) -> acc <> "[" <> int.to_string(index) <> "]"
    }
  })
}
