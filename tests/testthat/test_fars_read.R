testthat::test_that("FARS dataset file",
                    {
                      testthat::expect_type(farsReport:::fars_make_filename(), "character")
                      testthat::expect_true(tibble:::is.tibble(farsReport:::fars_read(farsReport:::fars_make_filename())))
                      testthat::expect_equal(ncol(farsReport:::fars_read(farsReport:::fars_make_filename())), 50)
                    }
)
