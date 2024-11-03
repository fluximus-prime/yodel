import startest.{describe, it}
import startest/expect
import yodel

pub fn json_tests() {
  describe("json", [
    it("should load basic json file", fn() {
      let assert Ok(config) = yodel.load("./test/fixtures/short.json")
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
    it("should not load fake json file", fn() {
      yodel.load("fake.json")
      |> expect.to_be_error
      Nil
    }),
    it("should load full json value", fn() {
      let assert Ok(config) =
        yodel.load(
          "{
              \"foo\": {
                \"bar\": \"fooey\"
              }
            }",
        )
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
  ])
}
