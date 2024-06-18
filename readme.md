## Comisarías de Chile

Base de datos con comisarías y otras instalaciones de Carabineros.

Por ahora solo abarca la Región Metropolitana.

Datos obtenidos desde OpenStreetMap.

La base de datos contiene 221 comisarías con nombre, comuna, clase (si es tenencia, comisaría, subcomisaría, retén, o prefectura), y columnas con la ubicación geográfica de las comisarías.

![Mapa de comisarías de la Región Metropolitana](mapa_comisarias_carabineros.jpg)

Respecto a la información geográfica de las comisarías, el archivo `comisarias.rds` contiene la columna `geometry`, que puede ser punto, polígono o multipolígono, mientras que el archivo `comisarias.csv` solo contiene la latitud y longitud.