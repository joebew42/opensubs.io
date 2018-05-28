alias Subs.UserRepo

{:ok, user} = UserRepo.create(%{
  email: "user@opensubs.io",
  password: "password",
  password_confirmation: "password",
  currency: "EUR"
})

UserRepo.update(user, %{confirmed_at: NaiveDateTime.utc_now()})
