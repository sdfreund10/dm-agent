module CharacterClasses
  AC_VALUES = {
    "NO_ARMOR" => 10,
    "LIGHT_ARMOR" => 11,
    "MEDIUM_ARMOR" => 13,
    "HEAVY_ARMOR" => 15,
    "SHIELD" => 2,
  }
  CON_MODS = {
    "TANK" => 3,
    "OFF_TANK" => 2,
    "SKIRMISHER" => 1,
    "CASTER" => 0,
  }
  DEX_MODS = { # I feel like there are better names
    "FAST" => 2,
    "NORMAL" => 1,
    "SLOW" => 0,
  }

  DNDClass= Data.define(:name, :hp_die, :con_mod, :ac)
  CLASSES = {
    "Barbarian" => DNDClass.new("Barbarian", 12, CON_MODS["TANK"], AC_VALUES["LIGHT_ARMOR"] + DEX_MODS["FAST"]),
    "Bard" => DNDClass.new("Bard", 8, CON_MODS["SKIRMISHER"], AC_VALUES["LIGHT_ARMOR"] + DEX_MODS["FAST"]),
    "Cleric" => DNDClass.new("Cleric", 8, CON_MODS["CASTER"], AC_VALUES["HEAVY_ARMOR"] + AC_VALUES["SHIELD"] + DEX_MODS["SLOW"]),
    "Druid" => DNDClass.new("Druid", 8, CON_MODS["CASTER"], AC_VALUES["LIGHT_ARMOR"] + AC_VALUES["SHIELD"] + DEX_MODS["SLOW"]),
    "Fighter" => DNDClass.new("Fighter", 10, CON_MODS["OFF_TANK"], AC_VALUES["HEAVY_ARMOR"] + AC_VALUES["SHIELD"] + DEX_MODS["NORMAL"]),
    "Monk" => DNDClass.new("Monk", 8, CON_MODS["SKIRMISHER"], AC_VALUES["NO_ARMOR"] + DEX_MODS["FAST"]),
    "Paladin" => DNDClass.new("Paladin", 10, CON_MODS["OFF_TANK"], AC_VALUES["HEAVY_ARMOR"] + AC_VALUES["SHIELD"] + DEX_MODS["NORMAL"]),
    "Ranger" => DNDClass.new("Ranger", 10, CON_MODS["SKIRMISHER"], AC_VALUES["LIGHT_ARMOR"] + DEX_MODS["FAST"]),
    "Rogue" => DNDClass.new("Rogue", 8, CON_MODS["SKIRMISHER"], AC_VALUES["LIGHT_ARMOR"] + DEX_MODS["FAST"]),
    "Sorcerer" => DNDClass.new("Sorcerer", 6, CON_MODS["CASTER"], AC_VALUES["NO_ARMOR"] + DEX_MODS["SLOW"]),
    "Warlock" => DNDClass.new("Warlock", 8, CON_MODS["CASTER"], AC_VALUES["NO_ARMOR"] + DEX_MODS["SLOW"]),
    "Wizard" => DNDClass.new("Wizard", 6, CON_MODS["CASTER"], AC_VALUES["NO_ARMOR"] + DEX_MODS["SLOW"]),
  }
end
