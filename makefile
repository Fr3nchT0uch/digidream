# 		DSK structure	MEMORY MAP / RAM TYPE / COMP / DEST
# boot0:    	T00/S00		$0800	MAIN
# FLOAD:		T00/S01-T00/S0x 	$FC00	RAMCARD
# MAIN:		T01/S00-Txx/Sxx	$D000	RAMCARD		
# DRUM:		T04/S00-T04/S00	$8000	AUX	*	(->$1000A)		 
# MUSIC:		T05/S00-T06/SXX	$8000	AUX	*	(->$2000A)
# GFX:		T07/S00-T0A/S0F	$2000	MAIN

ACME = acme.exe -f plain -o
DIRECTWRITE = /c/Python27/python /c/retrodev/bin/dw.py
LZ4 = lz4.exe
DISKNAME = dsk/test.dsk

player: boot.b fload.b drum.b main.b ZIC GFX
	cp $(DISKNAME) /e/

boot.b: include.a boot.a
	@echo "boot part"
	$(ACME) boot.b boot.a
	$(DIRECTWRITE) $(DISKNAME) boot.b 0 0 + p

fload.b: include.a fload.a
	@echo "fload decomp part"
	$(ACME) fload.b fload.a
	$(DIRECTWRITE) $(DISKNAME) fload.b 0 1 + p

drum.b: drum.a
	@echo "fload decomp part"
	$(ACME) drum.b drum.a
	$(LZ4) -2 drum.b
	$(DIRECTWRITE) $(DISKNAME) drum.b.lz4 4 0 + D

main.b: include.a drum.a main.a
	@echo "main part"
	$(ACME) main.b main.a
	$(DIRECTWRITE) $(DISKNAME) main.b 1 0 + D

ZIC: music\ZICDECOMP.lz4
	@echo "Music part"
	$(DIRECTWRITE) $(DISKNAME) music/ZICDECOMP.lz4 5 0 + D

GFX: gfx\PI.1 gfx\PI.2
	@echo "Gfx part"
	$(DIRECTWRITE) $(DISKNAME) gfx/PI.1 7 0 + D
	$(DIRECTWRITE) $(DISKNAME) gfx/PI.2 9 0 + D

clean:
	@echo "cleaning..."
	rm *.b

	