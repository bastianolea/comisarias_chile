
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


# intersectar para que solo sean los del gran santiago
st_crs(mapa_urbano$geometry) <- 4326

comisarias_2 <- comisarias |> st_sf()

st_crs(comisarias_2$point) <- 4326
st_crs(comisarias_2$geometry) <- 4326

comisarias_3 <- st_intersection(comisarias_2, mapa_urbano$geometry)


# graficar ----
ggplot() +
    geom_sf(data = mapa_urbano,
            aes(geometry = geometry),
            color = "grey70", fill = "grey90",
            linewidth = .3) +
    ggrepel::geom_text_repel(data = comisarias_3,
                             aes(label = nombre |> str_wrap(20),
                                 geometry = geometry),
                             stat = "sf_coordinates", point.padding = 3,
                             min.segment.length = 0.2, segment.size = 0.3, segment.alpha = 0.4,
                             size = 2, lineheight = .9) +
    geom_sf(data = comisarias_3,
            aes(geometry = point, shape = clase),
            color = "darkgreen", fill = "darkgreen",
            size = 3, alpha = .7) +
    scale_shape_manual(values = c(15:17, 23, 19)) +
    theme_void() +
    labs(title = "Comisarías en la Región Metropolitana",
         caption = "Fuente: OpenStreetMap
       \nVisualización: Bastián Olea Herrera") +
    guides(shape = guide_legend(position = "inside")) +
    theme(legend.position.inside = c(.93, .5),
          legend.title = element_blank(),
          legend.text = element_text(margin = margin(l = 0))) +
    theme(plot.title = element_text(face = "bold", size = 14),
          plot.subtitle = element_text(size = 12),
          plot.caption = element_text(lineheight = 0.6, size = 9, color = "grey40", margin = margin(t = -30))) +
    theme(plot.margin = unit(rep(0.2, 4), "cm"))


# guardar ----
ggsave(filename = "mapa_comisarias_carabineros_rm.jpg", 
       width = 5, height = 5, scale = 2, bg = "white")

