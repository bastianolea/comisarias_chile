# Fuente de la información: Carabineros de Chile, «Cuarteles de Carabineros». 
# Obtenida a través de la Plataforma de Datos Abiertos de Itrend.

# https://www.plataformadedatos.cl/datasets/es/60d196b8fe2d206e

library(sf)
library(dplyr)

cuarteles <- sf::read_sf("datos/cuarteles_carabineros_itrend.geojson")

# contar comisarías por comuna ----
cuarteles_conteo_comuna <- cuarteles |> 
    select(cut_comuna = cut_com, cut_region = cut_reg, nombre, tipo, geometry, lon, lat) |> 
    group_by(cut_comuna, cut_region, tipo) |> 
    count() |> 
    mutate(tipo = stringr::str_to_sentence(tipo)) |> 
    mutate(cut_region = as.numeric(cut_region))

# unique(cuarteles_conteo_comuna$tipo)

## guardar ----
cuarteles_conteo_comuna |> 
    st_drop_geometry() |> 
    write.csv2("datos_procesados/cuarteles_carabineros_itrend.csv")
