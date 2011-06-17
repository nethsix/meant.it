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

ActiveRecord::Schema.define(:version => 20110617031146) do

  create_table "end_point_tag_rels", :force => true do |t|
    t.integer  "endPoint_id"
    t.integer  "tag_id"
    t.string   "status",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "end_point_tag_rels", ["endPoint_id", "tag_id"], :name => "by_endPoint_id_tag_id", :unique => true

  create_table "end_points", :force => true do |t|
    t.integer  "creatorEndPoint_id"
    t.datetime "startTime",          :null => false
    t.datetime "endTime"
    t.string   "nick",               :null => false
    t.string   "status",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "end_points", ["nick", "creatorEndPoint_id"], :name => "by_nick_and_creatorEndPoint_id", :unique => true

  create_table "entities", :force => true do |t|
    t.string   "propertyDocument_id", :null => false
    t.string   "status",              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entities", ["id", "propertyDocument_id"], :name => "by_id_and_propertyDocument_id", :unique => true

  create_table "entity_end_point_rels", :force => true do |t|
    t.integer  "entity_id"
    t.integer  "endPoint_id"
    t.string   "verificationType", :null => false
    t.text     "verificationDesc"
    t.string   "status",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entity_end_point_rels", ["endPoint_id", "entity_id", "verificationType"], :name => "by_endPoint_id_and_entity_id_and_verificationType", :unique => true

  create_table "meant_it_rels", :force => true do |t|
    t.integer  "srcEndPoint_id", :null => false
    t.integer  "dstEndPoint_id", :null => false
    t.string   "messageType",    :null => false
    t.text     "message"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "obj_rels", :force => true do |t|
    t.integer  "srcObj_id",  :null => false
    t.integer  "dstObj_id",  :null => false
    t.string   "relType",    :null => false
    t.string   "relDesc"
    t.string   "status",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "relObjType"
  end

  add_index "obj_rels", ["srcObj_id", "dstObj_id", "relType"], :name => "by_srcObj_id_and_dstObj_id_and_relType", :unique => true

  create_table "piis", :force => true do |t|
    t.string   "piiType",     :null => false
    t.string   "piiValue",    :null => false
    t.text     "piiDesc"
    t.string   "status",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "endPoint_id"
  end

  add_index "piis", ["piiValue", "piiType"], :name => "by_piiVaue_and_piiType", :unique => true

  create_table "tags", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "desc"
    t.string   "status",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "by_name", :unique => true

end
