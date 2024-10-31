import gleam/list
import gleam/string
import simplifile
import yodel/loaders/yaml
import yodel/types.{
  type YodelContext, type YodelError, InvalidContent, InvalidPath,
}

pub fn load(from string: String) -> Result(YodelContext, YodelError) {
  case load_file(string) {
    Ok(ctx) -> Ok(ctx)
    Error(_) -> load_string(string)
  }
}

fn load_file(string: String) -> Result(YodelContext, YodelError) {
  let file_loaders = [yaml.load_file]
  //[load_json_file, load_yaml_file]
  let path = string.trim(string)
  case simplifile.is_file(path) {
    Ok(_) -> {
      list.fold(
        file_loaders,
        Error(InvalidPath("Error loading config")),
        fn(acc, loader) {
          case acc {
            Ok(ctx) -> Ok(ctx)
            Error(_) -> loader(path)
          }
        },
      )
    }
    _ -> Error(InvalidPath("Error loading config"))
  }
}

fn load_string(string: String) -> Result(YodelContext, YodelError) {
  let string_loaders = [yaml.load_string]
  //[load_json_string, load_yaml_string]
  let config = string.trim(string)
  case simplifile.is_file(config) {
    Ok(_) -> Error(InvalidPath("Error loading config"))
    _ -> {
      list.fold(
        string_loaders,
        Error(InvalidContent("Error loading config")),
        fn(acc, loader) {
          case acc {
            Ok(ctx) -> Ok(ctx)
            Error(_) -> loader(config)
          }
        },
      )
    }
  }
}
