% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/currentInput.R
\name{currentInput}
\alias{currentInput}
\title{Check the current input arguments}
\usage{
currentInput(workspaceName, config, requiredInputOnly = TRUE, analysis = NULL)
}
\arguments{
\item{workspaceName}{Name of the workspace}

\item{config}{Workflow configuration. Output from the
\code{\link{getWorkflowConfig}} function.}

\item{requiredInputOnly}{Under the default (\code{TRUE}), only the required
inputs are returned.}

\item{analysis}{If specified, only the minimally required inputs for a
given workflow will be returned.}
}
\value{
A data.frame for the inputs defined in a workflow configuration.
}
\description{
Check the current input arguments
}
\examples{
library(AnVILBase)
if (
    gcloud_exists() && identical(avplatform_namespace(), "AnVILGCP") &&
    nzchar(avworkspace_name())
) {
workspaceName <- "Bioconductor-Workflow-DESeq2"
config <- getWorkflowConfig(workspaceName)
currentInput(workspaceName = workspaceName, config = config)
}

}
