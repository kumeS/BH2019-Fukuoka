#rm(list=ls())
#library(keras)
pkg.name <- "DiagrammeR"
if(!require(pkg.name, character.only=TRUE)){
  install.packages(pkg.name)
}
library(pkg.name, character.only=TRUE)

pkg.name <- "assertthat"
if(!require(pkg.name, character.only=TRUE)){
  install.packages(pkg.name)
}
library(pkg.name, character.only=TRUE)

pkg.name <- "purrr"
if(!require(pkg.name, character.only=TRUE)){
  install.packages(pkg.name)
}
library(pkg.name, character.only=TRUE)

## モデルの表示
#model %>% deepviz::plot_model()
#model %>% plot_model_modi()

##############################################
plot_model_modi <- function(model, ...){
 UseMethod("plot_model", model)
}

globalVariables(c(".", "V1", "V2", "x"))

model_nodes <- function(x){
 assert_that(is.keras_model(x))
 if (is.keras_model_sequential(x)) {
  model_layers <- x$get_config()$layers
  l_name <- map_chr(model_layers, ~purrr::pluck(., "config", "name"))
 } else {
  model_layers <- x$get_config()$layers
  l_name <- model_layers %>% map_chr("name")
 }
 l_type <- model_layers %>% map_chr("class_name")
 
 l_activation <- model_layers %>%
  map_chr(
   ~(purrr::pluck(., "config", "activation") %||% "")
  )
 
 create_node_df(
  n = length(model_layers),
  name = l_name,
  type = l_type,
  label = glue::glue("{l_name}\n{l_type}\n{l_activation}"),
  shape = "rectangle",
  activation = l_activation
 )
}
model_edges_sequential <- function(ndf){
 assert_that(is.data.frame(ndf))
 z <- embed(ndf$id, dimension = 2)
 create_edge_df(
  from = z[, 2],
  to = z[, 1]
 )
}

inbound_nodes <- function(model){
 assert_that(is.keras_model_network(model))
 model_layers <- model$get_config()$layers
 inbound <- map(
  model_layers,
  function(x){
   if (length(x$inbound_nodes))
    x$inbound_nodes[[1]] %>%
    map_chr(c(1, 1))
   else NA
  }
 )
 names(inbound) <- map(model_layers, "name")
 z <- imap_dfr(
  inbound,
  ~ data.frame(to = .y, from = .x, stringsAsFactors = FALSE)
 )
 na.omit(z)[, c("from", "to")]
}

# The input x must be a nodes df
model_edges_network <- function(model, ndf){
 assert_that(is.keras_model_network(model))
 assert_that(is.data.frame(ndf))
 z <- inbound_nodes(model)
 z$from <- ndf$id[match(z$from, ndf$name)]
 z$to   <- ndf$id[match(z$to,   ndf$name)]
 z
}
is.keras_model <- function(x){
 inherits(x, "keras.engine.training.Model")
}

is.keras_model_sequential <- function(x){
 is.keras_model(x) && inherits(x, "keras.engine.sequential.Sequential")
}

is.keras_model_network <- function(x){
 is.keras_model(x) && !is.keras_model_sequential(x)
}

plot_model.keras.engine.training.Model <- function(model, width=4.5, height=1, ...){
 
 nodes_df <- model_nodes(model)
 if (is.keras_model_sequential(model)){edges_df <- model_edges_sequential(nodes_df)}else{edges_df <- model_edges_network(model, nodes_df)}
 
 graph <- DiagrammeR::create_graph(nodes_df, edges_df)
 graph <- DiagrammeR::set_edge_attrs(graph, "arrowhead", "vee")
 graph <- DiagrammeR::set_edge_attrs(graph, "arrowsize", 1)
 
 graph <- DiagrammeR::set_edge_attrs(graph, "color", "grey30") 
 graph <- DiagrammeR::set_node_attrs(graph, "fixedsize", FALSE)
 graph <- DiagrammeR::set_node_attrs(graph, "nodesep", 2)
 graph <- DiagrammeR::set_node_attrs(graph, "fontcolor", "black")
 graph <- DiagrammeR::set_node_attrs(graph, "fontsize", 15)

 graph <- DiagrammeR::set_node_attrs(graph, "color", "blue", nodes = (1:nrow(nodes_df))[nodes_df$type == "Conv2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "skyblue", nodes = (1:nrow(nodes_df))[nodes_df$type == "Conv2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "color", "red", nodes = (1:nrow(nodes_df))[nodes_df$type == "Activation"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "pink", nodes = (1:nrow(nodes_df))[nodes_df$type == "Activation"])
 graph <- DiagrammeR::set_node_attrs(graph, "color", "green", nodes = (1:nrow(nodes_df))[nodes_df$type == "SpatialDropout2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "aquamarine", nodes = (1:nrow(nodes_df))[nodes_df$type == "SpatialDropout2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "color", "black", nodes = (1:nrow(nodes_df))[nodes_df$type == "InputLayer"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "azure", nodes = (1:nrow(nodes_df))[nodes_df$type == "InputLayer"])
 graph <- DiagrammeR::set_node_attrs(graph, "color", "cora;", nodes = (1:nrow(nodes_df))[nodes_df$type == "MaxPooling2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "cornsilk", nodes = (1:nrow(nodes_df))[nodes_df$type == "MaxPooling2D"])
 graph <- DiagrammeR::set_node_attrs(graph, "color", "gold;", nodes = (1:nrow(nodes_df))[nodes_df$type == "BatchNormalizationV1"])
 graph <- DiagrammeR::set_node_attrs(graph, "fillcolor", "beige", nodes = (1:nrow(nodes_df))[nodes_df$type == "BatchNormalizationV1"])
 
 coords <- local({
  (igraph::layout_with_sugiyama(DiagrammeR::to_igraph(graph)))[[2]] %>%
   dplyr::as_tibble() %>%
   dplyr::rename(
    x = V1,
    y = V2) %>%
   dplyr::mutate(x = width * x) %>%
   dplyr::mutate(y = height * y)
 })
 
 graph$nodes_df <- graph$nodes_df %>%
  dplyr::bind_cols(coords)
 
 DiagrammeR::render_graph(graph, layout="dot")
 
}


####### ####### ####### ####### ####### ####### ####### #######
####### ####### ####### ####### ####### ####### ####### #######

