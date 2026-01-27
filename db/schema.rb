# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_27_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "credits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "amount", null: false
    t.date "expires_at", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_credits_on_user_id"
  end

  create_table "fixed_slots", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "day_of_week", null: false
    t.integer "hour", null: false
    t.bigint "room_id", null: false
    t.bigint "instructor_id", null: false
    t.string "level", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id"], name: "index_fixed_slots_on_instructor_id"
    t.index ["room_id"], name: "index_fixed_slots_on_room_id"
    t.index ["user_id", "day_of_week", "hour"], name: "index_fixed_slots_on_user_id_and_day_of_week_and_hour", unique: true
    t.index ["user_id"], name: "index_fixed_slots_on_user_id"
  end

  create_table "instructors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_instructors_on_user_id", unique: true
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "payment_method", default: 0, null: false
    t.integer "payment_status", default: 0, null: false
    t.string "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "provider_reference"
    t.string "checkout_url"
    t.datetime "paid_at"
    t.jsonb "provider_payload", default: {}, null: false
    t.integer "kind", default: 0, null: false
    t.date "due_date"
    t.date "period_start"
    t.date "period_end"
    t.integer "turns_included"
    t.string "notes"
    t.index ["due_date"], name: "index_payments_on_due_date"
    t.index ["kind"], name: "index_payments_on_kind"
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["provider", "provider_reference"], name: "index_payments_on_provider_and_provider_reference"
    t.index ["user_id", "kind", "period_start", "period_end"], name: "idx_payments_unique_period", unique: true
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "pilates_classes", force: :cascade do |t|
    t.string "name"
    t.integer "level"
    t.bigint "room_id", null: false
    t.bigint "instructor_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "max_capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "class_type", default: 0, null: false
    t.boolean "holiday", default: false, null: false
    t.string "holiday_reason"
    t.index ["holiday"], name: "index_pilates_classes_on_holiday"
    t.index ["instructor_id"], name: "index_pilates_classes_on_instructor_id"
    t.index ["room_id"], name: "index_pilates_classes_on_room_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pilates_class_id", null: false
    t.integer "request_type", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pilates_class_id"], name: "index_requests_on_pilates_class_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pilates_class_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "reserved_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "attendance_status", default: 0, null: false
    t.index ["pilates_class_id"], name: "index_reservations_on_pilates_class_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.integer "room_type"
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "level", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "class_type", default: 0, null: false
    t.integer "role", default: 0, null: false
    t.string "dni"
    t.string "phone"
    t.string "mobile"
    t.date "birth_date"
    t.string "name"
    t.boolean "active", default: true, null: false
    t.boolean "fake_email", default: false, null: false
    t.date "subscription_start"
    t.date "subscription_end"
    t.string "emergency_phone"
    t.text "additional_info"
    t.decimal "payment_amount", precision: 10, scale: 2
    t.decimal "debt_amount", precision: 10, scale: 2
    t.date "last_payment_date"
    t.integer "monthly_turns"
    t.date "join_date"
    t.date "first_payment_date"
    t.integer "payments_count"
    t.boolean "normal_view", default: true, null: false
    t.string "param1"
    t.string "param2"
    t.string "param3"
    t.integer "billing_status", default: 1, null: false
    t.index ["billing_status"], name: "index_users_on_billing_status"
    t.index ["dni"], name: "index_users_on_dni", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "credits", "users"
  add_foreign_key "fixed_slots", "instructors"
  add_foreign_key "fixed_slots", "rooms"
  add_foreign_key "fixed_slots", "users"
  add_foreign_key "instructors", "users"
  add_foreign_key "payments", "users"
  add_foreign_key "pilates_classes", "instructors"
  add_foreign_key "pilates_classes", "rooms"
  add_foreign_key "requests", "pilates_classes"
  add_foreign_key "requests", "users"
  add_foreign_key "reservations", "pilates_classes"
  add_foreign_key "reservations", "users"
end
