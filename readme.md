# ABC (AmigAtari Bitmap Converter) v2.00

AmigAtari Bitmap Converter (abc) is a command line tool to convert bitmap images into ready to use binary data. Main use case is demo creation.
One key feature is brute force best palette search when color quantization is needed. GPU computing power is used to make this brute force search faster!

## Some features
- Use your GPU power for heavy calculations like brute foce optimal best color quantization
- 1 to 5 bitplans support
- Support sprite or bitmap font sheets
- Amiga HAM, Sliced-HAM or high quality SHAM5b (using brute force best palette search)
- One palette per line mode support (using brute force best palettes search)
- RGB 444 output support
- PC PNG output preview (to look at final result directly on your PC)
- Color quantization if needed, with brute force optimal palette search
- color index remapping options
- Amiga, Atari STF or STE color format support
- bitplan or 4bits chunky format support

## Exemple
Convert "cycle-op.png" 24bits image into a sliced **HAM** amiga picture, floyd steinberg dithering, and "cycle-op-preview.png" preview image
````
  abc2.exe cycle-op.png -sham -floyd -b cycle-op.gfx -p cycle-op.pal -preview cycle-op-preview_sham.png
````

Convert oxg.png into 2 bitplans. Sprite sheet of 17 lines. Then, ensure pixel color at (0,18) will be remap to index 0, (31,17) to index 1, (3,3) to index 2 and (0,0) to index 3. Use Atari STE color format
````
  abc2.exe oxg.png -sprh 17 -ste -bpc 2 -b oxg.gfx -p oxg.pal -remap 0 18 0 -remap 31 17 1 -remap 3 3 2 -remap 0 0 3
````

Convert font.png into 3 bitplans font of 32*24 pixels per letter.
````
  abc2.exe oxg.png -sprw 32 -sprh 24 -bpc 3 -b font.gfx -p font.pal
````


## Command line options

````
AmigAtari Bitmap Converter 2.0 by Leonard/Oxygene
(GPU Enhanced version)

Usage:
        abc2 <src png file> [-options]

Export modes:
        -bpc <n> : output classic n bitplans bitmap
        -rgb : output 16bits rgb binary
        -mpp : use one palette per line ( more colors )
        -ham : convert to Amiga HAM6 format (brute force best result)
        -sham : convert to Amiga Sliced-HAM6 format (brute force best result)
        -sham5b : convert to best quality Amiga SHAM5b (31 shades) (brute force best result)
Options:
        -b <file> : bitmap binary output file
        -p <file> : palette binary output file
        -preview <file> : PC preview PNG output image
        -cpu : force CPU usage for HAM or -quantize option instead of GPU
        -quantize : if src has more color than supported by bitplan, reduce colors
        -uninterleaved: save each complete amiga bitplan (not interleaved per line)
        -forcecolor <id> <RGB> : force color index <id> to a RGB 444 value (like ff0 for yellow)
        -remap <x> <y> <i>: consider pixel (x,y) as color index <i>
        -swap <id0> <id1>: swap color index id0 with color index id1
        -floyd : use Floyd dithering during RGB888 to 444 or 555 quantization (HAM modes)
        -sierra : use Sierra dithering during RGB888 to 444 or 555 quantization (HAM modes)
        -bayer : use ordered Bayer dithering during RGB888 to 444 or 555 quantization (HAM modes)
        -chunky : store bitmap file in chunky mode (4bits per pixel)
        -amiga : use Amiga bitplan format output (default)
        -atari : use Atari bitplan format output
        -ste : use Atari STE palette format (Atari default)
        -stf : use Atari STF palette format (3bits per component)
        -sprw <w> : input image contains w pixels width tiles
        -sprh <h> : input image contains h pixels high tiles
        -sprc <n> : input image contains n tiles
        -erx <x> : export region start at x
        -ery <y> : export region start at y
        -erw <w> : export region is w pixels width
        -erh <h> : export region is h pixels high
````

## Credits

- Written by Arnaud Carré aka Leonard/Oxygene
- abc2 is using [libspng](https://github.com/randy408/libspng) and [miniz](https://github.com/richgel999/miniz) for PNG file reading & writing. 

## Links

[pouet.net](https://www.pouet.net/prod.php?which=95714) page

I also wrote two blogposts related to this tool somehow:

Blog post 1: [how the brute force best palette search is done](https://arnaud-carre.github.io/2022-12-30-amiga-ham/)

Blog post 2: [how the GPU is used to speed up the brute force search](https://arnaud-carre.github.io/2023-12-10-gpgpu/)

## Production ready

abc has been used in *many* Atari and Amiga demos

[<img src="https://content.pouet.net/files/screenshots/00094/00094129.jpg">](https://www.pouet.net/prod.php?which=94129)

[<img src="https://content.pouet.net/files/screenshots/00066/00066702.png">](https://www.pouet.net/prod.php?which=66702)

[<img src="https://content.pouet.net/files/screenshots/00085/00085276.png">](https://www.pouet.net/prod.php?which=85276)

[<img src="https://content.pouet.net/files/screenshots/00091/00091996.png">](https://www.pouet.net/prod.php?which=91996)

[<img src="https://content.pouet.net/files/screenshots/00081/00081081.jpg">](https://www.pouet.net/prod.php?which=81081)

