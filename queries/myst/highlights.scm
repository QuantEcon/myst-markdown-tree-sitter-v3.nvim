;; MyST Markdown Highlighting Queries
;; Extends the base markdown highlighting with MyST-specific patterns
;; These patterns have higher specificity and should override standard markdown highlighting

;; MyST code-cell directive highlighting - highest specificity
(fenced_code_block
  (info_string) @myst.code_cell.directive
  (#match? @myst.code_cell.directive "^\\{code-cell\\}"))

;; MyST generic directive highlighting for other directive types
(fenced_code_block
  (info_string) @myst.directive
  (#match? @myst.directive "^\\{[%w%-_]+\\}")
  (#not-match? @myst.directive "^\\{code-cell\\}"))

;; MyST role highlighting - matches {role}`target` patterns
(code_span @myst.role
 (#match? @myst.role "^{[%w%-_]+}`.*`$"))