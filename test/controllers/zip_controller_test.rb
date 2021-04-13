require "test_helper"

class ZipControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get zip_index_url
    assert_response :success
  end
end
