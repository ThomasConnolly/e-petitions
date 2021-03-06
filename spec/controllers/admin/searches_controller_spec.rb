require 'rails_helper'

RSpec.describe Admin::SearchesController, type: :controller, admin: true do
  context "when not logged in" do
    describe "GET /admin/search" do
      it "redirects to the login page" do
        get :show, type: "petition", q: "foo"
        expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/login")
      end
    end
  end

  context "when logged in as a moderator but need to reset password" do
    let(:user) { FactoryBot.create(:moderator_user, force_password_reset: true) }
    before { login_as(user) }

    describe "GET /admin/search" do
      it "redirects to the edit profile page" do
        get :show, type: "petition", q: "foo"
        expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/profile/#{user.id}/edit")
      end
    end
  end

  context "when logged in as a moderator" do
    let(:user) { FactoryBot.create(:moderator_user) }
    before { login_as(user) }

    describe "GET /admin/search" do
      context "when searching for petitions" do
        it "redirects to the petitions search url" do
          get :show, type: "petition", q: "foo"
          expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/petitions?q=foo")
        end
      end

      context "when searching for petitions with tags" do
        it "redirects to the petitions search url" do
          get :show, type: "petition", q: "foo", tags: ["1"], match: "any"
          expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/petitions?match=any&q=foo&tags%5B%5D=1")
        end
      end

      context "when searching for petitions with no tags" do
        it "redirects to the petitions search url" do
          get :show, type: "petition", q: "foo", match: "none"
          expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/petitions?match=none&q=foo")
        end
      end

      context "when searching for signatures" do
        it "redirects to the signatures search url" do
          get :show, type: "signature", q: "foo"
          expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin/signatures?q=foo")
        end
      end

      context "when searching for an unknown type" do
        it "redirects to the admin dashboard url" do
          get :show, q: "foo"
          expect(response).to redirect_to("https://moderate.petition.parliament.uk/admin")
          expect(flash[:notice]).to eq("Sorry, we didn't understand your query")
        end
      end
    end
  end
end
