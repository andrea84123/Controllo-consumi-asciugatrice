--
-- Domoticz passes information to scripts through a number of global tables
--
-- otherdevices, otherdevices_lastupdate and otherdevices_svalues are arrays for all devices: 
--   otherdevices['yourotherdevicename'] = "On"
--   otherdevices_lastupdate['yourotherdevicename'] = "2015-12-27 14:26:40"
--   otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- uservariables and uservariables_lastupdate are arrays for all user variables: 
--   uservari
--script_time_washingmachine.lua
--This script monitors the current consumption indicated by a Z-Wave plug, placed between the washingmachine and the mains outlet
--It will count the amount of time that the power usage is below the triggervalue to be configured below. This indicates us that the washer has finished.
--When the script thinks the washingmachine is done, it will send you a pushnotification (line #38)

--Change the values below to reflect to your own setup
local switch_washingmachine   = 'Stato asciugatrice'         --Name of virtual switch that will show the state of the washingmachine (on/off)
local washer_status_uservar   = 'washingmachine_status'
local energy_consumption      = 'Asciugatrice watt2'         --Name of Z-Wave plug that contains actual consumption of washingmachine (in Watts)
local washer_counter_uservar  = 'washingmachine_counter'   --Name of the uservariable that will contain the counter that is needed
local idle_minutes            = 5                      --The amount of minutes the consumption has to stay below the 'consumption_lower' value
local consumption_upper       = 300                     --If usage is higher than this value (Watts), the washingmachine has started
local consumption_lower       = 6                       --If usage is lower than this value (Watts), the washingmachine is idle for a moment/done washing
local washer_counter_uservar2 = 'washingmachine_counter2'                       --numero dei minuti con consumo elevato
sWatt, Totalkwh               = otherdevices_svalues[energy_consumption]:match("([^;]+);([^;]+)")
washer_usage                  = tonumber(sWatt)

commandArray = {}
--print(washer_usage)
--print(sWatt)
--Virtual switch is off, but consumption is higher than configured level, so washing has started
if (washer_usage > consumption_upper) and uservariables[washer_status_uservar] == 0 then --Washing machine is not using a lot of energy, subtract the counter
  commandArray['Variable:' .. washer_counter_uservar2]=tostring(math.max(tonumber(uservariables[washer_counter_uservar2]) - 1, 0))
  print('Utilizzo corrente (' ..washer_usage.. 'W) e piu alto di (' ..consumption_upper.. 'W), l asciugatrice potrebbe essere partita')
  print('Sottraggo 1 dal contatore, nuovo valore: ' ..uservariables[washer_counter_uservar2].. ' minuti') 
end



if ((uservariables[washer_status_uservar] == 0) and uservariables[washer_counter_uservar2] == 0) then
  commandArray['SendNotification']='Asciugatrice#Asciugatrice partita!#0'
  commandArray[switch_washingmachine]='On'
  commandArray['Variable:' .. washer_status_uservar]='1'
  print('Utilizzo di corrente (' ..washer_usage.. 'W) sopra il valore massimo (' ..consumption_upper.. 'W), l asciugatrice e partita!')
  commandArray['Variable:' .. washer_counter_uservar]=tostring(idle_minutes)
end      

if (washer_usage < consumption_lower) and uservariables[washer_status_uservar] == 1 then --Washing machine is not using a lot of energy, subtract the counter
  commandArray['Variable:' .. washer_counter_uservar]=tostring(math.max(tonumber(uservariables[washer_counter_uservar]) - 1, 0))
  print('Current power usage (' ..washer_usage.. 'W) is below lower boundary (' ..consumption_lower.. 'W), washer is idle or almost ready')
  print('Subtracting counter with 1, new value: ' ..uservariables[washer_counter_uservar].. ' minutes') 
end

--Washingmachine is done
if ((uservariables[washer_status_uservar] == 1) and uservariables[washer_counter_uservar] == 0) then
  print('Ciclo asciugatrice finito')
  print('Utilizzo corrente asciugatrice ' ..washer_usage.. 'W')
  commandArray['SendNotification']='Asciugatrice#Asciugatrice finita, svuotala!#0' --Use Domoticz to send a notification, replace line for your own command if needed.
  commandArray[switch_washingmachine]='Off'
  commandArray['Variable:' .. washer_status_uservar]='0'
  commandArray['Variable:' .. washer_counter_uservar2]=tostring(idle_minutes)
end   

return commandArray
