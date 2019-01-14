defmodule TypeDesignPlayground.SingleCaseUnionTypesTest do
  use ExUnit.Case
  use CivilTypes

  # Wrapping primitive types
  # https://fsharpforfunandprofit.com/posts/designing-with-types-single-case-dus/#wrapping-primitive-types

  defmodule PersonalName do
    use TypedStruct

    typedstruct do
      field :first_name, String.t()
      field :middle_initial, String.t()
      field :last_name, String.t()
    end
  end

  defmodule EmailAddress do
    use CivilTypes

    deftype String.t

    def create_with_cont(term, success, failure) do
      if String.contains?(term, "@") do
        term |> new |> success.()
      else
        failure.("Email address must contain an @ sign")
      end
    end

    def create(term) do
      success = fn(email) -> {:some, email} end
      failure = fn(_msg) -> :none end

      create_with_cont(term, success, failure)
    end

    def ap(e, f), do: f.(e.value)

    def value(e), do: ap(&id/1, e)
  end

  defmodule EmailContactInfo do
    use TypedStruct

    typedstruct do
      field :email_address, EmailAddress.t
      # true if ownership of email address is confirmed
      field :is_email_verified, boolean
    end
  end

  deftype ZipCode, String.t
  deftype StateCode, String.t

  defmodule PostalAddress do
    use TypedStruct

    typedstruct do
      field :address1, String.t
      field :address2, String.t
      field :city, String.t
      field :state, StateCode.t
      field :zip, ZipCode.t
    end
  end

  defmodule PostalAddressContactInfo do
    use TypedStruct

    typedstruct do
      field :address, PostalAddress.t()
      # true if validated against address service
      field :is_address_valid, boolean
    end
  end

  defmodule Contact do
    use TypedStruct

    typedstruct do
      field :name, PersonalName.t()
      field :email_contact_info, EmailContactInfo.t()
      field :postal_address_contact_info, PostalAddressContactInfo.t()
    end
  end

  test "types" do
    success = fn(email) -> assert EmailAddress.new("hello@example.com") == email end
    failure = fn(msg) -> assert msg, "Email address must contain an @ sign" end

    EmailAddress.create_with_cont("hello@example.com", success, failure)
    EmailAddress.create_with_cont("sad panda", success, failure)

    assert EmailAddress.create("hello@example.com") == {:some, EmailAddress.new("hello@example.com")}
    assert EmailAddress.create("sad panda") == :none

    result = "hello@example.com" |> EmailAddress.new() |> EmailAddress.ap(&String.contains?(&1, "@"))
    assert result
  end
end
