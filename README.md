# Controllo-consumi-asciugatrice
Script LUA per Domoticz per il controllo dell'asciugatrice

Ho creato uno script LUA per il controllo dell'avvio e della fine di un ciclo di asciugatura di una asciugatrice.

Occorrente:

Hardware: Sonoff POW con firmware Tasmota

Domoticz:
Creazione delle seguenti variabili integrer:
  washingmachine_status;
  washingmachine_counter;
  washingmachine_counter2;
Creazione dei seguenti Devices:
  Presa asciugatrice:	Light/Switch-->Switch --il device che corrisponde allo stato del Sonoff POW
  Asciugatrice watt:	Usage-->Electric --il device che corrisponde al consumo istantaneo del Sonoff POW
  Stato asciugatrice:	Light/Switch-->Switch --device virtuale che mostra lo stato dell'asciugatrice (On/Off)
  
  Nello script lua devono essere impostati questi 3 parametri:
  
local idle_minutes            = 5                      --I minuti di consumo Watt sotto la soglia per avere conferma che l'asciugatrice abbia finito il ciclo
local consumption_upper       = 300                    --Il consumo in Watt oltre il quale abbiamo conferma che l'asciugatrice abbia iniziato il ciclo
local consumption_lower       = 6                      --Il consumo in Watt al di sotto del quale abbiamo conferma che l'asciugatrice abbia finito il ciclo
