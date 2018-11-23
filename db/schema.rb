# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160222085815) do

  create_table "branches", force: true do |t|
    t.integer  "project_id"
    t.string   "name"
    t.integer  "latest_revision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "branches", ["project_id", "name"], name: "index_branches_on_project_id_and_name"

  create_table "builds", force: true do |t|
    t.integer  "branch_id"
    t.integer  "revision_id"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "status"
    t.string   "trigger"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inch_version"
    t.text     "stderr"
  end

  add_index "builds", ["branch_id"], name: "index_builds_on_branch_id"

  create_table "code_object_diffs", force: true do |t|
    t.integer  "revision_diff_id"
    t.integer  "before_object_id"
    t.integer  "after_object_id"
    t.string   "change"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "code_object_diffs", ["revision_diff_id"], name: "index_code_object_diffs_on_revision_diff_id"

  create_table "code_object_references", force: true do |t|
    t.integer  "revision_id"
    t.integer  "code_object_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "code_object_references", ["code_object_id", "revision_id"], name: "index_code_object_references_on_code_object_id_and_revision_id", unique: true
  add_index "code_object_references", ["revision_id"], name: "index_code_object_references_on_revision_id"

  create_table "code_object_role_names", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "code_object_roles", force: true do |t|
    t.integer  "code_object_id"
    t.integer  "code_object_role_name_id"
    t.string   "ref_name"
    t.integer  "priority"
    t.integer  "score"
    t.integer  "potential_score"
    t.integer  "min_score"
    t.integer  "max_score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "code_object_roles", ["code_object_id"], name: "index_code_object_roles_on_code_object_id"

  create_table "code_objects", force: true do |t|
    t.integer  "project_id"
    t.string   "type"
    t.text     "fullname"
    t.text     "docstring"
    t.integer  "score"
    t.string   "grade",      limit: 1
    t.integer  "priority"
    t.string   "location"
    t.string   "digest",     limit: 28
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "code_objects", ["digest"], name: "index_code_objects_on_digest"

  create_table "projects", force: true do |t|
    t.string   "uid"
    t.string   "name"
    t.text     "description",                limit: 255
    t.string   "homepage_url"
    t.string   "source_code_url"
    t.string   "repo_url"
    t.string   "documentation_url"
    t.integer  "default_branch_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "language"
    t.string   "origin"
    t.text     "languages"
    t.boolean  "fork"
    t.integer  "github_hook_id"
    t.boolean  "github_hook_active",                     default: false
    t.boolean  "badge_generated",                        default: false
    t.integer  "badge_filled_in_percent"
    t.boolean  "badge_in_readme",                        default: false
    t.datetime "badge_in_readme_added_at"
    t.datetime "badge_in_readme_removed_at"
  end

  add_index "projects", ["uid"], name: "index_projects_on_uid"

  create_table "revision_diffs", force: true do |t|
    t.integer  "branch_id"
    t.integer  "before_revision_id"
    t.integer  "after_revision_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "revision_diffs", ["branch_id"], name: "index_revision_diffs_on_branch_id"

  create_table "revisions", force: true do |t|
    t.integer  "branch_id"
    t.string   "uid"
    t.string   "tag_uid"
    t.text     "message",         limit: 255
    t.string   "author_name"
    t.string   "author_email"
    t.datetime "authored_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "badge_in_readme",             default: false
  end

  create_table "statistics", force: true do |t|
    t.datetime "date"
    t.string   "name"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "github_access_token"
    t.string   "display_name"
    t.string   "user_name"
    t.string   "email"
    t.text     "follows"
    t.datetime "last_signin_at"
    t.datetime "last_synced_projects_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "organizations"
  end

  add_index "users", ["provider", "user_name"], name: "index_users_on_provider_and_user_name", unique: true

end
