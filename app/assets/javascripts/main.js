var riotImgPath = "http://ddragon.leagueoflegends.com/cdn/5.21.1/img/spell/";
$(document).foundation();
window.onload = function(){
  var results = [];

  var adInput, apInput, cdrInput, hpInput, armorInput,
    mrInput, levelSelecte, levelSelectValue,
    skillLevelSelecte, skillLevelSelectValue;

  $("#inputForm").bind("keyup", getInputs);
  $("#skillLevel").change(function(){
    getInputs();
  });
  $("#champLevel").change(function(){
    getInputs();
  });
  $("#skillButton").click(function(){
    performCalculations();
  });

  function getInputs(){
    adInput = document.getElementById("adInput").value;
    apInput = document.getElementById("apInput").value;
    cdrInput = document.getElementById("cdrInput").value;
    hpInput = document.getElementById("hpInput").value;
    armorInput = document.getElementById("armorInput").value;
    mrInput = document.getElementById("mrInput").value;

    hpInput = checkValidInput(hpInput);
    armorInput = checkValidInput(armorInput);
    mrInput = checkValidInput(mrInput);

    levelSelecte = document.getElementById("champLevel");
    levelSelectValue = levelSelecte.options[levelSelecte.selectedIndex].value;
    skillLevelSelecte = document.getElementById("skillLevel");
    skillLevelSelectValue = skillLevelSelecte.options[skillLevelSelecte.selectedIndex].value;

    checkReq();
  }

  function checkValidInput(input){
    if(input == null || input == "" || input.length == 0){
      input = 0;
    }
    return input;
  }

  function checkReq(){
    if(adInput != null && !isNaN(adInput) && adInput != "" && adInput.length > 0){
      if(apInput != null && !isNaN(apInput) && apInput != ""  && apInput.length > 0){
        if(cdrInput != null && !isNaN(cdrInput) && cdrInput != ""  && cdrInput.length > 0
            && cdrInput >=0 && cdrInput <= 0.4){
          $("#skillButton").removeAttr("disabled");
        } else {
          $("#skillButton").attr("disabled", "disabled");
        }
      } else {
        $("#skillButton").attr("disabled", "disabled");
      }
    } else {
      $("#skillButton").attr("disabled", "disabled");
    }
  }

  function displayBestSkill(){
    var resultWrapper = document.getElementById("bestWrapper");
    resultWrapper.innerHTML = "";

    var bestTitle = document.createElement("div");
    var bestImg = document.createElement("img");
    var title = document.createElement("h3");
    var dps = document.createElement("h3");
    bestImg.src = riotImgPath + results[0].img;
    title.innerHTML = results[0].name
    title.style.display = "inline-block";
    title.style.marginLeft = "30px";
    title.style.marginRight = "50px";
    dps.innerHTML = "DPS: " + results[0].calculation;
    dps.style.display = "inline-block";
    bestTitle.appendChild(bestImg);
    bestTitle.appendChild(title);
    bestTitle.appendChild(dps);

    var desc = document.createElement("div");
    desc.innerHTML = results[0].desc;

    var stats = document.createElement("div");
    for(var key in results[0]){
      var calculationRegExp = new RegExp("calculation");
      var nameRegExp = new RegExp("name");
      var descRegExp = new RegExp("desc");
      var imgRegExp = new RegExp("img");
      if(!calculationRegExp.test(key) && !descRegExp.test(key)
          && !imgRegExp.test(key) && !nameRegExp.test(key)){
        var stat = document.createElement("div");
        stat.innerHTML = key + ": " + eval("parseFloat(results[0]." + key + ").toFixed(3)");
        stats.appendChild(stat);
      }
    }
    resultWrapper.appendChild(bestTitle);
    resultWrapper.appendChild(desc);
    resultWrapper.appendChild(stats);
  }

  function performCalculations(){
    results = [];
    for(var spell in data){
      var name = data[spell].name;
      var desc = data[spell].desc;
      var level = levelSelectValue;
      var baseAD = data[spell].baseAD + (level-1) * data[spell].adPerLv;
      var baseAP = data[spell].baseAP + (level-1) * data[spell].apPerLv;
      var baseArmor = data[spell].baseArmor + (level-1) * data[spell].arPerLv;
      var baseMR = data[spell].baseMR + (level-1) * data[spell].mrPerLv;
      var baseHP = data[spell].baseHP + (level-1) * data[spell].hpPerLv;
      var cdr = cdrInput;
      var skillLevel = skillLevelSelectValue;
      var champSpell = {name: name, desc: desc, baseAD: baseAD, baseAP: baseAP,
                    AD: adInput, AP: apInput, baseArmor: baseArmor,
                    baseMR: baseMR, baseHP: baseHP, HP: hpInput, armor: armorInput,
                    MR: mrInput, cdr: cdrInput, skillLevel: skillLevel,
                    champLevel: level, img: data[spell].img};

      eval('var cooldown = parseFloat(data[spell].cdr' + skillLevel + ')');
      cooldown = (1 - cdr) * cooldown;

      //BASE DAMAGES
      eval('var dmgCalc = parseFloat(data[spell].dmg' + skillLevel + ')');
      eval('var eDmgCalc = parseFloat(data[spell].eDmg' + skillLevel + ')');
      eval('var fDmgCalc = parseFloat(data[spell].fDmg' + skillLevel + ')');

      //% BONUSES
      eval('dmgCalc = addBonuses(data[spell].scale1' + skillLevel + ', data[spell].type1, dmgCalc, champSpell)');
      eval('eDmgCalc = addBonuses(data[spell].scale2' + skillLevel + ', data[spell].type2, eDmgCalc, champSpell)');
      eval('fDmgCalc = addBonuses(data[spell].scale3' + skillLevel + ', data[spell].type3, fDmgCalc, champSpell)');

      var calculation = cooldown != 0 ? ((dmgCalc + eDmgCalc + fDmgCalc)/cooldown).toFixed(3) : 0;
      champSpell.calculation = calculation;

      results.push(champSpell);
    }
    sortResults();
    populateResultsTable();
    displayBestSkill();
  }

  function populateResultsTable(){
    var table = document.getElementById("resultsTable");
    for(var spell in results){
      var row = table.insertRow(parseInt(spell) + 1);
      var nameCell = row.insertCell(0);
      var descCell = row.insertCell(1);
      var dpsCell = row.insertCell(2);

      nameCell.innerHTML = results[spell].name;
      descCell.innerHTML = results[spell].desc;
      dpsCell.innerHTML = results[spell].calculation;
    }
  }

  function addBonuses(scale, type, dmg, champSpell){
    if(type == "spelldamage"){
      dmg += scale * champSpell.AP;
    } else if(type == "attackdamage") {
      dmg += scale * champSpell.AD;
    } else if(type == "bonusattackdamage"){
      dmg += scale * (champSpell.AD - champSpell.baseAD);
    } else if(type == "bonushealth"){
      dmg += scale * (champSpell.HP - champSpell.baseHP);
    } else if(type == "@special.jaycew"){
      dmg = (dmg/100) * champSpell.AD;
    } else if(type == "bonusarmor"){
      dmg += scale * (champSpell.armor - champSpell.baseArmor);
    } else if(type == "bonusspellblock"){
      dmg += scale * (champSpell.MR - champSpell.baseMR);
    } else if(type == "@special.jaxrarmor"){
      dmg += scale * (champSpell.AD - champSpell.baseAD);
    } else if(type == "@special.jaxrmr"){
      dmg += scale * champSpell.AP;
    } else if(type == "armor"){
      dmg += scale * champSpell.armor;
    } else if(type == "health"){
      dmg += scale * champSpell.HP;
    }
    return dmg;
  }

  function sortResults(){
    results.sort(function(a, b){
        if(parseFloat(a.calculation) < parseFloat(b.calculation)) return 1;
        if(parseFloat(a.calculation) > parseFloat(b.calculation)) return -1;
        return 0;
    });
  }

}
