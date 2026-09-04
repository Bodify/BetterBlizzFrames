# BetterBlizzFrames 2.0.7b
## Midnight
### Bugfix
- Fix some new (and old) issues with the No Portrait skip settings; multiple other places only checked for no portrait setting and not if they were skipped or not causing lua errors.
### Tweak
- Restructure addon folders and get rid of unused files from the transition period between tww to midnight and from all the different classic updates slowly getting the retail treatment.

# BetterBlizzFrames 2.0.7
## Midnight
### New
- "No Portrait" settings now have right click options to disable for certain frames and/or only enable for party frames.
### Tweak
- Move the "Zzz" rest animation a bit for no portrait.
### Bugfix
- Fix issue with overlapping auras in PvE due to private auras.
- Fix a lua error that could happen in combat if micromenu tried to resize in combat
## Classic Era
### Tweak
- Fix shamans not being class colored blue like intended (after the "Midnight patches" came to Era as well)
## All versions
- Add a check for new SweepyBoop setting messing with BetterBlizzFrames' class coloring settings and turn it off. Too many bug reports for this.