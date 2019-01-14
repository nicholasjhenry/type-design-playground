defmodule TypeDesignPlayground.IntroductionTest do
  use ExUnit.Case

  # A basic example
  # https://fsharpforfunandprofit.com/posts/designing-with-types-intro/#a-basic-example

  defmodule Contact do
    use TypedStruct

    typedstruct do
      field :first_name, String.t()
      field :middle_initial, String.t()
      field :last_name, String.t()

      field :email_address, String.t
      # true if ownership of email address is confirmed
      field :is_email_verified, boolean

      field :address1, String.t
      field :address2, String.t
      field :city, String.t
      field :state, String.t
      field :zip, String.t
      # true if validated against address service
      field :is_address_valid, boolean
    end
  end

  # Creating “atomic” types
  # https://fsharpforfunandprofit.com/posts/designing-with-types-intro/#creating-atomic-types

  defmodule PersonalName do
    use TypedStruct

    typedstruct do
      field :first_name, String.t()
      field :middle_initial, String.t()
      field :last_name, String.t()
    end
  end

  defmodule EmailContactInfo do
    use TypedStruct

    typedstruct do
      field :email_address, String.t
      # true if ownership of email address is confirmed
      field :is_email_verified, boolean
    end
  end

  defmodule PostalAddress do
    use TypedStruct

    typedstruct do
      field :address1, String.t
      field :address2, String.t
      field :city, String.t
      field :state, String.t
      field :zip, String.t
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
end
