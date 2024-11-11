import startest.{describe, it}
import test_helpers
import yodel

pub fn json_tests() {
  describe("json", [
    it("loads simple file", fn() {
      test_helpers.assert_loads_simple_file(
        yodel.json,
        test_helpers.to_string(yodel.json),
      )
    }),
    it("loads complex file", fn() {
      test_helpers.assert_loads_complex_file(
        yodel.json,
        test_helpers.to_string(yodel.json),
      )
    }),
    it("does not load fake file", fn() {
      test_helpers.assert_does_not_load_fake_file(
        yodel.json,
        test_helpers.to_string(yodel.json),
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
        yodel.json,
        content,
        "foo.bar",
        "fooey",
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
        yodel.json,
        content,
        "foo[1].baz",
        "fooed",
      )
    }),
  ])
}
