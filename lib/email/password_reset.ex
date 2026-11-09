defmodule WorkOut2.PasswordReset do
  import Swoosh.Email

  def password_reset_code(user, code) do
    new()
    |> to({user.username, user.email})
    |> from({"noreply", "noreply@gmail.com"})
    |> subject("Password reset code")
    |> text_body("""
    Hello #{user.username}
    Your password reset code is #{code}
    Thank you for choosing us.
    """)
  end
end
