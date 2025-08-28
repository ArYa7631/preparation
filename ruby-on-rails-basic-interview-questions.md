# Ruby on Rails Basic to Mid-Level Interview Questions

## Table of Contents

### Basic Concepts
- [1. What is Ruby on Rails?](#1-what-is-ruby-on-rails)
- [2. Explain the MVC pattern in Rails](#2-explain-the-mvc-pattern-in-rails)
- [3. What are the Rails conventions?](#3-what-are-the-rails-conventions)

### ActiveRecord & Database
- [4. What is ActiveRecord?](#4-what-is-activerecord)
- [5. Explain Rails associations](#5-explain-rails-associations)
- [6. What are Rails validations?](#6-what-are-rails-validations)
- [7. Explain Rails callbacks](#7-explain-rails-callbacks)

### Routing & Controllers
- [8. Explain Rails routing](#8-explain-rails-routing)
- [9. What are strong parameters?](#9-what-are-strong-parameters)

### Advanced Topics
- [10. What are Rails concerns?](#10-what-are-rails-concerns)
- [11. Explain Rails caching strategies](#11-explain-rails-caching-strategies)
- [12. What is Rack in Rails?](#12-what-is-rack-in-rails)
- [13. What are Rails gems?](#13-what-are-rails-gems)
- [14. Explain Rails migrations](#14-explain-rails-migrations)
- [15. What are Rails scopes?](#15-what-are-rails-scopes)

### Testing
- [16. What testing frameworks are used in Rails?](#16-what-testing-frameworks-are-used-in-rails)
- [17. Write a basic RSpec test](#17-write-a-basic-rspec-test)

### Security
- [18. What are common Rails security concerns?](#18-what-are-common-rails-security-concerns)
- [19. How does Rails handle authentication?](#19-how-does-rails-handle-authentication)

### Performance
- [20. How do you optimize Rails performance?](#20-how-do-you-optimize-rails-performance)

### Practical Coding Questions
- [21. Create a simple Rails API endpoint](#21-create-a-simple-rails-api-endpoint)
- [22. Write a Rails service object](#22-write-a-rails-service-object)
- [23. Create a Rails job](#23-create-a-rails-job)

### System Design Questions
- [24. How would you design a Rails application for high traffic?](#24-how-would-you-design-a-rails-application-for-high-traffic)
- [25. Design a Rails API for a social media platform](#25-design-a-rails-api-for-a-social-media-platform)

### Behavioral Questions
- [26. How do you handle technical disagreements with team members?](#26-how-do-you-handle-technical-disagreements-with-team-members)
- [27. Describe a challenging bug you've debugged in Rails](#27-describe-a-challenging-bug-youve-debugged-in-rails)

---

## Related Files
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts (Questions 28-42)
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals (Questions 43-73)

---

## Basic Concepts

### <a id="1-what-is-ruby-on-rails"></a>1. **What is Ruby on Rails?**
   - Rails is a web application framework written in Ruby that follows the MVC (Model-View-Controller) pattern
   - It emphasizes convention over configuration and DRY (Don't Repeat Yourself) principles

### <a id="2-explain-the-mvc-pattern-in-rails"></a>2. **Explain the MVC pattern in Rails**
   - **Model**: Represents the data and business logic (ActiveRecord)
   - **View**: Handles the presentation layer (ERB templates)
   - **Controller**: Manages the flow between Model and View, handles requests

### <a id="3-what-are-the-rails-conventions"></a>3. **What are the Rails conventions?**
   - File naming: snake_case for files, CamelCase for classes
   - Database tables: plural nouns (users, posts)
   - Model names: singular nouns (User, Post)
   - Controller names: plural nouns (UsersController)

## ActiveRecord & Database

### <a id="4-what-is-activerecord"></a>4. **What is ActiveRecord?**
   - ActiveRecord is Rails' ORM (Object-Relational Mapping) layer
   - It provides an interface between database tables and Ruby objects
   - Handles database queries, relationships, and validations

### <a id="5-explain-rails-associations"></a>5. **Explain Rails associations**
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

### <a id="6-what-are-rails-validations"></a>6. **What are Rails validations?**
   ```ruby
   class User < ApplicationRecord
     validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
     validates :password, length: { minimum: 6 }
     validates :age, numericality: { greater_than: 0 }
   end
   ```

### <a id="7-explain-rails-callbacks"></a>7. **Explain Rails callbacks**
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

## Routing & Controllers

### <a id="8-explain-rails-routing"></a>8. **Explain Rails routing**
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

### <a id="9-what-are-strong-parameters"></a>9. **What are strong parameters?**
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

## Advanced Topics

### <a id="10-what-are-rails-concerns"></a>10. **What are Rails concerns?**
    ```ruby
    # app/models/concerns/searchable.rb
    module Searchable
      extend ActiveSupport::Concern
      
      included do
        scope :search, ->(query) { where("name LIKE ?", "%#{query}%") }
      end
    end
    
    class User < ApplicationRecord
      include Searchable
    end
    ```

### <a id="11-explain-rails-caching-strategies"></a>11. **Explain Rails caching strategies**
    - **Page caching**: Caches entire pages
    - **Action caching**: Caches controller actions
    - **Fragment caching**: Caches parts of views
    - **Russian doll caching**: Nested fragment caching

### <a id="12-what-is-rack-in-rails"></a>12. **What is Rack in Rails?**
    - Rack is a web server interface that Rails uses
    - It provides a minimal interface between web servers and Ruby frameworks
    - Rails applications are Rack applications

### <a id="13-what-are-rails-gems"></a>13. **What are Rails gems?**
    - Gems are Ruby packages that extend Rails functionality
    - Popular gems: Devise (authentication), CanCanCan (authorization), Sidekiq (background jobs)
    - Managed through Gemfile and Bundler

### <a id="14-explain-rails-migrations"></a>14. **Explain Rails migrations**
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

### <a id="15-what-are-rails-scopes"></a>15. **What are Rails scopes?**
    ```ruby
    class User < ApplicationRecord
      scope :active, -> { where(active: true) }
      scope :recent, -> { where('created_at > ?', 1.week.ago) }
      scope :by_name, ->(name) { where('name LIKE ?', "%#{name}%") }
    end
    ```

## Testing

### <a id="16-what-testing-frameworks-are-used-in-rails"></a>16. **What testing frameworks are used in Rails?**
    - **RSpec**: Popular testing framework with descriptive syntax
    - **Minitest**: Rails' default testing framework
    - **FactoryBot**: For creating test data
    - **Capybara**: For integration testing

### <a id="17-write-a-basic-rspec-test"></a>17. **Write a basic RSpec test**
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

### <a id="18-what-are-common-rails-security-concerns"></a>18. **What are common Rails security concerns?**
    - **SQL Injection**: Use parameterized queries
    - **XSS (Cross-Site Scripting)**: Rails automatically escapes output
    - **CSRF (Cross-Site Request Forgery)**: Rails includes CSRF protection
    - **Mass Assignment**: Use strong parameters

### <a id="19-how-does-rails-handle-authentication"></a>19. **How does Rails handle authentication?**
    - Devise gem provides authentication out of the box
    - Custom authentication using bcrypt for password hashing
    - JWT tokens for API authentication

## Performance

### <a id="20-how-do-you-optimize-rails-performance"></a>20. **How do you optimize Rails performance?**
    - Database indexing
    - Eager loading associations (includes, preload)
    - Caching (page, action, fragment)
    - Background job processing (Sidekiq, Delayed Job)
    - Database query optimization

## Practical Coding Questions

### <a id="21-create-a-simple-rails-api-endpoint"></a>21. **Create a simple Rails API endpoint**
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

### <a id="22-write-a-rails-service-object"></a>22. **Write a Rails service object**
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

### <a id="23-create-a-rails-job"></a>23. **Create a Rails job**
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

### <a id="24-how-would-you-design-a-rails-application-for-high-traffic"></a>24. **How would you design a Rails application for high traffic?**
    - Load balancing with multiple application servers
    - Database read replicas
    - Redis for caching and session storage
    - CDN for static assets
    - Background job processing

### <a id="25-design-a-rails-api-for-a-social-media-platform"></a>25. **Design a Rails API for a social media platform**
    - RESTful API design
    - Authentication with JWT tokens
    - Rate limiting
    - Pagination for large datasets
    - Real-time features with ActionCable

## Behavioral Questions

### <a id="26-how-do-you-handle-technical-disagreements-with-team-members"></a>26. **How do you handle technical disagreements with team members?**
    - Focus on data and evidence
    - Consider multiple perspectives
    - Be open to changing your mind
    - Document decisions and rationale

### <a id="27-describe-a-challenging-bug-youve-debugged-in-rails"></a>27. **Describe a challenging bug you've debugged in Rails**
    - Explain your debugging process
    - Show systematic thinking
    - Demonstrate persistence and problem-solving skills

---

## Next Steps
Ready for more advanced topics? Check out:
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts
- **[Core Ruby & Rails Concepts](ruby-on-rails-core-concepts-interview-questions.md)** - Language fundamentals
