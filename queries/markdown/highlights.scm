;; Markdown highlighting with MyST conflict prevention
;; This file extends/overrides default markdown highlighting to prevent conflicts with MyST patterns
;; Using predicates to disable standard markdown highlighting for MyST elements

;; Disable standard markdown fenced code block highlighting for MyST directives
;; This prevents conflicts between standard markdown and MyST code-cell highlighting
((fenced_code_block
   (info_string) @_info)
 (#not-match? @_info "^{[%w%-_]+}"))

;; Standard markdown emphasis should not conflict with MyST roles
((emphasis) @markup.italic
 (#not-match? @markup.italic "{[%w%-_]+}`"))

((strong) @markup.bold  
 (#not-match? @markup.bold "{[%w%-_]+}`"))

;; Inline code should not match MyST roles
((code_span) @markup.raw.inline
 (#not-match? @markup.raw.inline "^{[%w%-_]+}`"))

;; Standard markdown elements that should always work
(atx_heading) @markup.heading
(setext_heading) @markup.heading
(link) @markup.link
(block_quote) @markup.quote
(list_marker_plus) @markup.list
(list_marker_minus) @markup.list  
(list_marker_star) @markup.list
(thematic_break) @punctuation.special