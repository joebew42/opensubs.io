# OpenSubs [![Build Status](https://travis-ci.org/joaquimadraz/opensubs.io.svg?branch=master)](https://travis-ci.org/joaquimadraz/opensubs.io)
## Track recurring bills and subscriptions :money_with_wings:

Things I wrote about the project:
- [Guide to deploy an Elixir/Phoenix app to AWS ECS](https://joaquimadraz.com/guide-to-deploy-an-elixir-phoenix-app-to-aws-ecs)

### Stack
- Elixir backend
- React frontend
- PostgreSQL database

### How to run OpenSubs
1. `mix deps.get`, to install dependencies
2. `mix ecto.setup`, to create and migrate the database
3. `cd apps/subs_web/frontend && yarn install`, to install frontend dependencies
3. `mix phx.server`, to run the server, will also build the frontend

- `cd apps/subs_web/frontend && node_modules/.bin/webpack --config webpack.config.js`, to build the frontend manually

#### Running tests
- `brew install chromedriver`, to run acceptance tests (based on the operating system you are using you may have to install `chromedriver` through other package manager)

- `export MIX_ENV=test`
- `mix test`, to run all tests
- `mix test --only acceptance`, to run only acceptance tests
- `mix test --exclude acceptance`, to exclude acceptance tests

### MVP
#### Backend API
- [x] User signup/authentication
- [x] User password recovery
- [x] Services list
- [x] Subscriptions create
- [x] Subscriptions update
- [x] Subscriptions archive
- [x] Subscriptions list

#### Frontend
- [x] User signup/authentication
- [x] User password recovery
- [x] Create custom subscription
  - [x] Create from service service
- [x] List all subscriptions
- [x] Subscriptions dashboard
  - [x] Due this month
  - [x] Due next month
  - [x] Monthly payment
  - [x] Yearly payment

### Nice to have
- [ ] Categorization (personal, business, services)
- [x] Email notifications
- [ ] Web notifications

### Future
- [ ] Facebook bot

## License
MIT © [Joaquim Adraz](http://joaquimadraz.com)
