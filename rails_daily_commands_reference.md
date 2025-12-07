# Rails Daily Commands Reference

A concise guide for commonly used Rails commands with generated files and anchor tags.

## <a id="rails-new-project"></a>**Create New Rails Project**

* Command:

```bash
rails new my_app
```

* Files generated:

  * `Gemfile`, `Rakefile`, `config/`, `app/`, `db/`, `bin/`, `lib/`, `test/` or `spec/`

## <a id="generate-model"></a>**Generate Model**

* Command:

```bash
rails generate model User name:string email:string
```

* Files generated:

  * `app/models/user.rb`
  * Migration file in `db/migrate/`
  * Test/spec files: `test/models/user_test.rb` or `spec/models/user_spec.rb`

## <a id="generate-controller"></a>**Generate Controller**

* Command:

```bash
rails generate controller Users index show new edit
```

* Files generated:

  * `app/controllers/users_controller.rb`
  * Views: `app/views/users/index.html.erb`, `show.html.erb`, etc.
  * Helper: `app/helpers/users_helper.rb`
  * Test/spec: `test/controllers/users_controller_test.rb` or `spec/controllers/users_controller_spec.rb`

## <a id="generate-scaffold"></a>**Generate Scaffold**

* Command:

```bash
rails generate scaffold Post title:string content:text
```

* Files generated:

  * Model: `app/models/post.rb`
  * Controller: `app/controllers/posts_controller.rb`
  * Views: `app/views/posts/*`
  * Migration file: `db/migrate/`
  * Helper: `app/helpers/posts_helper.rb`
  * Test/spec files: `test/*` or `spec/*`

## <a id="db-migrate"></a>**Database Migrate**

* Command:

```bash
rails db:migrate
```

* Files affected:

  * Executes migration files in `db/migrate/`
  * Updates `schema.rb`

## <a id="db-rollback"></a>**Database Rollback**

* Command:

```bash
rails db:rollback
```

* Files affected:

  * Reverts last migration in `db/migrate/`
  * Updates `schema.rb`

## <a id="db-seed"></a>**Database Seed**

* Command:

```bash
rails db:seed
```

* Files affected:

  * Executes `db/seeds.rb`

## <a id="db-setup"></a>**Database Setup**

* Command:

```bash
rails db:setup
```

* Files affected:

  * Creates the database, loads schema, runs seeds

## <a id="db-reset"></a>**Database Reset**

* Command:

```bash
rails db:reset
```

* Files affected:

  * Drops, creates, migrates, and seeds database

## <a id="server-start"></a>**Start Rails Server**

* Command:

```bash
rails server
```

* Files affected:

  * No files generated; starts the local server

## <a id="console"></a>**Rails Console**

* Command:

```bash
rails console
```

* Files affected:

  * No files generated; opens interactive console

## <a id="routes"></a>**Show Routes**

* Command:

```bash
rails routes
```

* Files affected:

  * Displays routes defined in `config/routes.rb`

## <a id="generate-migration"></a>**Generate Migration**

* Command:

```bash
rails generate migration AddAgeToUsers age:integer
```

* Files generated:

  * Migration file in `db/migrate/`

## <a id="destroy"></a>**Destroy Generated Resource**

* Command:

```bash
rails destroy model User
```

* Files affected:

  * Removes files generated for that resource (model, migration, tests, etc.)

## <a id="credentials-edit"></a>**Edit Credentials**

* Command:

```bash
rails credentials:edit
```

* Files affected:

  * Edits `config/credentials.yml.enc`

## <a id="jobs-work"></a>**Run Background Jobs**

* Command:

```bash
rails jobs:work
```

* Files affected:

  * Processes jobs from `app/jobs`

## <a id="log-clear"></a>**Clear Logs**

* Command:

```bash
rails log:clear
```

* Files affected:

  * Clears log files in `log/`

## <a id="fixtures-load"></a>**Load Fixtures**

* Command:

```bash
rails db:fixtures:load
```

* Files affected:

  * Loads fixture data from `test/fixtures` into database
