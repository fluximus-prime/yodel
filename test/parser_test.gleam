import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import startest.{describe, it}
import startest/expect
import yodel/parsers/toml
import yodel/parsers/yaml
import yodel/types.{type ParseFunction}

type TestCase {
  TestCase(
    format_name: String,
    parse: ParseFunction,
    string_input: String,
    int_input: String,
    float_input: String,
    bool_input: String,
    basic_input: String,
    array_input: String,
  )
}

pub fn parser_tests() {
  let test_cases = [
    TestCase(
      format_name: "toml",
      parse: toml.parse,
      string_input: "foo.bar = \"fooey\"",
      int_input: "foo.bar = 42",
      float_input: "foo.bar = 99.999",
      bool_input: "foo.bar = true",
      basic_input: "
      [foo]
      bar = \"fooey\"
      ",
      array_input: "
      [[foo]]
      bar = \"fooey\"

      [[foo]]
      baz = \"fooed\"
      ",
    ),
    TestCase(
      format_name: "yaml",
      parse: yaml.parse,
      string_input: "foo.bar: fooey",
      int_input: "foo.bar: 42",
      float_input: "foo.bar: 99.999",
      bool_input: "foo.bar: true",
      basic_input: "
      foo:
        bar: fooey
      ",
      array_input: "
      foo:
        - bar: fooey
        - baz: fooed
      ",
    ),
    TestCase(
      format_name: "json",
      parse: yaml.parse,
      string_input: "\"foo\": {\"bar\": \"fooey\"}",
      int_input: "\"foo\": {\"bar\": 42}",
      float_input: "\"foo\": {\"bar\": 99.999}",
      bool_input: "\"foo\": {\"bar\": true}",
      basic_input: "
      {
        \"foo\": {
          \"bar\": \"fooey\"
        }
      }
      ",
      array_input: "
      {
        \"foo\": [
          {
            \"bar\": \"fooey\"
          },
          {
            \"baz\": \"fooed\"
          }
        ]
      }
      ",
    ),
  ]

  describe(
    "parser",
    list.map(test_cases, fn(test_case) {
      let TestCase(
        format_name,
        parse,
        string_input,
        int_input,
        float_input,
        bool_input,
        basic_input,
        array_input,
      ) = test_case

      describe(format_name, [
        it("loads basic value", fn() {
          parse(basic_input)
          |> expect.to_be_ok
          |> dict.get("foo.bar")
          |> expect.to_be_ok
          |> expect.to_equal("fooey")
        }),
        it("loads array", fn() {
          parse(array_input)
          |> expect.to_be_ok
          |> dict.get("foo[1].baz")
          |> expect.to_be_ok
          |> expect.to_equal("fooed")
        }),
        it("returns a string", fn() {
          parse(string_input)
          |> expect.to_be_ok
          |> dict.get("foo.bar")
          |> expect.to_be_ok
          |> expect.to_equal("fooey")
        }),
        it("returns an int", fn() {
          parse(int_input)
          |> expect.to_be_ok
          |> dict.get("foo.bar")
          |> expect.to_be_ok
          |> int.parse
          |> expect.to_be_ok
          |> expect.to_equal(42)
        }),
        it("returns a float", fn() {
          parse(float_input)
          |> expect.to_be_ok
          |> dict.get("foo.bar")
          |> expect.to_be_ok
          |> float.parse
          |> expect.to_be_ok
          |> float.to_precision(3)
          |> expect.to_equal(99.999)
        }),
        it("returns a bool", fn() {
          case
            parse(bool_input)
            |> expect.to_be_ok
            |> dict.get("foo.bar")
            |> expect.to_be_ok
            |> string.lowercase
          {
            "true" -> True
            _ -> False
          }
          |> expect.to_equal(True)
        }),
      ])
    }),
  )
}
