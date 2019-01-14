defmodule DiscoveringNewConceptsTest do
  use ExUnit.Case
  use CivilTypes

  deftype EmailContactInfo, String.t
  deftype PostalContactInfo, String.t
  deftype HomePhone, String.t
  deftype WorkPhone, String.t

  deftype ContactMethod, EmailContactInfo | PostalContactInfo | HomePhone | WorkPhone

  defmodule ContactInformation do
    use TypedStruct

    typedstruct do
      field :primary_contact_method, ContactMethod.t
      field :secondary_contact_methods, list(ContactMethod.t)
    end
  end

  def print_contact_method(contact_method) do
    case contact_method do
      %EmailContactInfo{} -> IO.puts "Email Address is #{contact_method}"
      %PostalContactInfo{} -> IO.puts "Postal Address is #{contact_method}"
      %HomePhone{} -> IO.puts "Home Phone is #{contact_method}"
      %WorkPhone{} -> IO.puts "Work Phone is #{contact_method}"
    end
  end

  def print_report(contact_info) do
    Enum.each(contact_info.secondary_contact_methods, &print_contact_method/1)
  end

  test "To contact a customer, there will be a list of contact methods. Each contact method could be an email OR a postal address OR a phone number" do
    contact_info = struct!(
      ContactInformation,
      primary_contact_method: WorkPhone.new("555-123-4321"),
      secondary_contact_methods: [EmailContactInfo.new("john@example.com"), HomePhone.new("555-123-1234")]
    )
    print_report(contact_info)
  end
end
