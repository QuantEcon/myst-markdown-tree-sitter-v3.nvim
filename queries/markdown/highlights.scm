;; Markdown Highlighting Queries (MyST Extension)
;; This file prevents standard markdown highlighting from interfering with MyST directives
;; by disabling markdown matches for code blocks that start with ```{

;; Disable markdown highlighting for fenced code blocks that start with {
;; This prevents conflicts with MyST directives like {code-cell}, {note}, etc.
(fenced_code_block
  (info_string) @_directive
  (#match? @_directive "^\\{")
  (#no-match!))