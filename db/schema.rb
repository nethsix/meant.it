# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110619065300) do

  create_table "appointments", :force => true do |t|
    t.datetime "app_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "physician_id"
    t.integer  "patient_id"
  end

  create_table "end_point_tag_rels", :force => true do |t|
    t.integer  "endpoint_id"
    t.integer  "tag_id"
    t.string   "status",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "end_point_tag_rels", ["endpoint_id", "tag_id"], :name => "by_endPoint_id_tag_id", :unique => true

  create_table "end_points", :force => true do |t|
    t.integer  "creator_endpoint_id"
    t.datetime "start_time",          :null => false
    t.datetime "end_time"
    t.string   "nick",                :null => false
    t.string   "status",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "end_points", ["nick", "creator_endpoint_id"], :name => "by_nick_and_creatorEndPoint_id", :unique => true

  create_table "entities", :force => true do |t|
    t.string   "property_document_id", :null => false
    t.string   "status",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["id", "property_document_id"], :name => "by_id_and_propertyDocument_id", :unique => true

  create_table "entity_end_point_rels", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "endpoint_id"
    t.string   "verification_type", :null => false
    t.text     "verification_desc"
    t.string   "status",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_end_point_rels", ["endpoint_id", "entity_id", "verification_type"], :name => "by_endPoint_id_and_entity_id_and_verificationType", :unique => true

  create_table "inbound_emails", :force => true do |t|
    t.text     "headers",          :null => false
    t.text     "body_text"
    t.text     "body_html"
    t.string   "from",             :null => false
    t.string   "to",               :null => false
    t.string   "cc"
    t.text     "subject"
    t.text     "dkim"
    t.text     "spf"
    t.text     "envelope",         :null => false
    t.text     "charsets"
    t.string   "spam_score"
    t.text     "spam_report"
    t.integer  "attachment_count", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "meant_it_rels", :force => true do |t|
    t.integer  "src_endpoint_id", :null => false
    t.integer  "dst_endpoint_id", :null => false
    t.string   "message_type",    :null => false
    t.text     "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "obj_rels", :force => true do |t|
    t.integer  "srcobj_id",    :null => false
    t.integer  "dstobj_id",    :null => false
    t.string   "rel_type",     :null => false
    t.string   "rel_desc"
    t.string   "status",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "rel_obj_type"
  end

  add_index "obj_rels", ["srcobj_id", "dstobj_id", "rel_type"], :name => "by_srcObj_id_and_dstObj_id_and_relType", :unique => true

  create_table "patients", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "physicians", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "piis", :force => true do |t|
    t.string   "pii_type",    :null => false
    t.string   "pii_value",   :null => false
    t.text     "pii_desc"
    t.string   "status",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "endpoint_id"
  end

  add_index "piis", ["pii_value", "pii_type"], :name => "by_piiVaue_and_piiType", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "desc"
    t.string   "status",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "by_name", :unique => true

end
