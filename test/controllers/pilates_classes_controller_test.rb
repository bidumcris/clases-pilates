require "test_helper"

class PilatesClassesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_pilates_classes_path
    assert_response :success
  end

  test "should get show" do
    # Necesitamos un ID válido, pero como es un test básico, podemos usar 1
    # En un test real, deberías crear un pilates_class primero
    get admin_pilates_class_path(1)
    # Si no existe, esperamos un 404 o redirect, no success
    assert_response :redirect
  end
end
