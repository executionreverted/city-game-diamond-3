task('deployApp', require("./deploy"))


task('giveResources', require("./giveResources"))
    .addParam('cityId', 'city Id')
    .addParam('amount', 'amount of resources')

task('upgradeBuilding', require("./upgradeBuilding"))
    .addParam('cityId', 'city Id')
    .addParam('buildingId', 'building Id')
    .addParam('autoClaim', 'auto claim before ugprade')
    .addParam('givePremium', 'give premium')