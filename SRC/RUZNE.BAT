@echo off
cd ruzne
copy /b lokomot1.scr+lokomot2.scr+lokomot3.scr+lokomot4.scr  ruzne01.scr
copy /b ruzne01.scr+lokomot5.scr+lokomot6.scr+lokomot7.scr+lokomot8.scr  ruzne02.scr
copy /b ruzne02.scr+lokomot9.scr+lokomotA.scr+lokomotB.scr+lokomotC.scr  ruzne03.scr
copy /b ruzne03.scr+srazka1.scr+srazka2.scr+srazka3.scr+srazka4.scr  ruzne04.scr
copy /b ruzne04.scr+srazka5.scr+srazka6.scr+srazka7.scr+srazka8.scr  ruzne05.scr
copy /b ruzne05.scr+srazka9.scr+srazkaA.scr  ruzne06.scr
copy /b ruzne06.scr+zed.scr+vrata1.scr+vrata2.scr  ruzne07.scr
copy /b ruzne07.scr+vrata3.scr+vrata4.scr+vrata5.scr+vrata6.scr  ruzne08.scr

copy ruzne08.scr ..\ruzne.scr

del ruzne01.scr
del ruzne02.scr
del ruzne03.scr
del ruzne04.scr
del ruzne05.scr
del ruzne06.scr
del ruzne07.scr
del ruzne08.scr

cd ..
