defmodule WorkOut2.EmailVerification do
  import Swoosh.Email

  def verification_email(user, code) do
    new()
    |> to({user.username, user.email})
    |> from({"noreply", "noreply@gmail.com"})
    |> subject("Email verification code")
    |> text_body("""
    Hello #{user.username}
    Your verification code is #{code}
    Thank you for choosing us.
    """)
  end
end
