#' Update the input
#'
#' @import AnVIL
#'
#' @param workspaceName Name of the workspace
#' @param inputs A tibble containing new input values. Provide the modify 
#' version of the current input table, which is a returned value from 
#' \code{\link{currentInput}} function.
#' @param workflowName Name of the workflow to run. If a single workflow is  
#' available under the specified workspace, this function will check the input
#' of that workflow under the default (\code{NULL}). If there are multiple 
#' workflows available, you should specify the workflow. 
#' @param dry Logical(1). When \code{TRUE} (default), report the updated
#' configuration but do not perform the action requested in Terra. When 
#' \code{FALSE}, inputs in Terra/AnVIL will updated.
#' @param verbose Logical(1). When \code{TRUE} (default), this function 
#' will print the updated input. 
#'
#' @return With \code{verbose=TRUE}, a list of updated inputs will be 
#' printed. A successful execution of the function will update the input
#' configuration of the target workflow in Terra/AnVIL.
#' 
#' @examples 
#' library(AnVIL)
#' if (gcloud_exists() && nzchar(avworkspace_name())) {
#' if ("salmon" %in% avworkspaces()$name) {
#' inputs <- currentInput(workspaceName = "salmon")
#' ## Modify the contents of 'inputs' table for your analysis
#' updateInput(workspaceName = "salmon", inputs = inputs) 
#' }}
#' 
#' @export
updateInput <- function(workspaceName,
                        inputs,
                        workflowName = NULL,
                        dry = TRUE, 
                        verbose = TRUE) {
    
    setCloudEnv(message = FALSE)
    
    ## Get the namespaces
    ws_fullname <- .get_workspace_fullname(workspaceName)
    ws_namespace <- unlist(strsplit(ws_fullname, "/"))[1]
    ws_name <- unlist(strsplit(ws_fullname, "/"))[2]
    wf_fullname <- .get_workflow_fullname(workspaceName = workspaceName,
                                          workflowName = workflowName)
    wf_namespace <- unlist(strsplit(wf_fullname, "/"))[1]
    wf_name <- unlist(strsplit(wf_fullname, "/"))[2]
    
    ## Get configuration
    config <- avworkflow_configuration_get(
        workflow_namespace = wf_namespace,
        workflow_name = wf_name,
        namespace = ws_namespace,
        name = ws_name
    )
    
    ## Check all the required inputs are there
    current_input <- avworkflow_configuration_inputs(config)
    ind <- which(current_input$optional == "FALSE")
    required_inputs <- current_input$name[ind]
    
    if (!all(required_inputs %in% inputs$name)) {
        missing_inputs <- setdiff(required_inputs, inputs$name)
        msg <- paste("The following required inputs are missing:",
                     missing_inputs, sep = "\n")
        stop(msg)
    }
    
    ## String formatting
    # Exclude input values from data model, starting with `workspace` or `this`
    ind1 <- grep("this|workspace", inputs$attribute)
    # Exclude `int` types
    ind2 <- which(inputs$inputType == "Int")
    # Exclude already correct values
    ind3 <- grep("^\"", inputs$attribute) # correctly formatted input
    
    ind_all <- c(ind1, ind2, ind3) # these are not supposed to overlap
    inputs$attribute[-ind_all] <- paste0("\"", inputs$attribute[-ind_all], "\"")
    
    ## Update the input configuration
    updated_config <- avworkflow_configuration_update(
        config,
        inputs = inputs
    )
    
    ## Update the input in Terra
    if (isFALSE(dry)) {
        avworkflow_configuration_set(updated_config, 
                                     namespace = ws_namespace,
                                     name = ws_name,
                                     dry = FALSE)
        msg <- paste0("Input for the following workspace-workflow is succesfully updated.\n", 
                      "\tworkspace: ", ws_fullname, "\n",
                      "\tworkflow: ", wf_fullname)
        show(msg)
    }
    
    if (verbose) {show(updated_config)}
}