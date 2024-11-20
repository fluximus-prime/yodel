import startest.{describe, it}
import startest/expect
import yodel/path

pub fn path_tests() {
  describe("path", [
    it("formats basic path", fn() {
      path.new()
      |> path.segment("foo")
      |> path.segment("bar")
      |> path.index(0)
      |> path.format
      |> expect.to_equal("foo.bar[0]")
    }),
    it("formats slightly less basic path", fn() {
      path.new()
      |> path.segment("foo")
      |> path.index(9)
      |> path.index(17)
      |> path.segment("bar")
      |> path.index(7)
      |> path.segment("baz")
      |> path.index(42)
      |> path.format
      |> expect.to_equal("foo[9][17].bar[7].baz[42]")
    }),
  ])
}
