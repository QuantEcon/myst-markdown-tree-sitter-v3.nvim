;; Markdown Highlighting Queries (MyST Extension)
;; This file prevents standard markdown highlighting from interfering with MyST code-cell directives
;; by disabling markdown matches for code blocks that start with ```{code-cell}

;; Disable markdown highlighting for fenced code blocks that start with {code-cell}
;; This prevents conflicts with MyST {code-cell} directives
(fenced_code_block
  (info_string) @_directive
  (#match? @_directive "^\\{code-cell\\}")
  (#no-match!))