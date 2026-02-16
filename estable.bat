del /f mainModer.lua
del /f mian.lua
copy mainAdmin.lua copyUbdate
ren copyUbdate\mainAdmin.lua mainModer.lua
move copyUbdate\mainModer.lua .
copy mainAdmin.lua copyUbdate
ren copyUbdate\mainAdmin.lua mian.lua
move copyUbdate\mian.lua .
