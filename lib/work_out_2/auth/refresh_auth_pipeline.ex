defmodule WorkOut2.Auth.RefreshAuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :WorkOut2,
    module: WorkOut2.Guardian,
    error_handler: WorkOut2.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer", claims: %{"typ" => "refresh"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
