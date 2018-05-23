@echo off
cd veci
copy /b krystal1.scr+krystal2.scr+krystal3.scr  veci01.scr
copy /b veci01.scr+koruna1.scr+koruna2.scr+koruna3.scr  veci02.scr
copy /b veci02.scr+strom1.scr+strom2.scr+strom3.scr  veci03.scr
copy /b veci03.scr+jablko1.scr+jablko2.scr+jablko3.scr  veci04.scr
copy /b veci04.scr+krava1.scr+krava2.scr+krava3.scr  veci05.scr
copy /b veci05.scr+tresne1.scr+tresne2.scr+tresne3.scr  veci06.scr
copy /b veci06.scr+rybnik1.scr+rybnik2.scr+rybnik3.scr  veci07.scr
copy /b veci07.scr+zirafa1.scr+zirafa2.scr+zirafa3.scr  veci08.scr
copy /b veci08.scr+zmrzlin1.scr+zmrzlin2.scr+zmrzlin3.scr  veci09.scr
copy /b veci09.scr+dort1.scr+dort2.scr+dort3.scr  veci10.scr
copy /b veci10.scr+pocitac1.scr+pocitac2.scr+pocitac3.scr  veci11.scr
copy /b veci11.scr+auto1.scr+auto2.scr+auto3.scr  veci12.scr
copy /b veci12.scr+balon1.scr+balon2.scr+balon3.scr  veci13.scr
copy /b veci13.scr+budik1.scr+budik2.scr+budik3.scr  veci14.scr
copy /b veci14.scr+slon1.scr+slon2.scr+slon3.scr  veci15.scr
copy /b veci15.scr+vino1.scr+vino2.scr+vino3.scr  veci16.scr
copy /b veci16.scr+penize1.scr+penize2.scr+penize3.scr  veci17.scr
copy /b veci17.scr+letadlo1.scr+letadlo2.scr+letadlo3.scr  veci18.scr

copy veci18.scr ..\veci.scr

del veci01.scr
del veci02.scr
del veci03.scr
del veci04.scr
del veci05.scr
del veci06.scr
del veci07.scr
del veci08.scr
del veci09.scr
del veci10.scr
del veci11.scr
del veci12.scr
del veci13.scr
del veci14.scr
del veci15.scr
del veci16.scr
del veci17.scr
del veci18.scr

cd ..
