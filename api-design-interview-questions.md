# Ruby on Rails API Design Interview Questions

## Table of Contents

### API Design Fundamentals
- [What is API design in Rails?](#what-is-api-design-in-rails)
- [RESTful API principles](#restful-api-principles)
- [API versioning strategies](#api-versioning-strategies)
- [HTTP status codes and responses](#http-status-codes-and-responses)

### Rails API Implementation
- [Rails API-only applications](#rails-api-only-applications)
- [API controllers and routing](#api-controllers-and-routing)
- [Request/Response handling](#request-response-handling)
- [API serialization](#api-serialization)

### Authentication & Authorization
- [API authentication methods](#api-authentication-methods)
- [JWT token implementation](#jwt-token-implementation)
- [API authorization patterns](#api-authorization-patterns)

### API Best Practices
- [Error handling and validation](#error-handling-and-validation)
- [Rate limiting and throttling](#rate-limiting-and-throttling)
- [API documentation](#api-documentation)
- [Testing APIs](#testing-apis)

### Performance & Security
- [API performance optimization](#api-performance-optimization)
- [API security best practices](#api-security-best-practices)
- [Caching strategies for APIs](#caching-strategies-for-apis)

### Advanced Topics
- [GraphQL vs REST APIs](#graphql-vs-rest-apis)
- [Microservices and API design](#microservices-and-api-design)
- [API monitoring and logging](#api-monitoring-and-logging)

---
---

## API Design Fundamentals

### What is API design in Rails?

API design in Rails refers to creating well-structured, consistent, and maintainable interfaces for applications to communicate with each other. It involves designing endpoints, request/response formats, authentication mechanisms, and following RESTful principles.

Key aspects include:
- **Consistency**: Uniform naming conventions and response structures
- **Statelessness**: Each request contains all necessary information
- **Scalability**: Design that can handle growth and changes
- **Documentation**: Clear API documentation for developers
- **Versioning**: Strategy for handling API evolution

### RESTful API principles

REST (Representational State Transfer) is an architectural style for designing web services:

**Core Principles:**
- **Client-Server**: Separation of concerns between client and server
- **Stateless**: Each request is independent and contains all necessary information
- **Cacheable**: Responses can be cached to improve performance
- **Uniform Interface**: Consistent interaction patterns
- **Layered System**: Architecture can have multiple layers
- **Code on Demand**: Optional ability to send executable code

**HTTP Methods Mapping:**
- `GET`: Retrieve data (idempotent, safe)
- `POST`: Create new resources
- `PUT`: Update entire resource (idempotent)
- `PATCH`: Partial updates
- `DELETE`: Remove resources (idempotent)

### API versioning strategies

**URL-based Versioning:**
```ruby
# routes.rb
namespace :v1 do
  resources :users
end

namespace :v2 do
  resources :users
end
```

**Header-based Versioning:**
```ruby
# Using Accept header
Accept: application/vnd.api+json;version=1
```

**Query Parameter Versioning:**
```
GET /api/users?version=1
```

**Pros and Cons:**
- **URL versioning**: Clear, cacheable, but breaks URLs
- **Header versioning**: Clean URLs, but harder to test
- **Query parameter**: Flexible, but can be confusing

### HTTP status codes and responses

**Success Codes:**
- `200 OK`: Successful GET, PUT, PATCH
- `201 Created`: Successful POST
- `204 No Content`: Successful DELETE

**Client Error Codes:**
- `400 Bad Request`: Invalid request syntax
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Authenticated but not authorized
- `404 Not Found`: Resource doesn't exist
- `422 Unprocessable Entity`: Validation errors

**Server Error Codes:**
- `500 Internal Server Error`: Server error
- `502 Bad Gateway`: Upstream server error
- `503 Service Unavailable`: Server temporarily unavailable

## Rails API Implementation

### Rails API-only applications

**Creating API-only Rails app:**
```bash
rails new my_api --api
```

**Key differences from regular Rails:**
- No view layer (no ERB, HAML, etc.)
- No asset pipeline
- No session middleware by default
- Optimized for JSON responses
- Smaller memory footprint

**Essential gems:**
```ruby
gem 'rack-cors'          # CORS handling
gem 'active_model_serializers'  # JSON serialization
gem 'jbuilder'           # JSON building
gem 'pundit'             # Authorization
gem 'jwt'                # Token authentication
```

### API controllers and routing

**API Controller Structure:**
```ruby
class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :update, :destroy]

  def index
    @users = User.all
    render json: @users
  end

  def show
    render json: @user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: @user, status: :created
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email)
  end
end
```

**Nested Resources:**
```ruby
resources :users do
  resources :posts do
    resources :comments
  end
end
```

### Request/Response handling

**Parameter Handling:**
```ruby
# Strong parameters
def user_params
  params.require(:user).permit(:name, :email, :age)
end

# Nested parameters
def user_params
  params.require(:user).permit(:name, :email, posts_attributes: [:title, :content])
end
```

**Pagination:**
```ruby
# Using Kaminari
@users = User.page(params[:page]).per(10)

# Custom pagination
def index
  page = params[:page] || 1
  per_page = params[:per_page] || 10
  @users = User.limit(per_page).offset((page - 1) * per_page)
end
```

### API serialization

**Active Model Serializers:**
```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at
  
  has_many :posts
  
  def created_at
    object.created_at.strftime('%Y-%m-%d')
  end
end
```

**Jbuilder:**
```ruby
# app/views/api/v1/users/index.json.jbuilder
json.array! @users do |user|
  json.extract! user, :id, :name, :email
  json.posts user.posts do |post|
    json.extract! post, :id, :title
  end
end
```

## Authentication & Authorization

### API authentication methods

**Token-based Authentication:**
```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    return render_unauthorized unless token
    
    decoded_token = JWT.decode(token, Rails.application.secrets.secret_key_base)
    @current_user = User.find(decoded_token[0]['user_id'])
  rescue JWT::DecodeError
    render_unauthorized
  end

  def render_unauthorized
    render json: { error: 'Unauthorized' }, status: 401
  end
end
```

**API Key Authentication:**
```ruby
class ApiKey < ApplicationRecord
  belongs_to :user
  
  def self.authenticate(key)
    find_by(key: key, active: true)
  end
end
```

### JWT token implementation

**JWT Token Generation:**
```ruby
class AuthService
  def self.generate_token(user)
    payload = {
      user_id: user.id,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def self.decode_token(token)
    decoded = JWT.decode(token, Rails.application.secrets.secret_key_base)
    decoded[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
end
```

**Security Considerations:**
- Use HTTPS for token transmission
- Implement token expiration
- Use secure secret keys
- Consider token refresh mechanisms
- Implement token blacklisting for logout

### API authorization patterns

**Role-based Access Control:**
```ruby
class User < ApplicationRecord
  enum role: { user: 0, admin: 1, moderator: 2 }
end

class PostsController < ApplicationController
  before_action :check_admin, only: [:destroy]

  private

  def check_admin
    render json: { error: 'Forbidden' }, status: 403 unless current_user.admin?
  end
end
```

**Resource-level Permissions:**
```ruby
class PostsController < ApplicationController
  def update
    @post = Post.find(params[:id])
    unless @post.user == current_user || current_user.admin?
      render json: { error: 'Forbidden' }, status: 403
      return
    end
    # Update logic
  end
end
```

## API Best Practices

### Error handling and validation

**Consistent Error Response:**
```ruby
class Api::V1::BaseController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  private

  def not_found
    render json: { error: 'Resource not found' }, status: 404
  end

  def unprocessable_entity(exception)
    render json: { 
      error: 'Validation failed', 
      details: exception.record.errors.full_messages 
    }, status: 422
  end
end
```

**Validation Error Handling:**
```ruby
def create
  @user = User.new(user_params)
  if @user.save
    render json: @user, status: :created
  else
    render json: {
      error: 'Validation failed',
      details: @user.errors.full_messages
    }, status: :unprocessable_entity
  end
end
```

### Rate limiting and throttling

**Using Rack::Attack:**
```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  throttle('api/user', limit: 1000, period: 1.hour) do |req|
    req.env['warden'].user&.id if req.path.start_with?('/api/')
  end
end
```

**Custom Rate Limiting:**
```ruby
class RateLimiter
  def self.check_limit(identifier, limit: 100, period: 1.hour)
    key = "rate_limit:#{identifier}:#{Time.current.to_i / period.to_i}"
    current = Rails.cache.read(key) || 0
    
    if current >= limit
      raise RateLimitExceeded
    else
      Rails.cache.write(key, current + 1, expires_in: period)
    end
  end
end
```

### API documentation

**Using Swagger/OpenAPI:**
```ruby
# Gemfile
gem 'rswag'

# swagger_helper.rb
RSpec.configure do |config|
  config.swagger_docs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://api.example.com',
          description: 'Production server'
        }
      ]
    }
  }
end
```

**API Documentation Best Practices:**
- Include endpoint descriptions
- Document request/response schemas
- Provide example requests/responses
- Include authentication requirements
- Document error responses
- Keep documentation updated

### Testing APIs

**Controller Testing:**
```ruby
RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'GET #index' do
    it 'returns users' do
      user = create(:user)
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        hash_including('id' => user.id, 'name' => user.name)
      )
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: { name: 'John', email: 'john@example.com' } }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns validation errors' do
        post :create, params: { user: { name: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to include('error')
      end
    end
  end
end
```

## Performance & Security

### API performance optimization

**N+1 Query Prevention:**
```ruby
# Bad - causes N+1 queries
@users = User.all
@users.each { |user| puts user.posts.count }

# Good - uses includes
@users = User.includes(:posts)
@users.each { |user| puts user.posts.count }

# Better - uses counter_cache
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end
```

**Database Optimization:**
```ruby
# Use select to limit fields
@users = User.select(:id, :name, :email)

# Use pagination
@users = User.page(params[:page]).per(20)

# Use database indexes
add_index :users, :email
add_index :posts, [:user_id, :created_at]
```

### API security best practices

**Input Validation:**
```ruby
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
end
```

**SQL Injection Prevention:**
```ruby
# Rails automatically prevents SQL injection with parameterized queries
User.where("name = ?", params[:name])
User.where(name: params[:name])  # Even safer
```

**CSRF Protection:**
```ruby
# For API-only apps, CSRF is typically disabled
class ApplicationController < ActionController::API
  # CSRF protection not needed for stateless APIs
end
```

### Caching strategies for APIs

**HTTP Caching:**
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    
    if stale?(@user, last_modified: @user.updated_at)
      render json: @user
    end
  end
end
```

**Application Caching:**
```ruby
class UsersController < ApplicationController
  def index
    @users = Rails.cache.fetch("users_index_#{params[:page]}", expires_in: 1.hour) do
      User.includes(:posts).page(params[:page])
    end
    render json: @users
  end
end
```

**Cache Invalidation:**
```ruby
class User < ApplicationRecord
  after_update :clear_cache

  private

  def clear_cache
    Rails.cache.delete_matched("users_*")
  end
end
```

## Advanced Topics

### GraphQL vs REST APIs

**REST API:**
- Multiple endpoints for different resources
- Fixed response structure
- Over-fetching or under-fetching data
- Simple caching with HTTP

**GraphQL:**
- Single endpoint
- Flexible query structure
- Fetch exactly what you need
- More complex caching

**GraphQL in Rails:**
```ruby
# Gemfile
gem 'graphql'

# app/graphql/types/user_type.rb
class Types::UserType < Types::BaseObject
  field :id, ID, null: false
  field :name, String, null: false
  field :email, String, null: false
  field :posts, [Types::PostType], null: true
end

# app/graphql/queries/users.rb
class Queries::Users < Queries::BaseQuery
  type [Types::UserType], null: false

  def resolve
    User.all
  end
end
```

### Microservices and API design

**API Gateway Pattern:**
- Single entry point for multiple services
- Authentication and authorization
- Rate limiting and monitoring
- Request routing and load balancing

**Service Communication:**
```ruby
# HTTP-based communication
class UserService
  def self.get_user(user_id)
    response = HTTParty.get("#{user_service_url}/users/#{user_id}")
    JSON.parse(response.body)
  end
end

# Message queue communication
class OrderService
  def self.create_order(order_data)
    OrderPublisher.publish('order.created', order_data)
  end
end
```

**Challenges:**
- Service discovery
- Data consistency
- Network latency
- Error handling
- Distributed transactions
- Monitoring and debugging

**Best Practices:**
- Design for failure
- Implement circuit breakers
- Use async communication when possible
- Maintain API contracts
- Implement proper logging and monitoring

### API monitoring and logging

**Structured Logging:**
```ruby
# config/initializers/lograge.rb
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current.iso8601,
      user_id: event.payload[:user_id],
      request_id: event.payload[:request_id]
    }
  end
end
```

**API Metrics:**
```ruby
class ApiMetrics
  def self.track_request(endpoint, duration, status)
    Rails.logger.info({
      type: 'api_request',
      endpoint: endpoint,
      duration: duration,
      status: status,
      timestamp: Time.current.iso8601
    }.to_json)
  end
end

# In controller
class ApplicationController < ActionController::API
  around_action :track_api_metrics

  private

  def track_api_metrics
    start_time = Time.current
    yield
  ensure
    duration = (Time.current - start_time) * 1000
    ApiMetrics.track_request(request.path, duration, response.status)
  end
end
```

**Error Tracking:**
```ruby
# Using Sentry
gem 'sentry-ruby'
gem 'sentry-rails'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.1
end
```

**Health Checks:**
```ruby
class HealthController < ApplicationController
  def index
    checks = {
      database: database_healthy?,
      redis: redis_healthy?,
      external_apis: external_apis_healthy?
    }
    
    status = checks.values.all? ? :ok : :service_unavailable
    render json: { status: status, checks: checks }, status: status
  end

  private

  def database_healthy?
    ActiveRecord::Base.connection.execute('SELECT 1')
    true
  rescue
    false
  end

  def redis_healthy?
    Rails.cache.redis.ping == 'PONG'
  rescue
    false
  end

  def external_apis_healthy?
    # Check external service health
    true
  end
end
```

**Performance Monitoring:**
```ruby
# Using New Relic or similar
class ApplicationController < ActionController::API
  before_action :set_custom_attributes

  private

  def set_custom_attributes
    NewRelic::Agent.add_custom_attributes(
      user_id: current_user&.id,
      api_version: request.headers['API-Version'],
      client_type: request.headers['Client-Type']
    )
  end
end
```

**Key Metrics to Monitor:**
- Response times (p50, p95, p99)
- Error rates (4xx, 5xx)
- Request volume
- Database query performance
- Memory and CPU usage
- Cache hit rates
- External API response times

**Logging Best Practices:**
- Use structured logging (JSON format)
- Include correlation IDs for request tracing
- Log at appropriate levels (debug, info, warn, error)
- Avoid logging sensitive information
- Implement log rotation and retention policies
- Use centralized logging (ELK stack, Splunk, etc.)