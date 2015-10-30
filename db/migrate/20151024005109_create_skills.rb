class CreateSkills < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string :name
      t.text :desc
      t.string :img
      t.decimal  "baseAD", precision: 16, scale: 8
      t.decimal  "baseAP", precision: 16, scale: 8
      t.decimal  "baseArmor", precision: 16, scale: 8
      t.decimal  "baseMR", precision: 16, scale: 8
      t.decimal  "baseHP", precision: 16, scale: 8
      t.decimal  "adPerLv", precision: 16, scale: 8
      t.decimal  "apPerLv", precision: 16, scale: 8
      t.decimal  "arPerLv", precision: 16, scale: 8
      t.decimal  "mrPerLv", precision: 16, scale: 8
      t.decimal  "hpPerLv", precision: 16, scale: 8
      t.decimal  "dmg1", precision: 16, scale: 8
      t.decimal  "dmg2", precision: 16, scale: 8
      t.decimal  "dmg3", precision: 16, scale: 8
      t.decimal  "dmg4", precision: 16, scale: 8
      t.decimal  "dmg5", precision: 16, scale: 8
      t.decimal  "dmg6", precision: 16, scale: 8
      t.decimal  "eDmg1", precision: 16, scale: 8
      t.decimal  "eDmg2", precision: 16, scale: 8
      t.decimal  "eDmg3", precision: 16, scale: 8
      t.decimal  "eDmg4", precision: 16, scale: 8
      t.decimal  "eDmg5", precision: 16, scale: 8
      t.decimal  "eDmg6", precision: 16, scale: 8
      t.decimal  "fDmg1", precision: 16, scale: 8
      t.decimal  "fDmg2", precision: 16, scale: 8
      t.decimal  "fDmg3", precision: 16, scale: 8
      t.decimal  "fDmg4", precision: 16, scale: 8
      t.decimal  "fDmg5", precision: 16, scale: 8
      t.decimal  "fDmg6", precision: 16, scale: 8
      t.decimal "scale11", precision: 16, scale: 8
      t.decimal "scale12", precision: 16, scale: 8
      t.decimal "scale13", precision: 16, scale: 8
      t.decimal "scale14", precision: 16, scale: 8
      t.decimal "scale15", precision: 16, scale: 8
      t.decimal "scale21", precision: 16, scale: 8
      t.decimal "scale22", precision: 16, scale: 8
      t.decimal "scale23", precision: 16, scale: 8
      t.decimal "scale24", precision: 16, scale: 8
      t.decimal "scale25", precision: 16, scale: 8
      t.decimal "scale31", precision: 16, scale: 8
      t.decimal "scale32", precision: 16, scale: 8
      t.decimal "scale33", precision: 16, scale: 8
      t.decimal "scale34", precision: 16, scale: 8
      t.decimal "scale35", precision: 16, scale: 8
      t.decimal "cdr1", precision: 16, scale: 8
      t.decimal "cdr2", precision: 16, scale: 8
      t.decimal "cdr3", precision: 16, scale: 8
      t.decimal "cdr4", precision: 16, scale: 8
      t.decimal "cdr5", precision: 16, scale: 8
      t.decimal "cdr6", precision: 16, scale: 8
      t.string  "type1"
      t.string  "type2"
      t.string  "type3"
      t.boolean "bonus"
      t.timestamps null: false
    end
  end
end
