ActiveAdmin.register Payment do
  permit_params :user_id, :amount, :payment_method, :payment_status, :transaction_id

  menu priority: 9, label: "Pagos"

  scope :all, default: true
  scope :completed
  scope :pending
  scope :failed

  index do
    selectable_column
    id_column
    column "Usuario" do |payment|
      link_to payment.user.email, admin_user_path(payment.user)
    end
    column :amount do |payment|
      number_to_currency(payment.amount, unit: "€", separator: ",", delimiter: ".")
    end
    column "Método" do |payment|
      case payment.payment_method
      when "card"
        "Tarjeta"
      when "qr"
        "QR"
      when "deposit"
        "Seña (50%)"
      else
        payment.payment_method
      end
    end
    column "Estado" do |payment|
      status_tag payment.payment_status
    end
    column :transaction_id
    column :created_at
    actions
  end

  filter :user
  filter :amount
  filter :payment_method
  filter :payment_status
  filter :created_at

  show do
    attributes_table do
      row "Usuario" do |payment|
        link_to payment.user.email, admin_user_path(payment.user)
      end
      row :amount do |payment|
        number_to_currency(payment.amount, unit: "€", separator: ",", delimiter: ".")
      end
      row "Método de Pago" do |payment|
        case payment.payment_method
        when "card"
          "Tarjeta"
        when "qr"
          "QR"
        when "deposit"
          "Seña (50%)"
        else
          payment.payment_method
        end
      end
      row "Estado" do |payment|
        status_tag payment.payment_status
      end
      row :transaction_id
      row :created_at
    end
  end

  form do |f|
    f.inputs "Información del Pago" do
      f.input :user
      f.input :amount
      f.input :payment_method, as: :select, collection: [
        [ "Tarjeta", "card" ],
        [ "QR", "qr" ],
        [ "Seña (50%)", "deposit" ]
      ]
      f.input :payment_status, as: :select, collection: Payment.payment_statuses.keys.map { |k| [ k.humanize, k ] }
      f.input :transaction_id, hint: "ID de transacción del procesador de pagos"
    end
    f.actions
  end

  action_item :complete, only: :show, if: proc { payment.pending? } do
    link_to "Marcar como Completado", complete_admin_payment_path(payment), method: :post
  end

  member_action :complete, method: :post do
    resource.complete!
    redirect_to resource_path, notice: "Pago marcado como completado"
  end
end
