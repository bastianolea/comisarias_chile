#remotes::install_github("ropensci/osmdata")
library(dplyr)
library(ggplot2)
library(osmdata)
library(chilemapas)
library(sf)
library(stringr)

#definir ciudad a obtener
ciudad = "Región Metropolitana"

# obtener ----
comisarias <- getbb(ciudad) %>%
    opq(timeout = 500) %>%
    add_osm_feature(key = "amenity", 
                    value = c("police")) %>%
    osmdata_sf()

# limpiar ----
comisarias_puntos <- comisarias$osm_points |> 
    tibble() |> 
    select(name, comuna = `addr:city`, calle = `addr:street`, amenity, geometry) |> 
    mutate(point = geometry,
           tipo = "point")

comisarias_poligonos <- comisarias$osm_polygons |> 
    tibble() |> 
    select(name, comuna = `addr:city`, calle = `addr:street`, amenity, geometry) |> 
    mutate(point = geometry |> st_simplify() |> st_centroid(of_largest_polygon = TRUE)) |> 
    mutate(tipo = "polygon")

comisarias_multipoligonos <- comisarias$osm_multipolygons |> 
    tibble() |> 
    select(name, comuna = `addr:city`, calle = `addr:street`, amenity, geometry) |> 
    mutate(point = geometry |> st_simplify() |> st_centroid(of_largest_polygon = TRUE)) |> 
    mutate(tipo = "multipolygon")


# revisar ----
comisarias_puntos
comisarias_poligonos
comisarias_multipoligonos


comisarias_puntos |> filter(tolower(comuna) == "santiago")
comisarias_poligonos |> filter(tolower(comuna) == "santiago")
comisarias_multipoligonos |> filter(tolower(comuna) == "santiago")

# unir ----
comisarias_0 <- bind_rows(comisarias_puntos, comisarias_poligonos, comisarias_multipoligonos) |> 
    filter(!is.na(name))
  
# complementar ----
comisarias <- comisarias_0 |> 
    rename(nombre = name) |> 
    select(-amenity) |> 
    mutate(clase = case_when(str_detect(tolower(nombre), "subcom") ~ "Subcomisaría",
                             str_detect(tolower(nombre), "prefect") ~ "Prefectura",
                             str_detect(tolower(nombre), "tenenc") ~ "Tenencia",
                             str_detect(tolower(nombre), "reten|retén") ~ "Retén",
                             str_detect(tolower(nombre), "comisar") ~ "Comisaría")) |> 
    filter(!is.na(clase))

comisarias |> filter(is.na(clase)) |> 
    select(nombre, comuna)


# guardar ----
saveRDS(comisarias, "datos_procesados/comisarias_osm.rds")

# guardar sin geometría como csv
comisarias |> 
    mutate(lon = st_coordinates(point)[1],
           lat = st_coordinates(point)[2]) |> 
    select(-geometry, -point, -tipo) |> 
    write.csv2("datos_procesados/comisarias_osm.csv")


# 
# # asignar crs
# st_crs(calles_principales$osm_lines) <- 4326
# # st_crs(rios$osm_lines) <- 4326
# st_crs(estructuras$osm_polygons) <- 4326


# obtener mapas de chile

# #cargar polígono regional
# mapa <- chilemapas::mapa_comunas %>%
#     left_join(
#         chilemapas::codigos_territoriales %>%
#             select(matches("comuna"))) %>%
#     filter(codigo_region=="13")
# # 
# # # graficar ----
# # ggplot() +
# #     geom_sf(data = mapa, aes(geometry = geometry)) +
# #     geom_sf(data = comisarias |> filter(str_detect(tolower(name), "reten|retén|tenencia|comisar")),  #|> filter(str_detect(tolower(comuna), "maipo")), 
# #             aes(geometry = point)) +
# #     geom_sf_text(data = comisarias,
# #                  aes(geometry = point, label = name),
# #                  check_overlap = T, size = 2)
# # 
