class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :name, null: false
      t.string :github_url, null: false
      t.string :short_code

      t.string :github_username
      t.integer :followers_count
      t.integer :following_count
      t.integer :stars_count
      t.integer :contributions_last_year
      t.string :avatar_url
      t.string :organization
      t.string :location

      t.datetime :last_scanned_at

      t.timestamps
    end

    add_index :profiles, :short_code, unique: true
  end
end

