defmodule CivilTypes do
  defmacro __using__(_) do
    quote do
      import CivilTypes, only: [deftype: 1, deftype: 2, id: 1]
    end
  end

  defmacro deftype(type) do
    quote do
      @enforce_keys [:value]
      defstruct [:value]

      @type t :: %__MODULE__{value: unquote(type)}

      defimpl Inspect do
        import Inspect.Algebra

        def inspect(term, opts) do
          concat([to_doc(@for, opts), "<", to_doc(term.value, opts), ">"])
        end
      end

      defimpl String.Chars do
        def to_string(type) do
          to_string(type.value)
        end
      end

      @spec new(unquote(type)) :: t
      def new(term) do
        struct!(__MODULE__, value: term)
      end
    end
  end

  defmacro deftype(atom, type) do
    quote do
      defmodule unquote(atom) do
        @enforce_keys [:value]
        defstruct [:value]

        defimpl Inspect do
          import Inspect.Algebra

          def inspect(term, opts) do
            concat([to_doc(@for, opts), "<", to_doc(term.value, opts), ">"])
          end
        end

        defimpl String.Chars do
          def to_string(type) do
            to_string(type.value)
          end
        end

        @type t :: %__MODULE__{value: unquote(type)}

        @spec new(unquote(type)) :: t
        def new(term) do
          struct!(__MODULE__, value: term)
        end
      end
    end
  end

  def id(term), do: term
end
