Ndecode
=======

** nested struct decode for Poison

add [Poison](http://github.com/devinus/poison) and Ndecode to your mix.exs

```
defp deps do
  [
    {:poison,"~> 1.3.1"},
    {:ndecode,github: "jschoch/ndecode.git"}
  ]
end
```

defimpl encode and decode for nested structs

use Ndecode


example defimpl from test

``` elixir

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
```


