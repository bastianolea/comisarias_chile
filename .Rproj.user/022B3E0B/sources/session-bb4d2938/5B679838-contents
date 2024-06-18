library(dplyr)
library(stringr)
library(ggplot2)
library(sf)
library(chilemapas)

# mapa urbano ----
mapa_zonas_urbanas <- chilemapas::mapa_zonas |> 
  filter(codigo_region == 13) |> 
  left_join(chilemapas::codigos_territoriales |> 
              select(matches("comuna")))

islas_urbanas <- c("13124071004", "13124071005", "13124081001", "13124071001", "13124071002", "13124071003", #Pudahuel
                   "13401121001", #San Bernardo
                   "13119131001", #Maipú
                   "13203031000", "13203031001", "13203031002", "13203011001", "13203011002" #San José de Maipo
)

# crear nuevo mapa
mapa_urbano <- mapa_zonas_urbanas |> 
  # dejar solo dos provincias, incluir San Bernardo y sacar Pirque
  filter(codigo_provincia %in% c(131, 132) | nombre_comuna == "San Bernardo", nombre_comuna != "Pirque") |>
  # filtrar islas urbanas
  filter(!geocodigo %in% islas_urbanas) |>
  # unir comunas
  group_by(nombre_comuna, codigo_comuna) %>%
  summarise(geometry = st_union(geometry)) |>
  ungroup()
# simplificar bordes del mapa (opcional)
# mutate(geometry = rmapshaper::ms_simplify(geometry,  keep = 0.4))


# datos campamentos ----
# # datos 2024 (sin coordenadas)
# library(readr)
# FL_Actualizaci_C3_B3n_Campamentos_2024 <- read_csv("datos/2024/FL_Actualizaci%C3%B3n_Campamentos_2024.csv")
# View(FL_Actualizaci_C3_B3n_Campamentos_2024)

geo <- read_sf("datos/2024/FL_Actualizaci%C3%B3n_Campamentos_2024.geojson")

campamentos_rm <- geo |> 
  janitor::clean_names() |> 
  filter(cut_r == 13) |> 
  select(nombre, cut_r, cut, comuna, n_hog, hectareas, geometry) |> 
  # slice(1:10) |>
  mutate(punto = geometry |> st_simplify() |> st_centroid(of_largest_polygon = TRUE))


campamentos_rm

# intersectar para que solo sean los del gran santiago
st_crs(mapa_urbano$geometry) <- 4326

st_crs(campamentos_rm$geometry) <- 4326

campamentos_rm_2 <- campamentos_rm |> 
  st_intersection(mapa_urbano$geometry)



# nombres de comunas para el mapa, que se repelan de los puntos del mapa
etiquetas <- mapa_urbano |> 
  filter(codigo_comuna %in% campamentos_rm_2$cut) |> 
  bind_rows(
    campamentos_rm_2 |> 
      select(geometry) |> 
      mutate(nombre_comuna = "")) |> 
  mutate(nombre_comuna = recode(nombre_comuna, 
                                "Maipu" = "Maipú",
                                "Conchali" = "Conchalí",
                                "Estacion Central" = "Estación Central",
                                "San Jose de Maipo" = "San José de Maipo"))

# graficar ----
ggplot() +
  geom_sf(data = mapa_urbano,
          aes(geometry = geometry),
          color = "grey70", fill = "grey95",
          linewidth = .3) +
  ggrepel::geom_text_repel(data = etiquetas,
                           aes(label = nombre_comuna, geometry = geometry),
                           stat = "sf_coordinates", box.padding = .3, min.segment.length = 3,
                           size = 3, color = "grey20") +
  geom_sf(data = campamentos_rm_2,
          aes(geometry = punto, size = n_hog),
          alpha = .35) +
  scale_size_continuous(range = c(3, 15), breaks = c(10, 100, 1000, 1500)) +
  theme_void() +
  guides(size = guide_legend(position = "inside", 
                             title = "N° de hogares por campamento" |> str_wrap(15))) +
  theme(legend.position.inside = c(.93, .5)) +
  labs(title = "Campamentos en la Región Metropolitana",
       subtitle = "Catastro de campamentos, actualización 2024",
       caption = "Fuente: Centro de Estudios - Ministerio de Vivienda y Urbanismo
       \nVisualización: Bastián Olea Herrera") +
  theme(plot.title = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 12),
        legend.title = element_text(face = "bold", size = 10), 
        plot.caption = element_text(lineheight = 0.6, size = 9, color = "grey40")) +
  theme(plot.margin = unit(rep(0.4, 4), "cm"))

# guardar
ggsave(filename = "mapas/mapa_campamentos_rm_1.png", 
       width = 5, height = 6, scale = 1.4, bg = "white")

# https://www.minvu.gob.cl/catastro-campamentos-2022/