test_that("load_label_config validates and caches a YAML configuration", {
	censobr:::clear_label_config_cache()
	root <- testthat::test_path("fixtures", "labels")

	config <- censobr:::load_label_config("population", 2010, "pt", root = root)
	cached <- censobr:::load_label_config("population", 2010, "pt", root = root)

	testthat::expect_identical(config, cached)
	testthat::expect_identical(config$mappings[[1]]$levels[[1]]$code, "1")
	testthat::expect_identical(config$mappings[[2]]$unmatched, "Não")
})

test_that("label configuration rejects invalid mappings", {
	config <- list(
		schema_version = 1L,
		dataset = "population",
		year = 2010,
		language = "pt",
		mappings = list(list(
			variables = c("V0601", "V0601"),
			unmatched = NULL,
			levels = list(list(code = "1", label = "Masculino"))
		))
	)

	testthat::expect_error(
		censobr:::validate_label_config(config),
		"variables"
	)
})

test_that("apply_label_config generates character labels in one mutation", {
	root <- testthat::test_path("fixtures", "labels")
	config <- censobr:::load_label_config("population", 2010, "pt", root = root)
	input <- data.frame(
		V0601 = c("1", "2", "9", NA_character_, "7"),
		V0617 = c("1", "0", "2", NA_character_, ""),
		untouched = 1:5
	)

	output <- censobr:::apply_label_config(input, config)

	testthat::expect_identical(
		output$V0601,
		c("Masculino", "Feminino", "Ignorado", NA_character_, NA_character_)
	)
	testthat::expect_identical(
		output$V0617,
		c("Sim", "Não", "Não", NA_character_, "Não")
	)
	testthat::expect_identical(output$untouched, input$untouched)
	testthat::expect_identical(vapply(output, typeof, character(1)),
										 c(V0601 = "character", V0617 = "character", untouched = "integer"))
})

test_that("aliases and descriptions do not rename configured variables", {
	config <- list(
		schema_version = 1L,
		dataset = "population",
		year = 2010,
		language = "pt",
		mappings = list(
			list(
				variables = list(list(
					name = "V0601",
					alias = "sex",
					description = "Sexo da pessoa"
				)),
				unmatched = NULL,
				levels = list(
					list(code = "1", label = "Masculino"),
					list(code = "2", label = "Feminino")
				)
			)
		)
	)
	input <- data.frame(V0601 = c("1", "9", NA_character_))

	output <- censobr:::apply_label_config(input, config)
	metadata <- censobr:::label_config_variable_metadata(config)

	testthat::expect_identical(names(output), "V0601")
	testthat::expect_identical(output$V0601, c("Masculino", NA_character_, NA_character_))
	testthat::expect_identical(metadata$alias, "sex")
	testthat::expect_identical(metadata$description, "Sexo da pessoa")
})

test_that("label_config_mutations only includes present columns", {
	root <- testthat::test_path("fixtures", "labels")
	config <- censobr:::load_label_config("population", 2010, "pt", root = root)

	mutations <- censobr:::label_config_mutations(config, c("V0617", "other"))

	testthat::expect_identical(names(mutations), "V0617")
})

test_that("load_label_config expands imported definitions", {
	root <- testthat::test_path("fixtures", "label_imports")
	config <- censobr:::load_label_config("population", 2010, "pt", root = root)

	specification <- censobr:::label_variable_specs(config$mappings[[1]]$variables)[[1]]
	testthat::expect_identical(specification$name, "V1006")
	testthat::expect_identical(specification$alias, "urban_rural")
	testthat::expect_null(config$mappings[[1]]$unmatched)
	testthat::expect_identical(
		vapply(config$mappings[[1]]$levels, `[[`, character(1), "label"),
		c("Urbana", "Rural")
	)
})

test_that("label imports reject unsafe and ambiguous references", {
	root <- tempfile("label-imports-")
	dir.create(root)
	on.exit(unlink(root, recursive = TRUE), add = TRUE)
	dir.create(file.path(root, "population"))
	dir.create(file.path(root, "shared"))

	writeLines(c(
		"schema_version: 1", "definitions:", "  urban_rural:",
		"    unmatched: null", "    levels:", "      - code: \\\"1\\\"", "        label: \\\"Urbana\\\""
	), file.path(root, "shared", "one.yml"))
	writeLines(c(
		"schema_version: 1", "definitions:", "  urban_rural:",
		"    unmatched: null", "    levels:", "      - code: \\\"2\\\"", "        label: \\\"Rural\\\""
	), file.path(root, "shared", "two.yml"))

	config_path <- file.path(root, "population", "2010-pt.yml")
	writeLines(c(
		"schema_version: 1", "dataset: population", "year: 2010", "language: pt",
		"imports:", "  - ../shared/one.yml", "  - ../shared/two.yml", "mappings:",
		"  - use: urban_rural", "    variables: [V1006]"
	), config_path)
	testthat::expect_error(
		censobr:::load_label_config("population", 2010, "pt", root = root),
		"collide"
	)

	writeLines(c(
		"schema_version: 1", "dataset: population", "year: 2010", "language: pt",
		"imports:", "  - ../../outside.yml", "mappings:",
		"  - use: urban_rural", "    variables: [V1006]"
	), config_path)
	testthat::expect_error(
		censobr:::load_label_config("population", 2010, "pt", root = root),
		"outside the label root"
	)

	writeLines(c(
		"schema_version: 1", "dataset: population", "year: 2010", "language: pt", "mappings:",
		"  - use: missing_definition", "    variables: [V1006]"
	), config_path)
	testthat::expect_error(
		censobr:::load_label_config("population", 2010, "pt", root = root),
		"unknown definition"
	)

	writeLines(c("schema_version: 1", "imports:", "  - cycle-b.yml"),
		file.path(root, "shared", "cycle-a.yml"))
	writeLines(c("schema_version: 1", "imports:", "  - cycle-a.yml"),
		file.path(root, "shared", "cycle-b.yml"))
	writeLines(c(
		"schema_version: 1", "dataset: population", "year: 2010", "language: pt",
		"imports:", "  - ../shared/cycle-a.yml", "mappings:",
		"  - use: urban_rural", "    variables: [V1006]"
	), config_path)
	testthat::expect_error(
		censobr:::load_label_config("population", 2010, "pt", root = root),
		"circular import"
	)
})

test_that("apply_label_config stays lazy for Arrow queries", {
	testthat::skip_if_not_installed("arrow")

	root <- testthat::test_path("fixtures", "labels")
	config <- censobr:::load_label_config("population", 2010, "pt", root = root)
	input <- arrow::arrow_table(data.frame(
		V0601 = c("1", "2", "9", NA_character_, "7"),
		V0617 = c("1", "0", "2", NA_character_, ""),
		untouched = 1:5
	))

	query <- censobr:::apply_label_config(input, config)
	output <- dplyr::collect(query)

	testthat::expect_s3_class(query, "arrow_dplyr_query")
	testthat::expect_identical(
		output$V0601,
		c("Masculino", "Feminino", "Ignorado", NA_character_, NA_character_)
	)
	testthat::expect_type(output$V0601, "character")
	testthat::expect_type(output$V0617, "character")
})

test_that("variable metadata does not change Arrow query columns", {
	testthat::skip_if_not_installed("arrow")
	config <- list(
		schema_version = 1L,
		dataset = "population",
		year = 2010,
		language = "pt",
		mappings = list(list(
			variables = list(list(name = "V0601", alias = "sex")),
			unmatched = NULL,
			levels = list(list(code = "1", label = "Masculino"))
		))
	)
	query <- censobr:::apply_label_config(
		arrow::arrow_table(data.frame(V0601 = c("1", "9"), untouched = 1:2)),
		config
	)
	output <- dplyr::collect(query)

	testthat::expect_s3_class(query, "arrow_dplyr_query")
	testthat::expect_identical(output$V0601, c("Masculino", NA_character_))
	testthat::expect_false("sex" %in% names(output))
})

test_that("population pilot configuration preserves published labels", {
	config <- censobr:::load_label_config(
		"population", 2010, "pt",
		root = system.file("labels", package = "censobr")
	)
	input <- data.frame(
		V1006 = c("1", "2", NA_character_, "3"),
		V0502 = c("01", "19", "20", "99"),
		V0601 = c("1", "2", "9", "7")
	)

	output <- censobr:::apply_label_config(input, config)

	testthat::expect_identical(output$V1006, c("Urbana", "Rural", NA_character_, NA_character_))
	testthat::expect_identical(
		output$V0502,
		c("Pessoa responsável pelo domicílio ",
			"Parente do(a) empregado(a)  doméstico(a)",
			"Individual em domicílio coletivo", NA_character_)
	)
	testthat::expect_identical(output$V0601, c("Masculino", "Feminino", "Ignorado", NA_character_))
})

test_that("add_labels_population applies the YAML pilot lazily", {
	testthat::skip_if_not_installed("arrow")
	input <- arrow::arrow_table(data.frame(
		V1006 = c("1", "2", "3"),
		V0502 = c("01", "19", "99"),
		V0601 = c("1", "9", "7")
	))

	query <- censobr:::add_labels_population(input, year = 2010, lang = "pt")
	output <- dplyr::collect(query)

	testthat::expect_s3_class(query, "arrow_dplyr_query")
	testthat::expect_identical(output$V1006, c("Urbana", "Rural", NA_character_))
	testthat::expect_identical(
		output$V0502,
		c("Pessoa responsável pelo domicílio ",
			"Parente do(a) empregado(a)  doméstico(a)", NA_character_)
	)
	testthat::expect_identical(output$V0601, c("Masculino", "Ignorado", NA_character_))
})
