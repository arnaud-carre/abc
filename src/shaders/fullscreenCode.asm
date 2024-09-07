; Raster line 0 [0]
; -------------- Clear mask buffer -----------
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#$00e0,$ffff8a30.w
	move.w	#$0001,$ffff8a36.w
	move.w	#$0200,$ffff8a3a.w
	move.w	m_maskBuffer(a6),$ffff8a32.w
	move.w	m_currentClearOffset(a6),d1
	; bitplan #0
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#61,(a2)	// blitter line count set to 61 (16x61 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d1
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 1 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#61,(a2)	// blitter line count set to 61 (16x61 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d1
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 2 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#31,(a2)	// blitter line count set to 31 (16x31 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d1
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#42,(a2)	// blitter line count set to 42 (16x42 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 3 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d1
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#64,(a2)	// blitter line count set to 64 (16x64 pixels)
	move.w	d7,(a3)	// run the blitter
; -------------- Draw N-1 sprites in mask buffer -----------
	move.w	m_preshiftedMasks(a6),$ffff8a24.w
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#$0207,$ffff8a3a.w
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	move.w	#$000a,$ffff8a22.w
	moveq	#-8,d2
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#29,(a2)	// blitter line count set to 29 (16x29 pixels)
	nop
	nop
	nop
	nop
	nop
	nop
; Raster line 4 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 5 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
; Raster line 6 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 7 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#27,(a2)	// blitter line count set to 27 (16x27 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 8 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 9 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#24,(a2)	// blitter line count set to 24 (16x24 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 10 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 11 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 12 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 13 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 14 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 15 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 16 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 17 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 18 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 19 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 20 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 21 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 22 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 23 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 24 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 25 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 26 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 27 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 28 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 29 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 30 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 31 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 32 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 33 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 34 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 35 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 36 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 37 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 38 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 39 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 40 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 41 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 42 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 43 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 44 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 45 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 46 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 47 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 48 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 49 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 50 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 51 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 52 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 53 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 54 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 55 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 56 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 57 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 58 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 59 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 60 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 61 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 62 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 63 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 64 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 65 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 66 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 67 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 68 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 69 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 70 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 71 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 72 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 73 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 74 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 75 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 76 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 77 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 78 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 79 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 80 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 81 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 82 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 83 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 84 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 85 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 86 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 87 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 88 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 89 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 90 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 91 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 92 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 93 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 94 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 95 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 96 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 97 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 98 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 99 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 100 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 101 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 102 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 103 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 104 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 105 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 106 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 107 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 108 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 109 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 110 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 111 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 112 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 113 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 114 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 115 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 116 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 117 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 118 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 119 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 120 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 121 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 122 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 123 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 124 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 125 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 126 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 127 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 128 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 129 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 130 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 131 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 132 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 133 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#23,(a2)	// blitter line count set to 23 (16x23 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d7,(a3)	// run the blitter
; Raster line 134 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 135 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 136 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 137 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 138 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 139 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 140 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 141 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 142 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 143 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	move.w	(a0)+,d1		; dst
	move.w	(a0)+,d0		; src
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 144 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 145 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 146 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 147 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 148 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 149 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 150 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 151 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 152 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 153 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
; -------------- clear last sprite on screen -----------
	move.w	m_maskBuffer(a6),$ffff8a24.w
	move.w	m_currentClearOffset(a6),d0
	move.w	m_currentScreen(a6),$ffff8a32.w
	move.w	d0,d1
	move.w	#$0201,$ffff8a3a.w
	move.w	#$00e0,$ffff8a22.w
	moveq	#-32,d2
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 154 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 155 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#25,(a2)	// blitter line count set to 25 (16x25 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 156 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 157 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#22,(a2)	// blitter line count set to 22 (16x22 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 158 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 159 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 160 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 161 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 162 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 163 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 164 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 165 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 166 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 167 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 168 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 169 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 170 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 171 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 172 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 173 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #2
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 174 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 175 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 176 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 177 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 178 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 179 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 180 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 181 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 182 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 183 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#15,(a2)	// blitter line count set to 15 (16x15 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #3
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 184 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 185 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 186 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 187 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 188 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 189 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 190 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 191 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 192 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 193 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#15,(a2)	// blitter line count set to 15 (16x15 pixels)
	move.w	d7,(a3)	// run the blitter
; -------------- mask sprite on screen -----------
	move.w	m_preshiftedMasks(a6),$ffff8a24.w
	move.w	m_currentBobMask(a6),d0
	move.w	m_currentScrOffset(a6),d1
	move.w	#$0204,$ffff8a3a.w
	move.w	#$000a,$ffff8a22.w
	moveq	#-8,d2
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 194 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 195 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 196 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 197 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 198 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 199 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 200 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 201 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 202 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 203 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 204 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 205 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 206 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 207 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 208 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 209 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 210 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 211 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 212 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 213 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #2
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 214 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 215 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 216 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 217 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#15,(a2)	// blitter line count set to 15 (16x15 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 218 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 219 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#14,(a2)	// blitter line count set to 14 (16x14 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#9,(a2)	// blitter line count set to 9 (16x9 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 220 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 221 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 222 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 223 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #3
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 224 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 225 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 226 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 227 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	;Open lower border
	move.w	#1,(a2)	// blitter line count set to 1 (16x1 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 228 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#27,(a2)	// blitter line count set to 27 (16x27 pixels)
	move.w	a5,(a5)	; End lower border switch
	move.w	d7,(a3)	// run the blitter
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 229 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#14,(a2)	// blitter line count set to 14 (16x14 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#9,(a2)	// blitter line count set to 9 (16x9 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 230 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 231 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#2,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 232 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 233 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#14,(a2)	// blitter line count set to 14 (16x14 pixels)
	move.w	d7,(a3)	// run the blitter
; -------------- OR sprite on screen -----------
	move.w	m_preshiftedMasks(a6),$ffff8a24.w	; on purpose mask instead of Sprite (64k aligned)
	move.w	m_currentBobOr(a6),d0
	move.w	m_currentScrOffset(a6),d1
	move.w	#$0207,$ffff8a3a.w
	move.w	#$0028,$ffff8a22.w
	moveq	#-30,d2
	; bitplan #0
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 234 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 235 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#21,(a2)	// blitter line count set to 21 (16x21 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#2,(a2)	// blitter line count set to 2 (16x2 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 236 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 237 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#20,(a2)	// blitter line count set to 20 (16x20 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#3,(a2)	// blitter line count set to 3 (16x3 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 238 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 239 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#19,(a2)	// blitter line count set to 19 (16x19 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#4,(a2)	// blitter line count set to 4 (16x4 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 240 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 241 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#18,(a2)	// blitter line count set to 18 (16x18 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 242 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 243 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 244 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 245 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#17,(a2)	// blitter line count set to 17 (16x17 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#6,(a2)	// blitter line count set to 6 (16x6 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 246 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 247 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#16,(a2)	// blitter line count set to 16 (16x16 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 248 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 249 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#15,(a2)	// blitter line count set to 15 (16x15 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#8,(a2)	// blitter line count set to 8 (16x8 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 250 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 251 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#14,(a2)	// blitter line count set to 14 (16x14 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#9,(a2)	// blitter line count set to 9 (16x9 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 252 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 253 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #2
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#9,(a2)	// blitter line count set to 9 (16x9 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 254 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 255 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 256 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 257 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 258 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 259 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 260 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 261 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 262 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 263 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	add.w	d2,d0
	add.w	#-(5-1)*8+2,d1
	; bitplan #3
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 264 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#5,(a2)	// blitter line count set to 5 (16x5 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	move.w	(a1)+,$ffff8240.w	// Change background color
; Raster line 265 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 266 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 267 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 268 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 269 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#11,(a2)	// blitter line count set to 11 (16x11 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#12,(a2)	// blitter line count set to 12 (16x12 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 270 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 271 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#10,(a2)	// blitter line count set to 10 (16x10 pixels)
	move.w	d7,(a3)	// run the blitter
	addq.w	#8,d0
	addq.w	#8,d1
	move.w	d0,$ffff8a26.w	// reset blitter src addr
	move.w	d1,$ffff8a34.w	// reset blitter dst addr
	move.w	#13,(a2)	// blitter line count set to 13 (16x13 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 272 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#28,(a2)	// blitter line count set to 28 (16x28 pixels)
	move.w	d7,(a3)	// run the blitter
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
	move.w	#7,(a2)	// blitter line count set to 7 (16x7 pixels)
	move.w	d7,(a3)	// run the blitter
; Raster line 273 [0]
	move.w	a4,(a4)	// open left border
	nop
	move.b	d6,(a4)	// back to low res
	move.w	#9,(a2)	// blitter line count set to 9 (16x9 pixels)
	move.w	d7,(a3)	// run the blitter
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.b	d6,(a5)	// cycle 376: open right border
	move.w	a5,(a5)	// back to 50hz
