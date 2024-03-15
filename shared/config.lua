Config = {}
Config.Locale = 'en' -- Only EN, edit the messages in the locales folder.
Config.Framework = 'ESX' -- ESX or QBCore
Config.ESXOldVersion = false
Config.Debug = true
Config.Time = 20 -- How many seconds it will be the medbag before dissapear
Config.HealthPerSecond = 10 -- How much health per second he's going to get
Config.RevivePlayer = true -- If you want to revive player inside the zone, currently setted up with esx_ambulancejob in esx and qb-ambulancejob in qbcore
Config.WhitelistToJobs = true -- This has to be on true if you want to make it whitelist only for jobs.
Config.Jobs = {
  'ambulance',
  --'police'
  -- Put the job that you want
}
Config.Objects = {
    ["medbag"] = {model = `prop_cs_shopping_bag`, freeze = true}, -- Don't touch this unless you want to change the 
  --["ITEM"] = {model = `PROPMODEL`, freeze = TRUE/FALSE}, (Better if freezes, if not will move the zone with the prop itself.)
}