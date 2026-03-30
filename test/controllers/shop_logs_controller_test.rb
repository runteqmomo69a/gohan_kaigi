require "test_helper"

class ShopLogsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get shop_logs_index_url
    assert_response :success
  end
end
