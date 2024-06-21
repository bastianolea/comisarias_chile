library(ggplot2)

source("obtener_mapa_urbano_rm.R")

cuarteles <- sf::read_sf("datos_originales/cuarteles_carabineros_itrend.geojson")

# intersectar para que solo sean los del gran santiago
# st_crs(comisarias_2$point) <- 4326
st_crs(cuarteles$geometry) <- 4326

cuarteles_2 <- st_intersection(cuarteles, mapa_urbano$geometry) |> 
    mutate(point = geometry |> st_simplify() |> st_centroid(of_largest_polygon = TRUE)) |> 
    mutate(tipo = stringr::str_to_sentence(tipo)) |> 
    filter(tipo != "Zona")


# graficar ----
ggplot() +
    geom_sf(data = mapa_urbano,
            aes(geometry = geometry),
            color = "grey70", fill = "grey90",
            linewidth = .3) +
    ggrepel::geom_text_repel(data = cuarteles_2,
                             aes(label = nombre |> stringr::str_wrap(20),
                                 geometry = geometry),
                             stat = "sf_coordinates", point.padding = 3,
                             min.segment.length = 0.2, segment.size = 0.3, segment.alpha = 0.4,
                             size = 2, lineheight = .9) +
    geom_sf(data = cuarteles_2,
            aes(geometry = point, shape = tipo),
            color = "darkgreen", fill = "darkgreen",
            size = 3, alpha = .7) +
    scale_shape_manual(values = c(15:17, 23, 19, 20)) +
    theme_void() +
    labs(title = "Comisarías en la Región Metropolitana",
         caption = "Fuente: Plataforma de Datos Abiertos de Itrend (Instituto para la Resiliencia ante Desastres)
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
ggsave(filename = "mapa_comisarias_carabineros_rm_itrend.jpg", 
       width = 5, height = 5, scale = 2, bg = "white")

