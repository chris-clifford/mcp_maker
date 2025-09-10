class CreateTools < ActiveRecord::Migration[8.0]
  def change
    create_table :tools do |t|
      t.string :description, null: false
      t.json :arguments, null: false, default: {}
      t.string :call_action, null: false

      t.timestamps
    end
  end
end

