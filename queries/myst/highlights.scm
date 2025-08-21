;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns
;; Uses priority-based highlighting to ensure MyST elements override markdown highlighting

;; Code cell directive info_string highlighting with high priority
;; Priority 110 ensures MyST directives override standard markdown highlighting
(fenced_code_block
  (info_string) @myst.code_cell.directive
  (#match? @myst.code_cell.directive "^\\{code-cell\\}")
  (#set! "priority" 110)
)