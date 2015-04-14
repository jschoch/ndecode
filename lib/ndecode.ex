defmodule Ndecode do
  defmacro __using__(_) do
    quote do
      require Logger
      defimpl Poison.Encoder, for: __MODULE__ do
        def encode(y,options) do
          Poison.Encoder.Map.encode(y,options)
        end
      end
      defimpl Poison.Decoder, for: __MODULE__ do
        defp ndecode(map,key,val) do
          mod_name = Map.fetch!(val,:__struct__)
          mod_atom = String.to_atom(mod_name)
          mod_struct = mod_atom.__struct__.__struct__
          ["Elixir"|short_name] = String.split(mod_name,".")
          decoder_name = :"Elixir.Poison.Decoder.#{short_name}"
          case Code.ensure_loaded(decoder_name) do
            {:module,_} ->
              decoded = decoder_name.decode(val,as: mod_struct)
              map = Map.put(map,key,decoded)
            {:error,reason} ->
              Loggger.warn "couldn't decode #{decoder_name} #{inspect reason}"
          end
        end
        def decode(map,options) when is_map(map) do
          map = Enum.reduce(Map.keys(map),map,fn(key,map) ->
            val = Map.fetch!(map,key)
            if (is_map(val)) do
              case Map.has_key?(val,:__struct__) do
                true ->
                  map = ndecode(map,key,val)
                false ->
                  Logger.debug "didn't find a :__struct__ for #{key}"
              end
            end
            map
          end)
        end
      end
    end
  end
end
