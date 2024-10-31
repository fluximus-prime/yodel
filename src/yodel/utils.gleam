import gleam/dict
import gleam/result
import simplifile
import yodel/errors
import yodel/types.{
  type Properties, type YodelContext, type YodelError, InvalidPath,
}

pub fn read_file(
  from path: String,
  then handler: fn(String) -> Result(YodelContext, YodelError),
) -> Result(YodelContext, YodelError) {
  simplifile.read(path)
  |> result.map_error(fn(err) {
    InvalidPath(err |> errors.file_error_to_string)
  })
  |> result.then(handler)
}

pub fn is_valid(props: Properties) -> Bool {
  case dict.size(props) {
    // prevent empty configs
    0 -> False
    1 -> {
      // prevent broken configs
      case dict.get(props, "") {
        Ok(_) -> False
        Error(_) -> True
      }
    }
    _ -> True
  }
}
