# Read, validate, and compile declarative categorical-label configurations.
#
# Label configurations live in inst/labels/<dataset>/<year>-<language>.yml.
# They are intentionally kept as data: add_labels_*() can share this machinery
# while each configuration preserves the exact labels published by IBGE.

#' Clear the internal label-configuration cache
#'
#' @keywords internal
clear_label_config_cache <- function() {
	cache <- censobr_env$label_config_cache
	if (length(ls(cache, all.names = TRUE)) > 0L) {
		rm(list = ls(cache, all.names = TRUE), envir = cache)
	}
	invisible(NULL)
}

label_config_abort <- function(path, message) {
	cli::cli_abort("Invalid label configuration {.file {path}}: {message}")
}

label_variable_specs <- function(variables, path = "<configuration>", prefix = "mapping") {
	fail <- function(message) label_config_abort(path, message)
	if (is.character(variables)) {
		if (length(variables) == 0L || anyNA(variables) || any(!nzchar(variables)) ||
				anyDuplicated(variables)) {
			fail("{prefix} {.field variables} must be unique non-empty strings")
		}
		return(lapply(variables, function(variable) {
			list(name = variable, alias = NA_character_, description = NA_character_)
		}))
	}

	if (!is.list(variables) || length(variables) == 0L) {
		fail("{prefix} {.field variables} must be strings or name metadata mappings")
	}
	specifications <- lapply(seq_along(variables), function(index) {
		specification <- variables[[index]]
		specification_prefix <- paste0(prefix, " variable ", index)
		if (!is.list(specification) || is.null(names(specification)) ||
				!("name" %in% names(specification))) {
			fail("{specification_prefix} must contain {.field name}")
		}
		unknown <- setdiff(names(specification), c("name", "alias", "description"))
		if (length(unknown) > 0L) {
			fail("{specification_prefix} has unsupported field{?s} {.field {unknown}}")
		}
		for (field in c("name", "alias", "description")) {
			if (!(field %in% names(specification))) { next }
			if (!is.character(specification[[field]]) || length(specification[[field]]) != 1L ||
					is.na(specification[[field]]) || !nzchar(specification[[field]])) {
				fail("{specification_prefix} {.field {field}} must be one non-empty string when supplied")
			}
		}
		list(
			name = specification$name,
			alias = if ("alias" %in% names(specification)) specification$alias else NA_character_,
			description = if ("description" %in% names(specification)) specification$description else NA_character_
		)
	})

	names <- vapply(specifications, `[[`, character(1), "name")
	if (anyDuplicated(names)) { fail("{prefix} repeats a {.field name}") }
	specifications
}

validate_label_mapping <- function(mapping, path, prefix,
											require_variables = TRUE) {
	fail <- function(message) label_config_abort(path, message)
	if (!is.list(mapping) || is.null(names(mapping))) { fail("{prefix} must be a named mapping") }

	needed <- c("unmatched", "levels")
	if (require_variables) { needed <- c("variables", needed) }
	absent <- setdiff(needed, names(mapping))
	if (length(absent) > 0L) { fail("{prefix} missing field{?s} {.field {absent}}") }

	if ("variables" %in% names(mapping)) {
		label_variable_specs(mapping$variables, path, prefix)
	}

	if (!is.null(mapping$unmatched) &&
			(!is.character(mapping$unmatched) || length(mapping$unmatched) != 1L ||
			 is.na(mapping$unmatched))) {
		fail("{prefix} {.field unmatched} must be null or one string")
	}

	levels <- mapping$levels
	if (!is.list(levels) || length(levels) == 0L) {
		fail("{prefix} {.field levels} must be a non-empty list")
	}

	codes_seen <- character()
	for (level_index in seq_along(levels)) {
		level <- levels[[level_index]]
		if (!is.list(level) || is.null(names(level)) ||
				!all(c("code", "label") %in% names(level))) {
			fail("{prefix} level {level_index} must contain {.field code} and {.field label}")
		}
		if (!is.character(level$code) || length(level$code) != 1L || is.na(level$code)) {
			fail("{prefix} level {level_index} {.field code} must be one string")
		}
		if (!is.character(level$label) || length(level$label) != 1L || is.na(level$label)) {
			fail("{prefix} level {level_index} {.field label} must be one string")
		}
		if (level$code %in% codes_seen) {
			fail("{prefix} repeats code {.val {level$code}}")
		}
		codes_seen <- c(codes_seen, level$code)
	}

	invisible(mapping)
}

validate_label_definitions <- function(definitions, path) {
	if (is.null(definitions)) { return(list()) }
	if (!is.list(definitions) || is.null(names(definitions)) ||
			anyNA(names(definitions)) || any(!nzchar(names(definitions))) ||
			anyDuplicated(names(definitions))) {
		label_config_abort(path, "{.field definitions} must be a named mapping")
	}
	for (name in names(definitions)) {
		validate_label_mapping(definitions[[name]], path,
			paste0("definition {.val {name}}"), require_variables = FALSE)
	}
	definitions
}

validate_label_imports <- function(imports, path) {
	if (is.null(imports)) { return(character()) }
	if (!is.character(imports) || length(imports) == 0L || anyNA(imports) ||
			any(!nzchar(imports)) || anyDuplicated(imports)) {
		label_config_abort(path, "{.field imports} must be unique non-empty strings")
	}
	imports
}

label_import_path <- function(import, path, root) {
	if (grepl("^(/|[A-Za-z]:[/\\\\])", import)) {
		label_config_abort(path, "import {.val {import}} must be relative to the label root")
	}

	# Resolve `.` and `..` lexically before checking existence. `normalizePath()`
	# with `mustWork = FALSE` leaves unresolved parent segments in some cases.
	candidate <- dirname(path)
	for (part in strsplit(import, "[/\\\\]+")[[1]]) {
		if (part %in% c("", ".")) { next }
		candidate <- if (identical(part, "..")) dirname(candidate) else file.path(candidate, part)
	}
	candidate <- normalizePath(candidate, mustWork = FALSE)
	# `root` and `candidate` are both normalizePath()'d, which uses `\` on Windows;
	# `.Platform$file.sep` is always `/`, so it can't be used to build the prefix here.
	root_prefix <- paste0(root, if (identical(.Platform$OS.type, "windows")) "\\" else "/")
	if (!identical(candidate, root) && !startsWith(candidate, root_prefix)) {
		label_config_abort(path, "import {.val {import}} is outside the label root")
	}
	if (!file.exists(candidate)) {
		label_config_abort(path, "import {.file {import}} does not exist")
	}
	# A link within the root can still resolve outside it, so check once more after
	# canonicalizing an existing import.
	candidate <- normalizePath(candidate, mustWork = TRUE)
	if (!identical(candidate, root) && !startsWith(candidate, root_prefix)) {
		label_config_abort(path, "import {.val {import}} resolves outside the label root")
	}
	candidate
}

load_label_definitions <- function(path, root, stack = character()) {
	path <- normalizePath(path, mustWork = TRUE)
	if (path %in% stack) {
		label_config_abort(path, "circular import detected")
	}

	library <- yaml::read_yaml(path)
	if (!is.list(library) || is.null(names(library)) ||
			(!identical(library$schema_version, 1L) && !identical(library$schema_version, 1))) {
		label_config_abort(path, "an imported library must be a schema version 1 named mapping")
	}
	unknown <- setdiff(names(library), c("schema_version", "imports", "definitions"))
	if (length(unknown) > 0L) {
		label_config_abort(path, "an imported library has unsupported field{?s} {.field {unknown}}")
	}

	definitions <- list()
	for (import in validate_label_imports(library$imports, path)) {
		imported <- load_label_definitions(label_import_path(import, path, root), root,
			c(stack, path))
		duplicates <- intersect(names(definitions), names(imported))
		if (length(duplicates) > 0L) {
			label_config_abort(path, "imported definition{?s} {.field {duplicates}} collide")
		}
		definitions <- c(definitions, imported)
	}

	local <- validate_label_definitions(library$definitions, path)
	duplicates <- intersect(names(definitions), names(local))
	if (length(duplicates) > 0L) {
		label_config_abort(path, "definition{?s} {.field {duplicates}} collide with imports")
	}
	c(definitions, local)
}

expand_label_config_references <- function(config, path, root) {
	definitions <- list()
	for (import in validate_label_imports(config$imports, path)) {
		imported <- load_label_definitions(label_import_path(import, path, root), root)
		duplicates <- intersect(names(definitions), names(imported))
		if (length(duplicates) > 0L) {
			label_config_abort(path, "imported definition{?s} {.field {duplicates}} collide")
		}
		definitions <- c(definitions, imported)
	}

	local <- validate_label_definitions(config$definitions, path)
	duplicates <- intersect(names(definitions), names(local))
	if (length(duplicates) > 0L) {
		label_config_abort(path, "definition{?s} {.field {duplicates}} collide with imports")
	}
	definitions <- c(definitions, local)

	if (is.null(config$mappings) || !is.list(config$mappings)) { return(config) }
	for (index in seq_along(config$mappings)) {
		mapping <- config$mappings[[index]]
		if (!is.list(mapping) || is.null(names(mapping)) || !("use" %in% names(mapping))) {
			next
		}
		if (!is.character(mapping$use) || length(mapping$use) != 1L || is.na(mapping$use) ||
				!nzchar(mapping$use)) {
			label_config_abort(path, "mapping {index} {.field use} must be one non-empty string")
		}
		if (!(mapping$use %in% names(definitions))) {
			label_config_abort(path, "mapping {index} references unknown definition {.val {mapping$use}}")
		}
		allowed <- c("use", "variables", "unmatched")
		unknown <- setdiff(names(mapping), allowed)
		if (length(unknown) > 0L) {
			label_config_abort(path, "mapping {index} reference has unsupported field{?s} {.field {unknown}}")
		}

		definition <- definitions[[mapping$use]]
		variables <- if ("variables" %in% names(mapping)) mapping$variables else definition$variables
		unmatched <- if ("unmatched" %in% names(mapping)) mapping$unmatched else definition$unmatched
		config$mappings[[index]] <- list(
			variables = variables,
			unmatched = unmatched,
			levels = definition$levels
		)
	}
	config$imports <- NULL
	config$definitions <- NULL
	config
}

#' Validate one parsed label configuration
#'
#' @param config A list returned by yaml::read_yaml().
#' @param path Character scalar identifying the configuration source.
#' @keywords internal
validate_label_config <- function(config, path = "<configuration>") {
	fail <- function(message) {
		label_config_abort(path, message)
	}

	if (!is.list(config) || is.null(names(config))) { fail("it must be a named mapping") }

	required <- c("schema_version", "dataset", "year", "language", "mappings")
	missing <- setdiff(required, names(config))
	if (length(missing) > 0L) { fail("missing field{?s} {.field {missing}}") }

	if (!identical(config$schema_version, 1L) && !identical(config$schema_version, 1)) {
		fail("{.field schema_version} must be 1")
	}
	if (!is.character(config$dataset) || length(config$dataset) != 1L ||
			is.na(config$dataset) || !nzchar(config$dataset)) {
		fail("{.field dataset} must be one non-empty string")
	}
	if (!is.numeric(config$year) || length(config$year) != 1L || is.na(config$year) ||
			config$year != as.integer(config$year)) {
		fail("{.field year} must be one integer")
	}
	if (!is.character(config$language) || length(config$language) != 1L ||
			is.na(config$language) || !nzchar(config$language)) {
		fail("{.field language} must be one non-empty string")
	}
	if (!is.list(config$mappings) || length(config$mappings) == 0L) {
		fail("{.field mappings} must be a non-empty list")
	}

	variables_seen <- character()
	for (index in seq_along(config$mappings)) {
		mapping <- config$mappings[[index]]
		prefix <- paste0("mapping ", index, "")
		validate_label_mapping(mapping, path, prefix)
		specifications <- label_variable_specs(mapping$variables, path, prefix)
		variables <- vapply(specifications, `[[`, character(1), "name")
		duplicate_variables <- intersect(variables_seen, variables)
		if (length(duplicate_variables) > 0L) {
			fail("variable{?s} {.field {duplicate_variables}} appear in more than one mapping")
		}
		variables_seen <- c(variables_seen, variables)
	}

	invisible(config)
}

#' Load a validated label configuration
#'
#' @param dataset Character scalar.
#' @param year Numeric scalar.
#' @param lang Character scalar.
#' @param root Root directory containing dataset label directories.
#' @keywords internal
load_label_config <- function(dataset, year, lang = "pt",
															root = system.file("labels", package = "censobr")) {
	checkmate::assert_string(dataset)
	checkmate::assert_number(year, lower = 0, finite = TRUE)
	checkmate::assert_string(lang)
	checkmate::assert_string(root)

	path <- file.path(root, dataset, paste0(as.integer(year), "-", lang, ".yml"))
	if (!file.exists(path)) {
		cli::cli_abort("No label configuration for {.val {dataset}}, year {.val {year}}, language {.val {lang}}.")
	}

	cache_key <- paste(normalizePath(path, mustWork = TRUE), collapse = "")
	cache <- censobr_env$label_config_cache
	if (exists(cache_key, envir = cache, inherits = FALSE)) {
		return(get(cache_key, envir = cache, inherits = FALSE))
	}

	root <- normalizePath(root, mustWork = TRUE)
	config <- yaml::read_yaml(path)
	config <- expand_label_config_references(config, path, root)
	validate_label_config(config, path)

	if (!identical(config$dataset, dataset) || config$year != as.integer(year) ||
			!identical(config$language, lang)) {
		cli::cli_abort("Label configuration {.file {path}} does not match its requested dataset, year, and language.")
	}

	assign(cache_key, config, envir = cache)
	config
}

#' Build a case_when expression for one configured variable
#'
#' @keywords internal
label_mapping_expression <- function(variable, mapping) {
	column <- rlang::sym(variable)
	clauses <- lapply(mapping$levels, function(level) {
		rlang::expr(!!column == !!level$code ~ !!level$label)
	})

	# `unmatched: null` is equivalent to the current case_when() calls without
	# a default. A string default preserves the current yes/no if_else() rules,
	# while the explicit is.na() guard leaves source nulls untouched.
	if (!is.null(mapping$unmatched)) {
		clauses <- c(clauses, list(
			rlang::expr(!is.na(!!column) ~ !!mapping$unmatched)
		))
	}

	rlang::expr(dplyr::case_when(!!!clauses))
}

#' Compile configured label mutations
#'
#' @param config A validated label configuration.
#' @param columns Character vector of columns available in the data.
#' @keywords internal
label_config_mutations <- function(config, columns) {
	validate_label_config(config)
	checkmate::assert_character(columns, any.missing = FALSE)

	mutations <- list()
	for (mapping in config$mappings) {
		for (specification in label_variable_specs(mapping$variables)) {
			if (!(specification$name %in% columns)) { next }
			mutations[[specification$name]] <- label_mapping_expression(specification$name, mapping)
		}
	}
	mutations
}

#' Return aliases and descriptions declared by one label configuration
#'
#' @param config A validated label configuration.
#' @keywords internal
label_config_variable_metadata <- function(config) {
	validate_label_config(config)
	rows <- list()
	for (mapping in config$mappings) {
		for (specification in label_variable_specs(mapping$variables)) {
			rows[[length(rows) + 1L]] <- data.frame(
				dataset = config$dataset,
				year = config$year,
				language = config$language,
				variable = specification$name,
				alias = specification$alias,
				description = specification$description,
				stringsAsFactors = FALSE
			)
		}
	}
	do.call(rbind, rows)
}

#' List aliases and descriptions for configured label variables
#'
#' @param dataset Character scalar.
#' @param year Numeric scalar.
#' @param lang Character scalar.
#' @param root Root directory containing dataset label directories.
#' @return A data frame with one row per configured variable.
#' @export
label_variable_metadata <- function(dataset, year, lang = "pt",
													root = system.file("labels", package = "censobr")) {
	label_config_variable_metadata(load_label_config(dataset, year, lang, root))
}

#' Apply configured categorical labels in one dplyr mutation
#'
#' @param arrw An Arrow dplyr query, Arrow table, or data frame.
#' @param config A validated label configuration.
#' @return `arrw` with configured columns replaced by character labels.
#' @keywords internal
apply_label_config <- function(arrw, config) {
	mutations <- label_config_mutations(config, names(arrw))
	if (length(mutations) == 0L) { return(arrw) }
	dplyr::mutate(arrw, !!!mutations)
}
