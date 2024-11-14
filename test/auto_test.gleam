import startest.{describe, it}
import startest/expect
import test_helpers
import yodel

pub fn auto_tests() {
  describe("auto", [
    it("parses string", fn() {
      "foo.bar: abc123"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_string("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal("abc123")
    }),
    it("parses int", fn() {
      "foo.bar: 42"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_int("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(42)
    }),
    it("parses float", fn() {
      "foo.bar: 42.24"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_float("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(42.24)
    }),
    it("parses bool", fn() {
      "foo.bar: true"
      |> yodel.load
      |> expect.to_be_ok
      |> yodel.get_bool("foo.bar")
      |> expect.to_be_ok
      |> expect.to_equal(True)
    }),
    it("loads simple yaml file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("loads complex yaml file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("does not load fake yaml file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("parses file with no extension", fn() {
      test_helpers.assert_loads_file_with_no_extension(
        yodel.yaml,
        test_helpers.to_string(yodel.yaml),
      )
    }),
    it("loads simple yaml string", fn() {
      let content = "foo.bar: fooey"
      test_helpers.assert_loads_simple_string(yodel.auto_detect, content)
    }),
    it("parses basic yaml value", fn() {
      let content =
        "
          foo:
            bar: fooey
        "
      test_helpers.assert_parses_basic_value(
        yodel.auto_detect,
        content,
        "foo.bar",
        "fooey",
      )
    }),
    it("parses yaml array", fn() {
      let content =
        "
          foo:
            - bar: fooey
            - baz: fooed
        "
      test_helpers.assert_parses_array(
        yodel.auto_detect,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
    it("loads simple json file", fn() {
      test_helpers.assert_loads_simple_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.json),
      )
    }),
    it("loads complex json file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.json),
      )
    }),
    it("does not load fake json file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.json),
      )
    }),
    it("parses basic json value", fn() {
      let content =
        "
          {
            \"foo\": {
              \"bar\": \"fooey\"
            }
          }
        "
      test_helpers.assert_parses_basic_value(
        yodel.auto_detect,
        content,
        "foo.bar",
        "fooey",
      )
    }),
    it("parses json array", fn() {
      let content =
        "
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
        "
      test_helpers.assert_parses_array(
        yodel.auto_detect,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
    it("loads simple toml file", fn() {
      test_helpers.assert_loads_simple_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("loads complex toml file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("does not load fake toml file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.auto_detect,
        test_helpers.to_string(yodel.toml),
      )
    }),
    it("loads simple toml string", fn() {
      let content = "foo.bar = \"fooey\""
      test_helpers.assert_loads_simple_string(yodel.auto_detect, content)
    }),
    it("parses basic toml value", fn() {
      let content =
        "
          [foo]
          bar = \"fooey\"
        "
      test_helpers.assert_parses_basic_value(
        yodel.auto_detect,
        content,
        "foo.bar",
        "fooey",
      )
    }),
    it("parses toml array", fn() {
      let content =
        "
          [[foo]]
          bar = \"fooey\"

          [[foo]]
          baz = \"fooed\"
        "
      test_helpers.assert_parses_array(
        yodel.auto_detect,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
  ])
}
