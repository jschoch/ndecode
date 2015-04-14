defmodule MyTime do
  defstruct stamp: {0,0,0}
  defimpl Poison.Encoder, for: MyTime do
    def encode(%MyTime{} = t,options) do
      list = Tuple.to_list(t.stamp)
      Poison.Encoder.Map.encode(%MyTime{stamp: list},options)
    end
  end
  defimpl Poison.Decoder, for: MyTime do
    def decode(s,options) do
      t = List.to_tuple(s.stamp)
      %MyTime{stamp: t}
    end
  end
end
defmodule X do
  defstruct name: :foo, ts: %MyTime{stamp: {2,2,2}}, m: nil, z: nil
  use Ndecode
end
defmodule S do
  defstruct name: :foo
  use Ndecode
end
defmodule Z do
  defstruct name: :baz
end
defmodule NdecodeTest do
  use ExUnit.Case

  test "embed works" do
    s = Poison.encode!(%X{name: :bar,m: %{},z: %Z{}})
    IO.puts "X: " <> inspect s
    x = Poison.decode!(s, [keys: :atoms,as: X])
    IO.puts "X: " <> inspect x
    assert is_tuple(x.ts.stamp)
    assert match?(%MyTime{},x.ts)
  end
end
