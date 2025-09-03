# Ruby on Rails Interview Questions

## Table of Contents

### Basic Concepts
- [What is Ruby on Rails?](#what-is-ruby-on-rails)
- [Explain the MVC pattern in Rails](#explain-the-mvc-pattern-in-rails)
- [What are the Rails conventions?](#what-are-the-rails-conventions)

### ActiveRecord & Database
- [What is ActiveRecord?](#what-is-activerecord)
- [Explain Rails associations](#explain-rails-associations)
- [What are Rails validations?](#what-are-rails-validations)
- [Explain Rails callbacks](#explain-rails-callbacks)
- [Explain Rails Callback Sequence Calling](#explain-rails-callback-sequence-calling)

### Routing & Controllers
- [Explain Rails routing](#explain-rails-routing)
- [What are strong parameters?](#what-are-strong-parameters)
- [Explain the request-response cycle in Rails](#explain-the-request-response-cycle-in-rails)

### Advanced Topics
- [What are Rails concerns?](#what-are-rails-concerns)
- [Explain Rails caching strategies](#explain-rails-caching-strategies)
- [What is Rack in Rails?](#what-is-rack-in-rails)
- [What are Rails gems?](#what-are-rails-gems)
- [Explain Rails migrations](#explain-rails-migrations)
- [What are Rails scopes?](#what-are-rails-scopes)
- [What are the key differences between Rails versions?](#what-are-the-key-differences-between-rails-versions)

### Testing
- [What testing frameworks are used in Rails?](#what-testing-frameworks-are-used-in-rails)
- [Write a basic RSpec test](#write-a-basic-rspec-test)

### Security
- [What are common Rails security concerns?](#what-are-common-rails-security-concerns)
- [How does Rails handle authentication?](#how-does-rails-handle-authentication)

### Performance
- [How do you optimize Rails performance?](#how-do-you-optimize-rails-performance)

### Practical Coding Questions
- [Create a simple Rails API endpoint](#create-a-simple-rails-api-endpoint)
- [Write a Rails service object](#write-a-rails-service-object)
- [Create a Rails job](#create-a-rails-job)

### System Design Questions
- [How would you design a Rails application for high traffic?](#how-would-you-design-a-rails-application-for-high-traffic)
- [Design a Rails API for a social media platform](#design-a-rails-api-for-a-social-media-platform)

### Behavioral Questions
- [How do you handle technical disagreements with team members?](#how-do-you-handle-technical-disagreements-with-team-members)
- [Describe a challenging bug you've debugged in Rails](#describe-a-challenging-bug-youve-debugged-in-rails)

---

# Ruby on Rails Interview Questions

## Basic Concepts

### <a id="what-is-ruby-on-rails"></a>**What is Ruby on Rails?**
   - Rails is a web application framework written in Ruby that follows the MVC (Model-View-Controller) pattern
   - It emphasizes convention over configuration and DRY (Don't Repeat Yourself) principles

### <a id="explain-the-mvc-pattern-in-rails"></a>**Explain the MVC pattern in Rails**
   - **Model**: Represents the data and business logic (ActiveRecord)
   - **View**: Handles the presentation layer (ERB templates)
   - **Controller**: Manages the flow between Model and View, handles requests

### <a id="what-are-the-rails-conventions"></a>**What are the Rails conventions?**
   - File naming: snake_case for files, CamelCase for classes
   - Database tables: plural nouns (users, posts)
   - Model names: singular nouns (User, Post)
   - Controller names: plural nouns (UsersController)

## ActiveRecord & Database

### <a id="what-is-activerecord"></a>**What is ActiveRecord?**
   - ActiveRecord is Rails' ORM (Object-Relational Mapping) layer
   - It provides an interface between database tables and Ruby objects
   - Handles database queries, relationships, and validations

### <a id="explain-rails-associations"></a>**Explain Rails associations**
   ```ruby
   # One-to-Many
   class User < ApplicationRecord
     has_many :posts
   end
   
   class Post < ApplicationRecord
     belongs_to :user
   end
   
   # Many-to-Many
   class User < ApplicationRecord
     has_and_belongs_to_many :roles
   end
   
   # Through association
   class User < ApplicationRecord
     has_many :posts
     has_many :comments, through: :posts
   end
   ```

### <a id="what-are-rails-validations"></a>**What are Rails validations?**
   ```ruby
   class User < ApplicationRecord
     validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :password, length: { minimum: 6 }
     validates :age, numericality: { greater_than: 0 }
   end
   ```

### <a id="explain-rails-callbacks"></a>**Explain Rails callbacks**
   ```ruby
   class User < ApplicationRecord
     before_create :generate_token
     after_save :send_welcome_email
     
     private
     
     def generate_token
       self.token = SecureRandom.hex(10)
     end
   end
   ```

### <a id="explain-rails-callback-sequence-calling"></a>**Explain Rails Callback Sequence Calling**
   ```ruby
   class User < ApplicationRecord
     # Callback sequence for create action
     before_validation :set_defaults
     before_validation :normalize_email
     after_validation :log_validation_errors
     before_save :encrypt_password
     before_create :generate_token
     after_create :send_welcome_email
     after_save :update_cache
     after_commit :notify_admin
     
     # Callback sequence for update action
     before_validation :set_defaults
     before_validation :normalize_email
     after_validation :log_validation_errors
     before_save :encrypt_password
     before_update :track_changes
     after_update :send_update_notification
     after_save :update_cache
     after_commit :notify_admin
     
     # Callback sequence for destroy action
     before_destroy :check_dependencies
     after_destroy :cleanup_associated_data
     after_commit :notify_admin_of_deletion
     
     private
     
     def set_defaults
       self.status ||= 'active'
       self.created_at ||= Time.current
     end
     
     def normalize_email
       self.email = email.downcase.strip if email.present?
     end
     
     def log_validation_errors
       Rails.logger.error "Validation errors: #{errors.full_messages}" if errors.any?
     end
     
     def encrypt_password
       self.password_hash = BCrypt::Password.create(password) if password.present?
     end
     
     def generate_token
       self.token = SecureRandom.hex(10)
     end
     
     def track_changes
       @changes = changes.dup
     end
     
     def check_dependencies
       throw(:abort) if posts.exists?
     end
   end
   ```

   **Complete Callback Sequence:**

   **For Create:**
   1. `before_validation`
   2. `validations`
   3. `after_validation`
   4. `before_save`
   5. `before_create`
   6. **Database INSERT**
   7. `after_create`
   8. `after_save`
   9. `after_commit` (after transaction commits)

   **For Update:**
   1. `before_validation`
   2. `validations`
   3. `after_validation`
   4. `before_save`
   5. `before_update`
   6. **Database UPDATE**
   7. `after_update`
   8. `after_save`
   9. `after_commit` (after transaction commits)

   **For Destroy:**
   1. `before_destroy`
   2. **Database DELETE**
   3. `after_destroy`
   4. `after_commit` (after transaction commits)

   **Key Points:**
   - `after_commit` runs after the database transaction is committed
   - `after_save` runs for both create and update operations
   - `after_create` and `after_update` run only for their respective operations
   - Callbacks can be skipped with `save(validate: false)` or `update_column`
   - Use `throw(:abort)` to halt the callback chain
   - `after_commit` is useful for external API calls or emails

## Routing & Controllers

### <a id="explain-rails-routing"></a>**Explain Rails routing**
   ```ruby
   # config/routes.rb
   Rails.application.routes.draw do
     resources :users do
       resources :posts, only: [:index, :new, :create]
     end
     
     get '/profile', to: 'users#profile'
     post '/login', to: 'sessions#create'
   end
   ```

### <a id="what-are-strong-parameters"></a>**What are strong parameters?**
   ```ruby
   class UsersController < ApplicationController
     def create
       @user = User.new(user_params)
       # Only allows permitted parameters
     end
     
     private
     
     def user_params
       params.require(:user).permit(:name, :email, :password)
     end
   end
   ```

### <a id="explain-the-request-response-cycle-in-rails"></a>**Explain the request-response cycle in Rails**
   The Rails request-response cycle follows this flow:

   **1. Web Server (e.g., Nginx, Apache)**
   - Receives HTTP request from client
   - Handles static assets (CSS, JS, images)
   - Proxies dynamic requests to application server

   **2. Application Server (e.g., Puma, Unicorn, Passenger)**
   - Receives request from web server
   - Manages Ruby processes/threads
   - Passes request to Rack middleware stack

   **2. Rack Middleware Stack**
   - Processes request through various middleware
   - Examples: Session handling, cookies, logging
   - Passes request to Rails application

   **3. Rails Router (config/routes.rb)**
   - Matches URL to controller action
   - Determines which controller and action to call
   ```ruby
   # Example route
   get '/users/:id', to: 'users#show'
   ```

   **4. Controller Action**
   - Receives request parameters
   - Performs business logic
   - Interacts with models
   - Prepares data for view
   ```ruby
   class UsersController < ApplicationController
     def show
       @user = User.find(params[:id])
       # Renders view or returns JSON
     end
   end
   ```

   **5. Model (ActiveRecord)**
   - Handles database operations
   - Performs validations
   - Manages business logic
   ```ruby
   class User < ApplicationRecord
     validates :email, presence: true
     has_many :posts
   end
   ```

   **6. View (ERB/HAML/Slim)**
   - Renders HTML/JSON response
   - Uses data from controller
   - Handles presentation logic

   **7. Response Flow**
   - View renders response
   - Controller returns response
   - Rack middleware processes response
   - Web server sends response to client

   **Key Components:**
   - **Rack**: Web server interface
   - **Router**: URL to controller mapping
   - **Controller**: Request handling logic
   - **Model**: Data and business logic
   - **View**: Response rendering
   - **Middleware**: Request/response processing

## Advanced Topics

### <a id="what-are-rails-concerns"></a>**What are Rails concerns?**

**Rails concerns** are modules that allow you to extract common functionality and share it across multiple classes. They help in organizing code by grouping related methods and behaviors, promoting code reusability and maintaining the DRY (Don't Repeat Yourself) principle.

**Key Points:**

1. **Purpose**: Concerns help avoid code duplication and keep models focused on their core responsibilities
2. **Location**: Stored in `app/models/concerns/` directory
3. **Naming**: Follow the convention of ending with "able" (e.g., `Searchable`, `Taggable`, `Voteable`)
4. **Structure**: Use `ActiveSupport::Concern` to define concerns

**Basic Structure:**
```ruby
# app/models/concerns/searchable.rb
module Searchable
  extend ActiveSupport::Concern
  
  included do
    # Class-level configurations (scopes, validations, callbacks)
    scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
    validates :searchable_field, presence: true
  end
  
  # Instance methods
  def search_method
    # Instance method logic
  end
  
  # Class methods (optional)
  class_methods do
    def class_search_method
      # Class method logic
    end
  end
end
```

**Usage Example:**
```ruby
class User < ApplicationRecord
  include Searchable
end

class Product < ApplicationRecord
  include Searchable
end
```

**Benefits:**
- **Code Reusability**: Share functionality across multiple models
- **Maintainability**: Centralized logic is easier to maintain
- **Readability**: Models become more focused and readable
- **Testing**: Concerns can be tested independently

**Common Use Cases:**
- Search functionality
- Soft deletes
- Timestamp tracking
- Authorization logic
- API response formatting

### <a id="explain-rails-caching-strategies"></a>**Explain Rails caching strategies**
    - **Page caching**: Caches entire pages
    - **Action caching**: Caches controller actions
    - **Fragment caching**: Caches parts of views
    - **Russian doll caching**: Nested fragment caching

### <a id="what-is-rack-in-rails"></a>**What is Rack in Rails?**
    - Rack is a web server interface that Rails uses
    - It provides a minimal interface between web servers and Ruby frameworks
    - Rails applications are Rack applications

### <a id="what-are-rails-gems"></a>**What are Rails gems?**
    - Gems are Ruby packages that extend Rails functionality
    - Popular gems: Devise (authentication), CanCanCan (authorization), Sidekiq (background jobs)
    - Managed through Gemfile and Bundler

### <a id="explain-rails-migrations"></a>**Explain Rails migrations**
    ```ruby
    class CreateUsers < ActiveRecord::Migration[7.0]
      def change
        create_table :users do |t|
          t.string :name, null: false
          t.string :email, null: false
          t.timestamps
        end
        
        add_index :users, :email, unique: true
      end
    end
    ```

### <a id="what-are-rails-scopes"></a>**What are Rails scopes?**
    ```ruby
    class User < ApplicationRecord
      scope :active, -> { where(active: true) }
      scope :recent, -> { where('created_at > ?', 1.week.ago) }
      scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") }
    end
    ```

### <a id="what-are-the-key-differences-between-rails-versions"></a>**What are the key differences between Rails versions?**

**Rails 6 vs Rails 7:**

**Rails 7 Key Features:**
- **Import Maps**: Built-in JavaScript bundling without Node.js
- **Hotwire**: Real-time updates with Turbo and Stimulus
- **CSS Bundling**: Built-in CSS bundling with esbuild, rollup, or webpack
- **Action Text**: Rich text editing with Trix editor
- **Action Mailbox**: Incoming email processing
- **Zeitwerk**: New autoloader replacing classic autoloader
- **Parallel Testing**: Built-in parallel test execution
- **Credentials**: Encrypted credentials management
- **Multiple Database Support**: Built-in support for multiple databases
- **Action Cable**: WebSocket support for real-time features

**Rails 6 Key Features:**
- **Action Text**: Rich text editing (introduced in 6.0)
- **Action Mailbox**: Incoming email processing (introduced in 6.0)
- **Multiple Database Support**: Basic support for multiple databases
- **Action Cable**: WebSocket support
- **Webpacker**: JavaScript bundling (deprecated in Rails 7)

**Key Differences:**
```ruby
# Rails 7 - Import Maps (no Node.js required)
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"

# Rails 6 - Webpacker (requires Node.js)
# config/webpacker.yml
default: &default
  source_path: app/javascript
  source_entry_path: packs
  public_root_path: public
  public_output_path: packs

# Rails 7 - CSS Bundling
# Gemfile
gem 'cssbundling-rails'

# Rails 6 - Manual CSS setup
# app/assets/stylesheets/application.scss
@import "bootstrap";

# Rails 7 - Zeitwerk Autoloader
# config/application.rb
config.autoloader = :zeitwerk

# Rails 6 - Classic Autoloader
# config/application.rb
config.autoloader = :classic
```

**Rails 7 vs Rails 8:**

**Rails 8 Key Features:**
- **Ruby 3.4+**: Requires Ruby 3.4 or higher
- **Enhanced Import Maps**: Improved JavaScript handling
- **Better Hotwire Integration**: Enhanced Turbo and Stimulus
- **Improved Performance**: Better caching and database optimizations
- **Enhanced Security**: Updated security features
- **Modern JavaScript**: Better ES6+ support
- **Improved Testing**: Enhanced testing capabilities
- **Better Documentation**: Improved guides and documentation

**Key Differences:**
```ruby
# Rails 8 - Enhanced Import Maps
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true

# Rails 7 - Basic Import Maps
# config/importmap.rb
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"

# Rails 8 - Enhanced Hotwire
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Turbo::FramesHelper
  include Turbo::StreamsHelper
end

# Rails 7 - Basic Hotwire
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
end
```

**Migration Considerations:**

**From Rails 6 to Rails 7:**
- Replace Webpacker with Import Maps or esbuild
- Update autoloader from classic to Zeitwerk
- Update JavaScript dependencies
- Review Action Text and Action Mailbox usage
- Update test configuration for parallel testing

**From Rails 7 to Rails 8:**
- Ensure Ruby 3.4+ compatibility
- Update JavaScript dependencies
- Review Hotwire implementation
- Update test configuration
- Review security settings

**Performance Improvements:**
- Rails 7: ~20-30% faster than Rails 6
- Rails 8: Additional 10-15% improvement over Rails 7
- Better memory usage and garbage collection
- Improved database query optimization

## Testing

### <a id="what-testing-frameworks-are-used-in-rails"></a>**What testing frameworks are used in Rails?**
    - **RSpec**: Popular testing framework with descriptive syntax
    - **Minitest**: Rails' default testing framework
    - **FactoryBot**: For creating test data
    - **Capybara**: For integration testing

### <a id="write-a-basic-rspec-test"></a>**Write a basic RSpec test**
    ```ruby
    require 'rails_helper'
    
    RSpec.describe User, type: :model do
      describe 'validations' do
        it 'is valid with valid attributes' do
          user = User.new(name: 'John', email: 'john@example.com')
          expect(user).to be_valid
        end
        
        it 'is not valid without an email' do
          user = User.new(name: 'John')
          expect(user).not_to be_valid
        end
      end
    end
    ```

## Security

### <a id="what-are-common-rails-security-concerns"></a>**What are common Rails security concerns?**
    - **SQL Injection**: Use parameterized queries
    - **XSS (Cross-Site Scripting)**: Rails automatically escapes output
    - **CSRF (Cross-Site Request Forgery)**: Rails includes CSRF protection
    - **Mass Assignment**: Use strong parameters

### <a id="how-does-rails-handle-authentication"></a>**How does Rails handle authentication?**
    - Devise gem provides authentication out of the box
    - Custom authentication using bcrypt for password hashing
    - JWT tokens for API authentication

## Performance

### <a id="how-do-you-optimize-rails-performance"></a>**How do you optimize Rails performance?**
    - Database indexing
    - Eager loading associations (includes, preload)
    - Caching (page, action, fragment)
    - Background job processing (Sidekiq, Delayed Job)
    - Database query optimization

## Practical Coding Questions

### <a id="create-a-simple-rails-api-endpoint"></a>**Create a simple Rails API endpoint**
    ```ruby
    # app/controllers/api/v1/users_controller.rb
    class Api::V1::UsersController < ApplicationController
      def index
        users = User.all
        render json: users
      end
      
      def create
        user = User.new(user_params)
        if user.save
          render json: user, status: :created
        else
          render json: { errors: user.errors }, status: :unprocessable_entity
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(:name, :email)
      end
    end
    ```

### <a id="write-a-rails-service-object"></a>**Write a Rails service object**
    ```ruby
    # app/services/user_registration_service.rb
    class UserRegistrationService
      def initialize(user_params)
        @user_params = user_params
      end
      
      def call
        user = User.new(@user_params)
        if user.save
          UserMailer.welcome_email(user).deliver_later
          { success: true, user: user }
        else
          { success: false, errors: user.errors }
        end
      end
    end
    ```

### <a id="create-a-rails-job"></a>**Create a Rails job**
    ```ruby
    # app/jobs/email_job.rb
    class EmailJob < ApplicationJob
      queue_as :default
      
      def perform(user_id)
        user = User.find(user_id)
        UserMailer.welcome_email(user).deliver_now
      end
    end
    ```

## System Design Questions

### <a id="how-would-you-design-a-rails-application-for-high-traffic"></a>**How would you design a Rails application for high traffic?**
    - Load balancing with multiple application servers
    - Database read replicas
    - Redis for caching and session storage
    - CDN for static assets
    - Background job processing

### <a id="design-a-rails-api-for-a-social-media-platform"></a>**Design a Rails API for a social media platform**
    - RESTful API design
    - Authentication with JWT tokens
    - Rate limiting
    - Pagination for large datasets
    - Real-time features with ActionCable

## Behavioral Questions

### <a id="how-do-you-handle-technical-disagreements-with-team-members"></a>**How do you handle technical disagreements with team members?**
    - Focus on data and evidence
    - Consider multiple perspectives
    - Be open to changing your mind
    - Document decisions and rationale

### <a id="describe-a-challenging-bug-youve-debugged-in-rails"></a>**Describe a challenging bug you've debugged in Rails**
    - Explain your debugging process
    - Show systematic thinking
    - Demonstrate persistence and problem-solving skills

---

## Related Files

For additional Rails interview questions, please refer to the following specialized files:

- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Mid-level to Senior-level Rails concepts
- **[Additional Ruby & Rails Concepts](ruby-on-rails-additional-concepts-interview-questions.md)** - Advanced Ruby concepts and Rails patterns
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals and core concepts

## <a id="tips-for-rails-interview-success"></a>Tips for Rails Interview Success

- Practice writing Rails code without an IDE
- Understand ActiveRecord queries and relationships
- Know common gems and their purposes
- Be familiar with Rails conventions
- Practice writing tests
- Understand Rails security best practices
- Be honest about what you don't know
- Show enthusiasm for learning and growth
- Understand Rails performance optimization techniques
- Know deployment and DevOps practices
- Be familiar with microservices and distributed systems
- Understand Rails architectural patterns
