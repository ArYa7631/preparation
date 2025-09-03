# Ruby on Rails Daily Useful Commands

## Table of Contents

### Development & Setup
- [Project Management](#project-management)
- [Database Operations](#database-operations)
- [Console & Debugging](#console--debugging)
- [Testing](#testing)
- [Asset Management](#asset-management)
- [Deployment & Production](#deployment--production)
- [Gem Management](#gem-management)
- [Rake Tasks](#rake-tasks)
- [Server Management](#server-management)
- [File Operations](#file-operations)

---

## Project Management

### Creating New Projects
```bash
# Create new Rails app
rails new my_app
rails new my_app --api                    # API-only app
rails new my_app --database=postgresql    # With specific database
rails new my_app --skip-test              # Skip test framework
rails new my_app --webpacker              # With webpacker

# Generate components
rails generate controller Users index show
rails generate model User name:string email:string
rails generate scaffold Post title:string content:text
rails generate migration AddFieldToTable field_name:type
rails generate service EmailService
rails generate job ProcessPayment
rails generate mailer UserMailer
```

### Project Structure
```bash
# View routes
rails routes
rails routes | grep user                    # Filter routes
rails routes -g user                        # Alternative grep

# View environment
rails about
rails version
rails environment                           # Show current environment
```

---

## Database Operations

### Database Management
```bash
# Database operations
rails db:create                            # Create database
rails db:drop                              # Drop database
rails db:migrate                           # Run pending migrations
rails db:migrate:status                    # Check migration status
rails db:rollback                          # Rollback last migration
rails db:rollback STEP=3                   # Rollback 3 migrations
rails db:reset                             # Drop, create, migrate, seed
rails db:seed                              # Run seed data
rails db:setup                             # Create, migrate, seed
rails db:version                           # Show current schema version
```

### Migration Commands
```bash
# Generate migrations
rails generate migration AddUserToPosts user:references
rails generate migration CreateJoinTable posts tags
rails generate migration RemoveFieldFromTable field_name

# Migration helpers
rails db:migrate:up VERSION=20231201123456    # Run specific migration
rails db:migrate:down VERSION=20231201123456  # Rollback specific migration
```

### Database Console
```bash
# Database console
rails dbconsole                             # Open database console
rails dbconsole -p                          # With password prompt

# PostgreSQL specific
psql -h localhost -U username -d database_name
```

---

## Console & Debugging

### Rails Console
```bash
# Console operations
rails console                               # Start console
rails console --sandbox                     # Sandbox mode (auto-rollback)
rails console -e production                 # Production environment

# Console shortcuts
rails c                                     # Short for console
rails c --sandbox                          # Short for sandbox console
```

### Debugging & Logging
```bash
# View logs
tail -f log/development.log                # Follow development logs
tail -f log/production.log                 # Follow production logs
rails log:clear                            # Clear log files

# Debug helpers
rails runner "puts User.count"             # Run single command
rails runner "User.find_each(&:save)"      # Run complex command
```

---

## Testing

### Test Execution
```bash
# Run tests
rails test                                  # Run all tests
rails test test/models/                    # Run model tests
rails test test/controllers/               # Run controller tests
rails test test/integration/               # Run integration tests
rails test test/system/                    # Run system tests
rails test test/helpers/                   # Run helper tests

# Specific test files
rails test test/models/user_test.rb
rails test test/controllers/users_controller_test.rb

# RSpec (if using)
bundle exec rspec                           # Run all specs
bundle exec rspec spec/models/              # Run model specs
bundle exec rspec --format documentation    # Detailed output
```

### Test Database
```bash
# Test database operations
rails test:prepare                          # Prepare test database
rails test:db:test:prepare                 # Alternative way
RAILS_ENV=test rails db:migrate            # Migrate test database
```

---

## Asset Management

### Asset Pipeline
```bash
# Asset compilation
rails assets:precompile                     # Precompile assets
rails assets:clean                          # Clean old assets
rails assets:clobber                        # Remove all assets
rails assets:environment                    # Load asset environment

# Webpacker (if using)
rails webpacker:install                     # Install webpacker
rails webpacker:compile                     # Compile webpack assets
rails webpacker:clobber                     # Clean webpack assets
```

---

## Deployment & Production

### Production Commands
```bash
# Production setup
RAILS_ENV=production rails db:migrate      # Production migration
RAILS_ENV=production rails assets:precompile
RAILS_ENV=production rails console         # Production console

# Environment variables
RAILS_ENV=production rails server          # Production server
```

### Server Management
```bash
# Server operations
rails server                                # Start development server
rails server -p 3001                       # Custom port
rails server -b 0.0.0.0                    # Bind to all interfaces
rails server -e production                  # Production environment
```

---

## Gem Management

### Bundle Operations
```bash
# Bundle commands
bundle install                              # Install gems
bundle update                               # Update gems
bundle update rails                         # Update specific gem
bundle outdated                             # Check outdated gems
bundle exec rails server                    # Run with bundle
bundle show rails                           # Show gem location
bundle list                                 # List installed gems
```

---

## Rake Tasks

### Built-in Rake Tasks
```bash
# List all rake tasks
rails -T                                    # Show all tasks
rails -T db                                # Show db-related tasks
rails -T assets                            # Show asset tasks

# Common rake tasks
rails routes:cache                          # Cache routes
rails tmp:clear                             # Clear temporary files
rails tmp:cache:clear                       # Clear cache
rails log:clear                             # Clear logs
rails middleware                            # Show middleware stack
```

### Custom Rake Tasks
```bash
# Generate custom rake task
rails generate task my_task

# Run custom rake task
rails my_task
rails my_task[param1,param2]               # With parameters
```

---

## Server Management

### Server Control
```bash
# Start/stop server
rails server                                # Start server
rails server -d                             # Start in background
pkill -f "rails server"                    # Stop server
lsof -ti:3000 | xargs kill                 # Kill process on port 3000

# Server info
lsof -i :3000                              # Check what's using port 3000
netstat -tulpn | grep :3000                # Alternative port check
```

---

## File Operations

### File Management
```bash
# Generate files
rails generate controller ControllerName action1 action2
rails generate model ModelName field1:type field2:type
rails generate migration MigrationName
rails generate scaffold ModelName field1:type field2:type

# Remove generated files
rails destroy controller ControllerName
rails destroy model ModelName
rails destroy migration MigrationName
rails destroy scaffold ModelName
```

### Configuration Files
```bash
# Edit common config files
vim config/routes.rb                        # Routes
vim config/database.yml                     # Database config
vim config/application.rb                   # Application config
vim config/environments/development.rb      # Environment config
```

---

## Daily Workflow Commands

### Morning Routine
```bash
# Start development day
git pull origin main                        # Pull latest changes
bundle install                              # Install new gems
rails db:migrate                            # Run pending migrations
rails server                                # Start development server
```

### Before Committing
```bash
# Pre-commit checks
rails test                                  # Run tests
rails routes:cache                          # Cache routes
rails assets:precompile                     # Precompile assets
rails log:clear                             # Clean logs
```

### Troubleshooting
```bash
# Common fixes
rails tmp:clear                             # Clear temp files
rails log:clear                             # Clear logs
rails db:reset                              # Reset database
bundle exec rails server                     # Force bundle execution
```

---

## Environment-Specific Commands

### Development
```bash
# Development shortcuts
rails c                                     # Console
rails s                                     # Server
rails routes                                # View routes
rails db:migrate                            # Migrate
```

### Staging/Production
```bash
# Production commands
RAILS_ENV=staging rails db:migrate
RAILS_ENV=production rails assets:precompile
RAILS_ENV=production rails console
```

---

## Tips & Tricks

### Useful Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias rs='rails server'
alias rc='rails console'
alias rr='rails routes'
alias rd='rails db:migrate'
alias rdr='rails db:rollback'
alias rt='rails test'
alias rts='rails test:system'
```

### Quick Commands
```bash
# One-liners
rails runner "User.count"                   # Count users
rails runner "User.last.update(name: 'New Name')"  # Update last user
rails runner "puts User.pluck(:name)"       # List user names
```

---

## Troubleshooting Common Issues

### Database Issues
```bash
# Database problems
rails db:drop rails db:create rails db:migrate  # Reset database
rails db:migrate:reset                        # Alternative reset
```

### Asset Issues
```bash
# Asset problems
rails assets:clobber rails assets:precompile   # Rebuild assets
rails tmp:clear                                # Clear temp files
```

### Server Issues
```bash
# Server problems
pkill -f "rails server"                       # Kill all rails servers
lsof -ti:3000 | xargs kill                    # Kill process on port 3000
```

---

## Performance Commands

### Performance Monitoring
```bash
# Performance tools
rails profiler                               # Profile application
rails benchmark                              # Benchmark code
rails time:zones:all                         # List time zones
```

---

## Security Commands

### Security Checks
```bash
# Security tools
rails secret                                 # Generate secret key
rails credentials:edit                       # Edit credentials
rails credentials:show                       # Show credentials
```

---

## Maintenance Commands

### Regular Maintenance
```bash
# Weekly/monthly maintenance
rails log:clear                              # Clear old logs
rails tmp:clear                              # Clear temp files
rails assets:clean                           # Clean old assets
bundle outdated                               # Check for gem updates
```

---

## Notes

- **Always check your current environment** before running production commands
- **Use `--sandbox`** when testing in console to avoid data changes
- **Keep your gems updated** regularly for security patches
- **Backup your database** before major operations
- **Test in development** before running in production
- **Use version control** for all configuration changes

---

## Quick Reference Card

### Most Used Commands
```bash
rails server          # Start server
rails console         # Open console
rails routes          # View routes
rails db:migrate      # Run migrations
rails test            # Run tests
rails generate        # Generate files
rails destroy         # Remove files
bundle install        # Install gems
```

### Emergency Commands
```bash
pkill -f "rails server"                    # Stop all servers
rails db:reset                              # Reset database
rails tmp:clear                             # Clear temp files
rails log:clear                             # Clear logs
```

This file serves as a quick reference for daily Ruby on Rails development tasks. Keep it handy for common operations and troubleshooting!
