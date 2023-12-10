rem Convert 24bits cycle-op.png into an Amiga standard HAM image
rem output cycle-op-preview_sham.png as a preview
abc2 cycle-op.png -sham -floyd -b cycle-op.gfx -p cycle-op.pal -preview cycle-op-preview_sham.png
abc2 cycle-op.png -bpc 5 -quantize -floyd -preview cycle-op-preview_32_colors.png
pause