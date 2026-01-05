require "test_helper"

class PilatesClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    # Este test verifica que la ruta existe y requiere autenticación
    # Los detalles de Ransack se pueden probar en tests más específicos
    get admin_pilates_classes_path
    # Puede ser success o redirect dependiendo de la configuración
    assert_response :success
  end
end
