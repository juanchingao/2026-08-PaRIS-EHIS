valid_harmonisation_classes <- function() {
  c("DIRECT", "RECODABLE", "DERIVABLE", "PARTIAL", "RELATED", "NONE")
}

valid_review_statuses <- function() {
  c("PROPOSED", "REVIEWED", "VALIDATED", "REJECTED", "UNRESOLVED")
}

validate_controlled_value <- function(x, allowed, field) {
  invalid <- setdiff(unique(x[!is.na(x)]), allowed)
  if (length(invalid)) {
    stop(field, " contains invalid values: ", paste(invalid, collapse = ", "),
         call. = FALSE)
  }
  invisible(TRUE)
}
