import envoy
import gleam/dict.{type Dict}
import gleam/option.{type Option, None, Some}
import gleam/string
import startest/expect
import yodel.{type Format}
import yodel/parser
import yodel/types.{type Properties, type YodelContext, YodelContext}

pub fn assert_loads_simple_file(
  format format: Format,
  extension extension: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options("./test/fixtures/simple." <> extension)
  |> expect.to_be_ok
  Nil
}

pub fn assert_loads_complex_file(
  format format: Format,
  extension extension: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options("./test/fixtures/complex." <> extension)
  |> expect.to_be_ok
  Nil
}

pub fn assert_does_not_load_fake_file(
  format format: Format,
  extension extension: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options("fake." <> extension)
  |> expect.to_be_error
  Nil
}

pub fn assert_loads_file_with_no_extension(
  format format: Format,
  extension extension: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options("./test/fixtures/no-ext-" <> extension)
  |> expect.to_be_ok
  Nil
}

pub fn assert_loads_simple_string(
  format format: Format,
  content content: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options(content)
  |> expect.to_be_ok
  Nil
}

pub fn assert_parses_basic_value(
  format format: Format,
  content content: String,
  path path: String,
  value value: String,
) {
  // yodel.default_options()
  // |> yodel.with_format(format)
  // |> yodel.load_with_options(content)
  // |> expect.to_be_ok
  // |> yodel.get_string(path)
  // |> expect.to_be_ok
  // |> expect.to_equal(value)
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.with_resolve_enabled(False)
  |> parser.parse(content, _)
  |> expect.to_be_ok
  |> dict.get(path)
  |> expect.to_be_ok
  |> expect.to_equal(value)
}

pub fn assert_parses_array(
  format format: Format,
  content content: String,
  path path: String,
  value value: String,
) {
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options(content)
  |> expect.to_be_ok
  |> yodel.get_string(path)
  |> expect.to_be_ok
  |> expect.to_equal(value)
}

pub fn to_string(format: Format) {
  format
  |> string.inspect
  |> string.lowercase
}

pub fn with_env(envs: Dict(String, Option(String)), handler: fn() -> Nil) {
  let old_envs = preserve_envs(envs)
  set_envs(envs)
  handler()
  restore_envs(old_envs)
}

fn preserve_envs(
  envs: Dict(String, Option(String)),
) -> Dict(String, Option(String)) {
  dict.map_values(envs, fn(key, _) {
    case envoy.get(key) {
      Ok(value) -> Some(value)
      _ -> None
    }
  })
}

fn set_envs(envs: Dict(String, Option(String))) {
  dict.each(envs, fn(key, value) {
    case value {
      Some(value) -> envoy.set(key, value)
      None -> envoy.unset(key)
    }
  })
}

fn restore_envs(old_envs: Dict(String, Option(String))) {
  dict.each(old_envs, fn(key, old_value) {
    case old_value {
      Some(old_value) -> envoy.set(key, old_value)
      None -> envoy.unset(key)
    }
  })
}
