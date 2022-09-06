default: hol/p4Script.sml

hol/p4Script.sml: ott/p4.ott
	cd hol && ott -i ../ott/p4.ott -o p4Script.sml && python ./polymorphise_p4Script.py

hol: hol/p4Script.sml hol/ottScript.sml hol/ottLib.sig hol/ottLib.sml
	Holmake -r -I hol

clean:
	rm -f hol/p4Script.sml
	cd hol && Holmake clean

.PHONY: default clean hol
