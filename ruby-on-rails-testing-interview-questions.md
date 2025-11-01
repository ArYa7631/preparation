# Ruby on Rails Testing Interview Questions

## Table of Contents

### Testing Fundamentals
- [What is testing in Rails and why is it important?](#what-is-testing-in-rails)
- [What are the different types of tests in Rails?](#types-of-tests-in-rails)
- [RSpec vs MiniTest - Which testing framework should you use?](#rspec-vs-minitest)

### Model Testing
- [How to write model tests?](#how-to-write-model-tests)
- [How to test validations and associations?](#testing-validations-and-associations)
- [How to test scopes and class methods?](#testing-scopes-and-class-methods)

### Controller & Request Testing
- [How to write controller tests?](#how-to-write-controller-tests)
- [How to write request/integration tests?](#request-integration-tests)
- [How to test authentication and authorization?](#testing-authentication-authorization)

### System Testing
- [How to write system tests with Capybara?](#system-tests-with-capybara)
- [How to test JavaScript interactions?](#testing-javascript-interactions)

### Testing Tools & Libraries
- [What is FactoryBot and how to use it?](#factorybot)
- [What are test doubles, mocks, and stubs?](#test-doubles-mocks-stubs)
- [How to use VCR for testing external APIs?](#vcr-for-external-apis)

### Testing Best Practices
- [What is the test pyramid?](#test-pyramid)
- [How to write maintainable tests?](#maintainable-tests)
- [What is test coverage and how to measure it?](#test-coverage)

### Advanced Testing
- [How to test background jobs?](#testing-background-jobs)
- [How to test API endpoints?](#testing-api-endpoints)
- [How to test email sending?](#testing-emails)

---

## Related Files
- **[Most Frequently Asked Questions](ruby-on-rails-frequently-asked-questions.md)** - Top 50 most commonly asked Rails interview questions
- **[Advanced Rails Questions](ruby-on-rails-advanced-interview-questions.md)** - Senior-level Rails concepts
- **[ActiveRecord Questions](ruby-on-rails-activerecord-interview-questions.md)** - Database and ORM specific questions

---

## Testing Fundamentals

### <a id="what-is-testing-in-rails"></a>**What is testing in Rails and why is it important?**

**Question**: Explain the importance of testing in Rails applications and what testing provides.

**Answer**:

Testing in Rails is the practice of writing code that verifies your application code works correctly. Rails has built-in support for testing, making it a fundamental part of the development workflow.

**Why Testing is Important:**

1. **Confidence in Changes**: Tests verify that existing functionality still works after changes
2. **Documentation**: Tests serve as executable documentation showing how code should work
3. **Regression Prevention**: Catch bugs before they reach production
4. **Refactoring Safety**: Allows safe code improvements with confidence
5. **Design Feedback**: Writing tests first (TDD) leads to better code design
6. **Debugging**: Tests help identify where bugs are located

**Rails Testing Philosophy:**

Rails encourages testing through:
- **Convention over Configuration**: Default test setup out of the box
- **Test-Driven Development (TDD)**: Write tests before code
- **Behavior-Driven Development (BDD)**: Tests describe application behavior
- **Comprehensive Coverage**: Test models, controllers, views, integrations

**Basic Test Structure:**

```ruby
# test/models/user_test.rb (MiniTest)
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should not save user without email" do
    user = User.new
    assert_not user.save, "Saved user without email"
  end
  
  test "should save user with valid attributes" do
    user = User.new(email: "test@example.com", name: "Test User")
    assert user.save
  end
end
```

```ruby
# spec/models/user_spec.rb (RSpec)
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it 'requires an email' do
      user = User.new
      expect(user).not_to be_valid
      expect(user.errors[:email]).to be_present
    end
    
    it 'saves with valid attributes' do
      user = User.new(email: "test@example.com", name: "Test User")
      expect(user).to be_valid
      expect(user.save).to be true
    end
  end
end
```

**Test Benefits in Practice:**

```ruby
# Without tests: Fear of breaking things
def update_user_status(user, status)
  # What if this breaks? No way to know without manual testing
  user.update(status: status)
end

# With tests: Confidence to refactor and improve
def update_user_status(user, status)
  user.update(status: status)
end

# Test ensures it works:
it 'updates user status' do
  user = create(:user, status: 'inactive')
  update_user_status(user, 'active')
  expect(user.reload.status).to eq('active')
end
```

**Interview Key Points:**

- Testing provides confidence and safety in development
- Rails has built-in testing support (test/ or spec/ directories)
- Tests serve as documentation
- Tests enable safe refactoring
- TDD/BDD improve code quality
- Different types of tests for different purposes

### <a id="types-of-tests-in-rails"></a>**What are the different types of tests in Rails?**

**Question**: Explain the different types of tests in Rails and when to use each.

**Answer**:

Rails supports multiple testing levels following the **Test Pyramid** principle. Each type serves a specific purpose in ensuring application quality.

**1. Unit Tests (Model Tests)**

**Purpose**: Test individual components in isolation

**What to Test:**
- Model validations
- Associations
- Scopes
- Class methods
- Business logic

**Example:**
```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end
  
  describe 'associations' do
    it { should have_many(:posts) }
    it { should belong_to(:company) }
  end
  
  describe 'scopes' do
    it 'returns active users' do
      active_user = create(:user, active: true)
      inactive_user = create(:user, active: false)
      
      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end
  end
end
```

**2. Controller Tests**

**Purpose**: Test controller actions and response handling

**What to Test:**
- Response status codes
- Redirects
- Instance variables
- Flash messages
- Template rendering

**Example:**
```ruby
# spec/controllers/users_controller_spec.rb
RSpec.describe UsersController, type: :controller do
  describe 'GET #show' do
    let(:user) { create(:user) }
    
    before do
      get :show, params: { id: user.id }
    end
    
    it 'returns success status' do
      expect(response).to have_http_status(:success)
    end
    
    it 'assigns @user' do
      expect(assigns(:user)).to eq(user)
    end
    
    it 'renders show template' do
      expect(response).to render_template(:show)
    end
  end
  
  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: attributes_for(:user) }
        }.to change(User, :count).by(1)
      end
      
      it 'redirects to user page' do
        post :create, params: { user: attributes_for(:user) }
        expect(response).to redirect_to(User.last)
      end
    end
    
    context 'with invalid params' do
      it 'does not create a user' do
        expect {
          post :create, params: { user: { email: '' } }
        }.not_to change(User, :count)
      end
      
      it 'renders new template' do
        post :create, params: { user: { email: '' } }
        expect(response).to render_template(:new)
      end
    end
  end
end
```

**3. Request/Integration Tests**

**Purpose**: Test full request-response cycle including routing

**What to Test:**
- HTTP requests
- Routes
- Middleware
- Full request flow

**Example:**
```ruby
# spec/requests/users_spec.rb
RSpec.describe 'Users API', type: :request do
  describe 'GET /users' do
    let!(:users) { create_list(:user, 3) }
    
    before { get '/users' }
    
    it 'returns success status' do
      expect(response).to have_http_status(:ok)
    end
    
    it 'returns all users' do
      json = JSON.parse(response.body)
      expect(json.size).to eq(3)
    end
  end
  
  describe 'POST /users' do
    context 'with valid params' do
      let(:valid_params) { { user: attributes_for(:user) } }
      
      it 'creates a new user' do
        expect {
          post '/users', params: valid_params
        }.to change(User, :count).by(1)
      end
      
      it 'returns created status' do
        post '/users', params: valid_params
        expect(response).to have_http_status(:created)
      end
    end
  end
end
```

**4. System Tests**

**Purpose**: Test user interactions through the browser

**What to Test:**
- User flows
- JavaScript interactions
- UI components
- End-to-end scenarios

**Example:**
```ruby
# spec/system/users_spec.rb
require 'rails_helper'

RSpec.describe 'User management', type: :system do
  before do
    driven_by :selenium_chrome_headless
  end
  
  it 'allows user to sign up' do
    visit new_user_registration_path
    
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'password123'
    fill_in 'Password confirmation', with: 'password123'
    
    click_button 'Sign up'
    
    expect(page).to have_content('Welcome! You have signed up successfully.')
    expect(User.count).to eq(1)
  end
  
  it 'allows user to log in' do
    user = create(:user, email: 'test@example.com', password: 'password123')
    
    visit new_user_session_path
    
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123'
    
    click_button 'Log in'
    
    expect(page).to have_content('Signed in successfully.')
  end
end
```

**5. Feature Tests (Integration with Capybara)**

**Purpose**: Test complete user workflows

**Example:**
```ruby
# spec/features/order_placement_spec.rb
RSpec.describe 'Order Placement', type: :feature do
  let(:user) { create(:user) }
  let(:product) { create(:product, price: 10.00) }
  
  before do
    login_as(user, scope: :user)
  end
  
  it 'allows user to place an order' do
    visit product_path(product)
    
    click_button 'Add to Cart'
    expect(page).to have_content('Item added to cart')
    
    visit cart_path
    expect(page).to have_content(product.name)
    expect(page).to have_content('$10.00')
    
    click_button 'Checkout'
    fill_in 'Shipping Address', with: '123 Main St'
    click_button 'Place Order'
    
    expect(page).to have_content('Order placed successfully')
    expect(Order.count).to eq(1)
  end
end
```

**When to Use Each Type:**

| Test Type | When to Use | Speed | Coverage |
|-----------|-------------|-------|----------|
| **Unit Tests** | Test models, logic | Fast | Individual components |
| **Controller Tests** | Test controller actions | Fast | Request handling |
| **Request Tests** | Test API endpoints | Medium | HTTP layer |
| **System Tests** | Test user interactions | Slow | Full application |

**Best Practices:**

1. **Many Unit Tests**: Fast, focused, isolated
2. **Some Integration Tests**: Test component interactions
3. **Few System Tests**: Test critical user flows only

**Interview Key Points:**

- Unit tests: Fast, test individual components
- Controller tests: Test controller logic
- Request tests: Test HTTP endpoints
- System tests: Test browser interactions
- Test pyramid: Many unit tests, fewer integration tests
- Each type serves different purpose
- Balance speed vs coverage

### <a id="rspec-vs-minitest"></a>**RSpec vs MiniTest - Which testing framework should you use?**

**Question**: Compare RSpec and MiniTest. When would you choose one over the other?

**Answer**:

Both RSpec and MiniTest are popular testing frameworks for Rails, each with different philosophies and strengths.

**MiniTest**

**Philosophy**: Simple, fast, built into Ruby standard library

**Characteristics:**
- ✅ Included with Ruby (no gem needed)
- ✅ Simple syntax
- ✅ Fast execution
- ✅ Less magic
- ✅ Functional style (assertions)

**Example:**
```ruby
# test/models/user_test.rb
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "email should be present" do
    user = User.new
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end
  
  test "email should be unique" do
    existing_user = User.create!(email: "test@example.com")
    duplicate_user = User.new(email: "test@example.com")
    assert_not duplicate_user.valid?
  end
  
  test "should have many posts" do
    user = users(:one)
    assert_respond_to user, :posts
    assert_equal 3, user.posts.count
  end
end
```

**RSpec**

**Philosophy**: Behavior-Driven Development (BDD), expressive DSL

**Characteristics:**
- ✅ Readable, English-like syntax
- ✅ Better for BDD approach
- ✅ Rich matcher library
- ✅ Powerful mocking/stubbing
- ✅ Better organization (describe, context, it blocks)

**Example:**
```ruby
# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
  end
  
  describe 'associations' do
    it { should have_many(:posts) }
    it { should belong_to(:company) }
  end
  
  describe '#full_name' do
    it 'returns first and last name' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
  
  describe '#admin?' do
    context 'when user is admin' do
      it 'returns true' do
        user = build(:user, role: 'admin')
        expect(user.admin?).to be true
      end
    end
    
    context 'when user is not admin' do
      it 'returns false' do
        user = build(:user, role: 'user')
        expect(user.admin?).to be false
      end
    end
  end
end
```

**Key Differences:**

| Feature | MiniTest | RSpec |
|---------|----------|-------|
| **Syntax** | Assertions (`assert`, `assert_equal`) | Matchers (`expect`, `should`) |
| **BDD** | Not BDD-focused | Built for BDD |
| **Readability** | Functional | More expressive |
| **Setup** | Included with Ruby | Requires gem |
| **Speed** | Faster | Slightly slower |
| **Learning Curve** | Easier | Steeper |
| **Community** | Smaller | Larger |

**When to Use MiniTest:**

- ✅ Simple projects
- ✅ Prefer minimal dependencies
- ✅ Team comfortable with assertions
- ✅ Need maximum speed
- ✅ Default Rails test framework

**When to Use RSpec:**

- ✅ BDD approach preferred
- ✅ Complex test scenarios
- ✅ Need powerful mocking
- ✅ Team values readability
- ✅ Large codebase

**Migration Between Frameworks:**

```ruby
# MiniTest
test "user email is required" do
  user = User.new
  assert_not user.valid?
end

# RSpec equivalent
it 'requires email' do
  user = User.new
  expect(user).not_to be_valid
end
```

**Interview Key Points:**

- MiniTest: Simple, fast, built-in
- RSpec: BDD-focused, expressive, powerful
- Choose based on team preference and project needs
- Both are valid choices
- RSpec more popular in Rails community
- MiniTest better for simplicity
- Can use both in same project (not recommended)

---

## Model Testing

### <a id="how-to-write-model-tests"></a>**How to write model tests?**

*Add your model testing questions here...*

### <a id="testing-validations-and-associations"></a>**How to test validations and associations?**

*Add your validation and association testing questions here...*

### <a id="testing-scopes-and-class-methods"></a>**How to test scopes and class methods?**

*Add your scope and class method testing questions here...*

---

## Controller & Request Testing

### <a id="how-to-write-controller-tests"></a>**How to write controller tests?**

*Add your controller testing questions here...*

### <a id="request-integration-tests"></a>**How to write request/integration tests?**

*Add your request/integration testing questions here...*

### <a id="testing-authentication-authorization"></a>**How to test authentication and authorization?**

*Add your authentication/authorization testing questions here...*

---

## System Testing

### <a id="system-tests-with-capybara"></a>**How to write system tests with Capybara?**

*Add your system testing questions here...*

### <a id="testing-javascript-interactions"></a>**How to test JavaScript interactions?**

*Add your JavaScript testing questions here...*

---

## Testing Tools & Libraries

### <a id="factorybot"></a>**What is FactoryBot and how to use it?**

**Question**: Explain FactoryBot and demonstrate how to use it for creating test data.

**Answer**:

FactoryBot (formerly FactoryGirl) is a library for creating test data objects in Ruby. It provides a simple and consistent way to generate test fixtures.

**Why FactoryBot?**

**Problems with Fixtures:**
- Hard to maintain
- Static data
- Difficult to create associations
- Not flexible

**Benefits of FactoryBot:**
- ✅ Dynamic data generation
- ✅ Easy associations
- ✅ Flexible attributes
- ✅ Sequences and traits
- ✅ Better maintainability

**Basic Usage:**

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "john@example.com" }
    password { "password123" }
    active { true }
  end
end

# In tests
user = create(:user)
user.name  # => "John Doe"
user.email # => "john@example.com"
```

**Advanced Features:**

**1. Sequences:**
```ruby
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
  end
end

# Generates unique emails:
create(:user) # email: "user1@example.com"
create(:user) # email: "user2@example.com"
```

**2. Traits:**
```ruby
FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { sequence(:email) { |n| "user#{n}@example.com" } }
    
    trait :admin do
      role { "admin" }
      admin { true }
    end
    
    trait :inactive do
      active { false }
    end
    
    trait :with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end
  end
end

# Usage
admin_user = create(:user, :admin)
inactive_user = create(:user, :inactive)
user_with_posts = create(:user, :with_posts)
```

**3. Associations:**
```ruby
FactoryBot.define do
  factory :post do
    title { "My Post" }
    content { "Post content" }
    association :user  # Creates associated user
    # Or:
    # user  # Shorthand for association
  end
  
  factory :user do
    name { "John Doe" }
    
    factory :user_with_posts do
      after(:create) do |user|
        create_list(:post, 3, user: user)
      end
    end
  end
end

# Usage
post = create(:post)  # Creates user automatically
user = create(:user_with_posts)  # Creates user with 3 posts
```

**4. Inheritance:**
```ruby
FactoryBot.define do
  factory :user do
    name { "John Doe" }
    email { "user@example.com" }
    
    factory :admin_user do
      role { "admin" }
      admin { true }
    end
    
    factory :guest_user do
      role { "guest" }
      active { false }
    end
  end
end
```

**5. Transient Attributes:**
```ruby
FactoryBot.define do
  factory :user do
    name { "John Doe" }
    
    transient do
      post_count { 0 }
    end
    
    after(:create) do |user, evaluator|
      create_list(:post, evaluator.post_count, user: user) if evaluator.post_count > 0
    end
  end
end

# Usage
user = create(:user, post_count: 5)  # Creates user with 5 posts
```

**FactoryBot Methods:**

```ruby
# create - Saves to database
user = create(:user)  # User is persisted

# build - Doesn't save
user = build(:user)  # User exists in memory only

# build_stubbed - Fake persisted object
user = build_stubbed(:user)  # Has ID but not in database

# attributes_for - Returns hash
attrs = attributes_for(:user)  # { name: "...", email: "..." }

# create_list - Creates multiple
users = create_list(:user, 5)  # Creates 5 users

# build_list - Builds multiple
users = build_list(:user, 5)  # Builds 5 users without saving
```

**Real-World Example:**

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { Faker::Name.name }
    password { "password123" }
    active { true }
    created_at { Time.current }
    
    trait :admin do
      role { "admin" }
      admin { true }
    end
    
    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end
  end
end

# spec/factories/posts.rb
FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    association :user
    published { true }
    
    trait :draft do
      published { false }
    end
    
    trait :with_comments do
      after(:create) do |post|
        create_list(:comment, 3, post: post)
      end
    end
  end
end

# In tests
RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }
  
  it 'belongs to a user' do
    expect(post.user).to eq(user)
  end
  
  it 'has comments when created with trait' do
    post_with_comments = create(:post, :with_comments, user: user)
    expect(post_with_comments.comments.count).to eq(3)
  end
end
```

**Interview Key Points:**

- FactoryBot creates test data dynamically
- Better than fixtures for maintainability
- Supports sequences, traits, associations
- Use `create` to persist, `build` for memory
- Traits provide reusable attribute combinations
- After callbacks useful for associations

### <a id="test-doubles-mocks-stubs"></a>**What are test doubles, mocks, and stubs?**

*Add your test doubles, mocks, and stubs questions here...*

### <a id="vcr-for-external-apis"></a>**How to write test cases when tests depend on third-party API requests?**

**Question**: How do you write test cases when your tests depend on third-party API requests? Explain different strategies and tools.

**Answer**:

Testing code that depends on external APIs is challenging because:
1. **External APIs may be unavailable** during tests
2. **API responses may vary** or change
3. **API calls are slow** and slow down test suite
4. **API calls may cost money** (rate limits, usage fees)
5. **Tests become unreliable** if API is down

**Solution 1: VCR (Video Cassette Recorder)**

VCR records HTTP interactions and replays them during tests.

**Setup:**
```ruby
# Gemfile
gem 'vcr'
gem 'webmock'  # Required for VCR

# spec/spec_helper.rb or spec/rails_helper.rb
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<API_KEY>') { ENV['STRIPE_API_KEY'] }
  config.filter_sensitive_data('<SECRET>') { ENV['STRIPE_SECRET'] }
end
```

**Basic Usage:**
```ruby
# app/services/payment_service.rb
class PaymentService
  def self.charge(card_token, amount)
    response = HTTParty.post(
      'https://api.stripe.com/v1/charges',
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" },
      body: { amount: amount, currency: 'usd', source: card_token }
    )
    JSON.parse(response.body)
  end
end

# spec/services/payment_service_spec.rb
RSpec.describe PaymentService, :vcr do
  describe '.charge' do
    it 'successfully charges a card' do
      result = PaymentService.charge('tok_visa', 1000)
      
      expect(result['status']).to eq('succeeded')
      expect(result['amount']).to eq(1000)
    end
    
    it 'handles declined cards' do
      result = PaymentService.charge('tok_chargeDeclined', 1000)
      
      expect(result['error']).to be_present
      expect(result['error']['type']).to eq('card_error')
    end
  end
end

# First run: Makes real API call, records to spec/vcr_cassettes/
# Subsequent runs: Uses recorded response (no API call)
```

**VCR Cassette Management:**
```ruby
# Named cassettes
RSpec.describe PaymentService do
  it 'charges a card', vcr: { cassette_name: 'stripe/successful_charge' } do
    result = PaymentService.charge('tok_visa', 1000)
    expect(result['status']).to eq('succeeded')
  end
  
  # With options
  it 'charges a card', vcr: { 
    cassette_name: 'stripe/charge',
    record: :new_episodes,  # Record new interactions
    match_requests_on: [:method, :uri, :body]  # How to match requests
  } do
    result = PaymentService.charge('tok_visa', 1000)
  end
end
```

**VCR Record Modes:**
```ruby
# :once (default) - Record once, use cassette afterwards
# :new_episodes - Record new requests, use existing ones
# :all - Always make real requests and re-record
# :none - Never make real requests, use only cassettes

# In spec_helper.rb
VCR.configure do |config|
  config.default_cassette_options = { 
    record: :new_episodes,
    re_record_interval: 7.days  # Re-record weekly
  }
end
```

**Solution 2: WebMock (Stubbing HTTP Requests)**

WebMock allows you to stub HTTP requests with predefined responses.

**Setup:**
```ruby
# Gemfile
gem 'webmock'

# spec/rails_helper.rb
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)
```

**Basic Usage:**
```ruby
# spec/services/payment_service_spec.rb
RSpec.describe PaymentService do
  describe '.charge' do
    it 'successfully charges a card' do
      # Stub the HTTP request
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .with(
          headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" },
          body: { amount: 1000, currency: 'usd', source: 'tok_visa' }
        )
        .to_return(
          status: 200,
          body: {
            id: 'ch_123',
            status: 'succeeded',
            amount: 1000
          }.to_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      
      result = PaymentService.charge('tok_visa', 1000)
      
      expect(result['status']).to eq('succeeded')
      expect(result['amount']).to eq(1000)
    end
    
    it 'handles API errors' do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .to_return(
          status: 402,
          body: {
            error: {
              type: 'card_error',
              message: 'Your card was declined.'
            }
          }.to_json
        )
      
      result = PaymentService.charge('tok_chargeDeclined', 1000)
      
      expect(result['error']).to be_present
      expect(result['error']['type']).to eq('card_error')
    end
    
    it 'handles network errors' do
      stub_request(:post, "https://api.stripe.com/v1/charges")
        .to_raise(Net::TimeoutError)
      
      expect {
        PaymentService.charge('tok_visa', 1000)
      }.to raise_error(Net::TimeoutError)
    end
  end
end
```

**Flexible Stubbing:**
```ruby
# Match requests flexibly
stub_request(:post, /api\.stripe\.com/)
  .with(body: hash_including(amount: 1000))
  .to_return(status: 200, body: { success: true }.to_json)

# Multiple responses
stub_request(:get, "https://api.example.com/users")
  .to_return([
    { status: 200, body: { users: [] }.to_json },
    { status: 200, body: { users: [{ id: 1 }] }.to_json }
  ])

# Timeout simulation
stub_request(:post, "https://api.example.com/data")
  .to_timeout
```

**Solution 3: Service Object with Dependency Injection**

Create a wrapper service and inject dependencies for testing.

```ruby
# app/services/payment_service.rb
class PaymentService
  def initialize(http_client: HTTParty)
    @http_client = http_client
  end
  
  def charge(card_token, amount)
    response = @http_client.post(
      'https://api.stripe.com/v1/charges',
      headers: { 'Authorization' => "Bearer #{ENV['STRIPE_API_KEY']}" },
      body: { amount: amount, currency: 'usd', source: card_token }
    )
    JSON.parse(response.body)
  end
end

# spec/services/payment_service_spec.rb
RSpec.describe PaymentService do
  let(:mock_http_client) { double('HTTPClient') }
  let(:service) { PaymentService.new(http_client: mock_http_client) }
  
  describe '#charge' do
    it 'successfully charges a card' do
      response = double(
        body: { status: 'succeeded', amount: 1000 }.to_json,
        code: 200
      )
      
      expect(mock_http_client).to receive(:post)
        .with(
          'https://api.stripe.com/v1/charges',
          hash_including(
            headers: anything,
            body: hash_including(amount: 1000)
          )
        )
        .and_return(response)
      
      result = service.charge('tok_visa', 1000)
      
      expect(result['status']).to eq('succeeded')
    end
  end
end
```

**Solution 4: Shared Examples for Common API Patterns**

```ruby
# spec/support/shared_examples/api_client.rb
RSpec.shared_examples 'an API client' do
  let(:api_client) { described_class.new }
  
  it 'handles successful responses' do
    stub_request(:any, /api\.example\.com/)
      .to_return(status: 200, body: { success: true }.to_json)
    
    expect { api_client.fetch_data }.not_to raise_error
  end
  
  it 'handles 404 errors' do
    stub_request(:any, /api\.example\.com/)
      .to_return(status: 404, body: { error: 'Not found' }.to_json)
    
    expect { api_client.fetch_data }.to raise_error(ApiClient::NotFoundError)
  end
  
  it 'handles timeouts' do
    stub_request(:any, /api\.example\.com/)
      .to_timeout
    
    expect { api_client.fetch_data }.to raise_error(ApiClient::TimeoutError)
  end
end

# spec/services/stripe_client_spec.rb
RSpec.describe StripeClient do
  it_behaves_like 'an API client'
  
  # Additional Stripe-specific tests
end
```

**Real-World Example: Testing Payment Integration**

```ruby
# app/services/stripe_payment_service.rb
class StripePaymentService
  BASE_URL = 'https://api.stripe.com/v1'
  
  def initialize
    @api_key = ENV['STRIPE_SECRET_KEY']
  end
  
  def create_payment_intent(amount, currency: 'usd')
    response = HTTParty.post(
      "#{BASE_URL}/payment_intents",
      headers: headers,
      body: { amount: amount, currency: currency }
    )
    
    handle_response(response)
  end
  
  def confirm_payment_intent(payment_intent_id)
    response = HTTParty.post(
      "#{BASE_URL}/payment_intents/#{payment_intent_id}/confirm",
      headers: headers
    )
    
    handle_response(response)
  end
  
  private
  
  def headers
    {
      'Authorization' => "Bearer #{@api_key}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end
  
  def handle_response(response)
    case response.code
    when 200
      JSON.parse(response.body)
    when 400..499
      raise ApiError, "Client error: #{response.body}"
    when 500..599
      raise ApiError, "Server error: #{response.body}"
    end
  end
end

# spec/services/stripe_payment_service_spec.rb
RSpec.describe StripePaymentService do
  let(:service) { described_class.new }
  let(:api_url) { 'https://api.stripe.com/v1' }
  
  describe '#create_payment_intent' do
    context 'with valid parameters' do
      it 'creates a payment intent successfully', :vcr do
        result = service.create_payment_intent(1000)
        
        expect(result['status']).to eq('requires_payment_method')
        expect(result['amount']).to eq(1000)
        expect(result['id']).to be_present
      end
    end
    
    context 'with WebMock' do
      it 'creates a payment intent successfully' do
        stub_request(:post, "#{api_url}/payment_intents")
          .with(
            headers: { 'Authorization' => /Bearer .+/ },
            body: { amount: 1000, currency: 'usd' }
          )
          .to_return(
            status: 200,
            body: {
              id: 'pi_123',
              status: 'requires_payment_method',
              amount: 1000
            }.to_json
          )
        
        result = service.create_payment_intent(1000)
        
        expect(result['status']).to eq('requires_payment_method')
        expect(result['amount']).to eq(1000)
      end
    end
    
    context 'when API returns error' do
      it 'raises ApiError for client errors' do
        stub_request(:post, "#{api_url}/payment_intents")
          .to_return(
            status: 400,
            body: { error: { message: 'Invalid amount' } }.to_json
          )
        
        expect {
          service.create_payment_intent(-100)
        }.to raise_error(ApiError, /Client error/)
      end
      
      it 'raises ApiError for server errors' do
        stub_request(:post, "#{api_url}/payment_intents")
          .to_return(status: 500, body: 'Internal Server Error')
        
        expect {
          service.create_payment_intent(1000)
        }.to raise_error(ApiError, /Server error/)
      end
    end
  end
  
  describe '#confirm_payment_intent' do
    it 'confirms payment intent successfully', :vcr do
      # Create intent first
      intent = service.create_payment_intent(1000)
      
      # Confirm it
      result = service.confirm_payment_intent(intent['id'])
      
      expect(result['status']).to eq('succeeded')
    end
  end
end
```

**Best Practices:**

**1. Use VCR for:**
- ✅ Complex API interactions
- ✅ Testing real API behavior
- ✅ When you want to test actual API responses
- ✅ Integration tests

**2. Use WebMock for:**
- ✅ Unit tests
- ✅ Fast test execution
- ✅ Specific error scenarios
- ✅ When you need precise control

**3. Use Dependency Injection for:**
- ✅ Service objects
- ✅ Better testability
- ✅ Isolation of concerns

**4. Test Configuration:**
```ruby
# spec/support/vcr_config.rb
VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  
  # Filter sensitive data
  config.filter_sensitive_data('<STRIPE_KEY>') { ENV['STRIPE_SECRET_KEY'] }
  config.filter_sensitive_data('<API_TOKEN>') { ENV['EXTERNAL_API_TOKEN'] }
  
  # Allow localhost for system tests
  config.ignore_localhost = true
  
  # Match requests flexibly
  config.default_cassette_options = {
    match_requests_on: [:method, :uri, :body]
  }
end

# spec/support/webmock_config.rb
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: ['elasticsearch.example.com']  # Allow specific hosts
)
```

**5. Test File Organization:**
```
spec/
  services/
    payment_service_spec.rb
  vcr_cassettes/
    stripe/
      successful_charge.yml
      declined_card.yml
      network_error.yml
```

**Common Patterns:**

**Pattern 1: Test both success and failure cases**
```ruby
RSpec.describe ApiService do
  describe '#fetch_data' do
    context 'successful response' do
      it 'returns data' do
        stub_request(:get, /api\.example\.com/)
          .to_return(status: 200, body: { data: [] }.to_json)
        
        expect(service.fetch_data).to be_successful
      end
    end
    
    context 'error response' do
      it 'handles 500 error' do
        stub_request(:get, /api\.example\.com/)
          .to_return(status: 500)
        
        expect { service.fetch_data }.to raise_error
      end
    end
  end
end
```

**Pattern 2: Test retry logic**
```ruby
RSpec.describe ApiService do
  describe '#fetch_with_retry' do
    it 'retries on failure' do
      stub_request(:get, /api\.example\.com/)
        .to_return([
          { status: 500 },
          { status: 500 },
          { status: 200, body: { success: true }.to_json }
        ])
      
      result = service.fetch_with_retry(max_retries: 3)
      
      expect(result).to be_successful
      expect(WebMock).to have_requested(:get, /api\.example\.com/).times(3)
    end
  end
end
```

**Interview Key Points:**

- VCR records and replays HTTP interactions
- WebMock stubs HTTP requests with predefined responses
- Dependency injection allows easier mocking
- Always test both success and failure scenarios
- Filter sensitive data in VCR cassettes
- Use WebMock for fast unit tests
- Use VCR for integration tests
- Test retry logic and error handling
- Organize cassettes by service/feature
- Disable network access except for localhost

---

## Testing Best Practices

### <a id="test-pyramid"></a>**What is the test pyramid?**

*Add your test pyramid questions here...*

### <a id="maintainable-tests"></a>**How to write maintainable tests?**

*Add your maintainable testing questions here...*

### <a id="test-coverage"></a>**What is test coverage and how to measure it?**

*Add your test coverage questions here...*

---

## Advanced Testing

### <a id="testing-background-jobs"></a>**How to test background jobs?**

*Add your background job testing questions here...*

### <a id="testing-api-endpoints"></a>**How to test API endpoints?**

*Add your API testing questions here...*

### <a id="testing-emails"></a>**How to test email sending?**

*Add your email testing questions here...*

---

## Tips for Rails Testing Interview Success

- Understand the difference between unit, integration, and system tests
- Know when to use RSpec vs MiniTest
- Master FactoryBot for test data creation
- Understand test doubles (mocks, stubs, spies)
- Know how to test asynchronous operations (background jobs, emails)
- Understand test coverage and its importance
- Practice writing tests for real-world scenarios
- Know testing best practices and anti-patterns
- Understand how to test with external dependencies (VCR)
- Be familiar with continuous integration testing

