;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns
;; Uses very high priority highlighting to ensure MyST elements consistently override markdown highlighting

;; Code cell directive info_string highlighting with very high priority
;; Priority 200 ensures MyST directives reliably override standard markdown highlighting
(fenced_code_block
  (info_string) @myst.code_cell.directive
  (#match? @myst.code_cell.directive "^\\{code-cell\\}")
  (#set! "priority" 200)
)

;; Also apply high priority to the entire fenced code block for code-cell directives
;; This ensures comprehensive MyST control over code-cell blocks
(fenced_code_block
  (info_string) @_directive
  (#match? @_directive "^\\{code-cell\\}")
) @myst.code_cell.block (#set! "priority" 200)