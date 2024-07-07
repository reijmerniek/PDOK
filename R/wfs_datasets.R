#' WFS Datasets
#'
#' @param use_stored_df A logical value. If TRUE, return the stored dataframe.
#'                      If FALSE, run a query.
#' @return A dataframe.
#' @examples
#' PDOK::wfs_datasets(TRUE)
#' PDOK::wfs_datasets(FALSE)
#' @export


wfs_datasets <- function(use_stored_df = FALSE){

  extract_year <- function(link) {
    year <- str_extract(link, "\\b\\d{4}\\b")
    if (is.na(year)) {
      return("")
    } else {
      return(year)
    }
  }

  if (use_stored_df==TRUE) {
    data("pdok_datasets", package = "PDOK")
    return(pdok_datasets)
    rm(pdok_datasets, envir = .GlobalEnv)
  } else {



    datasets_links <- map2_df(
      read_html("https://www.pdok.nl/datasets") %>% html_nodes(".card-label"),
      read_html("https://www.pdok.nl/datasets") %>% html_nodes(".card-title") %>% html_attr("href"),
      ~data.frame(Aanbieder= html_text(.x, trim = TRUE), Link = .y, stringsAsFactors = FALSE)
    ) %>% arrange(Aanbieder)



    i=1
    a=1
    dataframe <-NULL

    pb <- txtProgressBar(min = 0, max = length(datasets_links$Link), style =3)

    for(i in 1:length(datasets_links$Link)){

      Sys.sleep(0.1)
      setTxtProgressBar(pb, i)

      links_df <- map2_df(
        read_html(datasets_links$Link[i]) %>% html_nodes("a") %>% html_text(),
        read_html(datasets_links$Link[i]) %>% html_nodes("a") %>% html_attr("href"),
        ~data.frame(titles = .x, links = .y, stringsAsFactors = FALSE)
      )


      links_df <- links_df %>% mutate( grepl =grepl("\\(WFS\\)",links_df$titles) ) %>% filter(grepl =="TRUE")


      if (length(links_df$links)==0) {
        next
      }


      wfs_df <- map2_df(
        read_html(paste0("https://www.pdok.nl/",links_df$links[1])) %>% html_nodes("a") %>% html_attr("href"),
        read_html(paste0("https://www.pdok.nl/",links_df$links[1])) %>% html_nodes("a") %>% html_text(),
        ~data.frame(links = .x, titles = .y, stringsAsFactors = FALSE)
      )

      wfs_df <- wfs_df%>% mutate( grepl =grepl("/wfs/",wfs_df$titles) ) %>% filter(grepl =="TRUE")

      wfs_df$titles <-NULL
      wfs_df$grepl <- NULL
      row.names(wfs_df) <-NULL
      wfs_df$year <- sapply(wfs_df$links, extract_year)



      temp_dataframe <- NULL

      for(a in 1:length(wfs_df$links)){

        pdok = as_list(read_xml(wfs_df$links[a]))
        xml_df = tibble::as_tibble(pdok) %>%
          unnest_longer(WFS_Capabilities)

        suppressWarnings(
          suppressMessages(
            general_info <- xml_df %>%
              dplyr::filter(WFS_Capabilities_id %in%  c("Title","Abstract","ProviderName" )) %>%
              unnest_wider(WFS_Capabilities, names_sep = "", names_repair =  "unique")
          ))
        general_info$WFS_Capabilities_id <-NULL
        general_info$NAME <- c("Title","Abstract","ProviderName")
        general_info <- general_info %>% pivot_wider(names_from = NAME, values_from = WFS_Capabilities1)

        suppressWarnings(
          suppressMessages(
            xml_wider <- xml_df %>%
              dplyr::filter(WFS_Capabilities_id == "FeatureType") %>%
              unnest_wider(WFS_Capabilities, names_repair =  "unique") %>%
              select(,c(1:3))%>%
              unnest(cols = names(.))

          ))

        names(xml_wider)[1] <-"Type"
        names(xml_wider)[2] <- "Type_titel"
        names(xml_wider)[3] <-"Type_abstract"

        row_data <- datasets_links[i, c(1:2)]
        links_join <- data.frame(row_data[rep(1, each = length(xml_wider$Type)), ])

        names(links_join)[1] <- "link_site"


        general_info <-general_info[rep(1, each = length(xml_wider$Type)), ]
        wfs_join <- data.frame(wfs_df[a,][rep(1, each = length(xml_wider$Type)), ])

        file <- cbind(links_join,general_info,xml_wider,wfs_join)
        temp_dataframe <- rbind(temp_dataframe,file)



      }

      dataframe <-rbind(dataframe,temp_dataframe)


    }



    row.names(dataframe) <-NULL
    dataframe$query_nr <- seq(1:length(dataframe$link_site))
    dataframe <- dataframe %>% separate(col=links, into = c("1","2"), sep="_", remove = FALSE)
    dataframe$query <- paste0(dataframe$`1`,"_0?request=GetFeature&service=WFS&version=2.0.0&typeName=",dataframe$Type,"&outputFormat=json")
    dataframe <- dataframe %>% select(-c(`1`,`2`, links))
    return(dataframe)

  }
}


