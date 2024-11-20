import startest.{describe, it}
import test_helpers
import yodel

pub fn json_tests() {
  describe("parser", [
    describe("json", [
      it("loads simple file", fn() {
        test_helpers.assert_loads_simple_file(
          format: yodel.json,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("loads complex file", fn() {
        test_helpers.assert_loads_complex_file(
          format: yodel.json,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("does not load fake file", fn() {
        test_helpers.assert_does_not_load_fake_file(
          format: yodel.json,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("loads file with no extension", fn() {
        test_helpers.assert_loads_file_with_no_extension(
          format: yodel.json,
          extension: test_helpers.to_string(yodel.json),
        )
      }),
      it("parses basic value", fn() {
        let content =
          "
        {
          \"foo\": {
            \"bar\": \"fooey\"
          }
        }
        "
        test_helpers.assert_parses_basic_value(
          format: yodel.json,
          content:,
          path: "foo.bar",
          value: "fooey",
        )
      }),
      it("parses array", fn() {
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
          format: yodel.json,
          content:,
          path: "foo[1].baz",
          value: "fooed",
        )
      }),
    ]),
  ])
}
