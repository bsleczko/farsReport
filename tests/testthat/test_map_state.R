testthat::test_that("FARS map plotting function",
                    {
                      testthat::expect_null(farsReport:::fars_map_state(state.num = 1, year = 2013))
                    }
)
