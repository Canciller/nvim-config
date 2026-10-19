# quick-notes

Custom Neovim plugin (Lua, lives in this config). Select a code range, write a note in a floating window, and on `:wq` the note plus the code snippet is **appended** to a markdown file in the project. Purpose: after an agent makes changes, jot quick notes and later tell an agent "read `.notes/foo.md` and plan for notes 1 to 3".

## Layout
- `plugin/quick-notes.lua` (outside this dir) calls `require('canciller.quick-notes').setup()`, same pattern as `typescript-type-checker`.
- `init.lua`: config, capture, nui float, file picker, keymaps.
- `util.lua`: pure helpers (entry format/numbering, listing notes, append) and per-cwd state.

## Config (`setup{}` overrides)
| key | default | meaning |
| --- | --- | --- |
| `dir` | `.notes` | notes directory, relative to cwd (use `.plans` etc.) |
| `keymap` | `<leader>n` | pick the destination file on save |
| `quick_keymap` | `<leader>N` | save straight to the last file used in this project |
| `goto_keymap` | `gf` | in a note file: jump to the source of the entry under the cursor |
| `next_keymap` / `prev_keymap` | `]n` / `[n` | in a note file: next / previous `## Note` header |
| `width` / `height` | `0.6` / `0.4` | float size as a fraction of the editor |

## Keymaps
Both sets are operators (`:h g@`), built by `map_operator` in `init.lua`:
- `<key>{motion}`, `<key>n` / `<key>N` (current line), and visual `<key>`.
- `<leader>N` with no remembered file (or the file was deleted) shows a warning and does not open the float.

## Navigation (note files only)
A `BufEnter` autocmd maps `goto_keymap`, `next_keymap`, `prev_keymap` buffer-locally in `*.md` files under `cwd/<dir>/`.
- `gf` (`goto_source`): finds the entry header above the cursor (`util.find_entry`, stops at a `---` separator), opens the file at the range's start line/column. Cursor can be anywhere in the entry.
- `]n` / `[n`: search for `^## Note \d\+ `, count-aware.
- `util.parse_header` parses the header, so changing the header format in `format_entry` means updating it too.

## Behaviour
- Float is a `nui.layout`: read-only snippet pane on top (source filetype highlighting), markdown notes pane below (`buftype=acwrite`, so `:w`/`:wq` fire `BufWriteCmd`).
- `:w`/`:wq`: `vim.ui.select` lists `*.md` in `dir` numbered (`1. a.md`) plus `+ New file…` (asks for a name, `.md` added, no `/` or leading `.`). Quick-save skips this.
- `<C-c>` (insert or normal) discards and closes. `:q` on an empty note closes; `:q` on a non-empty note errors (E37) on purpose. Empty/whitespace notes are never saved.
- Charwise visual (`v`, and `<C-v>` treated the same) records columns: `Line 10:5 to 13:20`; `V` and motions are line-only: `Line 10 to 13`.
- Append only, never overwrites. Numbering is per file: `next_number` takes the highest existing `## Note N` + 1 (also understands the old `N. path Line` format).

## Entry format
````
## Note 1 — `src/foo.ts` · Line 10:5 to 13:20

```typescript
<selected code>
```

**Notes:**

<what was typed>

---
````
Fence language is the buffer's `filetype` (so `typescript`, not `ts`).

## State
"Last used file" is stored per cwd in `stdpath('state')/quick-notes/state.json` as `{ [cwd] = 'relative/path.md' }`. Chosen because it is per-user UI state: it stays out of the repo and out of the notes dir agents read. Missing or corrupt JSON is treated as empty. It is updated on every successful save.

## Gotchas (learned the hard way)
- The notes buffer stays `modified` until a file is chosen, so `:wq`'s quit fails and cancelling the picker keeps the note. This is intended.
- Open the picker with `vim.schedule` from `BufWriteCmd`. Opened synchronously, `:wq`'s trailing `:q` closes the picker. Closing the float after a save is scheduled for the same reason.
- nui's Layout container is `zindex = 49` and popups default to 50. Never set popup zindex below 49 or the float vanishes (this happened).
- Teardown: `WinClosed` on the notes window calls `layout:unmount()`. `note.winid` can be stale, so check `nvim_win_is_valid`.
- Visual mapping reads `getpos('v')` / `getpos('.')` and the mode before sending `<Esc>`. The end column is clamped to the line and extended with `vim.str_utf_end` for multibyte characters.

## Dependencies
- `nui.nvim`: required (already installed as a neo-tree dependency).
- `vim.ui.select` / `vim.ui.input`: any implementation works; this config uses telescope-ui-select (`lua/canciller/plugins/fuzzy-finder.lua`).
- `render-markdown.nvim`: cosmetic only.

## Testing
No test suite. Headless smoke tests that worked:
- `XDG_STATE_HOME=$(mktemp -d) nvim --headless -u NONE -l script.lua`, run from a temp dir containing a sample file.
- In the script, prepend rtp for this repo plus `~/.local/share/nvim/lazy/{nui.nvim,plenary.nvim,telescope.nvim,telescope-ui-select.nvim}`; load the ui-select extension to test the real picker.
- Drive it with `vim.fn.setpos("'[")` / `("']")` then `require('canciller.quick-notes').operator()`, or `nvim_feedkeys` for the keymaps. Fill the note with `nvim_buf_set_lines`, run `:wq`, `vim.wait(100)`.
- A window count back to 1 means clean teardown. A real UI check is still worth doing for visuals.

## Not done
- `<Tab>` to focus the snippet pane.
- True blockwise (`<C-v>`) rectangle capture.
