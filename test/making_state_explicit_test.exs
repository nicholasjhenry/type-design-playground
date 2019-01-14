defmodule MakingStateExplicitTest do
  use ExUnit.Case
  use CivilTypes

  deftype EmailAddress, String.t
  deftype UnverifiedData, EmailAddress.t()
  deftype VerifiedData, {EmailAddress.t(), DateTime.t()}

  deftype EmailContactInfo, UnverifiedData | VerifiedData

  def create(email) do
    EmailContactInfo.new(UnverifiedData.new(email))
  end

  def verified(email_contact_info, date_verified) do
    case email_contact_info.value do
      %UnverifiedData{} -> EmailContactInfo.new(VerifiedData.new({email_contact_info.value.value, date_verified}))
      %VerifiedData{} -> email_contact_info
    end
  end

  def send_verification_email(email_contact_info) do
    case email_contact_info.value do
      %UnverifiedData{} ->
        IO.puts("sending email")
        email_contact_info
      %VerifiedData{} -> :noop
    end
  end

  def send_password_reset(email_contact_info) do
    case email_contact_info.value do
      %UnverifiedData{} -> :noop
      %VerifiedData{} ->
        IO.puts("sending password reset")
        email_contact_info
    end
  end

  test "explicit states" do
    "john@example.com"
    |> create
    |> send_verification_email
    |> verified(DateTime.utc_now)
    |> send_password_reset
  end
end
