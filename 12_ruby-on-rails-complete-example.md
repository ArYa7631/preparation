### **Q: Write a complete Rails example from scratch including app initialization, model, migration, routes, controller, service object, serializers, error handling, and full RSpec tests — with best practices followed by senior Ruby on Rails developers.**

---

### **A: Complete Rails Example (Senior-Level, Production-Ready)**

This example follows **industry-standard Rails architecture**, including:
- Service Objects  
- Serializers  
- after_commit callbacks  
- API-ready error handling  
- Clean controller architecture  
- Fully isolated tests  

---

## **1. Initialize a New Rails Application**

```bash
rails new task_manager --api -T
cd task_manager
bundle install
```

---

## **2. Install Required Gems**

### Edit `Gemfile`:

```ruby
gem "pg"

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "rubocop", require: false
end
```

Install gems:

```bash
bundle install
rails g rspec:install
```

---

## **3. Generate Task Model With Validations and DB Constraints**

```bash
rails g model Task title:string description:text status:string due_date:date
```

Generated migration — **senior developers add DB constraints**:

```ruby
class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: "pending"
      t.date :due_date

      t.timestamps
    end

    add_index :tasks, :status
  end
end
```

Run migration:

```bash
rails db:migrate
```

### app/models/task.rb

```ruby
class Task < ApplicationRecord
  STATUSES = %w[pending in_progress done archived].freeze

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }

  before_validation :normalize_title
  after_commit :log_creation, on: :create

  private

  def normalize_title
    self.title = title.to_s.strip
  end

  def log_creation
    Rails.logger.info("Task created with ID: #{id}")
  end
end
```

---

## **4. Add a Serializer (Best Practice for APIs)**  
Keeps APIs consistent and clean.

### app/serializers/task_serializer.rb

```ruby
class TaskSerializer
  def initialize(task)
    @task = task
  end

  def as_json(*)
    {
      id: @task.id,
      title: @task.title,
      description: @task.description,
      status: @task.status,
      due_date: @task.due_date,
      created_at: @task.created_at
    }
  end
end
```

---

## **5. Create a Service Object (Business Logic Layer)**

### app/services/tasks/create_task_service.rb

```ruby
module Tasks
  class CreateTaskService
    def initialize(params)
      @params = params
    end

    def call
      task = Task.new(@params)

      if task.save
        task
      else
        raise ActiveRecord::RecordInvalid, task
      end
    end
  end
end
```

---

## **6. Clean Base Controller With Error Handling**

### app/controllers/application_controller.rb

```ruby
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable

  private

  def render_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  def render_unprocessable(error)
    render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
  end
end
```

---

## **7. Generate Tasks Controller**

### app/controllers/tasks_controller.rb

```ruby
class TasksController < ApplicationController
  def index
    tasks = Task.order(created_at: :desc)
    render json: tasks.map { |t| TaskSerializer.new(t).as_json }
  end

  def show
    task = Task.find(params[:id])
    render json: TaskSerializer.new(task).as_json
  end

  def create
    task = Tasks::CreateTaskService.new(task_params).call
    render json: TaskSerializer.new(task).as_json, status: :created
  end

  private

  def task_params
    params.require(:task).permit(:title, :description, :status, :due_date)
  end
end
```

---

## **8. Routes File**

### config/routes.rb

```ruby
Rails.application.routes.draw do
  resources :tasks, only: %i[index create show]
end
```

---

## **9. Add Seeds for Local Development**

### db/seeds.rb

```ruby
5.times do
  Task.create!(
    title: Faker::Lorem.sentence,
    description: Faker::Lorem.paragraph,
    status: "pending",
    due_date: Date.today + rand(1..7)
  )
end
```

Run:

```bash
rails db:seed
```

---

## **10. RSpec Factories**

### spec/factories/tasks.rb

```ruby
FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { "pending" }
    due_date { Date.today + 3.days }
  end
end
```

---

## **11. RSpec Model Specs**

### spec/models/task_spec.rb

```ruby
RSpec.describe Task, type: :model do
  it "is valid with valid attributes" do
    expect(build(:task)).to be_valid
  end

  it "is invalid without title" do
    expect(build(:task, title: nil)).not_to be_valid
  end

  it "normalizes title before save" do
    task = create(:task, title: "  Hello  ")
    expect(task.title).to eq("Hello")
  end
end
```

---

## **12. RSpec Service Tests**

### spec/services/tasks/create_task_service_spec.rb

```ruby
RSpec.describe Tasks::CreateTaskService do
  subject(:service) { described_class.new(params) }

  let(:params) { attributes_for(:task) }

  it "creates a task successfully" do
    expect { service.call }.to change(Task, :count).by(1)
  end

  it "raises error when invalid" do
    params[:title] = nil
    expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
```

---

## **13. RSpec Request Specs**

### spec/requests/tasks_spec.rb

```ruby
RSpec.describe "Tasks API", type: :request do
  describe "GET /tasks" do
    it "returns list of tasks" do
      create_list(:task, 3)
      get "/tasks"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(3)
    end
  end

  describe "POST /tasks" do
    let(:params) do
      {
        task: {
          title: "New Task",
          description: "Sample",
          status: "pending"
        }
      }
    end

    it "creates a task" do
      post "/tasks", params: params

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)["title"]).to eq("New Task")
    end
  end
end
```

---

## **14. Manual API Testing**

```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"task":{"title":"My First Task","description":"Test","status":"pending"}}'
```

---

## **15. Final Recommended Folder Structure (Senior-Level)**

```
app/
 ├── controllers/
 │    ├── application_controller.rb
 │    └── tasks_controller.rb
 ├── models/
 │    └── task.rb
 ├── serializers/
 │    └── task_serializer.rb
 └── services/
      └── tasks/
           └── create_task_service.rb

spec/
 ├── factories/tasks.rb
 ├── models/task_spec.rb
 ├── services/tasks/create_task_service_spec.rb
 └── requests/tasks_spec.rb
```

---

## **16. Senior-Level Best Practices Summary**

- **Always validate + sanitize input**  
- **Use service objects** for business logic  
- **Use serializers** for API output consistency  
- **Use after_commit instead of after_save**  
- **Add DB constraints (null: false, indexes)**  
- **Use RSpec + factories** for clean test suites  
- **Controllers stay thin** — only handling HTTP layer  
- **Prefer POROs** for non-ActiveRecord logic  
- **Never place API logic inside models**

---

