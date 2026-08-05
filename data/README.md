# Data

This folder holds the CSV exports used for R analysis.

## Files

- `coding_sheet.csv` — exported from `muldrow_coding_sheet_v2.xlsx` (Coding Sheet tab). Commit a fresh export at the end of each coding session or circuit.
- `triage_log.csv` — exported from the Triage Log tab. Used for the substitution analysis (pleading deficiency as post-*Muldrow* off-ramp).

## How to export from Excel

1. Open `muldrow_coding_sheet_v2.xlsx`
2. Select the Coding Sheet tab → File → Save a Copy → CSV UTF-8
3. Save as `data/coding_sheet.csv`
4. Repeat for Triage Log → `data/triage_log.csv`
5. Commit both files

The `.xlsx` working file is excluded from Git via `.gitignore` — Box handles its backup and sync.
