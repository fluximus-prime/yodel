import gleam/list
import gleam/string
import simplifile
import yodel/loaders/yaml
import yodel/types.{
  type YodelContext, type YodelError, InvalidContent, InvalidPath,
}

pub fn load(from string: String) -> Result(YodelContext, YodelError) {
  let trimmed = string.trim(string)

  case simplifile.is_file(trimmed) {
    Ok(True) -> load_file(trimmed)
    _ -> load_string(trimmed)
  }
}

fn load_file(path: String) -> Result(YodelContext, YodelError) {
  let file_loaders = [yaml.load_file]

  list.fold(
    file_loaders,
    Error(InvalidPath("Error loading config file")),
    fn(acc, loader) {
      case acc {
        Ok(ctx) -> Ok(ctx)
        Error(_) -> loader(path)
      }
    },
  )
}

fn load_string(content: String) -> Result(YodelContext, YodelError) {
  let string_loaders = [yaml.load_string]

  list.fold(
    string_loaders,
    Error(InvalidContent("Invalid config content")),
    fn(acc, loader) {
      case acc {
        Ok(ctx) -> Ok(ctx)
        Error(_) -> loader(content)
      }
    },
  )
}
