rem Convert 24bits cycle-op.png into a standard 32 colors (5 bitplans) image with brute force color reduction algorithm
abc2 cycle-op.png -bpc 5 -quantize -floyd -preview cycle-op-preview_32_colors.png -iff cycle-op-32_colors.iff

rem Convert 24bits cycle-op.png into a SlicedHAM Amiga image
abc2 cycle-op.png -sham -floyd -b cycle-op.gfx -p cycle-op.pal -preview cycle-op-sham.png -iff cycle-op-sham.iff
pause