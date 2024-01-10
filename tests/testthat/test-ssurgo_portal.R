test_that("ssurgo_portal() works (template only, no SSURGO data)", {

  # initiate ssurgo portal
  # expect_equal(ssurgo_portal(), 0)

  # test helper functions
  .expect_status_isTRUE <- function(x) {
    expect_true(inherits(x, 'list') &&
                 !is.null(x$status) &&
                 isTRUE(x$status))
  }

  .expect_response <- function(x) {
    expect_true(inherits(x, 'list') &&
                 !is.null(x$response) &&
                 is.list(x$response))
  }

  .expect_nodes <- function(x) {
    expect_true(inherits(x, 'list') &&
                 !is.null(x$nodes) &&
                 is.list(x$nodes))
  }

  # in theory this should be able to set up an adequate environment
  if (!.has_ssurgo_portal_dependencies())
    try(create_ssurgo_venv())

  # trigger an initialization outside of test expectation (if needed)
  try(ssurgo_portal("getstatus"))

  # check if its alive
  .expect_status_isTRUE(ssurgo_portal("getstatus"))
  .expect_response(ssurgo_portal("getstatus", schema = TRUE))

  # sample subdirectory
  dir.create("foo", showWarnings = FALSE)

  # inspect folder tree
  .expect_nodes(ssurgo_portal(
    "getfoldertree",
    path = ".",
    folderpattern = ".*",
    filepattern = "txt",
    ignorefoldercase = TRUE,
    ignorefilecase = TRUE,
    showfiles = FALSE,
    maxdepth = 2
  ))

  # get template catalog
  .expect_status_isTRUE(ssurgo_portal("gettemplatecatalog"))

  # create empty geopackage
  .expect_status_isTRUE(ssurgo_portal(
    "copytemplate",
    templatename = "GeoPackage",
    folder = "foo",
    filename = "my_gpkg",
    overwrite = TRUE
  ))

  dbp <- file.path("foo", "my_gpkg.gpkg")

  .expect_status_isTRUE(ssurgo_portal("opentemplate", database = dbp))

  # one subfolder that does not pass pretest
  dbt <- ssurgo_portal(
    "pretestimportcandidates",
    database = dbp,
    root = ".",
    istabularonly = FALSE
  )
  .expect_status_isTRUE(dbt)
  expect_true(isFALSE(dbt$allpassed))
  expect_equal(length(dbt$subfolders), 1)

  # can't import a subfolder that does not exist
  expect_output(ssurgo_portal(
    "importcandidates",
    database = dbp,
    root = ".",
    istabularonly = FALSE,
    skippretest = TRUE,
    subfolders = list("WV999"),
    loadinspatialorder = FALSE,
    loadspatialdatawithinsubprocess = TRUE,
    dissolvemupolygon = TRUE
  ), "sacatlog.*does not exist")

  .expect_status_isTRUE(ssurgo_portal("getdatabaseinventory", database = dbp))

  # TODO: does this do anything ?? status is TRUE anyway
  .expect_status_isTRUE(ssurgo_portal(
    "deleteareasymbols",
    database = dbp,
    areasymbols = list("somethingdifferent")
  ))

  unlink("foo", recursive = TRUE)
})
