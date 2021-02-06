require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  
  describe "#index" do
    # 認証済みユーザーとして
    context "as an authenticated user" do
      
      before do
        @user = FactoryBot.create(:user)
      end
      
      # 正常にレスポンスを返すこと
      it "responds successfully" do
        sign_in @user
        get :index
        expect(response).to be_success
      end
      
      # 200レスポンスを返すこと
      it "returns a 200 response" do
        sign_in @user
        get :index
        expect(response).to have_http_status "200"
      end
      
    end
    
    # ゲスト（ログインしていない状態）として
    context "as a guest" do
      # 302レスポンス（レスポンス）を返すこと
      it "returns a 302 response" do
        get :index
        expect(response).to have_http_status "302"
      end
      
      # サインイン画面にリダイレクトすること
      it "redirect to the sign_in page" do
        get :index
        expect(response).to redirect_to "/users/sign_in"
      end
      
    end
  end
  
  describe "#show" do
    # 認可されたユーザーとして
    context "as an authorozed user" do
      
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end
      
      # 正常にレスポンスを返すこと
      it "responds successfully" do
        sign_in @user
        get :show, params: { id: @project.id }
        expect(response).to be_success
      end
      
      # 認可されていないユーザーとして
      context "as an unauthorized user" do
        before do
          @user = FactoryBot.create(:user)
          other_user = FactoryBot.create(:user)
          @project = FactoryBot.create(:project, owner: other_user)
        end
        
        # ダッシュボードにリダイレクトすること
        it "redirects to the dashboard" do
          sign_in @user
          get :show, params: { id: @project.id }
          expect(response).to redirect_to root_path
        end
        
      end
    end
  end
  
  describe "#create" do
    # 認証済みユーザーとして
    context "as an authenticated user" do
      
      before do 
        @user = FactoryBot.create(:user)
      end
      
      it "adds a project" do
        project_params = FactoryBot.attributes_for(:project)
        sign_in @user
        
        expect {
          post :create, params: {project: project_params}
        }.to change(@user.projects, :count).by(1)
        
      end
      
    end
    
    
    context "as a guest" do
      "302レスポンスを返すこと"
      it "returns a 302 response" do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to have_http_status "302"
      end
      
      it "redirects to the sign_in page" do
        project_params = FactoryBot.attributes_for(:project)
        post :create, params: { project: project_params }
        expect(response).to redirect_to "users/sign_in"
      end
      
      
    end
    
  end
  
  
  describe "#update" do
    # 認可されたユーザーとして
    context "as an authorized user" do
      before do
        @user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: @user)
      end
      
      # プロジェクトを更新できること
      it "updates a project" do
        project_params = FactoryBot.attributes_for(:project, name: "New Project Name")
        sign_in @user
        patch :update, params: { id: @project.id, project: project_params }
        expect(@project.reload.name).to eq "New Project Name"
      end
    end
    
    # 認可されていないユーザーとして
    context "as an unauthorized user" do
      before do
        @user = FactoryBot.create(:user)
        other_user = FactoryBot.create(:user)
        @project = FactoryBot.create(:project, owner: other_user, name: "Same Old Name")
      end
      
      # プロジェクトを更新できないこと
      it "does not update the project" do
        project_params = FactoryBot.attributes_for(:project, name: "New Name")
        sign_in @user
        patch :update, params: { id: @project.id, project: project_params }
        expect(@project.reload.name).to eq "Same Old Name"
      end
      
      # ダッシュボードへリダイレクトすること
      it "redirects to the dashboard" do
        project_paramas = FactoryBot.attributes_for(:project)
        sign_in @user
        patch :update, params: { id: @project.id, project: project_paramas }
        expect(response).to redirect_to root_path
      end
      
      
      context "as a guest" do
        before do
          @project = FactoryBot.create(:project)
        end
        
        # 302レスポンスを返すこと
        it "returns a 302 response" do
          project_paramas = FactoryBot.attributes_for(:project)
          patch :update, params: { id: @project.id, project: project_paramas}
          expect(response).to have_http_status "302"
        end
        
      end
    end
    
  end
  
  
end
