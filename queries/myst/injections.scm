;; MyST Markdown Language Injection Queries
;; These queries tell tree-sitter to parse code-cell content with appropriate language parsers

;; Standard markdown language injection (preserve existing behavior)
((fenced_code_block
  (info_string) @injection.language
  (code_fence_content) @injection.content)
  (#not-eq? @injection.language "")
  (#not-match? @injection.language "^\\{"))

;; MyST code-cell injection patterns
;; Inject Python parser into code-cell python blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} python")
  (#set! injection.language "python"))

;; Inject JavaScript parser into code-cell javascript blocks  
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} javascript")
  (#set! injection.language "javascript"))

;; Inject Bash parser into code-cell bash blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} bash")
  (#set! injection.language "bash"))

;; Inject R parser into code-cell r blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} r")
  (#set! injection.language "r"))

;; Inject Julia parser into code-cell julia blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} julia")
  (#set! injection.language "julia"))

;; Inject C++ parser into code-cell cpp blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} cpp")
  (#set! injection.language "cpp"))

;; Inject C parser into code-cell c blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} c")
  (#set! injection.language "c"))

;; Inject Rust parser into code-cell rust blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} rust")
  (#set! injection.language "rust"))

;; Inject Go parser into code-cell go blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} go")
  (#set! injection.language "go"))

;; Inject TypeScript parser into code-cell typescript blocks
((fenced_code_block
  (info_string) @_lang
  (code_fence_content) @injection.content)
  (#eq? @_lang "{code-cell} typescript")
  (#set! injection.language "typescript"))

;; Handle code-cell blocks without explicit language (default to text)
((fenced_code_block
  (info_string) @_directive
  (code_fence_content) @injection.content)
  (#eq? @_directive "{code-cell}")
  (#set! injection.language "text"))