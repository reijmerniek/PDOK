#' @title Import Postcode/huisnummer tabels from cbs.nl
#' @description
#' This function can download the custom postcode/huisnummer datasets from the corresponding webpages of cbs.nl. It downloads the zip to your working directory, unzips it and imports it into R. It then transforms it in the a structured DF.
#'
#' @param jaar A year value between from 2017 until 2024
#' @param remove_files TRUE/FALSE. If FALSE it stores keeps the files stored in your working directory. Should be FALSE if you want to load multiple dataframes at once, as the function checks the files in your WD to find the files downloaded.
#' @param add_names TRUE/FALSE. If TRUE it adds the names for buurt/wijk/gem instead of just the numeric identifier.
#'
#' @return A dataframe.
#' @examples
#' df <-PDOK::cbs_pchn6( jaar=2024, remove_files =TRUE, add_names= TRUE)
#' @export
#' @import dplyr


cbs_pchn6<- function(jaar, remove_files =TRUE, add_names= TRUE){

  if (!jaar %in% c(2024,2023, 2022, 2021, 2020, 2019, 2018, 2017)) {
    stop("Alleen 2016 t/m 2024 beschikbaar.")
  }
  if(!remove_files %in% c(TRUE,FALSE)){
    print("remove_files not TRUE/FALSE, defaulted to TRUE")
  }
  if(!add_names %in% c(TRUE,FALSE)){
    print("add_names not TRUE/FALSE, defaulted to TRUE")
  }

  urls <- c(
    "https://download.cbs.nl/postcode/2024-cbs-pc6huisnr20240801_buurt.zip",
    "https://download.cbs.nl/maatwerk/2023-cbs-pc6huisnr20230801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2022/37/2022-cbs-pc6huisnr20210801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2021/36/2021-cbs-pc6huisnr20200801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2020/39/2020-cbs-pc6huisnr20200801-buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2019/42/2019-cbs-pc6huisnr20190801_buurt.zip",
    "https://www.cbs.nl/-/media/_excel/2018/36/2018-cbs-pc6huisnr20180801_buurt--vs2.zip",
    "https://www.cbs.nl/-/media/_excel/2017/38/2017-cbs-pc6huisnr20170801_buurt.zip"
  )

  jaren <- c(2024,2023, 2022, 2021, 2020, 2019, 2018, 2017)
  df <- data.frame(urls, jaren)

  url <- df$urls[df$jaren == jaar]

  download.file(url, destfile = "postcode_huisnummer.zip")
  unzip("postcode_huisnummer.zip", exdir = "./temp_r_files")

  csv_files <- list.files(pattern = "\\.csv$", full.names = TRUE, recursive = TRUE)
  file_info <- file.info(csv_files)
  largest_file <- rownames(file_info[which.max(file_info$size), ])
  data <- read.csv2(largest_file)
  names(data)[1] <-"pc"
  names(data)[2] <-"hn"

  if(add_names==FALSE ){
    data <- setNames(data, c("pc", "hn", "code_buurt","code_wijk","code_gem"))
  } else {


    buurt <-read.csv2(list.files(path = "./temp_r_files/", pattern = ".*(buurt|brt).*\\.csv$", full.names = TRUE, recursive = TRUE)[1])
    buurt <-buurt[,c(1:2)]
    data <- data %>%
      left_join(buurt, by = setNames(names(buurt)[1], names(data)[3]))

    wijk <-read.csv2(list.files(path = "./temp_r_files/", pattern = ".*(Wijk|wijk).*\\.csv$", full.names = TRUE, recursive = TRUE)[1])
    data <- data %>%
      left_join(wijk, by = setNames(names(wijk)[1], names(data)[4]))

    gem <-read.csv2(list.files(path = "./temp_r_files/", pattern = ".*(gem).*\\.csv$", full.names = TRUE, recursive = TRUE)[1])
    data <- data %>%
      left_join(gem, by = setNames(names(gem)[1], names(data)[5]))

    data <- setNames(data, c("pc", "hn", "code_buurt","code_wijk","code_gem","naam_buurt","naam_wijk","naam_gem"))

  }

  if(remove_files==TRUE){
    unlink("postcode_huisnummer.zip")
    unlink("./temp_r_files", recursive = TRUE)
    return(data)
  }else if(remove_files==FALSE){
    return(data)
  }

}
