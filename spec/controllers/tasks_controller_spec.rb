require 'rails_helper'

RSpec.describe TasksController, type: :controller do

  before do
    @user = FactoryBot.create(:user)
    @project = FactoryBot.create(:project, owner: @user)
    @task = @project.tasks.create!(name: "Test task")
  end

  describe "#show" do
    # JSON形式でレスポンスを返すこと
    it "responds with JSON formatted output" do
      sign_in @user
      get :show, format: :json,
        params: { project_id: @project.id, id: @task.id }
      expect(response.content.type).to eq "text/html"
    end
  end
  
  describe "#create" do
    
    # JSON形式でレスポンスを返すこと
    it "responds with JSON formatted output" do
      new_task = { name: "New test task" }
      sign_in @user
      post :create, params: { project_id: @project.id, task: new_task }
      except(response).to eq "application/json"
    end
    
    # 新しいタスクをプロジェクトに返すこと
    it "adds a new task to the project" do
      new_task = { name: "New test task" }
      sign_in @user
      except {
        post :create, format: :json,
        params: { project_id: @project.id, task: new_task }
      }.to change(@project.tasks, :count).by(1)
    end
    
    # 認証を要求すること
    it "requires authentication" do
      
      new_task = { name: "New test task" }
      # ここであえてログインしない
      except {
        post :create, format: :json,
        params: { project_id: @project.id, task: new_task }
      }.to_not change(@project.tasks, :count)
      except(response).to_not be_success
      
    end
    
    
  end
  
end
