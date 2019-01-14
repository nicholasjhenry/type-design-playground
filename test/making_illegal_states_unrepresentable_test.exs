defmodule MakingIllegalStatesUnrepresentableTest do
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
      field :is_email_verified, boolean, default: false
    end

    @spec new(EmailAddress.t) :: t
    def new(term) do
        struct!(__MODULE__, email_address: term)
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

  defmodule PostalContactInfo do
    use TypedStruct

    typedstruct do
      field :address, PostalAddress.t()
      # true if validated against address service
      field :is_address_valid, boolean, default: false
    end
  end

  deftype EmailOnly, EmailContactInfo
  deftype PostOnly, PostalContactInfo
  deftype EmailAndPost, {EmailContactInfo, PostalContactInfo}
  deftype ContactInfo, EmailOnly | PostOnly | EmailAndPost

  defmodule Contact do
    use TypedStruct

    typedstruct do
      field :name, PersonalName.t()
      field :contact_info, ContactInfo.t()
    end
  end

  def contact_from_email(name, email_str) do
    email_opt = EmailAddress.create(email_str)

    case email_opt do
      {:some, email} ->
        contact_info = email |> EmailContactInfo.new() |> EmailOnly.new()
        {:some, struct!(Contact, name: name, contact_info: contact_info)}
      :none -> :none
    end
  end

  test "creating a contact from email" do
    name = struct(PersonalName, first_name: "A", last_name: "Smith")
    contact_from_email(name, "abc@example.com")
  end

  def update_postal_address(contact, new_postal_address) do
    %{name: name, contact_info: contact_info} = contact
    new_contact_info = case contact_info do
      %EmailOnly{value: email} ->
        EmailAndPost.new({email, new_postal_address})
      %PostOnly{} -> # ignore existing address
        PostOnly.new(new_postal_address)
      %EmailAndPost{value: {email, _existing_postal_address}} -> # ignore existing address
        EmailAndPost.new({email, new_postal_address})
    end

    {:some, struct!(Contact, name: name, contact_info: new_contact_info)}
  end

  test "updating a contact" do
    name = struct(PersonalName, first_name: "A", last_name: "Smith")
    contact_opt = contact_from_email(name, "abc@example.com")

    # don't do this in production (i.e. destructing/struct)
    {:some, contact} = contact_opt
    new_postal_address = struct(PostalContactInfo,
      address: struct(PostalAddress,
        address_1: "123 Main",
        city: "Beverly Hills",
        state: StateCode.new("CA"),
        zip: ZipCode.new("97210")
      )
    )

    update_postal_address(contact, new_postal_address) |> IO.inspect
  end
end
