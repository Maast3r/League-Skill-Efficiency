require 'concurrent'
require 'json'
class Object
  def ensure_array
    [self]
  end
end
class Array
  def ensure_array
    to_a
  end
end
class NilClass
  def ensure_array
    to_a
  end
end
class MainController < ApplicationController
  @@key = ENV['RIOT_API_KEY']
  @@base_request = "global.api.pvp.net"
  @@versions_request_path = "/api/lol/static-data/na/v1.2/versions"
  @@champion_request_path = "/api/lol/static-data/na/v1.2/champion"
  def index
    @skills = Skill.all
    puts Skill.all.to_json
  end
  def populate_database
    getChamps
    index
    render action: 'index'
  end
  def getChamps
    champion_uri = URI::HTTPS.build(host: @@base_request,
                                    path: @@champion_request_path,
                                    query: {champData: "stats,spells", api_key: @@key}.to_query)
    response = HTTParty.get(champion_uri, verify: false)
    parse_API_response(response.parsed_response) if response.code == 200
  end
  def parse_API_response(response)
    response["data"].each do |champion_response|
      champion = champion_response[1]
      # INITALIZING VARAIBLES FOR EACH SPELL
      baseAD = champion["stats"]["attackdamage"]
      baseAP = 0.0 # All champs have no base AP
      baseArmor = champion["stats"]["armor"]
      baseMR = champion["stats"]["spellblock"]
      baseHP = champion["stats"]["hp"]
      adPerLv = champion["stats"]["attackdamageperlevel"]
      apPerLv = 0 # ALl champs don't get AP per level
      arPerLv = champion["stats"]["armorperlevel"]
      mrPerLv = champion["stats"]["spellblockperlevel"]
      hpPerLv = champion["stats"]["hpperlevel"]
      champion["spells"].each do |spells|
        img = spells["image"]["full"]
        dmg = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        eDmg = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        fDmg = [0.0, 0, 0.0, 0.0, 0.0, 0.0]
        scaling1 = [0.0, 0, 0.0, 0.0, 0.0]
        scaling2 = [0.0, 0, 0.0, 0.0, 0.0]
        scaling3 = [0.0, 0, 0.0, 0.0, 0.0]
        scaling = [scaling1, scaling2, scaling3]
        cooldown = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        type = ["", "", ""]
        bonus = false
        dmgCounter = 0
        #DMG SOURCES
        spells["leveltip"]["effect"].each_with_index do |effect, index|
          if (effect.include? "e") &&
              (spells["leveltip"]["label"][index].to_s !~ Regexp.union(/Distance/, /Speed/, /Range/, /Slow/, /Mana/, /Timer/, /Reduction/,
                                                                       /Maximum/, /Multiplier/, /Cost/, /Spider/, /Movement/))
            bonus = true if spells["leveltip"]["label"][index].to_s.include? "Bonus Damage"
            if dmgCounter == 0
              if spells["name"] == "Noxious Trap"
                # This is the only skill in the game that does base DMG/S,
                # but the DMG is coded as 4x each second's dmg in order to
                # look correct, So divide the damage value by 4
                getDmg(dmg, effect, spells, 4)
              else
                getDmg(dmg, effect, spells, 1)
              end
              dmgCounter = 1
            elsif dmgCounter == 1
              getDmg(eDmg, effect, spells, 1)
              dmgCounter = 2
            elsif dmgCounter == 2
              getDmg(fDmg, effect, spells, 1)
              dmgCounter = 3
            end
          end
        end
        #Scaling and TYPES (AD/AP)
        if spells["vars"]
          scaleCounter = 0
          spells["vars"].each_with_index do |scale|
            if (scale["key"].include? "e") || (scale["key"].include? "a") || (scale["link"].include? "dynamic") || (scale["link"].include? "special") || (scale["link"].include? "attack")
              if scale["coeff"].ensure_array.length > 1
                scale["coeff"].ensure_array.each_with_index do |scaleNumber, index|
                  scaling[scaleCounter][index] = scaleNumber.to_f
                end
              else
                (1..6).each do |i|
                  scaling[scaleCounter][i-1] = scale["coeff"][0].to_f
                end
              end
              type[scaleCounter] = scale["link"]
              scaleCounter += 1
            end
            break if scaleCounter == 3
          end
        end
        # CDR at each level of spell
        spells["cooldown"].each_with_index do |cd, index|
          cooldown[index] = cd
          cooldown[5] = cooldown[4] unless spells["cooldown"].ensure_array[5]
        end
        # ADD ALL DATA OF SPELL TO DATABASE
        skillExists = Skill.find_by(name: spells["name"])
        if skillExists
          skillExists.update(name: spells["name"], desc: spells["sanitizedDescription"], img: img,
                             baseAD: baseAD, baseAP: baseAP, baseArmor: baseArmor, baseMR: baseMR, baseHP: baseHP,
                             adPerLv: adPerLv, apPerLv: apPerLv, arPerLv: arPerLv, mrPerLv: mrPerLv, hpPerLv: hpPerLv,
                             eDmg1: eDmg[0], eDmg2: eDmg[1], eDmg3: eDmg[2], eDmg4: eDmg[3], eDmg5: eDmg[4], eDmg6: eDmg[5],
                             dmg1: dmg[0], dmg2: dmg[1], dmg3: dmg[2], dmg4: dmg[3], dmg5: dmg[4], dmg6: dmg[5],
                             fDmg1: fDmg[0], fDmg2: fDmg[1], fDmg3: fDmg[2], fDmg4: fDmg[3], fDmg5: fDmg[4], fDmg6: fDmg[5],
                             scale11: scaling[0][0], scale12: scaling[0][1], scale13: scaling[0][2], scale14: scaling[0][3], scale15: scaling[0][4],
                             scale21: scaling[1][0], scale22: scaling[1][1], scale23: scaling[1][2], scale24: scaling[1][3], scale25: scaling[1][4],
                             scale31: scaling[2][0], scale32: scaling[2][1], scale33: scaling[2][2], scale34: scaling[2][3], scale35: scaling[2][4],
                             cdr1: cooldown[0], cdr2: cooldown[1], cdr3: cooldown[2], cdr4: cooldown[3], cdr5: cooldown[4], cdr6: cooldown[5],
                             type1: type[0], type2: type[1], type3: type[2], bonus: bonus)
        else
          Skill.create(name: spells["name"], desc: spells["sanitizedDescription"], img: img,
                       baseAD: baseAD, baseAP: baseAP, baseArmor: baseArmor, baseMR: baseMR, baseHP: baseHP,
                       adPerLv: adPerLv, apPerLv: apPerLv, arPerLv: arPerLv, mrPerLv: mrPerLv, hpPerLv: hpPerLv,
                       eDmg1: eDmg[0], eDmg2: eDmg[1], eDmg3: eDmg[2], eDmg4: eDmg[3], eDmg5: eDmg[4], eDmg6: eDmg[5],
                       dmg1: dmg[0], dmg2: dmg[1], dmg3: dmg[2], dmg4: dmg[3], dmg5: dmg[4], dmg6: dmg[5],
                       fDmg1: fDmg[0], fDmg2: fDmg[1], fDmg3: fDmg[2], fDmg4: fDmg[3], fDmg5: fDmg[4], fDmg6: fDmg[5],
                       scale11: scaling[0][0], scale12: scaling[0][1], scale13: scaling[0][2], scale14: scaling[0][3], scale15: scaling[0][4],
                       scale21: scaling[1][0], scale22: scaling[1][1], scale23: scaling[1][2], scale24: scaling[1][3], scale25: scaling[1][4],
                       scale31: scaling[2][0], scale32: scaling[2][1], scale33: scaling[2][2], scale34: scaling[2][3], scale35: scaling[2][4],
                       cdr1: cooldown[0], cdr2: cooldown[1], cdr3: cooldown[2], cdr4: cooldown[3], cdr5: cooldown[4], cdr6: cooldown[5],
                       type1: type[0], type2: type[1], type3: type[2], bonus: bonus)
        end
      end
    end
  end
	def getDmg(dmg, effect, spells, divideBy)
	    eIndex = effect[effect.index("e").to_i + 1].to_i
	    dmg[0] = spells["effect"].ensure_array[eIndex].ensure_array[0] ? spells["effect"].ensure_array[eIndex].ensure_array[0]/divideBy : 0
	    dmg[1] = spells["effect"].ensure_array[eIndex].ensure_array[1] ? spells["effect"].ensure_array[eIndex].ensure_array[1]/divideBy : 0
	    dmg[2] = spells["effect"].ensure_array[eIndex].ensure_array[2] ? spells["effect"].ensure_array[eIndex].ensure_array[2]/divideBy : 0
	    unless spells["effect"].ensure_array[eIndex].ensure_array[3]
	      dmg[3] = dmg[2]
	    else
	      dmg[3] = spells["effect"].ensure_array[eIndex].ensure_array[3]
	    end
	    unless spells["effect"].ensure_array[eIndex].ensure_array[4]
	      dmg[4] = dmg[3]
	    else
	      dmg[4] = spells["effect"].ensure_array[eIndex].ensure_array[4]
	    end
	    unless spells["effect"].ensure_array[eIndex].ensure_array[5]
	      dmg[5] = dmg[4]
	    else
	      dmg[5] = spells["effect"].ensure_array[eIndex].ensure_array[5]
	    end
	  end
	end
