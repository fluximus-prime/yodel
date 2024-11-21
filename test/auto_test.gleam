import startest.{describe, it}
import startest/expect
import test_helpers
import yodel

pub fn auto_tests() {
  describe("parser", [
    describe("auto", [
      it("loads simple yaml file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("loads complex yaml file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("does not load fake yaml file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("parses file with no extension", fn() {
        test_helpers.assert_loads_file_with_no_extension(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.yaml),
        )
      }),
      it("loads simple yaml string", fn() {
        test_helpers.assert_loads_simple_string(
          format: yodel.auto_detect,
          content: "foo.bar: fooey",
        )
      }),
      it("parses basic yaml value", fn() {
        let content =
          "
          foo:
            bar: fooey
        "
        test_helpers.assert_parses_basic_value(
          format: yodel.auto_detect,
          content:,
          path: "foo.bar",
          value: "fooey",
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
          format: yodel.auto_detect,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
      it("loads simple json file", fn() {
        test_helpers.assert_loads_simple_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("loads complex json file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("does not load fake json file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.json),
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
          format: yodel.auto_detect,
          content:,
          path: "foo.bar",
          value: "fooey",
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
          format: yodel.auto_detect,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
      it("loads simple toml file", fn() {
        test_helpers.assert_loads_simple_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("loads complex toml file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("does not load fake toml file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.auto_detect,
          extension: test_helpers.to_string(yodel.toml),
        )
      }),
      it("loads simple toml string", fn() {
        test_helpers.assert_loads_simple_string(
          format: yodel.auto_detect,
          content: "foo.bar = \"fooey\"",
        )
      }),
      it("parses basic toml value", fn() {
        let content =
          "
          [foo]
          bar = \"fooey\"
        "
        test_helpers.assert_parses_basic_value(
          format: yodel.auto_detect,
          content:,
          path: "foo.bar",
          value: "fooey",
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
          format: yodel.auto_detect,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
    ]),
  ])
}
