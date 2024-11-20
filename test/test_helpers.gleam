import gleam/string
import startest/expect
import yodel.{type Format}

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
  yodel.default_options()
  |> yodel.with_format(format)
  |> yodel.load_with_options(content)
  |> expect.to_be_ok
  |> yodel.get_string(path)
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
