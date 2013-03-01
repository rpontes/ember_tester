require 'test_helper'

class Api::V1::PostsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index, format: :json
    assert_response :success
  end

  test "should get show" do
    get :show, id: Post.first.id, format: :json
    assert_response :success
  end
end
