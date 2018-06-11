# Categorization feature #24

Try to work on the [Categorization feature](https://github.com/joaquimadraz/opensubs.io/issues/24)

## DOING

- As a user when I go the the All Payments page I want to see a summary of all my expenses for each category
  - How the `amount` field is handled (it is expressed in cents or other?)
  - Extract the logic to generate the spendings summary from `subscription_controller` to `[generate|view]_spendings_summary` use case

HTTP GET /api/subscriptions/summary

{
  data: {
    currency: "EUR",
    currency_symbol: "€",
    spendings: [
      {category: "travel", amount: 239.99},
      {category: "videogames", amount: 999.99},
      {category: "other", amount: 9.99},
      {category: "uncategorized", amount: 1900.00},
    ]
  }
}

## TODO

- Error: `SubsServices.get_services/0` is undefined
- Why we run an empty seed `apps/repository/priv/repo/seeds.exs` when we execute the `mix ecto.setup` task?
- during the `mix deps.get` we get a `quantum 2.2.1 RETIRED! (invalid) Problem with Daylight Saving Time`
- Fix warnings:
warning: variable "status" is unused
  lib/subs/domain/subscription_repo.ex:40
warning: trailing commas are not allowed inside function/macro call arguments
  test/use_cases/subscriptions/update_subscription_test.exs:58
warning: trailing commas are not allowed inside function/macro call arguments
  test/use_cases/users/authenticate_user_test.exs:50
warning: trailing commas are not allowed inside function/macro call arguments
  test/use_cases/users/reset_password_test.exs:35
warning: trailing commas are not allowed inside function/macro call arguments
  test/use_cases/users/reset_password_test.exs:51
warning: trailing commas are not allowed inside function/macro call arguments
  test/use_cases/users/reset_password_test.exs:70

## DONE

- `Other` should be the default value of category for all the new payments.
- All the payments - prior to the release of this feature - will be migrated to a `Uncategorized`category (we translate this by adding the value uncategorized in the category field?).
- Write an acceptance test to document that as a logged user I can create a new subscription by specifing its category
- Add a new field `category` to `subscriptions`
- Try to play with the application
- Run the application
- README.md: improve the section that document how to run tests. It is not documented that we have to export the MIX_ENV=test. We can create an alias for `mix test` that will create, migrate the database and then run all the tests.
- create a seed data with an initial login user so that we can be able to authenticate to the application


## QUESTIONS

- The `subs_web` tests are quite slow, is there some way to make them faster?
  - Maybe the `frontend` could be moved out from the application `subs_web`?
- It seems that is difficult to run tests of a single application. For example, when I try to run only the tests for the `subs` application, I get this error:

```
$ mix cmd --app subs mix test

== Compilation error in file test/domain/user_test.exs ==
** (CompileError) test/domain/user_test.exs:2: module SubsWeb.ConnCase is not loaded and could not be found
```

The test file `test/domain/user_test.exs` depends on a module of the `SubsWeb` application.

- Why from the frontend side we talk about `payments`, and from the backend side we talk about `subscriptions` instead?
- Why we need a sepate application for the `repository`. Is it because the repository is shared across different apps?
