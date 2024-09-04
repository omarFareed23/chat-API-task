require 'rails_helper'

RSpec.describe 'Application Controller', type: :request do
  let(:valid_attributes) { { name: Faker::App.name } }
  let(:invalid_attributes) { { name: nil } }
  let!(:application) { Application.create!(name: Faker::App.name, token: SecureRandom.hex(16)) }
  let(:default_headers) { { 'ACCEPT' => 'application/json' } }

  describe "GET #show" do
    context "when application exists" do
      it "returns a success response and checks name and token" do
        get "/api/v1/applications/#{application.token}", params: { token: application.token }, headers: default_headers

        expect(response).to have_http_status(:ok)

        # Parse JSON response
        json_response = JSON.parse(response.body)

        # Assert that name and token are correct
        expect(json_response['name']).to eq(application.name)
        expect(json_response['token']).to eq(application.token)
      end
    end

    context "when application does not exist" do
      it "returns a not found response" do
        get "/api/v1/applications/invalid_token", headers: default_headers
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Application" do
        expect {
          post "/api/v1/applications", params: { application: valid_attributes }, headers: default_headers
        }.to change(Application, :count).by(1)
      end

      it "returns a created response" do
        post "/api/v1/applications", params: { application: valid_attributes }, headers: default_headers
        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid params" do
      it "does not create a new Application" do
        expect {
          post "/api/v1/applications", params: { application: invalid_attributes }, headers: default_headers
        }.to change(Application, :count).by(0)
      end

      it "returns an unprocessable entity response" do
        post "/api/v1/applications", params: { application: invalid_attributes }, headers: default_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { name: Faker::App.name } }

      it "updates the requested application" do
        put "/api/v1/applications/#{application.token}", params: { token: application.token, application: new_attributes }, headers: default_headers
        application.reload
        expect(application.name).to eq(new_attributes[:name])
      end

      it "returns a success response" do
        put "/api/v1/applications/#{application.token}", params: { token: application.token, application: valid_attributes }, headers: default_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      it "returns an unprocessable entity response" do
        put "/api/v1/applications/#{application.token}", params: { token: application.token, application: invalid_attributes }, headers: default_headers
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested application" do
      expect {
        delete "/api/v1/applications/#{application.token}", params: { token: application.token }, headers: default_headers
      }.to change(Application, :count).by(-1)
    end

    it "returns a no content response" do
      delete "/api/v1/applications/#{application.token}", params: { token: application.token }, headers: default_headers
      expect(response).to have_http_status(:no_content)
    end
  end
end
