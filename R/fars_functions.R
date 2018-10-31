#' Read FARS data
#'
#' This is a simple function, which reads FARS data from CSV file, specified in the function argument
#' The function checks for presence of specified file, if present, reads the file and converts to a tibble
#'
#' @importFrom readr read_csv
#' @importFrom dplyr tbl_df
#'
#' @param filename A relative file to csv file, with dec="." and sep="," (due to use of read_csv)
#'
#' @return This function returns a tibble, from a specified file
#'
#' @details The function cannot unpredictably malfunction, all error cases are covered with the if statement
#'
#' @examples
#' fars_read("inst/extdata/accident_2013.csv.bz2")
#'
#' @export
fars_read <- function(filename = farsReport:::fars_make_filename()) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Create filename following the Coursera FARS datasets naming convention
#'
#' This is a simple function returning the name of the file, according to the year given in the function argument
#'
#' @param year A character string (or numeric/integer value) specifying year of interest for FARS data.
#' The function uses as.integer(year), therefore, given agrument should be coercible to integer
#' Parsing from numeric should be taken with care, 2015.7 will result in 2015.
#'
#' @return This function returns string with filename matching the filename from Coursera dataset (does not include path)
#'
#' @details The function can malfunction in case the specified year is not coercible to integer or database for resulting integer
#' is missing
#'
#' @examples
#' fars_make_filename("2013")
#' fars_make_filename(2014)
#' fars_make_filename(2015)
#'
#' @export
fars_make_filename <- function(year = "2013"){
  year <- as.integer(year)
  if (year %in% as.integer(c("2013", "2014","2015"))){
    #return(sprintf("/inst/extdata/accident_%d.csv.bz2", year))
    return(system.file("extdata", sprintf("accident_%d.csv.bz2", year), package="farsReport"))
  }
  else{
    stop("Dataset for year ", year, " is unavailable")
  }
}

#' Load FARS accidents for given years
#'
#' For given list of years, load the FARS accidents dataset and return as a tibble (per year)
#'
#' @importFrom dplyr mutate select
#' @importFrom magrittr "%>%"
#'
#' @param years A list of years, format of each year must be corcible to a valid year by as.integer() function
#'
#' @return This function returns a list of tibbles, in each tibble month and year of each accident will be listed
#'
#' @details The function can malfunction in case the dataset for specified year is missing, or is given in wrong format
#'
#' @examples
#' fars_read_years("2013")
#' fars_read_years(c(2013, 2014))
#' fars_read_years(c("2013", "2014", "2015"))
#'
#' @export
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- fars_make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Summarize FARS accidents for given years
#'
#' For given list of years, summarize the FARS accidents per month and year
#'
#' @importFrom dplyr bind_rows group_by summarize
#' @importFrom tidyr spread
#' @importFrom magrittr "%>%"
#'
#' @param years A list of years, format of each year must be corcible to a valid year by as.integer() function
#'
#' @return This function returns a tibble with number of FARS accidents per month of each year
#' This function does not produce duplicate records, e.g. c("2015", "2015") will produce only one summary
#'
#' @details The function can malfunction in case the dataset for specified year is missing, or is given in wrong format
#'
#' @examples
#' fars_summarize_years("2013")
#' fars_summarize_years(c(2013, 2014))
#' fars_summarize_years(c("2013", "2014", "2015"))
#'
#' @export
fars_summarize_years <- function(years = c("2013", "2014", "2015")) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}


#' Plot FARS accidents on the map of the state (of given ID number)
#'
#' This function for given state and year plots the map of the FARS accident on the border of the state
#' This function does not return any data, side effect of the function is the plot of FARS accident on the border map of the state
#'
#' @importFrom maps map
#' @importFrom graphics points
#' @importFrom dplyr filter
#'
#' @param state.num State identification number, allowed values in range from 1 to 56 without {3,7,14,43,52}
#'
#' @param year Year for which the plot should be prepared, provided datasets allow year to be {2013,2014,2015}
#'
#' @return This function does not return any data, side effect of the function is the plot of FARS accident
#'
#' @details The function can malfunction in case the dataset for specified year is missing, or is given in wrong format
#' Additionally, the function can malfunction if the state identifier is not matching the format from dataset for specified year
#'
#' @examples
#' fars_map_state(1, 2013)
#' fars_map_state(12, 2014)
#' fars_map_state(23, 2013)
#'
#' @export
fars_map_state <- function(state.num = 13, year = 2013) {
        filename <- fars_make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
