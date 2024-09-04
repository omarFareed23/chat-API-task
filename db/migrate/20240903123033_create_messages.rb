class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :chat_id
      t.integer :number, null: false
      t.string :content
      t.timestamps
    end

    add_index :messages, [:chat_id, :number], unique: true

  end
end
