import startest.{describe, it}
import startest/expect
import yodel

pub fn common_tests() {
  describe("common tests", [
    it("should load basic value", fn() {
      let assert Ok(config) = yodel.load("foo.bar: fooey\n")
      config
      |> yodel.get_string_or("foo.bar", "error")
      |> expect.to_equal("fooey")
    }),
  ])
}
